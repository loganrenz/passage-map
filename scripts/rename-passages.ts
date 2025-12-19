#!/usr/bin/env tsx
/**
 * Script to rename passages based on their locations using MapKit Server API
 * Updates names in local D1, remote D2, and optionally JSON files
 */

import { readFile, readdir, writeFile, unlink } from 'fs/promises'
import { join } from 'path'
import { exec } from 'child_process'
import { promisify } from 'util'
import type { Passage } from '../types/passage'
import type { GeocodeResult } from '../server/utils/geocoding'

const execAsync = promisify(exec)

// Import geocoding utilities
// We'll need to create a standalone version that works in Node.js context
function getMapKitToken(): string {
  // Get token from environment (should be set by Doppler)
  const isProduction = process.env.NODE_ENV === 'production'
  const token = isProduction 
    ? process.env.MAPKIT_PROD_TOKEN 
    : process.env.MAPKIT_DEV_TOKEN
  
  if (!token) {
    throw new Error(
      `MapKit token not configured. ` +
      `Set ${isProduction ? 'MAPKIT_PROD_TOKEN' : 'MAPKIT_DEV_TOKEN'} in Doppler or environment variable. ` +
      `Run with: doppler run -- npx tsx scripts/rename-passages.ts`
    )
  }
  
  return token
}

/**
 * Reverse geocode coordinates using Apple Maps Server API
 */
async function reverseGeocode(
  lat: number,
  lon: number
): Promise<GeocodeResult | null> {
  try {
    const token = getMapKitToken()
    
    // Apple Maps Server API reverse geocoding endpoint
    const url = `https://maps-api.apple.com/v1/reverseGeocode?latitude=${lat}&longitude=${lon}`
    
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    })

    if (!response.ok) {
      const errorText = await response.text().catch(() => 'Unknown error')
      console.warn(`  ⚠ Geocoding failed: ${response.status} ${response.statusText}`)
      return null
    }

    const data = await response.json()

    // Apple Maps Server API response structure may vary
    // Handle both possible response formats
    let results: any[] = []
    
    if (data.results && Array.isArray(data.results)) {
      results = data.results
    } else if (data.result) {
      results = Array.isArray(data.result) ? data.result : [data.result]
    } else if (data.address) {
      results = [data]
    } else if (data.placemark || data.placemarks) {
      results = Array.isArray(data.placemark || data.placemarks) 
        ? (data.placemark || data.placemarks)
        : [data.placemark || data.placemarks]
    } else {
      // Try to use the data directly if it has address fields
      results = [data]
    }

    if (results.length === 0) {
      return null
    }
    
    // Try to find the best result - prefer results with locality or name
    let bestResult = results[0]
    for (const result of results) {
      const address = result.address || result
      // Prefer results that have locality (city/island name) or a meaningful name
      if (address.locality || (result.name && !result.name.match(/^\d+/))) {
        bestResult = result
        break
      }
    }
    
    const result = bestResult
    const address = result.address || result
    
    // Extract all possible location identifiers
    const geocodeResult: GeocodeResult = {
      name: result.name || address.name || undefined,
      locality: address.locality || address.subLocality || address.city || address.town || address.island || undefined,
      administrativeArea: address.administrativeArea || address.state || address.province || address.region || undefined,
      country: address.country || undefined,
      countryCode: address.countryCode || address.isoCountryCode || undefined,
      formattedAddress: result.formattedAddress || address.formattedAddress || result.displayName || result.formattedAddressLine || undefined,
    }

    return geocodeResult
  } catch (error) {
    console.error(`  ✗ Error geocoding ${lat}, ${lon}:`, error instanceof Error ? error.message : String(error))
    return null
  }
}

/**
 * Extract island name from formatted address or name
 * Looks for patterns like "Island Name" or "Name Island"
 */
function extractIslandName(text: string): string | null {
  if (!text) return null
  
  // Common island name patterns
  const islandPatterns = [
    /(\w+(?:\s+\w+)*)\s+Island/i,
    /Island\s+of\s+(\w+(?:\s+\w+)*)/i,
    /(\w+(?:\s+\w+)*)\s+Islands?/i,
  ]
  
  for (const pattern of islandPatterns) {
    const match = text.match(pattern)
    if (match && match[1]) {
      return match[1].trim()
    }
  }
  
  return null
}

/**
 * Get the best location name from geocode result
 * Priority: locality > name (if meaningful) > island name from formatted address > administrativeArea > formattedAddress
 */
function getLocationName(location: GeocodeResult | null): string {
  if (!location) return 'Unknown'
  
  // Prefer locality (city/town/island name)
  if (location.locality) {
    return location.locality
  }
  
  // Check if name is meaningful (not just coordinates or numbers)
  if (location.name) {
    // Skip if name looks like coordinates or is just a number
    if (!location.name.match(/^\d+[°\s]/) && !location.name.match(/^[\d\s,.-]+$/)) {
      // Check if it contains island-related terms
      const islandName = extractIslandName(location.name)
      if (islandName) {
        return islandName
      }
      return location.name
    }
  }
  
  // Try to extract island name from formatted address
  if (location.formattedAddress) {
    const islandName = extractIslandName(location.formattedAddress)
    if (islandName) {
      return islandName
    }
    
    // Try to extract meaningful location from formatted address
    // Format is usually: "Name, Locality, AdministrativeArea, Country"
    const parts = location.formattedAddress.split(',').map(p => p.trim())
    
    // Skip the first part if it's just a number or coordinate
    for (const part of parts) {
      if (part && !part.match(/^\d+[°\s]/) && !part.match(/^[\d\s,.-]+$/)) {
        // Check if this part contains an island name
        const islandName = extractIslandName(part)
        if (islandName) {
          return islandName
        }
        // Use the first meaningful part
        if (part.length > 2 && !part.match(/^(The|A|An)\s+/i)) {
          return part
        }
      }
    }
    
    // Last resort: return first part even if it looks like coordinates
    if (parts.length > 0) {
      return parts[0]
    }
  }
  
  // Use administrative area (state/province) as fallback
  if (location.administrativeArea) {
    return location.administrativeArea
  }
  
  return 'Unknown'
}

/**
 * Generate a passage name from start and end locations
 * Format: "From [start location] to [end location]"
 * Always uses "From X to Y" format, even if locations are the same
 */
function generatePassageName(
  startLocation: GeocodeResult | null,
  endLocation: GeocodeResult | null,
  fallbackName?: string
): string {
  const startName = getLocationName(startLocation)
  const endName = getLocationName(endLocation)

  // Always use "From X to Y" format, even if locations are the same
  return `From ${startName} to ${endName}`
}

/**
 * Helper function to escape SQL strings
 */
function escapeSQL(str: string | null | undefined): string {
  if (!str) return 'NULL'
  return `'${str.replace(/'/g, "''").replace(/\\/g, '\\\\')}'`
}

/**
 * Update passage name in local D1
 */
async function updatePassageNameInD1(passageId: string, newName: string): Promise<boolean> {
  try {
    // Check if wrangler is available
    try {
      await execAsync('which wrangler')
    } catch {
      console.warn('  ⚠ Wrangler not found, skipping D1 update')
      return false
    }

    const sqlStatement = `
      UPDATE passages
      SET name = ${escapeSQL(newName)}, updated_at = unixepoch()
      WHERE id = ${escapeSQL(passageId)};
    `

    const tempSqlFile = join(process.cwd(), `.d1-rename-${passageId.replace(/[^a-zA-Z0-9]/g, '_')}.sql`)
    await writeFile(tempSqlFile, sqlStatement, 'utf-8')

    try {
      // Update local D1
      await execAsync(`wrangler d1 execute passage-map-db --file=${tempSqlFile} --local`, {
        cwd: process.cwd(),
      })
      
      await unlink(tempSqlFile).catch(() => {})
      return true
    } catch (error) {
      await unlink(tempSqlFile).catch(() => {})
      throw error
    }
  } catch (error) {
    console.error(`  ✗ Error updating D1:`, error instanceof Error ? error.message : String(error))
    return false
  }
}

/**
 * Update passage name in remote D2
 */
async function updatePassageNameInD2(passageId: string, newName: string): Promise<boolean> {
  try {
    // Check if wrangler is available
    try {
      await execAsync('which wrangler')
    } catch {
      console.warn('  ⚠ Wrangler not found, skipping D2 update')
      return false
    }

    const sqlStatement = `
      UPDATE passages
      SET name = ${escapeSQL(newName)}, updated_at = unixepoch()
      WHERE id = ${escapeSQL(passageId)};
    `

    const tempSqlFile = join(process.cwd(), `.d2-rename-${passageId.replace(/[^a-zA-Z0-9]/g, '_')}.sql`)
    await writeFile(tempSqlFile, sqlStatement, 'utf-8')

    try {
      // Update remote D2 (without --local flag)
      await execAsync(`wrangler d1 execute passage-map-db --file=${tempSqlFile}`, {
        cwd: process.cwd(),
      })
      
      await unlink(tempSqlFile).catch(() => {})
      return true
    } catch (error) {
      await unlink(tempSqlFile).catch(() => {})
      throw error
    }
  } catch (error) {
    console.error(`  ✗ Error updating D2:`, error instanceof Error ? error.message : String(error))
    return false
  }
}

/**
 * Rename a passage based on its locations
 */
async function renamePassage(
  passage: Passage,
  options: {
    useExistingLocations?: boolean
    updateJson?: boolean
    updateD1?: boolean
    updateD2?: boolean
  } = {}
): Promise<{ success: boolean; oldName: string; newName: string }> {
  const { useExistingLocations = true, updateJson = false, updateD1 = true, updateD2 = true } = options

  let startGeocode: GeocodeResult | null = null
  let endGeocode: GeocodeResult | null = null

  // Try to use existing location data first (it often has better island names)
  if (useExistingLocations && passage.locations && passage.locations.length > 0) {
    console.log(`  Using existing location data (${passage.locations.length} locations)...`)
    
    // Find locations closest to start and end coordinates
    let closestStart: typeof passage.locations[0] | null = null
    let closestEnd: typeof passage.locations[0] | null = null
    let minStartDist = Infinity
    let minEndDist = Infinity
    
    for (const loc of passage.locations) {
      const startDist = Math.sqrt(
        Math.pow(loc.coordinate.lat - passage.startLocation.lat, 2) +
        Math.pow(loc.coordinate.lon - passage.startLocation.lon, 2)
      )
      const endDist = Math.sqrt(
        Math.pow(loc.coordinate.lat - passage.endLocation.lat, 2) +
        Math.pow(loc.coordinate.lon - passage.endLocation.lon, 2)
      )
      
      if (startDist < minStartDist) {
        minStartDist = startDist
        closestStart = loc
      }
      if (endDist < minEndDist) {
        minEndDist = endDist
        closestEnd = loc
      }
    }
    
    if (closestStart) {
      startGeocode = {
        name: closestStart.name || undefined,
        locality: closestStart.locality || undefined,
        administrativeArea: closestStart.administrativeArea || undefined,
        country: closestStart.country || undefined,
        countryCode: closestStart.countryCode || undefined,
        formattedAddress: closestStart.formattedAddress || undefined,
      }
    }
    
    if (closestEnd) {
      endGeocode = {
        name: closestEnd.name || undefined,
        locality: closestEnd.locality || undefined,
        administrativeArea: closestEnd.administrativeArea || undefined,
        country: closestEnd.country || undefined,
        countryCode: closestEnd.countryCode || undefined,
        formattedAddress: closestEnd.formattedAddress || undefined,
      }
    }
  }
  
  // If we don't have location data or it's incomplete, try geocoding
  if (!startGeocode || !endGeocode) {
    console.log(`  Geocoding start and end coordinates...`)
    const [start, end] = await Promise.all([
      startGeocode ? Promise.resolve(startGeocode) : reverseGeocode(passage.startLocation.lat, passage.startLocation.lon),
      endGeocode ? Promise.resolve(endGeocode) : reverseGeocode(passage.endLocation.lat, passage.endLocation.lon),
    ])
    startGeocode = start
    endGeocode = end
  }
    console.log(`  Geocoding failed, using existing location data as fallback...`)
    const sortedLocations = [...passage.locations].sort((a, b) => 
      Date.parse(a.time) - Date.parse(b.time)
    )
    
    // Find locations closest to start and end coordinates
    let closestStart: typeof sortedLocations[0] | null = null
    let closestEnd: typeof sortedLocations[0] | null = null
    let minStartDist = Infinity
    let minEndDist = Infinity
    
    for (const loc of sortedLocations) {
      const startDist = Math.sqrt(
        Math.pow(loc.coordinate.lat - passage.startLocation.lat, 2) +
        Math.pow(loc.coordinate.lon - passage.startLocation.lon, 2)
      )
      const endDist = Math.sqrt(
        Math.pow(loc.coordinate.lat - passage.endLocation.lat, 2) +
        Math.pow(loc.coordinate.lon - passage.endLocation.lon, 2)
      )
      
      if (startDist < minStartDist) {
        minStartDist = startDist
        closestStart = loc
      }
      if (endDist < minEndDist) {
        minEndDist = endDist
        closestEnd = loc
      }
    }
    
    if (!startGeocode && closestStart) {
      startGeocode = {
        name: closestStart.name || undefined,
        locality: closestStart.locality || undefined,
        administrativeArea: closestStart.administrativeArea || undefined,
        country: closestStart.country || undefined,
        countryCode: closestStart.countryCode || undefined,
        formattedAddress: closestStart.formattedAddress || undefined,
      }
    }
    
    if (!endGeocode && closestEnd) {
      endGeocode = {
        name: closestEnd.name || undefined,
        locality: closestEnd.locality || undefined,
        administrativeArea: closestEnd.administrativeArea || undefined,
        country: closestEnd.country || undefined,
        countryCode: closestEnd.countryCode || undefined,
        formattedAddress: closestEnd.formattedAddress || undefined,
      }
    }
  }
  
  // Debug: log what we got
  if (startGeocode) {
    console.log(`  Start: ${getLocationName(startGeocode)} (${startGeocode.locality || startGeocode.name || 'unknown'})`)
  }
  if (endGeocode) {
    console.log(`  End: ${getLocationName(endGeocode)} (${endGeocode.locality || endGeocode.name || 'unknown'})`)
  }

  const oldName = passage.name
  const newName = generatePassageName(startGeocode, endGeocode, passage.name)

  // Skip if name hasn't changed or if we couldn't geocode (both Unknown)
  if (newName === oldName) {
    return {
      success: true,
      oldName,
      newName,
    }
  }

  // Don't update if we got "From Unknown to Unknown" - keep the original name
  if (newName === 'From Unknown to Unknown') {
    console.log(`  ⚠ Could not geocode locations, keeping original name`)
    return {
      success: false,
      oldName,
      newName: oldName,
    }
  }

  // Update in D1
  if (updateD1) {
    const d1Updated = await updatePassageNameInD1(passage.id, newName)
    if (!d1Updated) {
      console.warn(`  ⚠ Failed to update D1`)
    }
  }

  // Update in D2
  if (updateD2) {
    const d2Updated = await updatePassageNameInD2(passage.id, newName)
    if (!d2Updated) {
      console.warn(`  ⚠ Failed to update D2`)
    }
  }

  // Update JSON file if requested
  if (updateJson) {
    const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
    const filename = passage.filename || `passage_${passage.id}.json`
    const filePath = join(passagesDir, filename)
    
    try {
      passage.name = newName
      await writeFile(filePath, JSON.stringify(passage, null, 2), 'utf-8')
    } catch (error) {
      console.warn(`  ⚠ Failed to update JSON file:`, error instanceof Error ? error.message : String(error))
    }
  }

  return {
    success: true,
    oldName,
    newName,
  }
}

/**
 * Main function
 */
async function main() {
  // Show usage if help requested
  if (process.argv.includes('--help') || process.argv.includes('-h')) {
    console.log(`
Usage: npx tsx scripts/rename-passages.ts [options]

Options:
  --json, --update-json    Also update JSON files with new names
  --d1-only                Only update local D1 (skip remote D2)
  --d2-only                 Only update remote D2 (skip local D1)
  --force                   Rename passages even if they already have location-based names
  --help, -h                Show this help message

Examples:
  # Rename all passages and update D1 and D2
  npx tsx scripts/rename-passages.ts

  # Also update JSON files
  npx tsx scripts/rename-passages.ts --json

  # Only update local D1
  npx tsx scripts/rename-passages.ts --d1-only
`)
    return
  }

  const updateJson = process.argv.includes('--json') || process.argv.includes('--update-json')
  const d1Only = process.argv.includes('--d1-only')
  const d2Only = process.argv.includes('--d2-only')
  const force = process.argv.includes('--force')

  // Read passages from JSON files
  const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
  const files = await readdir(passagesDir)
  const passageFiles = files.filter((f) => f.startsWith('passage_') && f.endsWith('.json'))

  console.log(`Found ${passageFiles.length} passage files`)
  console.log(`\nRenaming passages using MapKit Server API...`)
  if (updateJson) console.log('  ✓ Will update JSON files')
  if (d1Only) console.log('  ✓ Will only update local D1')
  if (d2Only) console.log('  ✓ Will only update remote D2')
  if (!d1Only && !d2Only) console.log('  ✓ Will update both D1 and D2')
  console.log()

  let totalRenamed = 0
  let totalSkipped = 0
  let totalErrors = 0

  for (const filename of passageFiles) {
    try {
      const filePath = join(passagesDir, filename)
      const content = await readFile(filePath, 'utf-8')
      const passage: Passage = JSON.parse(content)

      // Skip if name already looks location-based (unless --force)
      if (!force && passage.name.startsWith('From ') && passage.name.includes(' to ')) {
        console.log(`Skipping ${passage.id} - already has location-based name: "${passage.name}"`)
        totalSkipped++
        continue
      }

      console.log(`Processing ${passage.id}...`)
      console.log(`  Current name: "${passage.name}"`)

      const result = await renamePassage(passage, {
        useExistingLocations: true,
        updateJson,
        updateD1: !d2Only,
        updateD2: !d1Only,
      })

      if (result.success) {
        if (result.oldName !== result.newName) {
          console.log(`  ✓ Renamed: "${result.oldName}" → "${result.newName}"`)
          totalRenamed++
        } else {
          console.log(`  - Name unchanged: "${result.newName}"`)
          totalSkipped++
        }
      } else {
        console.log(`  ✗ Failed to rename`)
        totalErrors++
      }

      // Small delay to avoid rate limiting
      await new Promise((resolve) => setTimeout(resolve, 200))
    } catch (error) {
      console.error(`Error processing ${filename}:`, error)
      totalErrors++
    }
  }

  console.log(`\n✓ Renaming complete!`)
  console.log(`  - Renamed: ${totalRenamed} passages`)
  console.log(`  - Skipped: ${totalSkipped} passages`)
  console.log(`  - Errors: ${totalErrors} passages`)
}

// Run main if this is the entry point
const isMainModule = import.meta.url === `file://${process.argv[1]}` || 
                     process.argv[1]?.endsWith('rename-passages.ts') ||
                     process.argv[1]?.includes('rename-passages')

if (isMainModule) {
  main().catch(console.error)
}


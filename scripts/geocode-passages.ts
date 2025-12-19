#!/usr/bin/env tsx
/**
 * Script to geocode passages and store location information
 * Uses MapKit JS Geocoder to reverse geocode coordinates along passage routes
 */

import { readFile, readdir, writeFile, unlink } from 'fs/promises'
import { join } from 'path'
import { exec } from 'child_process'
import { promisify } from 'util'
import type { Passage, LocationInfo, PassagePosition } from '../types/passage'

const execAsync = promisify(exec)

// Using OpenStreetMap Nominatim and Overpass API for geocoding

/**
 * Reverse geocode a coordinate to get location information
 */
async function reverseGeocode(
  lat: number,
  lon: number
): Promise<LocationInfo | null> {
  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}&zoom=10&addressdetails=1`,
      {
        headers: {
          'User-Agent': 'PassageMap/1.0',
        },
      }
    )

    if (!response.ok) {
      return null
    }

    const data = await response.json()
    if (!data || data.error) {
      return null
    }

    const address = data.address || {}
    const locationInfo: LocationInfo = {
      coordinate: { lat, lon },
      time: '',
      name: data.name || address.amenity || address.leisure || address.tourism,
      locality: address.city || address.town || address.village || address.municipality,
      administrativeArea: address.state || address.region,
      country: address.country,
      countryCode: address.country_code?.toUpperCase(),
      formattedAddress: data.display_name,
      pointsOfInterest: [],
    }

    // Extract points of interest from address
    if (address.amenity || address.leisure || address.tourism) {
      locationInfo.pointsOfInterest = [
        address.amenity,
        address.leisure,
        address.tourism,
      ].filter(Boolean) as string[]
    }

    return locationInfo
  } catch (error) {
    console.error(`Error reverse geocoding ${lat}, ${lon}:`, error)
    return null
  }
}

/**
 * Search for nearby water features (marinas, ports, lighthouses, etc.)
 * Uses Overpass API for better structured queries
 */
async function findNearbyWaterFeatures(
  lat: number,
  lon: number,
  radius: number = 10000
): Promise<string[]> {
  try {
    // Use Overpass API to find water-related features
    const overpassQuery = `
      [out:json][timeout:10];
      (
        node["seamark:type"="harbour"](around:${radius},${lat},${lon});
        node["seamark:type"="marina"](around:${radius},${lat},${lon});
        node["seamark:type"="port"](around:${radius},${lat},${lon});
        node["seamark:type"="lighthouse"](around:${radius},${lat},${lon});
        node["amenity"="marina"](around:${radius},${lat},${lon});
        node["harbour"="yes"](around:${radius},${lat},${lon});
        node["leisure"="marina"](around:${radius},${lat},${lon});
        way["seamark:type"="harbour"](around:${radius},${lat},${lon});
        way["seamark:type"="marina"](around:${radius},${lat},${lon});
        way["amenity"="marina"](around:${radius},${lat},${lon});
        way["harbour"="yes"](around:${radius},${lat},${lon});
      );
      out center;
    `

    const response = await fetch('https://overpass-api.de/api/interpreter', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: `data=${encodeURIComponent(overpassQuery)}`,
    })

    if (!response.ok) {
      return []
    }

    const data = await response.json()
    if (!data.elements || data.elements.length === 0) {
      return []
    }

    const features: string[] = []
    for (const element of data.elements.slice(0, 5)) { // Limit to 5 closest
      const name = element.tags?.name || 
                   element.tags?.['seamark:name'] ||
                   element.tags?.seamark_type ||
                   element.tags?.amenity ||
                   'Water Feature'
      
      const elat = element.lat || element.center?.lat
      const elon = element.lon || element.center?.lon
      
      if (elat && elon) {
        const distance = calculateDistance(lat, lon, elat, elon)
        const type = element.tags?.['seamark:type'] || element.tags?.amenity || 'feature'
        features.push(`${name} (${type}, ${Math.round(distance * 10) / 10}km away)`)
      }
    }

    return features
  } catch {
    // Silently fail - water features are optional
    return []
  }
}

/**
 * Search for nearby tourist attractions and landmarks
 */
async function findNearbyAttractions(
  lat: number,
  lon: number,
  radius: number = 5000
): Promise<string[]> {
  try {
    // Search for tourist attractions using Overpass API (more detailed than Nominatim)
    const overpassQuery = `
      [out:json][timeout:10];
      (
        node["tourism"](around:${radius},${lat},${lon});
        node["historic"](around:${radius},${lat},${lon});
        node["leisure"](around:${radius},${lat},${lon});
        way["tourism"](around:${radius},${lat},${lon});
        way["historic"](around:${radius},${lat},${lon});
        way["leisure"](around:${radius},${lat},${lon});
      );
      out center;
    `

    const response = await fetch('https://overpass-api.de/api/interpreter', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: `data=${encodeURIComponent(overpassQuery)}`,
    })

    if (!response.ok) {
      return []
    }

    const data = await response.json()
    if (!data.elements || data.elements.length === 0) {
      return []
    }

    const attractions: string[] = []
    for (const element of data.elements.slice(0, 5)) { // Limit to 5 closest
      const name = element.tags?.name || element.tags?.tourism || element.tags?.historic || element.tags?.leisure
      if (name) {
        const elat = element.lat || element.center?.lat
        const elon = element.lon || element.center?.lon
        if (elat && elon) {
          const distance = calculateDistance(lat, lon, elat, elon)
          attractions.push(`${name} (${Math.round(distance)}km away)`)
        }
      }
    }

    return attractions
  } catch {
    // Silently fail - attractions are optional
    return []
  }
}

/**
 * Calculate distance between two coordinates in kilometers (Haversine formula)
 */
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371 // Earth's radius in km
  const dLat = (lat2 - lat1) * (Math.PI / 180)
  const dLon = (lon2 - lon1) * (Math.PI / 180)
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

/**
 * Enhanced geocoding with multiple data sources
 */
async function enhancedGeocode(
  lat: number,
  lon: number
): Promise<LocationInfo | null> {
  // Run all geocoding requests in parallel
  const [locationInfo, waterFeatures, attractions] = await Promise.all([
    reverseGeocode(lat, lon),
    findNearbyWaterFeatures(lat, lon),
    findNearbyAttractions(lat, lon),
  ])

  if (!locationInfo) {
    return null
  }

  // Combine all points of interest
  locationInfo.pointsOfInterest = [
    ...(locationInfo.pointsOfInterest || []),
    ...waterFeatures.map((f) => `🌊 ${f}`),
    ...attractions.map((a) => `📍 ${a}`),
  ]

  return locationInfo
}

/**
 * Sample key points along a passage for geocoding
 */
function samplePassagePoints(passage: Passage): Array<{ lat: number; lon: number; time: string }> {
  const points: Array<{ lat: number; lon: number; time: string }> = []

  if (!passage.positions || passage.positions.length === 0) {
    points.push({
      lat: passage.startLocation.lat,
      lon: passage.startLocation.lon,
      time: passage.startTime,
    })
    points.push({
      lat: passage.endLocation.lat,
      lon: passage.endLocation.lon,
      time: passage.endTime,
    })
    return points
  }

  // Sort positions by time
  const sortedPositions = [...passage.positions].sort((a, b) => {
    return Date.parse(a._time) - Date.parse(b._time)
  })

  // Always include start and end
  const startPos = sortedPositions[0]
  const endPos = sortedPositions[sortedPositions.length - 1]

  if (startPos) {
    points.push({
      lat: startPos.lat,
      lon: startPos.lon,
      time: startPos._time,
    })
  }

  // Sample points at regular intervals
  const totalDuration = Date.parse(passage.endTime) - Date.parse(passage.startTime)
  const intervalMs = Math.min(totalDuration / 10, 30 * 60 * 1000) // 10% or 30 minutes

  const sampledTimes = new Set<number>()
  for (let time = Date.parse(passage.startTime); time <= Date.parse(passage.endTime); time += intervalMs) {
    sampledTimes.add(time)
  }

  // Find positions closest to sampled times
  for (const targetTime of sampledTimes) {
    if (targetTime === Date.parse(passage.startTime) || targetTime === Date.parse(passage.endTime)) {
      continue
    }

    let closestPos: PassagePosition | null = null
    let minTimeDiff = Infinity

    for (const pos of sortedPositions) {
      const timeDiff = Math.abs(Date.parse(pos._time) - targetTime)
      if (timeDiff < minTimeDiff) {
        minTimeDiff = timeDiff
        closestPos = pos
      }
    }

    if (closestPos && minTimeDiff < intervalMs / 2) {
      points.push({
        lat: closestPos.lat,
        lon: closestPos.lon,
        time: closestPos._time,
      })
    }
  }

  // Always include end
  if (endPos && endPos !== startPos) {
    points.push({
      lat: endPos.lat,
      lon: endPos.lon,
      time: endPos._time,
    })
  }

  // Remove duplicates
  const uniquePoints: Array<{ lat: number; lon: number; time: string }> = []
  const seen = new Set<string>()

  for (const point of points) {
    const key = `${point.lat.toFixed(4)},${point.lon.toFixed(4)}`
    if (!seen.has(key)) {
      seen.add(key)
      uniquePoints.push(point)
    }
  }

  return uniquePoints
}

/**
 * Geocode a passage with parallel processing
 */
async function geocodePassage(passage: Passage): Promise<LocationInfo[]> {
  const points = samplePassagePoints(passage)
  
  console.log(`Geocoding ${points.length} points for passage ${passage.id}...`)

  // Process points in batches to respect rate limits while still using parallelism
  const batchSize = 3 // Process 3 points at a time
  const locationInfos: LocationInfo[] = []

  for (let i = 0; i < points.length; i += batchSize) {
    const batch = points.slice(i, i + batchSize)
    
    // Process batch in parallel
    const batchResults = await Promise.all(
      batch.map(async (point, batchIndex) => {
        if (!point) return null
        
        try {
          const locationInfo = await enhancedGeocode(point.lat, point.lon)
          if (locationInfo) {
            locationInfo.time = point.time
            const index = i + batchIndex + 1
            const locationName = locationInfo.locality || locationInfo.name || 'Unknown'
            const poiCount = locationInfo.pointsOfInterest?.length || 0
            console.log(`  ✓ ${index}/${points.length}: ${locationName}${poiCount > 0 ? ` (${poiCount} POIs)` : ''}`)
            return locationInfo
          } else {
            const index = i + batchIndex + 1
            console.log(`  ✗ ${index}/${points.length}: Failed to geocode ${point.lat}, ${point.lon}`)
            return null
          }
        } catch (error) {
          const index = i + batchIndex + 1
          console.error(`  ✗ ${index}/${points.length}: Error geocoding ${point.lat}, ${point.lon}:`, error)
          return null
        }
      })
    )

    // Filter out null results and add to locationInfos
    for (const result of batchResults) {
      if (result) {
        locationInfos.push(result)
      }
    }

    // Rate limit between batches: wait 2 seconds between batches
    if (i + batchSize < points.length) {
      await new Promise((resolve) => setTimeout(resolve, 2000))
    }
  }

  return locationInfos
}

/**
 * Helper function to escape SQL strings
 */
function escapeSQL(str: string | null | undefined): string {
  if (!str) return 'NULL'
  return `'${str.replace(/'/g, "''").replace(/\\/g, '\\\\')}'`
}

/**
 * Save locations to D1 database using wrangler
 */
async function saveLocationsToD1(passageId: string, locations: LocationInfo[]): Promise<boolean> {
  if (locations.length === 0) return false

  try {
    // Check if wrangler is available
    try {
      await execAsync('which wrangler')
    } catch {
      console.warn('  ⚠ Wrangler not found, skipping D1 save')
      return false
    }

    // Build SQL statements
    const sqlStatements: string[] = []
    
    // Delete existing locations for this passage
    sqlStatements.push(`DELETE FROM passage_locations WHERE passage_id = ${escapeSQL(passageId)};`)
    
    // Build insert statements
    for (const loc of locations) {
      sqlStatements.push(`
        INSERT INTO passage_locations (
          passage_id, time, lat, lon, name, locality, administrative_area,
          country, country_code, formatted_address, points_of_interest
        ) VALUES (
          ${escapeSQL(passageId)},
          ${escapeSQL(loc.time)},
          ${loc.coordinate.lat},
          ${loc.coordinate.lon},
          ${escapeSQL(loc.name)},
          ${escapeSQL(loc.locality)},
          ${escapeSQL(loc.administrativeArea)},
          ${escapeSQL(loc.country)},
          ${escapeSQL(loc.countryCode)},
          ${escapeSQL(loc.formattedAddress)},
          ${escapeSQL(loc.pointsOfInterest ? JSON.stringify(loc.pointsOfInterest) : null)}
        );
      `)
    }

    // Write to temporary SQL file
    const tempSqlFile = join(process.cwd(), `.d1-locations-${passageId.replace(/[^a-zA-Z0-9]/g, '_')}.sql`)
    await writeFile(tempSqlFile, sqlStatements.join('\n'), 'utf-8')

    try {
      // Execute SQL file using wrangler
      await execAsync(`wrangler d1 execute passage-map-db --file=${tempSqlFile}`, {
        cwd: process.cwd(),
      })
      
      // Clean up temp file
      await unlink(tempSqlFile).catch(() => {}) // Ignore errors
      
      return true
    } catch (error) {
      // Clean up temp file even on error
      await unlink(tempSqlFile).catch(() => {})
      throw error
    }
  } catch (error) {
    console.error(`  ✗ Error saving to D1:`, error instanceof Error ? error.message : String(error))
    return false
  }
}

/**
 * Main function
 */
async function main() {
  // Show usage if help requested
  if (process.argv.includes('--help') || process.argv.includes('-h')) {
    console.log(`
Usage: npx tsx scripts/geocode-passages.ts [options]

Options:
  --d1, --save-d1    Save locations to D1 database after geocoding
  --force            Re-geocode passages that already have locations
  --help, -h         Show this help message

Examples:
  # Geocode and save to JSON files only
  npx tsx scripts/geocode-passages.ts

  # Geocode and save to both JSON and D1
  npx tsx scripts/geocode-passages.ts --d1

  # Re-geocode all passages (including those with existing locations)
  npx tsx scripts/geocode-passages.ts --force
`)
    return
  }

  const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
  const files = await readdir(passagesDir)
  const passageFiles = files.filter((f) => f.startsWith('passage_') && f.endsWith('.json'))

  console.log(`Found ${passageFiles.length} passage files`)

  // Check if we should save to D1
  const saveToD1 = process.argv.includes('--d1') || process.argv.includes('--save-d1')
  if (saveToD1) {
    console.log('📦 D1 save enabled - locations will be saved to D1 database')
    console.log('   Make sure wrangler is installed and you are logged in')
  }

  for (const filename of passageFiles) {
    try {
      const filePath = join(passagesDir, filename)
      const content = await readFile(filePath, 'utf-8')
      const passage: Passage = JSON.parse(content)

      // Skip if already has locations (unless --force flag)
      const force = process.argv.includes('--force')
      if (passage.locations && passage.locations.length > 0 && !force) {
        console.log(`Skipping ${filename} - already has ${passage.locations.length} locations`)
        continue
      }

      console.log(`\nProcessing ${filename}...`)
      const locations = await geocodePassage(passage)

      if (locations.length > 0) {
        // Save to JSON file
        passage.locations = locations
        await writeFile(filePath, JSON.stringify(passage, null, 2), 'utf-8')
        console.log(`✓ Saved ${locations.length} locations to ${filename}`)

        // Save to D1 if enabled
        if (saveToD1) {
          const saved = await saveLocationsToD1(passage.id, locations)
          if (saved) {
            console.log(`✓ Saved ${locations.length} locations to D1 for passage ${passage.id}`)
          }
        }
      } else {
        console.log(`⚠ No locations found for ${filename}`)
      }
    } catch (error) {
      console.error(`Error processing ${filename}:`, error)
    }
  }

  console.log('\n✓ Geocoding complete!')
  if (saveToD1) {
    console.log('💾 All locations have been saved to D1 database')
  }
}

// Run main if this is the entry point
const isMainModule = import.meta.url === `file://${process.argv[1]}` || 
                     process.argv[1]?.endsWith('geocode-passages.ts') ||
                     process.argv[1]?.includes('geocode-passages')

if (isMainModule) {
  main().catch(console.error)
}


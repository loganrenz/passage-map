#!/usr/bin/env tsx
/**
 * Script to fetch vessel names for MMSI numbers
 * 
 * This script can be used to populate the mmsi-to-vessel-name.json file
 * by querying various maritime APIs or web services.
 * 
 * Usage:
 *   npx tsx scripts/fetch-vessel-names.ts [options]
 * 
 * Options:
 *   --mmsi <number>     Fetch name for a specific MMSI
 *   --file <path>       Input file with MMSI numbers (one per line or JSON array)
 *   --output <path>     Output file path (default: public/data/mmsi-to-vessel-name.json)
 *   --limit <number>    Limit number of lookups (useful for testing)
 *   --delay <ms>        Delay between API calls in milliseconds (default: 1000)
 */

import { readFileSync, writeFileSync, existsSync } from 'fs'
import { join } from 'path'
import { execSync } from 'child_process'

/**
 * Get AISHub API key from Doppler or environment variable
 */
function getAISHubKey(): string | null {
  // Try environment variable first
  if (process.env.AIS_HUB_API_KEY) {
    return process.env.AIS_HUB_API_KEY
  }
  if (process.env.AISHUB_USERNAME || process.env.AISHUB_API_KEY) {
    return process.env.AISHUB_USERNAME || process.env.AISHUB_API_KEY
  }
  
  // Try to get from Doppler
  try {
    const key = execSync('doppler secrets get AIS_HUB_API_KEY --plain 2>/dev/null', { encoding: 'utf-8' }).trim()
    if (key && key.length > 0) {
      return key
    }
  } catch (error) {
    // Doppler not available or key not found
  }
  
  return null
}

interface VesselNameMapping {
  _comment?: string
  _lastUpdated?: string
  _totalMmsis?: number
  mappings: Record<string, string>
}

/**
 * Fetch vessel name from a web service
 * 
 * Free options (no API key required or free with registration):
 * 1. Marinesia API (FREE) - https://docs.marinesia.com/
 * 2. Global Fishing Watch API (FREE with token) - https://globalfishingwatch.org/our-apis/documentation
 * 
 * Paid options:
 * 3. MarineTraffic API - https://www.marinetraffic.com/en/ais-api-services
 * 4. VesselFinder API - https://www.vesselfinder.com/vessel-particulars-api
 * 5. Datalastic API - https://datalastic.com/ship-finder-data-api/
 */
async function fetchVesselNameFromAPI(mmsi: string): Promise<string | null> {
  console.log(`  Fetching name for MMSI ${mmsi}...`)
  
  // Option 1: Try local database first (if you've downloaded one)
  // You can download vessel databases from:
  // - Datalastic: https://datalastic.com/maritime-database/ (paid but comprehensive)
  // - Or create your own from various sources
  const localDbPath = join(process.cwd(), 'public/data/vessel-database.json')
  if (existsSync(localDbPath)) {
    try {
      const db = JSON.parse(readFileSync(localDbPath, 'utf-8'))
      const vessel = db.find((v: any) => v.mmsi === mmsi || v.MMSI === mmsi)
      if (vessel && (vessel.name || vessel.NAME || vessel.vesselName)) {
        const name = vessel.name || vessel.NAME || vessel.vesselName
        if (name && typeof name === 'string' && name.trim().length > 0) {
          console.log(`  Found in local database`)
          return name.trim()
        }
      }
    } catch (error) {
      // Continue to API options
    }
  }
  
  // Option 2: Marinesia API (FREE - check docs.marinesia.com for actual endpoints)
  // Note: Actual endpoint may vary - check their documentation
  try {
    // Try different possible endpoints
    const endpoints = [
      `https://api.marinesia.com/v1/vessels?mmsi=${mmsi}`,
      `https://marinesia.com/api/vessels/${mmsi}`,
      `https://api.marinesia.com/vessels/${mmsi}`,
    ]
    
    for (const endpoint of endpoints) {
      try {
        const response = await fetch(endpoint, {
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'PassageMap/1.0',
          },
        })
        
        if (response.ok) {
          const data = await response.json()
          // Try different response structures
          const name = data.vessel?.name || 
                      data.name || 
                      data[0]?.name ||
                      data.data?.name ||
                      data.result?.name
          
          if (name && typeof name === 'string' && name.trim().length > 0) {
            console.log(`  Found via Marinesia API`)
            return name.trim()
          }
        }
      } catch (e) {
        // Try next endpoint
        continue
      }
    }
  } catch (error) {
    // Continue to next option
  }
  
  // Option 2: AISHub API (FREE - requires username/key from Doppler)
  // API format: https://data.aishub.net/ws.php?username=USERNAME&format=1&output=json&mmsi=MMSI
  // Rate limit: 1 request per minute
  const AISHUB_USERNAME = getAISHubKey()
  if (AISHUB_USERNAME) {
    try {
      const url = `https://data.aishub.net/ws.php?username=${encodeURIComponent(AISHUB_USERNAME)}&format=1&output=json&mmsi=${mmsi}`
      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PassageMap/1.0',
        },
      })
      
      if (response.ok) {
        const text = await response.text()
        
        // AISHub returns JSON wrapped in array format: [metadata, [vessels]]
        try {
          const parsed = JSON.parse(text)
          
          // Check for error in metadata
          if (Array.isArray(parsed) && parsed.length > 0) {
            const metadata = parsed[0]
            
            if (metadata.ERROR === true) {
              if (metadata.ERROR_MESSAGE?.includes('Too frequent')) {
                console.log(`  ⚠️  AISHub rate limit - need 60+ second delay between requests`)
                // Return null so we can continue to next API option
                return null
              } else {
                console.log(`  AISHub error: ${metadata.ERROR_MESSAGE || 'Unknown error'}`)
                return null
              }
            }
            
            // Response format: [{"ERROR":false,"RECORDS":N}, [vessel1, vessel2, ...]]
            if (parsed.length >= 2 && Array.isArray(parsed[1])) {
              const vessels = parsed[1]
              
              if (vessels.length > 0) {
                // Get the first vessel
                const vessel = vessels[0]
                // AISHub vessel data structure varies, try common field names
                const name = vessel.NAME || vessel.name || vessel.SHIPNAME || vessel.shipname || vessel.VESSELNAME
                if (name && typeof name === 'string' && name.trim().length > 0 && name !== 'N/A') {
                  console.log(`  ✅ Found via AISHub API`)
                  return name.trim()
                }
              } else if (metadata.RECORDS === 0) {
                console.log(`  Vessel not found in AISHub database (0 records)`)
              }
            }
          } else if (parsed.NAME || parsed.name) {
            // Single vessel object format
            const name = parsed.NAME || parsed.name
            if (name && typeof name === 'string' && name.trim().length > 0 && name !== 'N/A') {
              console.log(`  ✅ Found via AISHub API`)
              return name.trim()
            }
          }
        } catch (parseError) {
          console.log(`  AISHub response parse error: ${parseError}`)
        }
      } else if (response.status === 429) {
        console.log(`  ⚠️  AISHub rate limit - need 60+ second delay`)
      }
    } catch (error) {
      console.log(`  AISHub API error`)
    }
  }
  
  // Option 3: Global Fishing Watch API (FREE with token - get one at https://globalfishingwatch.org/)
  const GFW_TOKEN = process.env.GFW_API_TOKEN
  if (GFW_TOKEN) {
    try {
      const response = await fetch(
        `https://gateway.api.globalfishingwatch.org/v2/vessels?mmsi=${mmsi}`,
        {
          headers: {
            'Authorization': `Bearer ${GFW_TOKEN}`,
            'Accept': 'application/json',
          },
        }
      )
      
      if (response.ok) {
        const data = await response.json()
        if (data.entries && data.entries.length > 0) {
          const vessel = data.entries[0]
          if (vessel.name) {
            return vessel.name.trim()
          }
        }
      }
    } catch (error) {
      console.log(`  Global Fishing Watch API error`)
    }
  }
  
  // Option 3: MarineTraffic API (requires paid API key)
  const MARINETRAFFIC_API_KEY = process.env.MARINETRAFFIC_API_KEY
  if (MARINETRAFFIC_API_KEY) {
    try {
      const response = await fetch(
        `https://services.marinetraffic.com/api/exportvessel/v:8/format:json/mmsi:${mmsi}/protocol:jsono`,
        {
          headers: {
            'Authorization': `Bearer ${MARINETRAFFIC_API_KEY}`
          }
        }
      )
      if (response.ok) {
        const data = await response.json()
        return data[0]?.SHIPNAME || null
      }
    } catch (error) {
      console.log(`  MarineTraffic API error`)
    }
  }
  
  // Option 4: VesselFinder API (requires paid API key)
  const VESSELFINDER_API_KEY = process.env.VESSELFINDER_API_KEY
  if (VESSELFINDER_API_KEY) {
    try {
      const response = await fetch(
        `https://api.vesselfinder.com/vessels/${mmsi}`,
        {
          headers: {
            'Authorization': `Bearer ${VESSELFINDER_API_KEY}`
          }
        }
      )
      if (response.ok) {
        const data = await response.json()
        return data.name || null
      }
    } catch (error) {
      console.log(`  VesselFinder API error`)
    }
  }
  
  // No API found the vessel
  return null
}

/**
 * Load existing mapping file
 */
function loadMappingFile(filePath: string): VesselNameMapping {
  if (existsSync(filePath)) {
    try {
      const content = readFileSync(filePath, 'utf-8')
      return JSON.parse(content) as VesselNameMapping
    } catch (error) {
      console.error(`Error reading mapping file: ${error}`)
    }
  }

  return {
    _comment: 'Mapping of MMSI (Maritime Mobile Service Identity) numbers to vessel names',
    _lastUpdated: new Date().toISOString(),
    mappings: {},
  }
}

/**
 * Save mapping file
 */
function saveMappingFile(filePath: string, mapping: VesselNameMapping): void {
  mapping._lastUpdated = new Date().toISOString()
  writeFileSync(filePath, JSON.stringify(mapping, null, 2), 'utf-8')
  console.log(`\n✅ Saved ${Object.keys(mapping.mappings).length} vessel name mappings to ${filePath}`)
}

/**
 * Load MMSI numbers from file
 */
function loadMmsiList(filePath: string): string[] {
  const content = readFileSync(filePath, 'utf-8')
  
  // Try JSON array first
  try {
    const json = JSON.parse(content)
    if (Array.isArray(json)) {
      return json.map(m => String(m))
    }
  } catch {
    // Not JSON, treat as line-separated
  }

  // Treat as line-separated
  return content
    .split('\n')
    .map(line => line.trim())
    .filter(line => line && !line.startsWith('#'))
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2)
  
  let mmsi: string | null = null
  let inputFile: string | null = null
  let outputFile = join(process.cwd(), 'public/data/mmsi-to-vessel-name.json')
  let limit: number | null = null
  let delay = 1000 // Default delay

  // Parse arguments
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--mmsi' && args[i + 1]) {
      mmsi = args[i + 1]
      i++
    } else if (args[i] === '--file' && args[i + 1]) {
      inputFile = args[i + 1]
      i++
    } else if (args[i] === '--output' && args[i + 1]) {
      outputFile = args[i + 1]
      i++
    } else if (args[i] === '--limit' && args[i + 1]) {
      limit = parseInt(args[i + 1], 10)
      i++
    } else if (args[i] === '--delay' && args[i + 1]) {
      delay = parseInt(args[i + 1], 10)
      i++
    }
  }
  
  // If using AISHub (which has 1 req/min limit), ensure delay is at least 60 seconds
  const aishubKey = getAISHubKey()
  if (aishubKey && delay < 60000) {
    console.log('ℹ️  AISHub API detected - increasing delay to 60 seconds (rate limit: 1 req/min)')
    delay = 60000 // AISHub requires 60 seconds between requests
  }

  // Load existing mappings
  const mapping = loadMappingFile(outputFile)
  const existingCount = Object.keys(mapping.mappings).length
  console.log(`📋 Loaded ${existingCount} existing vessel name mappings`)

  // Get list of MMSIs to process
  let mmsisToProcess: string[] = []

  if (mmsi) {
    mmsisToProcess = [mmsi]
  } else if (inputFile) {
    mmsisToProcess = loadMmsiList(inputFile)
  } else {
    // Default: use the mmsi-list.json file
    const mmsiListPath = join(process.cwd(), 'public/data/mmsi-list.json')
    if (existsSync(mmsiListPath)) {
      mmsisToProcess = loadMmsiList(mmsiListPath)
    } else {
      console.error('❌ No MMSI list found. Use --mmsi or --file to specify MMSIs to process.')
      process.exit(1)
    }
  }

  // Filter out already-mapped MMSIs
  const unmapped = mmsisToProcess.filter(m => !mapping.mappings[m])
  console.log(`📊 Found ${unmapped.length} unmapped MMSIs (out of ${mmsisToProcess.length} total)`)

  if (unmapped.length === 0) {
    console.log('✅ All MMSIs are already mapped!')
    return
  }

  // Apply limit if specified
  const toProcess = limit ? unmapped.slice(0, limit) : unmapped
  console.log(`🔄 Processing ${toProcess.length} MMSIs...\n`)

  // Process each MMSI
  let successCount = 0
  let failCount = 0

  for (let i = 0; i < toProcess.length; i++) {
    const mmsiToProcess = toProcess[i]
    console.log(`[${i + 1}/${toProcess.length}] Processing MMSI ${mmsiToProcess}...`)

    const vesselName = await fetchVesselNameFromAPI(mmsiToProcess)
    
    if (vesselName) {
      mapping.mappings[mmsiToProcess] = vesselName
      console.log(`  ✅ Found: ${vesselName}`)
      successCount++
    } else {
      console.log(`  ⚠️  No name found`)
      failCount++
    }

    // Save periodically (every 10 entries)
    if ((i + 1) % 10 === 0) {
      saveMappingFile(outputFile, mapping)
    }

    // Delay between requests to avoid rate limiting
    if (i < toProcess.length - 1 && delay > 0) {
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }

  // Final save
  saveMappingFile(outputFile, mapping)

  console.log(`\n📊 Summary:`)
  console.log(`   ✅ Successfully fetched: ${successCount}`)
  console.log(`   ❌ Failed: ${failCount}`)
  console.log(`   📝 Total mappings: ${Object.keys(mapping.mappings).length}`)
}

// Run if executed directly
// Check if this is the main module (ES module way)
if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('fetch-vessel-names.ts')) {
  main().catch(error => {
    console.error('❌ Error:', error)
    process.exit(1)
  })
}


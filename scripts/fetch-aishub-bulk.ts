#!/usr/bin/env tsx
/**
 * Script to fetch ALL vessel data from AISHub in bulk and extract MMSI -> vessel name mappings
 * 
 * This is much more efficient than querying one MMSI at a time!
 * 
 * Usage:
 *   npx tsx scripts/fetch-aishub-bulk.ts
 * 
 * The script will:
 * 1. Download compressed JSON from AISHub
 * 2. Decompress and parse the data
 * 3. Extract MMSI -> vessel name mappings
 * 4. Save to mmsi-to-vessel-name.json
 */

import { readFileSync, writeFileSync, existsSync } from 'fs'
import { join } from 'path'
import { execSync } from 'child_process'
import { createGunzip } from 'zlib'
import { createReadStream } from 'fs'
import { createInterface } from 'readline'

interface VesselNameMapping {
  _comment?: string
  _lastUpdated?: string
  _totalMmsis?: number
  mappings: Record<string, string>
}

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

/**
 * Download AISHub data (uncompressed for easier parsing)
 */
async function downloadAISHubData(username: string, compressed: boolean = false): Promise<string> {
  const compressParam = compressed ? '&compress=1' : '&compress=0'
  const url = `https://data.aishub.net/ws.php?username=${encodeURIComponent(username)}&format=1&output=json${compressParam}`
  const tempFile = compressed ? '/tmp/aishub-data.zip' : '/tmp/aishub-data.json'
  
  console.log('📥 Downloading AISHub data (this may take a moment)...')
  console.log(`   URL: https://data.aishub.net/ws.php?username=${username}&format=1&output=json${compressParam}`)
  
  const response = await fetch(url)
  
  if (!response.ok) {
    throw new Error(`Failed to download AISHub data: ${response.status} ${response.statusText}`)
  }
  
  // Save data
  const buffer = await response.arrayBuffer()
  writeFileSync(tempFile, Buffer.from(buffer))
  
  const sizeMB = (buffer.byteLength / 1024 / 1024).toFixed(2)
  console.log(`✅ Downloaded ${sizeMB} MB`)
  
  return tempFile
}

/**
 * Decompress and parse AISHub JSON data
 */
async function parseAISHubData(compressedFile: string): Promise<Record<string, string>> {
  console.log('📦 Decompressing and parsing data...')
  
  // Read file
  const fileData = readFileSync(compressedFile)
  
  // Check magic bytes to detect compression type
  let text: string
  const isGzip = fileData[0] === 0x1f && fileData[1] === 0x8b
  const isZip = fileData[0] === 0x50 && fileData[1] === 0x4b // "PK" - ZIP file
  
  if (isZip) {
    console.log('   Detected ZIP compression, extracting...')
    // AISHub returns ZIP with a JSON file inside
    // Use unzip command or Node.js zip library
    // For simplicity, let's try using the system unzip command
    try {
      const tempDir = '/tmp/aishub-extract'
      execSync(`mkdir -p ${tempDir} && cd ${tempDir} && unzip -q -o ${compressedFile} && cat *.json`, { encoding: 'utf-8' })
      // Actually, let's just read the zip and extract the JSON
      // For now, let's use a simpler approach - download without compression
      throw new Error('ZIP extraction - will use uncompressed download instead')
    } catch (error) {
      // Fall back to uncompressed download
      console.log('   ZIP extraction failed, will download uncompressed version')
      throw error
    }
  } else if (isGzip) {
    console.log('   Detected gzip compression, decompressing...')
    // Decompress
    const decompressed = await new Promise<Buffer>((resolve, reject) => {
      const gunzip = createGunzip()
      const chunks: Buffer[] = []
      
      gunzip.on('data', (chunk) => chunks.push(chunk))
      gunzip.on('end', () => resolve(Buffer.concat(chunks)))
      gunzip.on('error', reject)
      
      gunzip.write(fileData)
      gunzip.end()
    })
    
    text = decompressed.toString('utf-8')
    console.log(`   Decompressed size: ${(text.length / 1024 / 1024).toFixed(2)} MB`)
  } else {
    // Not compressed, read as text
    text = fileData.toString('utf-8')
    console.log(`   File size: ${(text.length / 1024 / 1024).toFixed(2)} MB (not compressed)`)
  }
  
  // Parse JSON
  // AISHub returns: [metadata, [vessel1, vessel2, ...]]
  let data: any
  try {
    data = JSON.parse(text)
  } catch (parseError) {
    console.error(`   Failed to parse JSON. First 500 chars: ${text.substring(0, 500)}`)
    throw new Error(`JSON parse error: ${parseError}`)
  }
  
  if (!Array.isArray(data)) {
    throw new Error('Unexpected AISHub data format - expected array')
  }
  
  // Check for error response
  if (data.length > 0 && data[0].ERROR === true) {
    const errorMsg = data[0].ERROR_MESSAGE || 'Unknown error'
    if (errorMsg.includes('Too frequent')) {
      throw new Error('AISHub rate limit - wait 1 minute before trying again')
    }
    throw new Error(`AISHub API error: ${errorMsg}`)
  }
  
  if (data.length < 2) {
    throw new Error('Unexpected AISHub data format - array too short')
  }
  
  const metadata = data[0]
  const vessels = data[1]
  
  if (!Array.isArray(vessels)) {
    throw new Error('Unexpected AISHub data format - vessels not an array')
  }
  
  console.log(`   Records: ${metadata.RECORDS || vessels.length}`)
  console.log(`   Vessels in array: ${vessels.length}`)
  
  // Extract MMSI -> NAME mappings
  const mappings: Record<string, string> = {}
  let processed = 0
  let skipped = 0
  
  for (const vessel of vessels) {
    const mmsi = String(vessel.MMSI || vessel.mmsi || '').trim()
    const name = vessel.NAME || vessel.name || ''
    
    if (mmsi && name && mmsi.match(/^\d+$/)) {
      const cleanName = String(name).trim()
      if (cleanName && cleanName.length > 0 && cleanName !== 'N/A') {
        mappings[mmsi] = cleanName
        processed++
      } else {
        skipped++
      }
    } else {
      skipped++
    }
  }
  
  console.log(`✅ Extracted ${processed} vessel name mappings`)
  if (skipped > 0) {
    console.log(`   Skipped ${skipped} vessels (missing MMSI or name)`)
  }
  
  return mappings
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
}

async function main() {
  console.log('🚢 AISHub Bulk Vessel Name Fetcher\n')
  
  // Get AISHub key
  const aishubKey = getAISHubKey()
  if (!aishubKey) {
    console.error('❌ AISHub API key not found!')
    console.error('   Set AIS_HUB_API_KEY environment variable or configure Doppler')
    process.exit(1)
  }
  
  console.log(`✅ Found AISHub key: ${aishubKey.substring(0, 8)}...\n`)
  
  // Load existing mappings
  const outputFile = join(process.cwd(), 'public/data/mmsi-to-vessel-name.json')
  const mapping = loadMappingFile(outputFile)
  const existingCount = Object.keys(mapping.mappings).length
  console.log(`📋 Loaded ${existingCount} existing vessel name mappings\n`)
  
  try {
    // Download data (try uncompressed first for easier parsing)
    let dataFile: string
    try {
      dataFile = await downloadAISHubData(aishubKey, false) // Uncompressed
    } catch (error) {
      console.log('   Trying compressed download...')
      dataFile = await downloadAISHubData(aishubKey, true) // Compressed
    }
    
    // Parse and extract mappings
    const newMappings = await parseAISHubData(dataFile)
    
    // Merge with existing mappings (new mappings override existing ones)
    let added = 0
    let updated = 0
    
    for (const [mmsi, name] of Object.entries(newMappings)) {
      if (mapping.mappings[mmsi]) {
        if (mapping.mappings[mmsi] !== name) {
          updated++
        }
      } else {
        added++
      }
      mapping.mappings[mmsi] = name
    }
    
    // Save merged mappings
    saveMappingFile(outputFile, mapping)
    
    console.log(`\n✅ Import complete!`)
    console.log(`   ➕ Added: ${added} new mappings`)
    console.log(`   🔄 Updated: ${updated} existing mappings`)
    console.log(`   📝 Total mappings: ${Object.keys(mapping.mappings).length}`)
    console.log(`   💾 Saved to: ${outputFile}`)
    
    // Clean up temp file
    try {
      require('fs').unlinkSync(dataFile)
    } catch (e) {
      // Ignore cleanup errors
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error)
    process.exit(1)
  }
}

main().catch(error => {
  console.error('❌ Fatal error:', error)
  process.exit(1)
})


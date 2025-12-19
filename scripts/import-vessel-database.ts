#!/usr/bin/env tsx
/**
 * Script to import vessel names from a CSV or JSON database file
 * 
 * This is useful if you download a vessel database (e.g., from Datalastic or other sources)
 * 
 * Usage:
 *   npx tsx scripts/import-vessel-database.ts <database-file> [--format csv|json]
 * 
 * Example:
 *   npx tsx scripts/import-vessel-database.ts vessel-database.csv --format csv
 *   npx tsx scripts/import-vessel-database.ts vessel-database.json --format json
 */

import { readFileSync, writeFileSync, existsSync } from 'fs'
import { join } from 'path'

interface VesselNameMapping {
  _comment?: string
  _lastUpdated?: string
  _totalMmsis?: number
  mappings: Record<string, string>
}

/**
 * Parse CSV file and extract MMSI -> name mappings
 */
function parseCSV(filePath: string): Record<string, string> {
  const content = readFileSync(filePath, 'utf-8')
  const lines = content.split('\n').filter(line => line.trim())
  
  if (lines.length === 0) {
    throw new Error('CSV file is empty')
  }
  
  // Try to detect header
  const header = lines[0].toLowerCase()
  let mmsiIndex = -1
  let nameIndex = -1
  
  // Common column name variations
  const mmsiVariations = ['mmsi', 'mmsi_number', 'ais_mmsi', 'vessel_mmsi']
  const nameVariations = ['name', 'vessel_name', 'ship_name', 'vesselname', 'shipname']
  
  const headerCols = header.split(',').map((col: string) => col.trim().replace(/"/g, ''))
  
  for (let i = 0; i < headerCols.length; i++) {
    const col = headerCols[i].toLowerCase()
    if (mmsiVariations.some(v => col.includes(v)) && mmsiIndex === -1) {
      mmsiIndex = i
    }
    if (nameVariations.some(v => col.includes(v)) && nameIndex === -1) {
      nameIndex = i
    }
  }
  
  if (mmsiIndex === -1 || nameIndex === -1) {
    throw new Error(`Could not find MMSI and/or Name columns. Found columns: ${headerCols.join(', ')}`)
  }
  
  const mappings: Record<string, string> = {}
  
  // Parse data rows
  for (let i = 1; i < lines.length; i++) {
    const cols = lines[i].split(',').map((col: string) => col.trim().replace(/^"|"$/g, ''))
    
    if (cols.length > Math.max(mmsiIndex, nameIndex)) {
      const mmsi = String(cols[mmsiIndex]).trim()
      const name = cols[nameIndex].trim()
      
      if (mmsi && name && mmsi.match(/^\d+$/)) {
        mappings[mmsi] = name
      }
    }
  }
  
  return mappings
}

/**
 * Parse JSON file and extract MMSI -> name mappings
 */
function parseJSON(filePath: string): Record<string, string> {
  const content = readFileSync(filePath, 'utf-8')
  const data = JSON.parse(content)
  
  const mappings: Record<string, string> = {}
  
  // Handle array of vessels
  if (Array.isArray(data)) {
    for (const vessel of data) {
      const mmsi = String(vessel.mmsi || vessel.MMSI || vessel.mmsi_number || '').trim()
      const name = vessel.name || vessel.NAME || vessel.vesselName || vessel.vessel_name || vessel.shipName || ''
      
      if (mmsi && name && mmsi.match(/^\d+$/)) {
        mappings[mmsi] = String(name).trim()
      }
    }
  } 
  // Handle object with vessels array
  else if (data.vessels || data.data || data.entries) {
    const vessels = data.vessels || data.data || data.entries
    for (const vessel of vessels) {
      const mmsi = String(vessel.mmsi || vessel.MMSI || vessel.mmsi_number || '').trim()
      const name = vessel.name || vessel.NAME || vessel.vesselName || vessel.vessel_name || vessel.shipName || ''
      
      if (mmsi && name && mmsi.match(/^\d+$/)) {
        mappings[mmsi] = String(name).trim()
      }
    }
  }
  // Handle flat object with MMSI as keys
  else {
    for (const [key, value] of Object.entries(data)) {
      if (key.match(/^\d+$/)) {
        const vessel = value as any
        const name = vessel.name || vessel.NAME || vessel.vesselName || String(vessel).trim()
        if (name) {
          mappings[key] = String(name).trim()
        }
      }
    }
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
  const args = process.argv.slice(2)
  
  if (args.length === 0) {
    console.error('Usage: npx tsx scripts/import-vessel-database.ts <database-file> [--format csv|json]')
    console.error('\nExample:')
    console.error('  npx tsx scripts/import-vessel-database.ts vessel-database.csv --format csv')
    console.error('  npx tsx scripts/import-vessel-database.ts vessel-database.json --format json')
    process.exit(1)
  }
  
  const dbFilePath = args[0]
  const format = args.includes('--format') 
    ? args[args.indexOf('--format') + 1] 
    : dbFilePath.endsWith('.csv') ? 'csv' : 'json'
  
  const outputFile = join(process.cwd(), 'public/data/mmsi-to-vessel-name.json')
  
  if (!existsSync(dbFilePath)) {
    console.error(`❌ Database file not found: ${dbFilePath}`)
    process.exit(1)
  }
  
  console.log(`📂 Loading database from: ${dbFilePath}`)
  console.log(`📋 Format: ${format}`)
  
  // Load existing mappings
  const mapping = loadMappingFile(outputFile)
  const existingCount = Object.keys(mapping.mappings).length
  console.log(`📋 Loaded ${existingCount} existing vessel name mappings`)
  
  // Parse database file
  let newMappings: Record<string, string>
  try {
    if (format === 'csv') {
      newMappings = parseCSV(dbFilePath)
    } else {
      newMappings = parseJSON(dbFilePath)
    }
  } catch (error) {
    console.error(`❌ Error parsing database file: ${error}`)
    process.exit(1)
  }
  
  console.log(`📊 Found ${Object.keys(newMappings).length} vessel mappings in database`)
  
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
}

main().catch(error => {
  console.error('❌ Error:', error)
  process.exit(1)
})


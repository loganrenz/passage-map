#!/usr/bin/env tsx
/**
 * Script to load existing locations from JSON files into D1
 * This is useful for migrating existing geocoded data to D1
 */

import { readFile, readdir } from 'fs/promises'
import { join } from 'path'
import { exec } from 'child_process'
import { promisify } from 'util'
import type { Passage, LocationInfo } from '../types/passage'

const execAsync = promisify(exec)

/**
 * Helper function to escape SQL strings
 */
function escapeSQL(str: string | null | undefined): string {
  if (!str) return 'NULL'
  return `'${str.replace(/'/g, "''").replace(/\\/g, '\\\\')}'`
}

/**
 * Save passage to D1 (if not exists)
 */
async function ensurePassageInD1(passage: Passage): Promise<boolean> {
  try {
    const sqlStatements: string[] = []
    
    sqlStatements.push(`
      INSERT OR IGNORE INTO passages (
        id, start_time, end_time, duration, avg_speed, max_speed, distance,
        start_lat, start_lon, end_lat, end_lon, description, name, route,
        export_timestamp, filename, query_metadata, encounters_filename, updated_at
      ) VALUES (
        ${escapeSQL(passage.id)},
        ${escapeSQL(passage.startTime)},
        ${escapeSQL(passage.endTime)},
        ${passage.duration},
        ${passage.avgSpeed},
        ${passage.maxSpeed},
        ${passage.distance},
        ${passage.startLocation.lat},
        ${passage.startLocation.lon},
        ${passage.endLocation.lat},
        ${passage.endLocation.lon},
        ${escapeSQL(passage.description)},
        ${escapeSQL(passage.name)},
        ${escapeSQL(passage.route)},
        ${escapeSQL(passage.exportTimestamp)},
        ${escapeSQL(passage.filename)},
        ${escapeSQL(passage.queryMetadata ? JSON.stringify(passage.queryMetadata) : null)},
        ${escapeSQL(passage.encountersFilename)},
        unixepoch()
      );
    `)

    const tempSqlFile = join(process.cwd(), `.d1-passage-${passage.id.replace(/[^a-zA-Z0-9]/g, '_')}.sql`)
    await import('fs/promises').then(({ writeFile }) =>
      writeFile(tempSqlFile, sqlStatements.join('\n'), 'utf-8')
    )

    try {
      await execAsync(`wrangler d1 execute passage-map-db --file=${tempSqlFile} --local`, {
        cwd: process.cwd(),
      })
      await import('fs/promises').then(({ unlink }) =>
        unlink(tempSqlFile).catch(() => {})
      )
      return true
    } catch (error) {
      await import('fs/promises').then(({ unlink }) =>
        unlink(tempSqlFile).catch(() => {})
      )
      throw error
    }
  } catch (error) {
    console.error(`  ✗ Error ensuring passage in D1:`, error instanceof Error ? error.message : String(error))
    return false
  }
}

/**
 * Save locations to D1 database using wrangler
 */
async function saveLocationsToD1(passage: Passage, locations: LocationInfo[]): Promise<boolean> {
  if (locations.length === 0) return false

  try {
    // First ensure passage exists in D1
    await ensurePassageInD1(passage)

    // Build SQL statements
    const sqlStatements: string[] = []
    
    // Delete existing locations for this passage
    sqlStatements.push(`DELETE FROM passage_locations WHERE passage_id = ${escapeSQL(passage.id)};`)
    
    // Build insert statements
    for (const loc of locations) {
      sqlStatements.push(`
        INSERT INTO passage_locations (
          passage_id, time, lat, lon, name, locality, administrative_area,
          country, country_code, formatted_address, points_of_interest
        ) VALUES (
          ${escapeSQL(passage.id)},
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
    const tempSqlFile = join(process.cwd(), `.d1-locations-${passage.id.replace(/[^a-zA-Z0-9]/g, '_')}.sql`)
    await import('fs/promises').then(({ writeFile }) =>
      writeFile(tempSqlFile, sqlStatements.join('\n'), 'utf-8')
    )

    try {
      // Execute SQL file using wrangler (local)
      await execAsync(`wrangler d1 execute passage-map-db --file=${tempSqlFile} --local`, {
        cwd: process.cwd(),
      })
      
      // Clean up temp file
      await import('fs/promises').then(({ unlink }) =>
        unlink(tempSqlFile).catch(() => {})
      )
      
      return true
    } catch (error) {
      // Clean up temp file even on error
      await import('fs/promises').then(({ unlink }) =>
        unlink(tempSqlFile).catch(() => {})
      )
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
  const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
  const files = await readdir(passagesDir)
  const passageFiles = files.filter((f) => f.startsWith('passage_') && f.endsWith('.json'))

  console.log(`Found ${passageFiles.length} passage files`)
  console.log('Loading locations from JSON files into D1...\n')

  let totalLoaded = 0
  let totalSkipped = 0

  for (const filename of passageFiles) {
    try {
      const filePath = join(passagesDir, filename)
      const content = await readFile(filePath, 'utf-8')
      const passage: Passage = JSON.parse(content)

      if (!passage.locations || passage.locations.length === 0) {
        totalSkipped++
        continue
      }

      console.log(`Loading ${passage.locations.length} locations for passage ${passage.id}...`)
      const saved = await saveLocationsToD1(passage, passage.locations)
      
      if (saved) {
        console.log(`  ✓ Saved ${passage.locations.length} locations to D1`)
        totalLoaded += passage.locations.length
      } else {
        console.log(`  ✗ Failed to save locations`)
        totalSkipped++
      }
    } catch (error) {
      console.error(`Error processing ${filename}:`, error)
      totalSkipped++
    }
  }

  console.log(`\n✓ Complete!`)
  console.log(`  - Loaded ${totalLoaded} locations from ${passageFiles.length - totalSkipped} passages`)
  console.log(`  - Skipped ${totalSkipped} passages (no locations or errors)`)
}

// Run main if this is the entry point
const isMainModule = import.meta.url === `file://${process.argv[1]}` || 
                     process.argv[1]?.endsWith('load-locations-to-d1.ts') ||
                     process.argv[1]?.includes('load-locations-to-d1')

if (isMainModule) {
  main().catch(console.error)
}


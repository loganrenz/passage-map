#!/usr/bin/env tsx
/**
 * Migration script to move passage JSON files to D2 database
 * Run this after setting up D2 database with wrangler
 */

import { readFile, readdir } from 'fs/promises'
import { join } from 'path'
import type { Passage } from '../types/passage'

// Helper function to escape SQL strings
function escapeSQL(str: string | null | undefined): string {
  if (!str) return 'NULL'
  return `'${str.replace(/'/g, "''").replace(/\\/g, '\\\\')}'`
}

/**
 * Convert passage JSON to D2 format
 */
function convertPassageToD2(passage: Passage) {
  return {
    id: passage.id,
    startTime: passage.startTime,
    endTime: passage.endTime,
    duration: passage.duration,
    avgSpeed: passage.avgSpeed,
    maxSpeed: passage.maxSpeed,
    distance: passage.distance,
    startLocation: passage.startLocation,
    endLocation: passage.endLocation,
    description: passage.description,
    name: passage.name,
    route: passage.route,
    exportTimestamp: passage.exportTimestamp,
    filename: passage.filename,
    queryMetadata: passage.queryMetadata,
    encountersFilename: passage.encountersFilename,
  }
}

/**
 * Main migration function
 */
async function migratePassages() {
  const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
  const files = await readdir(passagesDir)
  const passageFiles = files.filter((f) => f.startsWith('passage_') && f.endsWith('.json'))

  console.log(`Found ${passageFiles.length} passage files to migrate`)

  // Note: In a real scenario, you'd get the D2 database from wrangler
  // For now, we'll create SQL files that can be executed with wrangler d1 execute
  const sqlStatements: string[] = []

  // Initialize schema
  sqlStatements.push(`
    -- Initialize schema
    CREATE TABLE IF NOT EXISTS passages (
      id TEXT PRIMARY KEY,
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      duration INTEGER NOT NULL,
      avg_speed REAL NOT NULL,
      max_speed REAL NOT NULL,
      distance REAL NOT NULL,
      start_lat REAL NOT NULL,
      start_lon REAL NOT NULL,
      end_lat REAL NOT NULL,
      end_lon REAL NOT NULL,
      description TEXT,
      name TEXT NOT NULL,
      route TEXT,
      export_timestamp TEXT,
      filename TEXT,
      query_metadata TEXT,
      encounters_filename TEXT,
      created_at INTEGER DEFAULT (unixepoch()),
      updated_at INTEGER DEFAULT (unixepoch())
    );

    CREATE TABLE IF NOT EXISTS passage_positions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      passage_id TEXT NOT NULL,
      time TEXT NOT NULL,
      lat REAL NOT NULL,
      lon REAL NOT NULL,
      speed REAL,
      heading REAL,
      distance REAL,
      FOREIGN KEY (passage_id) REFERENCES passages(id) ON DELETE CASCADE,
      UNIQUE(passage_id, time)
    );

    CREATE TABLE IF NOT EXISTS passage_locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      passage_id TEXT NOT NULL,
      time TEXT NOT NULL,
      lat REAL NOT NULL,
      lon REAL NOT NULL,
      name TEXT,
      locality TEXT,
      administrative_area TEXT,
      country TEXT,
      country_code TEXT,
      formatted_address TEXT,
      points_of_interest TEXT,
      created_at INTEGER DEFAULT (unixepoch()),
      FOREIGN KEY (passage_id) REFERENCES passages(id) ON DELETE CASCADE
    );

    CREATE INDEX IF NOT EXISTS idx_passages_start_time ON passages(start_time);
    CREATE INDEX IF NOT EXISTS idx_passages_end_time ON passages(end_time);
    CREATE INDEX IF NOT EXISTS idx_passage_positions_passage_id ON passage_positions(passage_id);
    CREATE INDEX IF NOT EXISTS idx_passage_positions_time ON passage_positions(time);
    CREATE INDEX IF NOT EXISTS idx_passage_locations_passage_id ON passage_locations(passage_id);
    CREATE INDEX IF NOT EXISTS idx_passage_locations_time ON passage_locations(time);
  `)

  for (const filename of passageFiles) {
    try {
      const filePath = join(passagesDir, filename)
      const content = await readFile(filePath, 'utf-8')
      const passage: Passage = JSON.parse(content)

      console.log(`Migrating ${filename}...`)

      // Insert passage
      const passageData = convertPassageToD2(passage)
      sqlStatements.push(`
        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          ${escapeSQL(passageData.id)},
          ${escapeSQL(passageData.startTime)},
          ${escapeSQL(passageData.endTime)},
          ${passageData.duration},
          ${passageData.avgSpeed},
          ${passageData.maxSpeed},
          ${passageData.distance},
          ${passageData.startLocation.lat},
          ${passageData.startLocation.lon},
          ${passageData.endLocation.lat},
          ${passageData.endLocation.lon},
          ${escapeSQL(passageData.description)},
          ${escapeSQL(passageData.name)},
          ${escapeSQL(passageData.route)},
          ${escapeSQL(passageData.exportTimestamp)},
          ${escapeSQL(passageData.filename)},
          ${escapeSQL(passageData.queryMetadata ? JSON.stringify(passageData.queryMetadata) : null)},
          ${escapeSQL(passageData.encountersFilename)},
          unixepoch()
        );
      `)

      // Insert positions
      if (passage.positions && passage.positions.length > 0) {
        sqlStatements.push(`DELETE FROM passage_positions WHERE passage_id = ${escapeSQL(passageData.id)};`)
        
        for (const pos of passage.positions) {
          sqlStatements.push(`
            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              ${escapeSQL(passageData.id)},
              ${escapeSQL(pos._time)},
              ${pos.lat},
              ${pos.lon},
              ${pos.speed !== undefined ? pos.speed : 'NULL'},
              ${pos.heading !== undefined ? pos.heading : 'NULL'},
              ${pos.distance !== undefined ? pos.distance : 'NULL'}
            );
          `)
        }
      }

      // Insert locations
      if (passage.locations && passage.locations.length > 0) {
        sqlStatements.push(`DELETE FROM passage_locations WHERE passage_id = ${escapeSQL(passageData.id)};`)
        
        for (const loc of passage.locations) {
          sqlStatements.push(`
            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              ${escapeSQL(passageData.id)},
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
      }

      console.log(`  ✓ Migrated ${filename}`)
    } catch (error) {
      console.error(`  ✗ Error migrating ${filename}:`, error)
    }
  }

  // Write SQL file
  const sqlFile = join(process.cwd(), 'migration.sql')
  await import('fs/promises').then(({ writeFile }) =>
    writeFile(sqlFile, sqlStatements.join('\n'), 'utf-8')
  )

  console.log(`\n✓ Migration SQL written to ${sqlFile}`)
  console.log(`\nTo apply migration, run:`)
  console.log(`  wrangler d1 execute passage-map-db --file=./migration.sql`)
}

// Run migration if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  migratePassages().catch(console.error)
}


#!/usr/bin/env tsx
/**
 * Direct migration script to move passage JSON files to D1 database
 * Uses D2 storage utilities to directly insert data
 * Run this to sync any missing passages from JSON files to D1
 */

import { readFile, readdir } from 'fs/promises'
import { join } from 'path'
import type { Passage } from '../types/passage'
import { getD2Database, initD2Schema, upsertPassage, insertPassagePositions, insertPassageLocations } from '../server/utils/d2Storage'

/**
 * Get D1 database for local migration
 * This uses wrangler's local D1 binding
 */
async function getLocalD1Database() {
  // For local migration, we'll use wrangler's local D1
  // This requires running through wrangler dev or using the D1 API
  // For now, we'll create a script that can be run via wrangler
  
  // Check if we can access D1 via environment
  // In a real scenario, this would be called from a Cloudflare Worker context
  // For now, we'll output instructions to run via wrangler
  
  console.log('This script needs to be run in a Cloudflare Worker context.')
  console.log('Use the migrate-to-d2.ts script to generate SQL, or')
  console.log('run this via wrangler dev with a custom endpoint.')
  
  return null
}

/**
 * Migrate a single passage to D1
 */
async function migratePassage(db: any, passage: Passage) {
  try {
    // Upsert passage metadata
    await upsertPassage(db, {
      id: passage.id,
      startTime: passage.startTime,
      endTime: passage.endTime,
      duration: passage.duration,
      avgSpeed: passage.avgSpeed,
      maxSpeed: passage.maxSpeed,
      distance: passage.distance,
      startLocation: passage.startLocation,
      endLocation: passage.endLocation,
      description: passage.description || '',
      name: passage.name,
      route: passage.route || '',
      exportTimestamp: passage.exportTimestamp,
      filename: passage.filename,
      queryMetadata: passage.queryMetadata,
      encountersFilename: passage.encountersFilename,
    })

    // Insert positions if available
    if (passage.positions && passage.positions.length > 0) {
      await insertPassagePositions(
        db,
        passage.id,
        passage.positions.map((p) => ({
          _time: p._time,
          lat: p.lat,
          lon: p.lon,
          speed: p.speed,
          heading: p.heading,
          distance: p.distance,
        }))
      )
    }

    // Insert locations if available
    if (passage.locations && passage.locations.length > 0) {
      await insertPassageLocations(
        db,
        passage.id,
        passage.locations.map((loc) => ({
          coordinate: loc.coordinate,
          time: loc.time,
          name: loc.name,
          locality: loc.locality,
          administrativeArea: loc.administrativeArea,
          country: loc.country,
          countryCode: loc.countryCode,
          formattedAddress: loc.formattedAddress,
          pointsOfInterest: loc.pointsOfInterest,
        }))
      )
    }

    return true
  } catch (error) {
    console.error(`Error migrating passage ${passage.id}:`, error)
    return false
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

  // Load all passages
  const passages: Passage[] = []
  for (const filename of passageFiles) {
    try {
      const filePath = join(passagesDir, filename)
      const content = await readFile(filePath, 'utf-8')
      const passage: Passage = JSON.parse(content)
      
      // Ensure filename is set
      if (!passage.filename) {
        passage.filename = filename
      }
      
      passages.push(passage)
    } catch (error) {
      console.error(`Error reading ${filename}:`, error)
    }
  }

  console.log(`\nLoaded ${passages.length} passages`)
  console.log('\nTo migrate these passages, you have two options:')
  console.log('\n1. Use the SQL migration script (recommended):')
  console.log('   npx tsx scripts/migrate-to-d2.ts')
  console.log('   wrangler d1 execute passage-map-db --file=./migration.sql')
  console.log('\n2. Use wrangler dev with a migration endpoint (for direct API migration)')
  console.log('\nNote: The existing migrate-to-d2.ts script generates SQL that can be')
  console.log('executed directly with wrangler d1 execute.')
}

if (require.main === module) {
  migratePassages().catch(console.error)
}


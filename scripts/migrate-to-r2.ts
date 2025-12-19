#!/usr/bin/env tsx
/**
 * Migration script to upload existing filesystem data to Cloudflare R2
 * 
 * Usage: npx tsx scripts/migrate-to-r2.ts
 */

import { readdir, readFile } from 'fs/promises'
import { join } from 'path'
import { execSync } from 'child_process'

const PASSAGES_DIR = join(process.cwd(), 'public', 'data', 'passages')
const VESSEL_DATA_DIR = join(process.cwd(), 'public', 'data', 'passages_vessel_data')

const PASSAGES_BUCKET = 'passage-map-passages'
const VESSEL_DATA_BUCKET = 'passage-map-vessel-data'
const QUERIES_BUCKET = 'passage-map-queries'

/**
 * Upload a file to R2 using wrangler
 */
function uploadToR2(bucket: string, key: string, filePath: string): void {
  try {
    console.log(`Uploading ${key} to ${bucket}...`)
    execSync(
      `npx wrangler r2 object put ${bucket}/${key} --file="${filePath}" --remote`,
      { stdio: 'inherit' }
    )
    console.log(`✓ Uploaded ${key}`)
  } catch (error) {
    console.error(`✗ Failed to upload ${key}:`, error)
    throw error
  }
}

/**
 * Migrate passage files
 */
async function migratePassages(): Promise<void> {
  console.log('\n📦 Migrating passage files...')
  
  const files = await readdir(PASSAGES_DIR)
  const passageFiles = files.filter(
    (file) => file.startsWith('passage_') && file.endsWith('.json')
  )

  console.log(`Found ${passageFiles.length} passage files`)

  for (const filename of passageFiles) {
    const filePath = join(PASSAGES_DIR, filename)
    uploadToR2(PASSAGES_BUCKET, filename, filePath)
  }

  console.log(`✓ Migrated ${passageFiles.length} passage files`)
}

/**
 * Migrate vessel data files
 */
async function migrateVesselData(): Promise<void> {
  console.log('\n🚢 Migrating vessel data files...')
  
  const files = await readdir(VESSEL_DATA_DIR)
  const vesselFiles = files.filter((file) => file.endsWith('.json'))

  console.log(`Found ${vesselFiles.length} vessel data files`)

  for (const filename of vesselFiles) {
    const filePath = join(VESSEL_DATA_DIR, filename)
    uploadToR2(VESSEL_DATA_BUCKET, filename, filePath)
  }

  console.log(`✓ Migrated ${vesselFiles.length} vessel data files`)
}

/**
 * Migrate queries if they exist
 */
async function migrateQueries(): Promise<void> {
  console.log('\n📝 Checking for queries...')
  
  const queriesFile = join(PASSAGES_DIR, 'queries.json')
  
  try {
    await readFile(queriesFile, 'utf-8')
    console.log('Found queries.json')
    uploadToR2(QUERIES_BUCKET, 'queries.json', queriesFile)
    console.log('✓ Migrated queries.json')
  } catch (error) {
    console.log('No queries.json found (this is okay)')
  }
}

/**
 * Main migration function
 */
async function main(): Promise<void> {
  console.log('🚀 Starting R2 migration...\n')

  try {
    await migratePassages()
    await migrateVesselData()
    await migrateQueries()

    console.log('\n✅ Migration complete!')
    console.log('\nVerifying uploads...')
    
    // Verify bucket contents
    const passagesInfo = execSync(
      `npx wrangler r2 bucket info ${PASSAGES_BUCKET} --remote`,
      { encoding: 'utf-8' }
    )
    console.log('\n' + passagesInfo)

    const vesselInfo = execSync(
      `npx wrangler r2 bucket info ${VESSEL_DATA_BUCKET} --remote`,
      { encoding: 'utf-8' }
    )
    console.log(vesselInfo)

    const queriesInfo = execSync(
      `npx wrangler r2 bucket info ${QUERIES_BUCKET} --remote`,
      { encoding: 'utf-8' }
    )
    console.log(queriesInfo)

  } catch (error) {
    console.error('\n❌ Migration failed:', error)
    process.exit(1)
  }
}

main()


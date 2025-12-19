#!/usr/bin/env tsx
/**
 * Script to verify D1 database configuration
 * Checks if the D1 database exists, has data, and is properly configured
 */

import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

const DATABASE_ID = '6dae99e4-d07d-44f0-96a7-84a66a70ed6b'
const DATABASE_NAME = 'passage-map-db'
const BINDING_NAME = 'passage_map_db'

async function runCommand(command: string): Promise<{ stdout: string; stderr: string }> {
  try {
    return await execAsync(command)
  } catch (error: any) {
    return { stdout: error.stdout || '', stderr: error.stderr || '' }
  }
}

async function checkDatabaseExists(remote: boolean = false): Promise<boolean> {
  const flag = remote ? '--remote' : ''
  const { stdout } = await runCommand(
    `wrangler d1 execute ${DATABASE_NAME} ${flag} --command="SELECT 1 as test;" --json`
  )
  
  try {
    const result = JSON.parse(stdout)
    return result[0]?.success === true
  } catch {
    return false
  }
}

async function getPassageCount(remote: boolean = false): Promise<number> {
  const flag = remote ? '--remote' : ''
  const { stdout } = await runCommand(
    `wrangler d1 execute ${DATABASE_NAME} ${flag} --command="SELECT COUNT(*) as count FROM passages;" --json`
  )
  
  try {
    const result = JSON.parse(stdout)
    return result[0]?.results?.[0]?.count || 0
  } catch {
    return -1
  }
}

async function main() {
  console.log('🔍 Verifying D1 Database Configuration\n')
  console.log(`Database ID: ${DATABASE_ID}`)
  console.log(`Database Name: ${DATABASE_NAME}`)
  console.log(`Binding Name: ${BINDING_NAME}\n`)

  // Check local database
  console.log('📦 Checking LOCAL database...')
  const localExists = await checkDatabaseExists(false)
  if (localExists) {
    console.log('   ✅ Local database is accessible')
    const localCount = await getPassageCount(false)
    if (localCount >= 0) {
      console.log(`   ✅ Local database has ${localCount} passages`)
    } else {
      console.log('   ⚠️  Could not count passages in local database')
    }
  } else {
    console.log('   ❌ Local database is not accessible')
  }

  console.log('\n🌐 Checking REMOTE (production) database...')
  const remoteExists = await checkDatabaseExists(true)
  if (remoteExists) {
    console.log('   ✅ Remote database is accessible')
    const remoteCount = await getPassageCount(true)
    if (remoteCount >= 0) {
      console.log(`   ✅ Remote database has ${remoteCount} passages`)
      
      if (remoteCount === 0) {
        console.log('\n   ⚠️  WARNING: Remote database has no passages!')
        console.log('   You may need to migrate data to the remote database.')
      }
    } else {
      console.log('   ⚠️  Could not count passages in remote database')
    }
  } else {
    console.log('   ❌ Remote database is not accessible')
    console.log('   This might indicate:')
    console.log('   - Database does not exist')
    console.log('   - Authentication issue (run: wrangler login)')
    console.log('   - Wrong database ID')
  }

  // Check if this is a Vercel deployment
  const isVercel = !!process.env.VERCEL || !!process.env.VERCEL_URL
  
  if (isVercel) {
    console.log('\n📋 Vercel Deployment Detected:')
    console.log('   Vercel cannot directly access D1 bindings.')
    console.log('   You need to use the D2 API Worker:')
    console.log('')
    console.log('   1. Deploy D2 API Worker:')
    console.log('      cd workers/d2-api')
    console.log('      wrangler deploy')
    console.log('')
    console.log('   2. Set D2_API_URL in Vercel:')
    console.log('      - Go to: https://vercel.com/dashboard')
    console.log('      - Your Project → Settings → Environment Variables')
    console.log('      - Add: D2_API_URL = https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev')
    console.log('')
    console.log('   3. Redeploy your Vercel project')
    console.log('')
    console.log('   See docs/FIX_PRODUCTION_D1.md for detailed instructions')
  } else {
    console.log('\n📋 Cloudflare Pages Configuration:')
    console.log('   To link D1 database in Cloudflare Pages:')
    console.log('   1. Go to: https://dash.cloudflare.com/')
    console.log('   2. Navigate to: Workers & Pages → Your Project → Settings')
    console.log('   3. Go to: Functions → D1 Database bindings')
    console.log('   4. Add binding:')
    console.log(`      - Variable name: ${BINDING_NAME}`)
    console.log(`      - D1 database: ${DATABASE_NAME} (${DATABASE_ID})`)
    console.log('   5. Save and redeploy your project')
  }

  console.log('\n📋 Wrangler Configuration:')
  console.log('   Your wrangler.toml should have:')
  console.log(`   [[d1_databases]]`)
  console.log(`   binding = "${BINDING_NAME}"`)
  console.log(`   database_name = "${DATABASE_NAME}"`)
  console.log(`   database_id = "${DATABASE_ID}"`)

  console.log('\n✅ Verification complete!')
}

main().catch(console.error)


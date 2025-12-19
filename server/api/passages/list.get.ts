import type { Passage } from '~/types/passage'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'
import { getD2Database, listPassages } from '~/server/utils/d2Storage'
import { getD2ApiClient } from '~/server/utils/d2ApiClient'

export default defineEventHandler(async (event) => {
  try {
    const env = getCloudflareEnv(event)
    const config = useRuntimeConfig(event)
    
    // Try to get passages from D1 first (preferred)
    // Priority: Direct D1 bindings > D2 API client > Filesystem storage
    let passages: Passage[] = []
    
    // Try direct D1 access first (for Cloudflare Workers/Pages with bindings)
    const db = getD2Database(env)
    if (db) {
      try {
        console.log('✅ Using D1 database (direct bindings) to list passages')
        const d2Passages = await listPassages(db, 1000, 0)
        console.log(`✅ Successfully fetched ${d2Passages.length} passages from D1`)
        passages = d2Passages.map((p: any) => ({
          id: p.id,
          startTime: p.start_time,
          endTime: p.end_time,
          duration: p.duration,
          avgSpeed: p.avg_speed,
          maxSpeed: p.max_speed,
          distance: p.distance,
          startLocation: {
            lat: p.start_lat,
            lon: p.start_lon,
          },
          endLocation: {
            lat: p.end_lat,
            lon: p.end_lon,
          },
          description: p.description || '',
          name: p.name,
          route: p.route || '',
          exportTimestamp: p.export_timestamp || undefined,
          filename: p.filename || undefined,
          queryMetadata: p.query_metadata ? JSON.parse(p.query_metadata) : undefined,
          encountersFilename: p.encounters_filename || undefined,
        }))
      } catch (error: any) {
        console.error('❌ Error fetching from D1 (direct bindings):', error)
        console.error('   Error message:', error?.message)
        console.error('   Error stack:', error?.stack)
        // Fall through to API client or storage
      }
    } else {
      // Log diagnostic information when D1 binding is not found
      console.warn('⚠️  D1 database binding not found')
      console.warn('   Available env keys:', Object.keys(env || {}))
      if ((env as any)?.cloudflare?.env) {
        console.warn('   Cloudflare env keys:', Object.keys((env as any).cloudflare.env))
      }
      console.warn('   NODE_ENV:', process.env.NODE_ENV)
      console.warn('   VERCEL:', process.env.VERCEL)
    }
    
    // If direct D2 didn't work, try D2 API client (for Vercel/external access)
    if (passages.length === 0) {
      // Always log in production to help diagnose
      console.log('🔍 Attempting to use D2 API client...')
      console.log(`   process.env.D2_API_URL: ${process.env.D2_API_URL ? 'set (hidden)' : 'NOT SET'}`)
      console.log(`   config.d2ApiUrl: ${config.d2ApiUrl || 'not set'}`)
      console.log(`   config keys: ${Object.keys(config).join(', ')}`)
      
      const d2Client = getD2ApiClient()
      if (d2Client) {
        try {
          if (process.env.NODE_ENV !== 'production') {
            console.log('Using D2 API client to list passages')
            const apiUrl = process.env.D2_API_URL || config.d2ApiUrl || 'not set'
            console.log(`D2_API_URL: ${apiUrl}`)
            
            // Try health check first to verify worker is accessible
            try {
              const health = await d2Client.healthCheck()
              console.log(`✅ D2 API worker health check: ${JSON.stringify(health)}`)
            } catch (healthError) {
              console.warn('⚠️  D2 API worker health check failed:', healthError)
              console.warn('   This might mean the D2 API worker is not running or not accessible')
            }
          }
          const d2Passages = await d2Client.listPassages(1000, 0)
          passages = d2Passages.map((p: any) => ({
            id: p.id,
            startTime: p.start_time,
            endTime: p.end_time,
            duration: p.duration,
            avgSpeed: p.avg_speed,
            maxSpeed: p.max_speed,
            distance: p.distance,
            startLocation: {
              lat: p.start_lat,
              lon: p.start_lon,
            },
            endLocation: {
              lat: p.end_lat,
              lon: p.end_lon,
            },
            description: p.description || '',
            name: p.name,
            route: p.route || '',
            exportTimestamp: p.export_timestamp || undefined,
            filename: p.filename || undefined,
            queryMetadata: p.query_metadata ? JSON.parse(p.query_metadata) : undefined,
            encountersFilename: p.encounters_filename || undefined,
          }))
        } catch (error) {
          console.warn('Error fetching from D2 API:', error)
          // Fall through to storage
        }
      }
    }
    
    // D1 is primary - if we don't have passages from D1, provide helpful error
    if (passages.length === 0) {
      const isProduction = process.env.NODE_ENV === 'production'
      const isVercel = !!process.env.VERCEL
      
      if (isProduction && !isVercel) {
        // Cloudflare Pages production
        console.error('❌ D1 database binding not found in Cloudflare Pages production')
        console.error('   Database ID: 6dae99e4-d07d-44f0-96a7-84a66a70ed6b')
        console.error('   Database name: passage-map-db')
        console.error('   Binding name: passage_map_db')
        console.error('')
        console.error('   To fix this:')
        console.error('   1. Go to Cloudflare Dashboard → Pages → Your Project → Settings')
        console.error('   2. Navigate to "Functions" → "D1 Database bindings"')
        console.error('   3. Add binding:')
        console.error('      - Variable name: passage_map_db')
        console.error('      - D1 database: passage-map-db (6dae99e4-d07d-44f0-96a7-84a66a70ed6b)')
        console.error('   4. Redeploy your Pages project')
        console.error('')
        console.error('   Or use wrangler to link:')
        console.error('   wrangler pages project list')
        console.error('   wrangler pages deployment tail')
      } else if (isVercel) {
        // Vercel deployment - use D2 API
        console.error('❌ D1 database not available on Vercel')
        console.error('   Vercel deployments must use the D2 API worker')
        console.error('   Steps to fix:')
        console.error('   1. Deploy D2 API worker: cd workers/d2-api && wrangler deploy')
        console.error('   2. Set D2_API_URL in Vercel: Settings → Environment Variables')
        console.error('      Value: https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev')
        console.error('   3. Redeploy your Vercel project')
        console.error('   See docs/FIX_PRODUCTION_D1.md for detailed instructions')
      } else {
        // Local development
        console.error('❌ D1 database is not available in local development.')
        console.error('   Options:')
        console.error('   1. Set D2_API_URL environment variable to use the D2 API worker')
        console.error('      Example: export D2_API_URL="http://localhost:8787"')
        console.error('      Then run: cd workers/d2-api && npm run d2:api:dev')
        console.error('   2. Use npm run dev:wrangler to run with D1 bindings via wrangler')
        console.error('      (Note: requires building first with npm run build)')
      }
      
      throw createError({
        statusCode: 503,
        statusMessage: isProduction && !isVercel
          ? 'D1 database binding not configured in Cloudflare Pages. Please link the D1 database in Pages settings.'
          : 'D1 database is not available. For local dev, set D2_API_URL or use npm run dev:wrangler',
      })
    }
    
    return passages
  } catch (error) {
    console.error('Error listing passages:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to list passages',
    })
  }
})


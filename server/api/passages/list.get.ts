import type { Passage } from '~/types/passage'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'
import { getD2Database, listPassages } from '~/server/utils/d2Storage'
import { getD2ApiClient } from '~/server/utils/d2ApiClient'

export default defineEventHandler(async (event) => {
  try {
    const env = getCloudflareEnv(event)
    const config = useRuntimeConfig(event)
    
    // Try to get passages from D2 first (preferred)
    // Priority: Direct D2 bindings > D2 API client > Filesystem storage
    let passages: Passage[] = []
    
    // Try direct D2 access first (for Cloudflare Workers/local with bindings)
    const db = getD2Database(env)
    if (db) {
      try {
        if (process.env.NODE_ENV !== 'production') {
          console.log('Using D2 database (direct bindings) to list passages')
        }
        const d2Passages = await listPassages(db, 1000, 0)
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
        console.warn('Error fetching from D2 (direct bindings):', error)
        // Fall through to API client or storage
      }
    }
    
    // If direct D2 didn't work, try D2 API client (for Vercel/external access)
    if (passages.length === 0) {
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
      if (process.env.NODE_ENV !== 'production') {
        console.error('D1 database is not available in local development.')
        console.error('Options:')
        console.error('1. Set D2_API_URL environment variable to use the D2 API worker')
        console.error('   Example: export D2_API_URL="http://localhost:8787"')
        console.error('   Then run: cd workers/d2-api && npm run d2:api:dev')
        console.error('2. Use npm run dev:wrangler to run with D1 bindings via wrangler')
        console.error('   (Note: requires building first with npm run build)')
      }
      
      throw createError({
        statusCode: 503,
        statusMessage: 'D1 database is not available. For local dev, set D2_API_URL or use npm run dev:wrangler',
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


import type { Passage, LocationInfo } from '~/types/passage'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'
import { getD2Database } from '~/server/utils/d2Storage'
import { getD2ApiClient } from '~/server/utils/d2ApiClient'

export default defineEventHandler(async (event) => {
  const passageId = getRouterParam(event, 'id')
  
  if (!passageId) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Passage ID is required',
    })
  }

  try {
    const env = getCloudflareEnv(event)

    // D1 is primary - try to get passage from D1
    // Priority: Direct D2 bindings > D2 API client
    let passage: Passage | null = null
    let locations: LocationInfo[] | undefined = undefined

    // Try direct D2 access first (for Cloudflare Workers/local with bindings)
    const db = getD2Database(env)
    if (db) {
      try {
        if (process.env.NODE_ENV !== 'production') {
          console.log('Using D2 database (direct bindings) to get passage')
        }
        const { getPassage } = await import('~/server/utils/d2Storage')
        const d1Data = await getPassage(db, passageId)
        if (d1Data && d1Data.passage) {
          const d1Passage = d1Data.passage
          passage = {
            id: d1Passage.id,
            startTime: d1Passage.start_time,
            endTime: d1Passage.end_time,
            duration: d1Passage.duration,
            avgSpeed: d1Passage.avg_speed,
            maxSpeed: d1Passage.max_speed,
            distance: d1Passage.distance,
            startLocation: {
              lat: d1Passage.start_lat,
              lon: d1Passage.start_lon,
            },
            endLocation: {
              lat: d1Passage.end_lat,
              lon: d1Passage.end_lon,
            },
            description: d1Passage.description || '',
            name: d1Passage.name,
            route: d1Passage.route || '',
            exportTimestamp: d1Passage.export_timestamp || undefined,
            filename: d1Passage.filename || undefined,
            queryMetadata: d1Passage.query_metadata ? JSON.parse(d1Passage.query_metadata) : undefined,
            encountersFilename: d1Passage.encounters_filename || undefined,
            positions: d1Data.positions?.map((p: any) => ({
              _time: p.time,
              lat: p.lat,
              lon: p.lon,
              speed: p.speed || undefined,
              heading: p.heading || undefined,
              distance: p.distance || undefined,
            })),
          }

          // Convert D1 locations to LocationInfo format
          if (d1Data.locations && d1Data.locations.length > 0) {
            locations = d1Data.locations.map((loc: any) => ({
              coordinate: { lat: loc.lat, lon: loc.lon },
              time: loc.time,
              name: loc.name || undefined,
              locality: loc.locality || undefined,
              administrativeArea: loc.administrative_area || undefined,
              country: loc.country || undefined,
              countryCode: loc.country_code || undefined,
              formattedAddress: loc.formatted_address || undefined,
              pointsOfInterest: loc.points_of_interest && loc.points_of_interest !== 'null' ? JSON.parse(loc.points_of_interest) : undefined,
            }))
          }
        }
      } catch (error) {
        console.warn('Error fetching from D2 (direct bindings):', error)
        // Fall through to API client or storage
      }
    }
    
    // If direct D2 didn't work, try D2 API client (for Vercel/external access)
    if (!passage) {
      const d2Client = getD2ApiClient()
      if (d2Client) {
        try {
          if (process.env.NODE_ENV !== 'production') {
            console.log('Using D2 API client to get passage')
          }
          const d1Data = await d2Client.getPassage(passageId)
          if (d1Data && d1Data.passage) {
            // Convert D1 row to Passage format
            const d1Passage = d1Data.passage
            passage = {
              id: d1Passage.id,
              startTime: d1Passage.start_time,
              endTime: d1Passage.end_time,
              duration: d1Passage.duration,
              avgSpeed: d1Passage.avg_speed,
              maxSpeed: d1Passage.max_speed,
              distance: d1Passage.distance,
              startLocation: {
                lat: d1Passage.start_lat,
                lon: d1Passage.start_lon,
              },
              endLocation: {
                lat: d1Passage.end_lat,
                lon: d1Passage.end_lon,
              },
              description: d1Passage.description || '',
              name: d1Passage.name,
              route: d1Passage.route || '',
              exportTimestamp: d1Passage.export_timestamp || undefined,
              filename: d1Passage.filename || undefined,
              queryMetadata: d1Passage.query_metadata ? JSON.parse(d1Passage.query_metadata) : undefined,
              encountersFilename: d1Passage.encounters_filename || undefined,
              positions: d1Data.positions?.map((p: any) => ({
                _time: p.time,
                lat: p.lat,
                lon: p.lon,
                speed: p.speed || undefined,
                heading: p.heading || undefined,
                distance: p.distance || undefined,
              })),
            }

            // Convert D1 locations to LocationInfo format
            if (d1Data.locations && d1Data.locations.length > 0) {
              locations = d1Data.locations.map((loc: any) => ({
                coordinate: { lat: loc.lat, lon: loc.lon },
                time: loc.time,
                name: loc.name || undefined,
                locality: loc.locality || undefined,
                administrativeArea: loc.administrative_area || undefined,
                country: loc.country || undefined,
                countryCode: loc.country_code || undefined,
                formattedAddress: loc.formatted_address || undefined,
                pointsOfInterest: loc.points_of_interest && loc.points_of_interest !== 'null' ? JSON.parse(loc.points_of_interest) : undefined,
              }))
            }
          }
        } catch (error) {
          console.warn('Error fetching from D2 API:', error)
          // Fall through to storage
        }
      }
    }

    // D1 is primary - if passage not found, that's an error
    if (!passage) {
      throw createError({
        statusCode: 404,
        statusMessage: 'Passage not found in D1 database',
      })
    }

    // Add locations if we have them
    if (locations && locations.length > 0) {
      passage.locations = locations
    }

    return passage
  } catch (error: any) {
    console.error('Error fetching passage:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.message || 'Failed to fetch passage',
    })
  }
})


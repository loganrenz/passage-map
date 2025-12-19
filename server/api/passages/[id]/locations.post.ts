import type { LocationInfo } from '~/types/passage'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'
import { getD2Database } from '~/server/utils/d2Storage'
import { getD2ApiClient } from '~/server/utils/d2ApiClient'
import { insertPassageLocations } from '~/server/utils/d2Storage'

export default defineEventHandler(async (event) => {
  const passageId = getRouterParam(event, 'id')
  
  if (!passageId) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Passage ID is required',
    })
  }

  const body = await readBody(event)
  const locations: LocationInfo[] = body.locations

  if (!Array.isArray(locations)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Locations must be an array',
    })
  }

  try {
    const env = getCloudflareEnv(event)

    // Try D1 API client (for Vercel)
    const d2Client = getD2ApiClient()
    if (d2Client) {
      // Convert locations to format expected by API
      const locationData = locations.map((loc) => ({
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

      // First delete existing locations
      await d2Client.query('DELETE FROM passage_locations WHERE passage_id = ?', [passageId])

      // Insert locations one by one (D1 API client batch expects specific format)
      // We'll insert in smaller batches to avoid overwhelming the API
      const batchSize = 20
      for (let i = 0; i < locationData.length; i += batchSize) {
        const batch = locationData.slice(i, i + batchSize)
        const queries = batch.map((loc) => ({
          query: `INSERT INTO passage_locations (passage_id, time, lat, lon, name, locality, administrative_area, country, country_code, formatted_address, points_of_interest) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          params: [
            passageId,
            loc.time,
            loc.coordinate.lat,
            loc.coordinate.lon,
            loc.name || null,
            loc.locality || null,
            loc.administrativeArea || null,
            loc.country || null,
            loc.countryCode || null,
            loc.formattedAddress || null,
            loc.pointsOfInterest ? JSON.stringify(loc.pointsOfInterest) : null,
          ],
        }))
        await d2Client.batch(queries)
      }

      return { success: true, count: locations.length }
    } else {
      // Try direct D1 access (for Cloudflare Workers)
      const db = getD2Database(env)
      if (db) {
        await insertPassageLocations(db, passageId, locations)
        return { success: true, count: locations.length }
      }
    }

    // If D1 is not available, just return success (locations are already in JSON)
    return { success: true, count: locations.length, note: 'D1 not available, locations saved to JSON only' }
  } catch (error: any) {
    console.error('Error saving locations to D1:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.message || 'Failed to save locations to D1',
    })
  }
})


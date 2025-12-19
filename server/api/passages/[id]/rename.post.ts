import type { Passage } from '~/types/passage'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'
import { getD2Database } from '~/server/utils/d2Storage'
import { getD2ApiClient } from '~/server/utils/d2ApiClient'
import { getPassage, updatePassageName } from '~/server/utils/d2Storage'
import { reverseGeocode, generatePassageName } from '~/server/utils/geocoding'

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
    
    // Get passage from D2
    let passage: Passage | null = null
    let db: ReturnType<typeof getD2Database> = null

    // Try direct D2 access first
    db = getD2Database(env)
    if (db) {
      try {
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
          }

          // Check if we have location data already
          if (d1Data.locations && d1Data.locations.length > 0) {
            const sortedLocations = d1Data.locations.sort((a: any, b: any) => 
              Date.parse(a.time) - Date.parse(b.time)
            )
            const startLocation = sortedLocations[0]
            const endLocation = sortedLocations[sortedLocations.length - 1]

            if (startLocation && endLocation) {
              // Use existing location data
              const startGeocode = {
                name: startLocation.name || undefined,
                locality: startLocation.locality || undefined,
                administrativeArea: startLocation.administrative_area || undefined,
                country: startLocation.country || undefined,
                countryCode: startLocation.country_code || undefined,
                formattedAddress: startLocation.formatted_address || undefined,
              }
              const endGeocode = {
                name: endLocation.name || undefined,
                locality: endLocation.locality || undefined,
                administrativeArea: endLocation.administrative_area || undefined,
                country: endLocation.country || undefined,
                countryCode: endLocation.country_code || undefined,
                formattedAddress: endLocation.formatted_address || undefined,
              }

              const newName = generatePassageName(startGeocode, endGeocode, passage.name)
              
              if (db) {
                await updatePassageName(db, passageId, newName)
              } else {
                throw createError({
                  statusCode: 500,
                  statusMessage: 'Database not available',
                })
              }

              return {
                success: true,
                passageId,
                oldName: passage.name,
                newName,
              }
            }
          }
        }
      } catch (error) {
        console.warn('Error fetching from D2 (direct bindings):', error)
      }
    }

    // If not found in direct D2, try D2 API client
    if (!passage) {
      const d2Client = getD2ApiClient()
      if (d2Client) {
        try {
          const d1Data = await d2Client.getPassage(passageId)
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
            }

            // Check for existing locations
            if (d1Data.locations && d1Data.locations.length > 0) {
              const sortedLocations = d1Data.locations.sort((a: any, b: any) => 
                Date.parse(a.time) - Date.parse(b.time)
              )
              const startLocation = sortedLocations[0]
              const endLocation = sortedLocations[sortedLocations.length - 1]

              if (startLocation && endLocation) {
                const startGeocode = {
                  name: startLocation.name || undefined,
                  locality: startLocation.locality || undefined,
                  administrativeArea: startLocation.administrative_area || undefined,
                  country: startLocation.country || undefined,
                  countryCode: startLocation.country_code || undefined,
                  formattedAddress: startLocation.formatted_address || undefined,
                }
                const endGeocode = {
                  name: endLocation.name || undefined,
                  locality: endLocation.locality || undefined,
                  administrativeArea: endLocation.administrative_area || undefined,
                  country: endLocation.country || undefined,
                  countryCode: endLocation.country_code || undefined,
                  formattedAddress: endLocation.formatted_address || undefined,
                }

                const newName = generatePassageName(startGeocode, endGeocode, passage.name)
                
                // Update via D2 API client using query method
                await d2Client.query(
                  'UPDATE passages SET name = ?, updated_at = unixepoch() WHERE id = ?',
                  [newName, passageId]
                )

                return {
                  success: true,
                  passageId,
                  oldName: passage.name,
                  newName,
                }
              }
            }
          }
        } catch (error: any) {
          if (error.statusCode) {
            throw error
          }
          console.warn('Error fetching from D2 API:', error)
        }
      }
    }

    if (!passage) {
      throw createError({
        statusCode: 404,
        statusMessage: 'Passage not found',
      })
    }

    // If we don't have location data, geocode start and end locations
    // Apple Maps Server API can handle parallel requests
    const [startGeocode, endGeocode] = await Promise.all([
      reverseGeocode(passage.startLocation.lat, passage.startLocation.lon),
      reverseGeocode(passage.endLocation.lat, passage.endLocation.lon),
    ])

    const newName = generatePassageName(startGeocode, endGeocode, passage.name)

    // Update passage name in D2
    if (db) {
      await updatePassageName(db, passageId, newName)
    } else {
      // Try D2 API client as fallback
      const d2Client = getD2ApiClient()
      if (d2Client) {
        await d2Client.query(
          'UPDATE passages SET name = ?, updated_at = unixepoch() WHERE id = ?',
          [newName, passageId]
        )
      } else {
        throw createError({
          statusCode: 500,
          statusMessage: 'Database not available for update',
        })
      }
    }

    return {
      success: true,
      passageId,
      oldName: passage.name,
      newName,
      startLocation: startGeocode,
      endLocation: endGeocode,
    }
  } catch (error: any) {
    console.error('Error renaming passage:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.message || 'Failed to rename passage',
    })
  }
})


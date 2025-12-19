import { getInfluxDBConfig, executeQuery } from '~/server/utils/influxClient'
import {
  buildPassagePositionQuery,
  buildPassageSpeedQuery,
  type PassageQueryParams,
  validateQuery,
} from '~/server/utils/influxQueries'
import {
  transformToPassage,
  parseInfluxResults,
} from '~/server/utils/passageTransformer'
import { addQuery } from '~/server/utils/queryRegistry'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'
import { getD2Database, upsertPassage, insertPassagePositions } from '~/server/utils/d2Storage'
import { getD2ApiClient } from '~/server/utils/d2ApiClient'
import type { Passage } from '~/types/passage'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const influxConfig = getInfluxDBConfig()
  
  // D1 is primary storage
  const env = getCloudflareEnv(event)
  const runtimeConfig = useRuntimeConfig(event)

  // Support both direct query string or query parameters
  let queryString: string | undefined
  let queryParams: PassageQueryParams | undefined
  let description: string | undefined

  if (body.query) {
    // Direct Flux query string
    const validation = validateQuery(body.query)
    if (!validation.valid) {
      throw createError({
        statusCode: 400,
        statusMessage: validation.error || 'Invalid query',
      })
    }
    queryString = body.query
    description = body.description || 'Custom Flux query'
  } else if (body.startTime && body.endTime) {
    // Query builder parameters
    queryParams = {
      startTime: body.startTime,
      endTime: body.endTime,
      measurement: body.measurement || 'navigation.position',
      resolution: body.resolution || 60,
      self: body.self !== false, // default true
    }
    description =
      body.description ||
      `Passage from ${queryParams.startTime} to ${queryParams.endTime}`
  } else {
    throw createError({
      statusCode: 400,
      statusMessage:
        'Either "query" (Flux query string) or "startTime" and "endTime" parameters are required',
    })
  }

  try {
    let positionResults: Array<Record<string, unknown>> = []
    let speedResults: Array<Record<string, unknown>> | undefined

    if (queryString) {
      // Execute custom query
      positionResults = await executeQuery(influxConfig, queryString)
    } else if (queryParams) {
      // Build and execute queries using query builder
      const positionQuery = buildPassagePositionQuery(influxConfig.bucket, queryParams)
      positionResults = await executeQuery(influxConfig, positionQuery)

      // Optionally get speed data
      if (body.includeSpeed !== false) {
        try {
          const speedQuery = buildPassageSpeedQuery(influxConfig.bucket, queryParams)
          speedResults = await executeQuery(influxConfig, speedQuery)
        } catch (error) {
          console.warn('Failed to fetch speed data:', error)
          // Continue without speed data
        }
      }
    }

    if (positionResults.length === 0) {
      throw createError({
        statusCode: 404,
        statusMessage: 'No data found for the specified query',
      })
    }

    // Parse and transform results
    const passageData = parseInfluxResults(positionResults, speedResults)
    const passage = transformToPassage(passageData, {
      id: body.passageId,
      name: body.name,
      description,
      startTime: queryParams?.startTime,
      endTime: queryParams?.endTime,
    })

    // Generate filename
    const timestamp = new Date(passage.startTime).getTime()
    const dateStr = new Date(passage.startTime).toISOString().split('T')[0]
    const filename = body.filename || `passage_${dateStr}_passage_${timestamp}.json`
    passage.filename = filename

    // Save passage to D1 (primary storage)
    const db = getD2Database(env)
    if (db) {
      // Use direct D1 bindings
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
    } else {
      // Fallback: Try D2 API client
      const d2Client = getD2ApiClient()
      if (!d2Client) {
        throw createError({
          statusCode: 503,
          statusMessage: 'D1 database is not available. Please ensure D1 is configured.',
        })
      }
      // Note: D2 API client doesn't have write methods yet
      // For now, throw error if direct bindings aren't available
      throw createError({
        statusCode: 503,
        statusMessage: 'D1 direct bindings required for writing passages. D2 API client write support not yet implemented.',
      })
    }

    // Store query in registry
    const queryMetadata = await addQuery({
      query: queryString || buildPassagePositionQuery(influxConfig.bucket, queryParams!),
      parameters: queryParams || {},
      passageId: passage.id,
      description,
      passageFilename: filename,
    }, env, {
      r2AccessKeyId: runtimeConfig.r2AccessKeyId,
      r2SecretAccessKey: runtimeConfig.r2SecretAccessKey,
    })

    // Add query metadata to passage
    passage.queryMetadata = {
      id: queryMetadata.id,
      query: queryMetadata.query,
      parameters: queryMetadata.parameters,
      timestamp: queryMetadata.timestamp,
      description: queryMetadata.description,
    }

    // Update the passage in D1 with query metadata
    if (db) {
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
    }

    return {
      success: true,
      passage,
      queryId: queryMetadata.id,
      message: `Passage generated successfully: ${filename}`,
    }
  } catch (error: any) {
    console.error('Error generating passage:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.message || 'Failed to generate passage',
    })
  }
})


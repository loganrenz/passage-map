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
import { getPassagesStorage } from '~/server/utils/storage'
import type { Passage } from '~/types/passage'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const config = getInfluxDBConfig()
  
  // Get storage adapter (R2 in production, filesystem in dev)
  const env = event.context.cloudflare?.env || {}
  const storage = getPassagesStorage(env)

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
      positionResults = await executeQuery(config, queryString)
    } else if (queryParams) {
      // Build and execute queries using query builder
      const positionQuery = buildPassagePositionQuery(config.bucket, queryParams)
      positionResults = await executeQuery(config, positionQuery)

      // Optionally get speed data
      if (body.includeSpeed !== false) {
        try {
          const speedQuery = buildPassageSpeedQuery(config.bucket, queryParams)
          speedResults = await executeQuery(config, speedQuery)
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

    // Save passage to storage (R2 or filesystem)
    await storage.writeJSON(filename, passage)

    // Store query in registry
    const queryMetadata = await addQuery({
      query: queryString || buildPassagePositionQuery(config.bucket, queryParams!),
      parameters: queryParams || {},
      passageId: passage.id,
      description,
      passageFilename: filename,
    }, env)

    // Add query metadata to passage
    passage.queryMetadata = {
      id: queryMetadata.id,
      query: queryMetadata.query,
      parameters: queryMetadata.parameters,
      timestamp: queryMetadata.timestamp,
      description: queryMetadata.description,
    }

    // Update the saved file with query metadata
    await storage.writeJSON(filename, passage)

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


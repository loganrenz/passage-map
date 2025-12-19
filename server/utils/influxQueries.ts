import { flux } from '@influxdata/influxdb-client'
import type { InfluxDBConfig } from './influxClient'
import { executeQuery, getInfluxDBConfig } from './influxClient'

export interface PassageQueryParams {
  startTime: string
  endTime: string
  measurement?: string
  resolution?: number // in seconds, default 60
  self?: boolean // filter by self tag, default true
}

/**
 * Build a Flux query to get position data for a passage
 */
export function buildPassagePositionQuery(
  bucket: string,
  params: PassageQueryParams
): string {
  const {
    startTime,
    endTime,
    measurement = 'navigation.position',
    resolution = 60,
    self = true,
  } = params

  let query = flux`
    from(bucket: ${bucket})
      |> range(start: ${startTime}, stop: ${endTime})
      |> filter(fn: (r) => r["_measurement"] == ${measurement})
  `

  if (self) {
    query = flux`${query}
      |> filter(fn: (r) => r["self"] == "t")`
  }

  query = flux`${query}
      |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
      |> filter(fn: (r) => exists r.lat and exists r.lon)
      |> aggregateWindow(every: ${String(resolution)}s, fn: first, createEmpty: false)
      |> yield(name: "positions")
  `

  return query.toString()
}

/**
 * Build a Flux query to get speed data for a passage
 */
export function buildPassageSpeedQuery(
  bucket: string,
  params: PassageQueryParams
): string {
  const {
    startTime,
    endTime,
    measurement = 'navigation.speedOverGround',
    resolution = 60,
    self = true,
  } = params

  let query = flux`
    from(bucket: ${bucket})
      |> range(start: ${startTime}, stop: ${endTime})
      |> filter(fn: (r) => r["_measurement"] == ${measurement})
  `

  if (self) {
    query = flux`${query}
      |> filter(fn: (r) => r["self"] == "t")`
  }

  query = flux`${query}
      |> aggregateWindow(every: ${String(resolution)}s, fn: mean, createEmpty: false)
      |> yield(name: "speed")
  `

  return query.toString()
}

/**
 * Build a query to explore available measurements and fields
 */
export function buildExploreQuery(
  bucket: string,
  startTime: string,
  endTime: string,
  limit: number = 100
): string {
  const query = flux`
    from(bucket: ${bucket})
      |> range(start: ${startTime}, stop: ${endTime})
      |> limit(n: ${String(limit)})
      |> yield(name: "explore")
  `

  return query.toString()
}

/**
 * Build a query to list all measurements in a bucket
 */
export function buildMeasurementsQuery(bucket: string): string {
  const query = flux`
    import "influxdata/influxdb/schema"
    schema.measurements(bucket: ${bucket})
  `

  return query.toString()
}

/**
 * Build a query to list all fields for a measurement
 */
export function buildFieldsQuery(
  bucket: string,
  measurement: string,
  startTime?: string,
  endTime?: string
): string {
  const range = startTime && endTime
    ? flux`|> range(start: ${startTime}, stop: ${endTime})`
    : flux`|> range(start: -30d)`

  const query = flux`
    import "influxdata/influxdb/schema"
    schema.fieldKeys(
      bucket: ${bucket},
      measurement: ${measurement}
    )
    ${range}
  `

  return query.toString()
}

/**
 * Build a query to list all tag keys for a measurement
 */
export function buildTagKeysQuery(
  bucket: string,
  measurement: string
): string {
  const query = flux`
    import "influxdata/influxdb/schema"
    schema.tagKeys(
      bucket: ${bucket},
      measurement: ${measurement}
    )
  `

  return query.toString()
}

/**
 * Explore InfluxDB schema - get measurements and their fields
 */
export async function exploreSchema(
  config?: InfluxDBConfig,
  startTime?: string,
  endTime?: string
): Promise<{
  measurements: Array<{
    name: string
    fields: string[]
    tagKeys: string[]
  }>
}> {
  const influxConfig = config || getInfluxDBConfig()
  const rangeStart = startTime || '-30d'
  const rangeEnd = endTime || 'now()'

  // Get all measurements
  const measurementsQuery = buildMeasurementsQuery(influxConfig.bucket)
  const measurementResults = await executeQuery(influxConfig, measurementsQuery)
  const measurementNames = measurementResults
    .map((r) => r._value as string)
    .filter((name) => name && typeof name === 'string')

  // For each measurement, get fields and tag keys
  const measurements = await Promise.all(
    measurementNames.map(async (name) => {
      try {
        const fieldsQuery = buildFieldsQuery(
          influxConfig.bucket,
          name,
          rangeStart,
          rangeEnd
        )
        const fieldsResults = await executeQuery(influxConfig, fieldsQuery)
        const fields = fieldsResults
          .map((r) => r._value as string)
          .filter((f) => f && typeof f === 'string')

        const tagKeysQuery = buildTagKeysQuery(influxConfig.bucket, name)
        const tagKeysResults = await executeQuery(influxConfig, tagKeysQuery)
        const tagKeys = tagKeysResults
          .map((r) => r._value as string)
          .filter((t) => t && typeof t === 'string')

        return {
          name,
          fields,
          tagKeys,
        }
      } catch (error) {
        console.error(`Error exploring measurement ${name}:`, error)
        return {
          name,
          fields: [],
          tagKeys: [],
        }
      }
    })
  )

  return { measurements }
}

/**
 * Validate a Flux query string (basic validation)
 */
export function validateQuery(query: string): { valid: boolean; error?: string } {
  if (!query || typeof query !== 'string') {
    return { valid: false, error: 'Query must be a non-empty string' }
  }

  if (!query.includes('from(bucket:')) {
    return { valid: false, error: 'Query must include a from(bucket:) clause' }
  }

  return { valid: true }
}


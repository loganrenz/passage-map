import { InfluxDB, flux } from '@influxdata/influxdb-client'

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const query = getQuery(event)
  
  const startTime = query.startTime as string
  const endTime = query.endTime as string
  const resolution = query.resolution ? parseInt(query.resolution as string) : 60 // Default 60 seconds
  
  if (!startTime || !endTime) {
    throw createError({
      statusCode: 400,
      statusMessage: 'startTime and endTime query parameters are required'
    })
  }

  if (!config.influxToken || !config.influxOrgId || !config.influxBucket) {
    throw createError({
      statusCode: 500,
      statusMessage: 'InfluxDB configuration is missing. Please check Doppler secrets.'
    })
  }

  try {
    const influxDB = new InfluxDB({
      url: config.influxUrl,
      token: config.influxToken,
    })

    const queryApi = influxDB.getQueryApi(config.influxOrgId)

    // Query for navigation.position data (lat/lon) with self tag
    // Based on signalk-to-influxdb2 structure: navigation.position is stored with geo features
    // Using pivot to combine lat/lon fields into single rows
    const fluxQuery = flux`
      from(bucket: ${config.influxBucket})
        |> range(start: ${startTime}, stop: ${endTime})
        |> filter(fn: (r) => r["_measurement"] == "navigation.position")
        |> filter(fn: (r) => r["self"] == "t")
        |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
        |> filter(fn: (r) => exists r.lat and exists r.lon)
        |> aggregateWindow(every: ${String(resolution)}s, fn: first, createEmpty: false)
        |> yield(name: "positions")
    `

    const positions: Array<{ time: string; lat: number; lon: number }> = []

    return new Promise((resolve, reject) => {
      queryApi.queryRows(fluxQuery, {
        next(row, tableMeta) {
          const tableObject = tableMeta.toObject(row)
          const time = tableObject._time as string
          const lat = tableObject.lat as number | undefined
          const lon = tableObject.lon as number | undefined
          
          if (lat !== undefined && lon !== undefined && !isNaN(lat) && !isNaN(lon)) {
            positions.push({
              time,
              lat,
              lon,
            })
          }
        },
        error(error) {
          console.error('InfluxDB query error:', error)
          reject(createError({
            statusCode: 500,
            statusMessage: `InfluxDB query failed: ${error.message}`
          }))
        },
        complete() {
          resolve({
            positions,
            count: positions.length,
          })
        },
      })
    })
  } catch (error: any) {
    console.error('Error querying InfluxDB:', error)
    throw createError({
      statusCode: 500,
      statusMessage: `Failed to query InfluxDB: ${error.message}`
    })
  }
})


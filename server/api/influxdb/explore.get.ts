import { InfluxDB, flux } from '@influxdata/influxdb-client'

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const query = getQuery(event)
  
  const startTime = query.startTime as string || '2025-06-26T00:00:00Z'
  const endTime = query.endTime as string || '2025-07-05T00:00:00Z'
  const limit = query.limit ? parseInt(query.limit as string) : 10

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

    // Query to explore available measurements and fields
    const exploreQuery = flux`
      from(bucket: ${config.influxBucket})
        |> range(start: ${startTime}, stop: ${endTime})
        |> filter(fn: (r) => r["self"] == "t")
        |> limit(n: ${String(limit)})
        |> yield(name: "explore")
    `

    const results: any[] = []

    return new Promise((resolve, reject) => {
      queryApi.queryRows(exploreQuery, {
        next(row, tableMeta) {
          const tableObject = tableMeta.toObject(row)
          results.push(tableObject)
        },
        error(error) {
          console.error('InfluxDB explore query error:', error)
          reject(createError({
            statusCode: 500,
            statusMessage: `InfluxDB query failed: ${error.message}`
          }))
        },
        complete() {
          // Group by measurement to see structure
          const byMeasurement = new Map<string, Set<string>>()
          
          results.forEach((row) => {
            const measurement = row._measurement as string
            const field = row._field as string
            
            if (!byMeasurement.has(measurement)) {
              byMeasurement.set(measurement, new Set())
            }
            byMeasurement.get(measurement)!.add(field)
          })

          const structure = Array.from(byMeasurement.entries()).map(([measurement, fields]) => ({
            measurement,
            fields: Array.from(fields),
            sampleCount: results.filter(r => r._measurement === measurement).length,
          }))

          resolve({
            totalRows: results.length,
            measurements: structure,
            sampleRows: results.slice(0, 5),
          })
        },
      })
    })
  } catch (error: any) {
    console.error('Error exploring InfluxDB:', error)
    throw createError({
      statusCode: 500,
      statusMessage: `Failed to explore InfluxDB: ${error.message}`
    })
  }
})


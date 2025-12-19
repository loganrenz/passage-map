import { InfluxDB } from '@influxdata/influxdb-client'

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const body = await readBody(event)
  
  const { query } = body

  if (!query || typeof query !== 'string') {
    throw createError({
      statusCode: 400,
      statusMessage: 'Query is required and must be a string'
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

    const results: any[] = []

    return new Promise((resolve, reject) => {
      queryApi.queryRows(query, {
        next(row, tableMeta) {
          const tableObject = tableMeta.toObject(row)
          results.push(tableObject)
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
            results,
            count: results.length,
          })
        },
      })
    })
  } catch (error: any) {
    console.error('Error executing InfluxDB query:', error)
    throw createError({
      statusCode: 500,
      statusMessage: `Failed to execute query: ${error.message}`
    })
  }
})


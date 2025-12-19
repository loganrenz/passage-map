import { exploreSchema } from '~/server/utils/influxQueries'
import { getInfluxDBConfig } from '~/server/utils/influxClient'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const startTime = (query.startTime as string) || undefined
  const endTime = (query.endTime as string) || undefined

  try {
    const config = getInfluxDBConfig()
    const result = await exploreSchema(config, startTime, endTime)
    return result
  } catch (error: any) {
    console.error('Error exploring InfluxDB schema:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.message || 'Failed to explore InfluxDB schema',
    })
  }
})


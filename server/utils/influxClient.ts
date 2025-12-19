import { InfluxDB, QueryApi } from '@influxdata/influxdb-client'

let influxDBInstance: InfluxDB | null = null
let queryApiInstance: QueryApi | null = null

export interface InfluxDBConfig {
  url: string
  token: string
  orgId: string
  bucket: string
}

export interface QueryResult {
  [key: string]: unknown
}

/**
 * Initialize InfluxDB client singleton
 */
export function getInfluxDBClient(config: InfluxDBConfig): InfluxDB {
  if (!influxDBInstance) {
    influxDBInstance = new InfluxDB({
      url: config.url,
      token: config.token,
    })
  }
  return influxDBInstance
}

/**
 * Get QueryApi instance
 */
export function getQueryApi(config: InfluxDBConfig): QueryApi {
  if (!queryApiInstance) {
    const client = getInfluxDBClient(config)
    queryApiInstance = client.getQueryApi(config.orgId)
  }
  return queryApiInstance
}

/**
 * Execute a Flux query and return results as an array of objects
 */
export async function executeQuery(
  config: InfluxDBConfig,
  query: string
): Promise<QueryResult[]> {
  if (!config.token || !config.orgId || !config.bucket) {
    throw new Error('InfluxDB configuration is missing. Please check environment variables.')
  }

  const queryApi = getQueryApi(config)
  const results: QueryResult[] = []

  return new Promise((resolve, reject) => {
    queryApi.queryRows(query, {
      next(row, tableMeta) {
        const tableObject = tableMeta.toObject(row)
        results.push(tableObject)
      },
      error(error) {
        console.error('InfluxDB query error:', error)
        reject(new Error(`InfluxDB query failed: ${error.message}`))
      },
      complete() {
        resolve(results)
      },
    })
  })
}

/**
 * Execute a Flux query with custom row handler
 */
export async function executeQueryWithHandler<T>(
  config: InfluxDBConfig,
  query: string,
  handler: {
    next?: (row: QueryResult, tableMeta: any) => void
    error?: (error: Error) => void
    complete?: () => void
  }
): Promise<T[]> {
  if (!config.token || !config.orgId || !config.bucket) {
    throw new Error('InfluxDB configuration is missing. Please check environment variables.')
  }

  const queryApi = getQueryApi(config)
  const results: T[] = []

  return new Promise((resolve, reject) => {
    queryApi.queryRows(query, {
      next(row, tableMeta) {
        const tableObject = tableMeta.toObject(row)
        if (handler.next) {
          handler.next(tableObject, tableMeta)
        }
        results.push(tableObject as T)
      },
      error(error) {
        console.error('InfluxDB query error:', error)
        const err = new Error(`InfluxDB query failed: ${error.message}`)
        if (handler.error) {
          handler.error(err)
        }
        reject(err)
      },
      complete() {
        if (handler.complete) {
          handler.complete()
        }
        resolve(results)
      },
    })
  })
}

/**
 * Get InfluxDB config from runtime config
 */
export function getInfluxDBConfig(): InfluxDBConfig {
  const config = useRuntimeConfig()
  
  if (!config.influxToken || !config.influxOrgId || !config.influxBucket) {
    throw new Error('InfluxDB configuration is missing. Please check Doppler secrets.')
  }

  return {
    url: config.influxUrl || 'http://127.0.0.1:8086',
    token: config.influxToken,
    orgId: config.influxOrgId,
    bucket: config.influxBucket,
  }
}


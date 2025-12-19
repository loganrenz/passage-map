/**
 * Local D1 access utilities for development
 * Uses wrangler d1 execute commands to access local D1 database
 */

import { exec } from 'child_process'
import { promisify } from 'util'
import { writeFile, unlink } from 'fs/promises'
import { join } from 'path'
import type { LocationInfo } from '~/types/passage'

const execAsync = promisify(exec)

/**
 * Check if we're in local development mode
 */
function isLocalDev(): boolean {
  return process.env.NODE_ENV !== 'production' && !process.env.D2_API_URL
}

/**
 * Execute a SQL query on local D1
 */
async function executeLocalD1Query<T = unknown>(sql: string): Promise<T[]> {
  if (!isLocalDev()) {
    return []
  }

  try {
    // Write SQL to temp file
    const tempFile = join(process.cwd(), `.d1-query-${Date.now()}.sql`)
    await writeFile(tempFile, sql, 'utf-8')

    try {
      const { stdout } = await execAsync(
        `wrangler d1 execute passage-map-db --file=${tempFile} --local --json`,
        { cwd: process.cwd() }
      )

      const result = JSON.parse(stdout)
      if (result && result[0] && result[0].results) {
        return result[0].results as T[]
      }
      return []
    } finally {
      await unlink(tempFile).catch(() => {})
    }
  } catch (error) {
    console.warn('Local D1 query failed:', error)
    return []
  }
}

/**
 * Get locations for a passage from local D1
 */
export async function getLocationsFromLocalD1(passageId: string): Promise<LocationInfo[]> {
  if (!isLocalDev()) {
    return []
  }

  try {
    const results = await executeLocalD1Query<{
      time: string
      lat: number
      lon: number
      name: string | null
      locality: string | null
      administrative_area: string | null
      country: string | null
      country_code: string | null
      formatted_address: string | null
      points_of_interest: string | null
    }>(
      `SELECT time, lat, lon, name, locality, administrative_area, country, country_code, formatted_address, points_of_interest FROM passage_locations WHERE passage_id = '${passageId.replace(/'/g, "''")}' ORDER BY time;`
    )

    return results.map((row) => ({
      coordinate: { lat: row.lat, lon: row.lon },
      time: row.time,
      name: row.name || undefined,
      locality: row.locality || undefined,
      administrativeArea: row.administrative_area || undefined,
      country: row.country || undefined,
      countryCode: row.country_code || undefined,
      formattedAddress: row.formatted_address || undefined,
      pointsOfInterest: row.points_of_interest ? JSON.parse(row.points_of_interest) : undefined,
    }))
  } catch (error) {
    console.warn('Error getting locations from local D1:', error)
    return []
  }
}


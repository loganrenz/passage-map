import type { PassagePosition } from '~/types/passage'

export interface InfluxDBPosition {
  time: string
  lat: number
  lon: number
}

export interface InfluxDBPassageData {
  positions: InfluxDBPosition[]
  count: number
}

/**
 * Composable for fetching passage data from InfluxDB
 */
export const useInfluxDB = () => {
  /**
   * Fetch position data from InfluxDB for a given time range
   * @param startTime ISO 8601 timestamp (e.g., "2025-06-26T13:15:00.000Z")
   * @param endTime ISO 8601 timestamp (e.g., "2025-07-04T17:00:00.000Z")
   * @param resolution Resolution in seconds (default: 60). Higher values reduce data points.
   * @returns Promise with position data
   */
  const fetchPassageData = async (
    startTime: string,
    endTime: string,
    resolution: number = 60
  ): Promise<InfluxDBPassageData> => {
    try {
      const { data, error } = await useFetch<InfluxDBPassageData>(
        '/api/influxdb/passage-data',
        {
          query: {
            startTime,
            endTime,
            resolution,
          },
        }
      )

      if (error.value) {
        throw new Error(`Failed to fetch InfluxDB data: ${error.value.message}`)
      }

      if (!data.value) {
        return { positions: [], count: 0 }
      }

      return data.value
    } catch (error: any) {
      console.error('Error fetching InfluxDB passage data:', error)
      throw error
    }
  }

  /**
   * Convert InfluxDB positions to PassagePosition format
   * @param positions InfluxDB position data
   * @returns Array of PassagePosition objects
   */
  const convertToPassagePositions = (
    positions: InfluxDBPosition[]
  ): PassagePosition[] => {
    return positions.map((pos) => ({
      _time: pos.time,
      lat: pos.lat,
      lon: pos.lon,
    }))
  }

  return {
    fetchPassageData,
    convertToPassagePositions,
  }
}


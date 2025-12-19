import type { Passage, PassageLocation, PassagePosition } from '~/types/passage'

export interface InfluxPosition {
  _time: string
  lat: number
  lon: number
}

export interface InfluxSpeed {
  _time: string
  _value: number
}

export interface PassageData {
  positions: InfluxPosition[]
  speeds?: InfluxSpeed[]
}

/**
 * Calculate distance between two coordinates using Haversine formula
 */
function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371 // Earth's radius in kilometers
  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLon = ((lon2 - lon1) * Math.PI) / 180
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

/**
 * Calculate total distance from positions array
 */
function calculateTotalDistance(positions: InfluxPosition[]): number {
  if (positions.length < 2) {
    return 0
  }

  let totalDistance = 0
  for (let i = 1; i < positions.length; i++) {
    const prev = positions[i - 1]
    const curr = positions[i]
    totalDistance += calculateDistance(prev.lat, prev.lon, curr.lat, curr.lon)
  }

  return totalDistance
}

/**
 * Calculate average speed from speeds array or positions
 */
function calculateAverageSpeed(
  positions: InfluxPosition[],
  speeds?: InfluxSpeed[]
): number {
  if (speeds && speeds.length > 0) {
    const sum = speeds.reduce((acc, s) => acc + s._value, 0)
    return sum / speeds.length
  }

  // Calculate from positions if no speed data
  if (positions.length < 2) {
    return 0
  }

  let totalSpeed = 0
  let count = 0

  for (let i = 1; i < positions.length; i++) {
    const prev = positions[i - 1]
    const curr = positions[i]

    const timeDiff =
      (new Date(curr._time).getTime() - new Date(prev._time).getTime()) / 1000 // seconds
    if (timeDiff > 0) {
      const distance = calculateDistance(prev.lat, prev.lon, curr.lat, curr.lon)
      const speed = distance / (timeDiff / 3600) // km/h
      totalSpeed += speed
      count++
    }
  }

  return count > 0 ? totalSpeed / count : 0
}

/**
 * Calculate max speed from speeds array or positions
 */
function calculateMaxSpeed(
  positions: InfluxPosition[],
  speeds?: InfluxSpeed[]
): number {
  if (speeds && speeds.length > 0) {
    return Math.max(...speeds.map((s) => s._value))
  }

  // Calculate from positions if no speed data
  if (positions.length < 2) {
    return 0
  }

  let maxSpeed = 0

  for (let i = 1; i < positions.length; i++) {
    const prev = positions[i - 1]
    const curr = positions[i]

    const timeDiff =
      (new Date(curr._time).getTime() - new Date(prev._time).getTime()) / 1000 // seconds
    if (timeDiff > 0) {
      const distance = calculateDistance(prev.lat, prev.lon, curr.lat, curr.lon)
      const speed = distance / (timeDiff / 3600) // km/h
      maxSpeed = Math.max(maxSpeed, speed)
    }
  }

  return maxSpeed
}

/**
 * Transform InfluxDB query results into Passage format
 */
export function transformToPassage(
  data: PassageData,
  options?: {
    id?: string
    name?: string
    description?: string
    startTime?: string
    endTime?: string
  }
): Passage {
  const { positions, speeds } = data

  if (!positions || positions.length === 0) {
    throw new Error('No position data available to create passage')
  }

  // Sort positions by time
  const sortedPositions = [...positions].sort(
    (a, b) => new Date(a._time).getTime() - new Date(b._time).getTime()
  )

  const startTime =
    options?.startTime || sortedPositions[0]._time
  const endTime =
    options?.endTime || sortedPositions[sortedPositions.length - 1]._time

  const startLocation: PassageLocation = {
    lat: sortedPositions[0].lat,
    lon: sortedPositions[0].lon,
  }

  const endLocation: PassageLocation = {
    lat: sortedPositions[sortedPositions.length - 1].lat,
    lon: sortedPositions[sortedPositions.length - 1].lon,
  }

  const duration =
    (new Date(endTime).getTime() - new Date(startTime).getTime()) /
    (1000 * 60 * 60) // hours

  const distance = calculateTotalDistance(sortedPositions)
  const avgSpeed = calculateAverageSpeed(sortedPositions, speeds)
  const maxSpeed = calculateMaxSpeed(sortedPositions, speeds)

  // Generate passage ID if not provided
  const id =
    options?.id ||
    `passage_${new Date(startTime).getTime()}`

  // Generate name if not provided
  const name =
    options?.name ||
    `Passage ${id}`

  // Generate description if not provided
  const description =
    options?.description ||
    `Passage from ${new Date(startTime).toISOString()} to ${new Date(endTime).toISOString()}`

  // Generate route string
  const route = `${startLocation.lat.toFixed(2)}, ${startLocation.lon.toFixed(2)} → ${endLocation.lat.toFixed(2)}, ${endLocation.lon.toFixed(2)}`

  // Transform positions to PassagePosition format
  const passagePositions: PassagePosition[] = sortedPositions.map((pos) => ({
    _time: pos._time,
    lat: pos.lat,
    lon: pos.lon,
  }))

  return {
    id,
    startTime,
    endTime,
    duration: Math.round(duration * 100) / 100, // Round to 2 decimal places
    avgSpeed: Math.round(avgSpeed * 100) / 100,
    maxSpeed: Math.round(maxSpeed * 100) / 100,
    distance: Math.round(distance * 100) / 100,
    startLocation,
    endLocation,
    description,
    name,
    route,
    exportTimestamp: new Date().toISOString(),
    positions: passagePositions,
  }
}

/**
 * Parse InfluxDB query results into structured data
 */
export function parseInfluxResults(
  positionResults: Array<Record<string, unknown>>,
  speedResults?: Array<Record<string, unknown>>
): PassageData {
  const positions: InfluxPosition[] = positionResults
    .map((row) => {
      const time = row._time as string
      const lat = row.lat as number | undefined
      const lon = row.lon as number | undefined

      if (
        time &&
        lat !== undefined &&
        lon !== undefined &&
        !isNaN(lat) &&
        !isNaN(lon)
      ) {
        return {
          _time: time,
          lat,
          lon,
        }
      }
      return null
    })
    .filter((p): p is InfluxPosition => p !== null)

  const speeds: InfluxSpeed[] | undefined = speedResults
    ? speedResults
        .map((row) => {
          const time = row._time as string
          const value = row._value as number | undefined

          if (time && value !== undefined && !isNaN(value)) {
            return {
              _time: time,
              _value: value,
            }
          }
          return null
        })
        .filter((s): s is InfluxSpeed => s !== null)
    : undefined

  return {
    positions,
    speeds,
  }
}


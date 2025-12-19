import type { Passage, PassageLocation } from '~/types/passage'

export function createCoordinate(location: PassageLocation): [number, number] {
  return [location.lat, location.lon]
}

export function getPassageBounds(passage: Passage): {
  north: number
  south: number
  east: number
  west: number
} {
  const lats = [passage.startLocation.lat, passage.endLocation.lat]
  const lons = [passage.startLocation.lon, passage.endLocation.lon]

  if (passage.positions && passage.positions.length > 0) {
    passage.positions.forEach((pos) => {
      lats.push(pos.lat)
      lons.push(pos.lon)
    })
  }

  return {
    north: Math.max(...lats),
    south: Math.min(...lats),
    east: Math.max(...lons),
    west: Math.min(...lons),
  }
}

export function getAllPassagesBounds(passages: Passage[]): {
  north: number
  south: number
  east: number
  west: number
} {
  if (passages.length === 0) {
    return { north: 0, south: 0, east: 0, west: 0 }
  }

  const allBounds = passages.map(getPassageBounds)
  return {
    north: Math.max(...allBounds.map((b) => b.north)),
    south: Math.min(...allBounds.map((b) => b.south)),
    east: Math.max(...allBounds.map((b) => b.east)),
    west: Math.min(...allBounds.map((b) => b.west)),
  }
}

export function formatDuration(hours: number): string {
  if (hours < 24) {
    return `${hours.toFixed(1)} hours`
  }
  const days = Math.floor(hours / 24)
  const remainingHours = hours % 24
  if (remainingHours === 0) {
    return `${days} day${days !== 1 ? 's' : ''}`
  }
  return `${days} day${days !== 1 ? 's' : ''}, ${remainingHours.toFixed(1)} hours`
}

export function formatDistance(nm: number): string {
  if (nm < 1) {
    return `${(nm * 1000).toFixed(0)} m`
  }
  return `${nm.toFixed(1)} nm`
}

export function getTimeRange(passage: Passage): { start: number; end: number } {
  const start = Date.parse(passage.startTime)
  const end = Date.parse(passage.endTime)
  
  // Validate that dates are valid
  if (isNaN(start) || isNaN(end)) {
    console.warn('Invalid date range for passage:', passage.id)
    return { start: 0, end: 0 }
  }
  
  return { start, end }
}

export function getPositionAtTime(
  passage: Passage,
  timestamp: string
): { lat: number; lon: number } | null {
  if (!passage) return null

  const targetTime = Date.parse(timestamp)
  const startTime = Date.parse(passage.startTime)
  const endTime = Date.parse(passage.endTime)

  // Clamp to passage time range
  if (targetTime < startTime) {
    return { lat: passage.startLocation.lat, lon: passage.startLocation.lon }
  }
  if (targetTime > endTime) {
    return { lat: passage.endLocation.lat, lon: passage.endLocation.lon }
  }

  // If passage has detailed positions, interpolate between them
  if (passage.positions && passage.positions.length > 0) {
    // Find the two positions to interpolate between
    for (let i = 0; i < passage.positions.length - 1; i++) {
      const pos1 = passage.positions[i]
      const pos2 = passage.positions[i + 1]
      if (!pos1 || !pos2) continue
      
      const time1 = Date.parse(pos1._time)
      const time2 = Date.parse(pos2._time)

      // Check if target time is between these two positions
      if (targetTime >= time1 && targetTime <= time2) {
        // Calculate interpolation factor
        const timeDiff = time2 - time1
        if (timeDiff === 0) {
          return { lat: pos1.lat, lon: pos1.lon }
        }
        const progress = (targetTime - time1) / timeDiff

        // Linear interpolation
        const lat = pos1.lat + (pos2.lat - pos1.lat) * progress
        const lon = pos1.lon + (pos2.lon - pos1.lon) * progress

        return { lat, lon }
      }
    }

    // If we get here, target time is after the last position
    const lastPos = passage.positions[passage.positions.length - 1]
    if (lastPos) {
      return { lat: lastPos.lat, lon: lastPos.lon }
    }
  }

  // Fallback: interpolate between start and end locations
  const totalDuration = endTime - startTime
  if (totalDuration === 0) {
    return { lat: passage.startLocation.lat, lon: passage.startLocation.lon }
  }

  const progress = (targetTime - startTime) / totalDuration
  const lat = passage.startLocation.lat + (passage.endLocation.lat - passage.startLocation.lat) * progress
  const lon = passage.startLocation.lon + (passage.endLocation.lon - passage.startLocation.lon) * progress

  return { lat, lon }
}


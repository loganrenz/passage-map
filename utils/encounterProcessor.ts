/**
 * Utility functions for processing vessel data into encounter information
 */

import type {
  VesselEncounter,
  EncounterSegment,
  VesselPosition,
  VesselMetadata,
  PassageEncounters,
  EncounterCalculationOptions,
} from '~/types/vessel-encounter'
import type { Passage, PassagePosition } from '~/types/passage'

/**
 * Raw vessel data structure from JSON files
 */
export interface RawVesselData {
  vessels: Array<{
    vessel: {
      id: string
      name: string
      mmsi?: string
      type?: string
      flag?: string
      length?: number | string
      beam?: number
      color?: string
      description?: string
    }
    track: Array<{
      coordinate: {
        latitude: number
        longitude: number
      }
      timestamp: string
      speed?: number
      heading?: number
      altitude?: number
      accuracy?: number
    }>
  }>
}

/**
 * Calculate distance between two coordinates using Haversine formula
 * @returns Distance in nautical miles
 */
export function calculateDistanceNauticalMiles(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 3440.065 // Earth radius in nautical miles
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
 * Convert raw vessel track point to VesselPosition
 */
function convertTrackPoint(
  point: RawVesselData['vessels'][0]['track'][0]
): VesselPosition {
  return {
    timestamp: point.timestamp,
    lat: point.coordinate.latitude,
    lon: point.coordinate.longitude,
    speed: point.speed,
    heading: point.heading,
    altitude: point.altitude,
    accuracy: point.accuracy,
  }
}

/**
 * Find the closest position in passage positions to a given vessel position
 */
function findClosestPassagePosition(
  vesselPos: VesselPosition,
  passagePositions: PassagePosition[]
): PassagePosition | null {
  if (passagePositions.length === 0) return null

  let closest: PassagePosition | null = null
  let minDistance = Infinity
  const vesselTime = new Date(vesselPos.timestamp).getTime()

  for (const passagePos of passagePositions) {
    const passageTime = new Date(passagePos._time).getTime()
    const timeDiff = Math.abs(vesselTime - passageTime)

    // Find position closest in time (within 1 hour)
    if (timeDiff < 60 * 60 * 1000) {
      const distance = calculateDistanceNauticalMiles(
        vesselPos.lat,
        vesselPos.lon,
        passagePos.lat,
        passagePos.lon
      )

      if (distance < minDistance) {
        minDistance = distance
        closest = passagePos
      }
    }
  }

  return closest
}

/**
 * Calculate distances for a segment using passage positions
 */
function calculateSegmentDistances(
  segment: EncounterSegment,
  passagePositions: PassagePosition[]
): {
  closestApproachDistance?: number
  closestApproachTime?: string
  averageDistance?: number
} {
  if (passagePositions.length === 0) {
    return {}
  }

  let minDistance = Infinity
  let closestTime: string | undefined
  let totalDistance = 0
  let validDistances = 0

  for (const vesselPos of segment.positions) {
    const closestPassage = findClosestPassagePosition(vesselPos, passagePositions)
    if (closestPassage) {
      const distance = calculateDistanceNauticalMiles(
        vesselPos.lat,
        vesselPos.lon,
        closestPassage.lat,
        closestPassage.lon
      )

      if (distance < minDistance) {
        minDistance = distance
        closestTime = vesselPos.timestamp
      }

      totalDistance += distance
      validDistances++
    }
  }

  return {
    closestApproachDistance: minDistance !== Infinity ? minDistance : undefined,
    closestApproachTime: closestTime,
    averageDistance: validDistances > 0 ? totalDistance / validDistances : undefined,
  }
}

/**
 * Group vessel positions into encounter segments
 * 
 * Segments are separated by gaps larger than the specified threshold.
 */
function groupIntoSegments(
  positions: VesselPosition[],
  segmentGapMinutes: number
): EncounterSegment[] {
  if (positions.length === 0) return []

  // Sort positions by timestamp
  const sorted = [...positions].sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
  )

  const segments: EncounterSegment[] = []
  let currentSegment: VesselPosition[] = [sorted[0]]

  for (let i = 1; i < sorted.length; i++) {
    const prevTime = new Date(sorted[i - 1].timestamp).getTime()
    const currTime = new Date(sorted[i].timestamp).getTime()
    const gapMinutes = (currTime - prevTime) / (1000 * 60)

    if (gapMinutes > segmentGapMinutes) {
      // Gap detected - close current segment and start new one
      const segment = createSegment(currentSegment)
      segments.push(segment)
      currentSegment = [sorted[i]]
    } else {
      // Continue current segment
      currentSegment.push(sorted[i])
    }
  }

  // Add final segment
  if (currentSegment.length > 0) {
    const segment = createSegment(currentSegment)
    segments.push(segment)
  }

  return segments
}

/**
 * Create an encounter segment from position array
 */
function createSegment(positions: VesselPosition[]): EncounterSegment {
  if (positions.length === 0) {
    throw new Error('Cannot create segment from empty positions array')
  }

  const sorted = [...positions].sort(
    (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
  )

  const startTime = sorted[0].timestamp
  const endTime = sorted[sorted.length - 1].timestamp
  const startDate = new Date(startTime)
  const endDate = new Date(endTime)
  const duration = (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60) // hours

  return {
    startTime,
    endTime,
    duration,
    positions: sorted,
  }
}

/**
 * Process raw vessel data into encounter information
 */
export function processVesselEncounters(
  rawData: RawVesselData,
  passage: Passage,
  options: EncounterCalculationOptions = {}
): PassageEncounters {
  const {
    maxEncounterDistance = 50, // 50 nautical miles default
    segmentGapMinutes = 30, // 30 minutes default
    calculateDistances = true,
  } = options

  const passagePositions = passage.positions || []
  const encounters: VesselEncounter[] = []

  // Identify self vessel (usually the one with most track points matching passage timeline)
  const selfVesselId = identifySelfVessel(rawData, passage)

  for (const vesselData of rawData.vessels) {
    // Skip self vessel
    if (vesselData.vessel.id === selfVesselId) {
      continue
    }

    // Convert track points
    const positions: VesselPosition[] = vesselData.track.map(convertTrackPoint)

    if (positions.length === 0) continue

    // Group into segments
    const segments = groupIntoSegments(positions, segmentGapMinutes)

    if (segments.length === 0) continue

    // Calculate distances if requested
    if (calculateDistances && passagePositions.length > 0) {
      for (const segment of segments) {
        const distances = calculateSegmentDistances(segment, passagePositions)
        Object.assign(segment, distances)
      }
    }

    // Calculate overall statistics
    const allTimes = positions.map((p) => new Date(p.timestamp).getTime())
    const firstSeen = new Date(Math.min(...allTimes)).toISOString()
    const lastSeen = new Date(Math.max(...allTimes)).toISOString()
    const totalDuration = segments.reduce((sum, seg) => sum + seg.duration, 0)

    // Find overall closest approach
    let overallClosest: number | undefined
    let overallClosestTime: string | undefined
    for (const segment of segments) {
      if (segment.closestApproachDistance !== undefined) {
        if (
          overallClosest === undefined ||
          segment.closestApproachDistance < overallClosest
        ) {
          overallClosest = segment.closestApproachDistance
          overallClosestTime = segment.closestApproachTime
        }
      }
    }

    // Create vessel metadata
    const vessel: VesselMetadata = {
      id: vesselData.vessel.id,
      name: vesselData.vessel.name,
      mmsi: vesselData.vessel.mmsi,
      type: vesselData.vessel.type,
      flag: vesselData.vessel.flag,
      length: vesselData.vessel.length,
      beam: vesselData.vessel.beam,
      color: vesselData.vessel.color,
      description: vesselData.vessel.description,
    }

    const encounter: VesselEncounter = {
      vessel,
      segments,
      firstSeen,
      lastSeen,
      totalDuration,
      totalPositionCount: positions.length,
      overallClosestApproach: overallClosest,
      overallClosestApproachTime: overallClosestTime,
    }

    encounters.push(encounter)
  }

  // Sort encounters by first seen time
  encounters.sort(
    (a, b) => new Date(a.firstSeen).getTime() - new Date(b.firstSeen).getTime()
  )

  const totalSegments = encounters.reduce((sum, enc) => sum + enc.segments.length, 0)

  return {
    passageId: passage.id,
    generatedAt: new Date().toISOString(),
    encounters,
    totalVessels: encounters.length,
    totalSegments,
  }
}

/**
 * Identify the self vessel (Tideye) from raw data
 * Usually the vessel with the most track points that matches the passage timeline
 */
function identifySelfVessel(
  rawData: RawVesselData,
  passage: Passage
): string | null {
  const passageStart = new Date(passage.startTime).getTime()
  const passageEnd = new Date(passage.endTime).getTime()

  let bestMatch: { id: string; score: number } | null = null

  for (const vesselData of rawData.vessels) {
    if (vesselData.track.length === 0) continue

    const vesselTimes = vesselData.track.map((p) => new Date(p.timestamp).getTime())
    const vesselStart = Math.min(...vesselTimes)
    const vesselEnd = Math.max(...vesselTimes)

    // Check if vessel timeline overlaps significantly with passage
    const overlapStart = Math.max(passageStart, vesselStart)
    const overlapEnd = Math.min(passageEnd, vesselEnd)
    const overlapDuration = Math.max(0, overlapEnd - overlapStart)
    const passageDuration = passageEnd - passageStart

    // Score based on track point count and timeline overlap
    const overlapRatio = overlapDuration / passageDuration
    const score = vesselData.track.length * overlapRatio

    if (!bestMatch || score > bestMatch.score) {
      bestMatch = { id: vesselData.vessel.id, score }
    }
  }

  return bestMatch?.id || null
}

/**
 * Load encounters data from a JSON file
 */
export async function loadEncountersData(
  filename: string
): Promise<PassageEncounters | null> {
  try {
    const response = await fetch(`/data/passages_vessel_data/${filename}`)
    if (!response.ok) {
      return null
    }
    const data = await response.json()
    return data as PassageEncounters
  } catch (error) {
    console.error(`Error loading encounters data ${filename}:`, error)
    return null
  }
}


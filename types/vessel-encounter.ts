/**
 * Data model for tracking vessel encounters during a passage
 * 
 * This model handles vessels that may come in and out of range,
 * allowing us to track multiple encounter segments per vessel.
 */

/**
 * A single position point for a vessel at a specific time
 */
export interface VesselPosition {
  /** ISO 8601 timestamp */
  timestamp: string
  /** Latitude in decimal degrees */
  lat: number
  /** Longitude in decimal degrees */
  lon: number
  /** Speed in knots (optional) */
  speed?: number
  /** Heading in degrees (0-360, optional) */
  heading?: number
  /** Altitude in meters (optional) */
  altitude?: number
  /** Position accuracy in meters (optional) */
  accuracy?: number
}

/**
 * Metadata about a vessel
 */
export interface VesselMetadata {
  /** Unique vessel identifier (often MMSI) */
  id: string
  /** Vessel name */
  name: string
  /** Maritime Mobile Service Identity (MMSI) number */
  mmsi?: string
  /** Vessel type (e.g., "cargo", "tanker", "fishing", etc.) */
  type?: string
  /** Vessel flag country */
  flag?: string
  /** Vessel length in meters */
  length?: number | string
  /** Vessel beam (width) in meters */
  beam?: number
  /** Display color for the vessel */
  color?: string
  /** Additional description */
  description?: string
}

/**
 * A continuous encounter segment with a vessel
 * 
 * Represents a period when a vessel is in range.
 * If a vessel goes out of range and comes back, that's a new segment.
 */
export interface EncounterSegment {
  /** Start time of this encounter segment (ISO 8601) */
  startTime: string
  /** End time of this encounter segment (ISO 8601) */
  endTime: string
  /** Duration of this segment in hours */
  duration: number
  /** All position points during this segment */
  positions: VesselPosition[]
  /** Closest approach distance in nautical miles during this segment */
  closestApproachDistance?: number
  /** Timestamp when closest approach occurred */
  closestApproachTime?: string
  /** Average distance during this segment in nautical miles */
  averageDistance?: number
}

/**
 * Complete encounter information for a vessel
 * 
 * A vessel may have multiple encounter segments if it comes in and out of range.
 */
export interface VesselEncounter {
  /** Vessel metadata */
  vessel: VesselMetadata
  /** All encounter segments with this vessel (sorted by startTime) */
  segments: EncounterSegment[]
  /** First time this vessel was seen (across all segments) */
  firstSeen: string
  /** Last time this vessel was seen (across all segments) */
  lastSeen: string
  /** Total duration of all encounters combined in hours */
  totalDuration: number
  /** Total number of position points across all segments */
  totalPositionCount: number
  /** Overall closest approach distance across all segments */
  overallClosestApproach?: number
  /** Timestamp of overall closest approach */
  overallClosestApproachTime?: string
}

/**
 * Complete encounter data for a passage
 */
export interface PassageEncounters {
  /** Passage ID this data belongs to */
  passageId: string
  /** Timestamp when this data was generated */
  generatedAt: string
  /** All vessel encounters during this passage */
  encounters: VesselEncounter[]
  /** Total number of unique vessels encountered */
  totalVessels: number
  /** Total number of encounter segments */
  totalSegments: number
}

/**
 * Options for calculating encounter distances
 */
export interface EncounterCalculationOptions {
  /** Maximum distance in nautical miles to consider an encounter (default: 50) */
  maxEncounterDistance?: number
  /** Minimum time gap in minutes to consider segments separate (default: 30) */
  segmentGapMinutes?: number
  /** Whether to calculate closest approach distances */
  calculateDistances?: boolean
}


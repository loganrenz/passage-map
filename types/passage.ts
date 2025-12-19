export interface PassageLocation {
  lat: number
  lon: number
}

export interface PassagePosition {
  _time: string
  lat: number
  lon: number
  speed?: number // Speed in knots (optional, can be calculated)
  heading?: number // Heading in degrees 0-360 (optional, can be calculated)
  distance?: number // Distance from start in km (optional, can be calculated)
}

export interface QueryMetadata {
  id?: string
  query?: string
  parameters?: Record<string, unknown>
  timestamp?: string
  description?: string
}

export interface Passage {
  id: string
  startTime: string
  endTime: string
  duration: number
  avgSpeed: number
  maxSpeed: number
  distance: number
  startLocation: PassageLocation
  endLocation: PassageLocation
  description: string
  name: string
  route: string
  exportTimestamp?: string
  filename?: string
  positions?: PassagePosition[]
  queryMetadata?: QueryMetadata
  /** Optional encounters data filename (relative to passages_vessel_data directory) */
  encountersFilename?: string
}


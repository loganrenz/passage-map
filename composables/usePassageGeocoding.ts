import type { Passage, LocationInfo, PassagePosition } from '~/types/passage'

/**
 * Composable for reverse geocoding passage coordinates using MapKit Geocoder
 */
export const usePassageGeocoding = () => {
  const geocodingCache = new Map<string, LocationInfo>()
  const isGeocoding = ref(false)

  /**
   * Wait for MapKit to be available
   */
  const waitForMapKit = (): Promise<void> => {
    return new Promise((resolve, reject) => {
      if (typeof window !== 'undefined' && window.mapkit && window.mapkit.Geocoder) {
        resolve()
        return
      }

      let attempts = 0
      const maxAttempts = 50
      const interval = setInterval(() => {
        attempts++
        if (typeof window !== 'undefined' && window.mapkit && window.mapkit.Geocoder) {
          clearInterval(interval)
          resolve()
        } else if (attempts >= maxAttempts) {
          clearInterval(interval)
          reject(new Error('MapKit Geocoder not available'))
        }
      }, 100)
    })
  }

  /**
   * Reverse geocode a single coordinate
   */
  const reverseGeocode = async (
    lat: number,
    lon: number,
    time?: string
  ): Promise<LocationInfo | null> => {
    if (typeof window === 'undefined') {
      console.warn('Window not available for geocoding')
      return null
    }

    try {
      await waitForMapKit()
    } catch (error) {
      console.warn('MapKit Geocoder not available:', error)
      return null
    }

    // Check cache first
    const cacheKey = `${lat.toFixed(4)},${lon.toFixed(4)}`
    if (geocodingCache.has(cacheKey)) {
      const cached = geocodingCache.get(cacheKey)!
      return {
        ...cached,
        time: time || cached.time,
      }
    }

    return new Promise((resolve) => {
      try {
        const geocoder = new window.mapkit.Geocoder()
        const coordinate = new window.mapkit.Coordinate(lat, lon)

        geocoder.reverseLookup(coordinate, (error, data) => {
          if (error) {
            console.warn('Reverse geocoding error:', error)
            resolve(null)
            return
          }

          if (!data || !data.places || data.places.length === 0) {
            resolve(null)
            return
          }

          const place = data.places[0]
          const locationInfo: LocationInfo = {
            coordinate: { lat, lon },
            time: time || '',
            name: place.name,
            locality: place.locality,
            administrativeArea: place.administrativeArea,
            country: place.country,
            countryCode: place.countryCode,
            formattedAddress: place.formattedAddress,
            pointsOfInterest: [],
          }

          // Extract points of interest from other places in the results
          if (data.places.length > 1) {
            locationInfo.pointsOfInterest = data.places
              .slice(1)
              .map((p) => p.name)
              .filter((name): name is string => !!name)
          }

          // Cache the result
          geocodingCache.set(cacheKey, locationInfo)
          resolve(locationInfo)
        })
      } catch (error) {
        console.error('Error in reverse geocoding:', error)
        resolve(null)
      }
    })
  }

  /**
   * Sample key points along a passage for geocoding
   * Returns coordinates at regular intervals and significant points
   */
  const samplePassagePoints = (passage: Passage): Array<{ lat: number; lon: number; time: string }> => {
    const points: Array<{ lat: number; lon: number; time: string }> = []

    if (!passage.positions || passage.positions.length === 0) {
      // Fallback to start and end locations
      points.push({
        lat: passage.startLocation.lat,
        lon: passage.startLocation.lon,
        time: passage.startTime,
      })
      points.push({
        lat: passage.endLocation.lat,
        lon: passage.endLocation.lon,
        time: passage.endTime,
      })
      return points
    }

    // Sort positions by time
    const sortedPositions = [...passage.positions].sort((a, b) => {
      return Date.parse(a._time) - Date.parse(b._time)
    })

    // Always include start and end
    const startPos = sortedPositions[0]
    const endPos = sortedPositions[sortedPositions.length - 1]

    if (startPos) {
      points.push({
        lat: startPos.lat,
        lon: startPos.lon,
        time: startPos._time,
      })
    }

    // Sample points at regular intervals (every 10% of the journey or every 30 minutes, whichever is more frequent)
    const totalDuration = Date.parse(passage.endTime) - Date.parse(passage.startTime)
    const intervalMs = Math.min(totalDuration / 10, 30 * 60 * 1000) // 10% or 30 minutes

    const sampledTimes = new Set<number>()
    for (let time = Date.parse(passage.startTime); time <= Date.parse(passage.endTime); time += intervalMs) {
      sampledTimes.add(time)
    }

    // Find positions closest to sampled times
    for (const targetTime of sampledTimes) {
      if (targetTime === Date.parse(passage.startTime) || targetTime === Date.parse(passage.endTime)) {
        continue // Already added
      }

      let closestPos: PassagePosition | null = null
      let minTimeDiff = Infinity

      for (const pos of sortedPositions) {
        const timeDiff = Math.abs(Date.parse(pos._time) - targetTime)
        if (timeDiff < minTimeDiff) {
          minTimeDiff = timeDiff
          closestPos = pos
        }
      }

      if (closestPos && minTimeDiff < intervalMs / 2) {
        // Only add if it's reasonably close to the target time
        points.push({
          lat: closestPos.lat,
          lon: closestPos.lon,
          time: closestPos._time,
        })
      }
    }

    // Always include end
    if (endPos && endPos !== startPos) {
      points.push({
        lat: endPos.lat,
        lon: endPos.lon,
        time: endPos._time,
      })
    }

    // Remove duplicates (same coordinate)
    const uniquePoints: Array<{ lat: number; lon: number; time: string }> = []
    const seen = new Set<string>()

    for (const point of points) {
      const key = `${point.lat.toFixed(4)},${point.lon.toFixed(4)}`
      if (!seen.has(key)) {
        seen.add(key)
        uniquePoints.push(point)
      }
    }

    return uniquePoints
  }

  /**
   * Geocode all sampled points along a passage
   */
  const geocodePassage = async (passage: Passage): Promise<LocationInfo[]> => {
    if (isGeocoding.value) {
      console.warn('Geocoding already in progress')
      return []
    }

    isGeocoding.value = true

    try {
      const points = samplePassagePoints(passage)
      const locationInfos: LocationInfo[] = []

      // Geocode points with rate limiting (MapKit has rate limits)
      for (let i = 0; i < points.length; i++) {
        const point = points[i]
        if (!point) continue

        const locationInfo = await reverseGeocode(point.lat, point.lon, point.time)
        if (locationInfo) {
          locationInfos.push(locationInfo)
        }

        // Rate limit: wait 100ms between requests
        if (i < points.length - 1) {
          await new Promise((resolve) => setTimeout(resolve, 100))
        }
      }

      return locationInfos
    } finally {
      isGeocoding.value = false
    }
  }

  /**
   * Get a narrative/story from location information
   */
  const getLocationNarrative = (locations: LocationInfo[]): string => {
    if (locations.length === 0) {
      return 'No location information available for this passage.'
    }

    const parts: string[] = []
    const seenLocations = new Set<string>()

    for (const location of locations) {
      const locationName = location.locality || location.name || location.administrativeArea
      if (locationName && !seenLocations.has(locationName)) {
        seenLocations.add(locationName)
        const timeStr = location.time
          ? new Date(location.time).toLocaleString('en-US', {
              month: 'short',
              day: 'numeric',
              hour: '2-digit',
              minute: '2-digit',
            })
          : ''

        if (location.locality) {
          parts.push(
            `${timeStr ? `${timeStr}: ` : ''}Passed through ${location.locality}${
              location.administrativeArea ? `, ${location.administrativeArea}` : ''
            }${location.country ? `, ${location.country}` : ''}`
          )
        } else if (location.name) {
          parts.push(`${timeStr ? `${timeStr}: ` : ''}Near ${location.name}`)
        }
      }
    }

    return parts.join('. ') + (parts.length > 0 ? '.' : '')
  }

  return {
    reverseGeocode,
    samplePassagePoints,
    geocodePassage,
    getLocationNarrative,
    isGeocoding: readonly(isGeocoding),
  }
}


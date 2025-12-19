/**
 * Composable for loading and managing vessel encounters
 */

import type { Passage } from '~/types/passage'
import type { PassageEncounters, VesselEncounter, VesselPosition } from '~/types/vessel-encounter'
import { processVesselEncounters, type RawVesselData } from '~/utils/encounterProcessor'

export const useVesselEncounters = () => {
  const encounters = ref<PassageEncounters | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  /**
   * Load vessel encounters for a passage
   */
  const loadEncounters = async (passage: Passage) => {
    if (!passage.encountersFilename && !passage.filename) {
      encounters.value = null
      return
    }

    isLoading.value = true
    error.value = null

    try {
      // Try to load pre-processed encounters first
      if (passage.encountersFilename) {
        const response = await fetch(`/data/passages_vessel_data/${passage.encountersFilename}`)
        if (response.ok) {
          const data = await response.json()
          encounters.value = data as PassageEncounters
          isLoading.value = false
          return
        }
      }

      // Otherwise, try to load raw vessel data and process it
      // Look for vessel data file matching the passage
      // Passage filenames can be:
      // - passage_YYYY-MM-DD_passage_<timestamp>.json → vessels_passage_<timestamp>.json
      // - passage_YYYY-MM-DD_tideye_passage_<id>.json → vessels_tideye_passage_<id>.json
      let vesselFilename: string | null = null
      if (passage.filename) {
        // Remove 'passage_' prefix
        let name = passage.filename.replace(/^passage_/, '')
        // Remove date prefix pattern (YYYY-MM-DD_) if present
        name = name.replace(/^\d{4}-\d{2}-\d{2}_/, '')
        vesselFilename = `vessels_${name}`
      }

      if (vesselFilename) {
        const response = await fetch(`/data/passages_vessel_data/${vesselFilename}`)
        if (response.ok) {
          const rawData: RawVesselData = await response.json()
          const processed = processVesselEncounters(rawData, passage, {
            maxEncounterDistance: 50,
            segmentGapMinutes: 30,
            calculateDistances: true,
          })
          encounters.value = processed
        } else {
          encounters.value = null
        }
      } else {
        encounters.value = null
      }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to load vessel encounters'
      console.error('Error loading vessel encounters:', err)
      encounters.value = null
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Get vessels that are visible at a specific time
   */
  const getVisibleVessels = (timestamp: string): Array<{
    encounter: VesselEncounter
    position: VesselPosition
    segmentIndex: number
  }> => {
    if (!encounters.value) return []

    const targetTime = new Date(timestamp).getTime()
    const visible: Array<{
      encounter: VesselEncounter
      position: VesselPosition
      segmentIndex: number
    }> = []

    for (const encounter of encounters.value.encounters) {
      for (let segIdx = 0; segIdx < encounter.segments.length; segIdx++) {
        const segment = encounter.segments[segIdx]
        const segmentStart = new Date(segment.startTime).getTime()
        const segmentEnd = new Date(segment.endTime).getTime()

        // Check if timestamp is within this segment
        if (targetTime >= segmentStart && targetTime <= segmentEnd) {
          // Find the closest position in this segment
          let closestPos: VesselPosition | null = null
          let minTimeDiff = Infinity

          for (const pos of segment.positions) {
            const posTime = new Date(pos.timestamp).getTime()
            const timeDiff = Math.abs(posTime - targetTime)
            if (timeDiff < minTimeDiff) {
              minTimeDiff = timeDiff
              closestPos = pos
            }
          }

          if (closestPos) {
            visible.push({
              encounter,
              position: closestPos,
              segmentIndex: segIdx,
            })
          }
        }
      }
    }

    return visible
  }

  /**
   * Check if a vessel is entering (first appearance in current segment)
   */
  const isVesselEntering = (
    encounter: VesselEncounter,
    segmentIndex: number,
    timestamp: string
  ): boolean => {
    const segment = encounter.segments[segmentIndex]
    if (!segment) return false

    const targetTime = new Date(timestamp).getTime()
    const segmentStart = new Date(segment.startTime).getTime()
    const timeDiff = targetTime - segmentStart

    // Consider entering if within first 5 minutes of segment
    return timeDiff >= 0 && timeDiff <= 5 * 60 * 1000
  }

  /**
   * Check if a vessel is exiting (last appearance in current segment)
   */
  const isVesselExiting = (
    encounter: VesselEncounter,
    segmentIndex: number,
    timestamp: string
  ): boolean => {
    const segment = encounter.segments[segmentIndex]
    if (!segment) return false

    const targetTime = new Date(timestamp).getTime()
    const segmentEnd = new Date(segment.endTime).getTime()
    const timeDiff = segmentEnd - targetTime

    // Consider exiting if within last 5 minutes of segment
    return timeDiff >= 0 && timeDiff <= 5 * 60 * 1000
  }

  return {
    encounters: readonly(encounters),
    isLoading: readonly(isLoading),
    error: readonly(error),
    loadEncounters,
    getVisibleVessels,
    isVesselEntering,
    isVesselExiting,
  }
}


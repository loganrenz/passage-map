<template>
    <div class="relative w-full h-full">
        <div ref="mapContainer" class="w-full h-full" />
        <!-- Vessel details callout popover -->
        <div
            v-if="selectedVesselData"
            ref="vesselCalloutRef"
            class="vessel-callout-popover"
            :style="vesselCalloutStyle"
        >
            <div class="vessel-callout-content">
                <div class="vessel-callout-header">
                    <div class="vessel-callout-name">{{ selectedVesselData.name }}</div>
                    <span v-if="selectedVesselData.type && selectedVesselData.type !== 'vessel'" class="vessel-callout-type">
                        {{ selectedVesselData.type }}
                    </span>
                </div>
                <div class="vessel-callout-details">
                    <div v-if="selectedVesselData.mmsi" class="vessel-callout-detail">
                        <div class="vessel-callout-label">MMSI</div>
                        <div class="vessel-callout-value">{{ selectedVesselData.mmsi }}</div>
                    </div>
                    <div class="vessel-callout-detail">
                        <div class="vessel-callout-label">Speed</div>
                        <div class="vessel-callout-value">{{ selectedVesselData.speed }}</div>
                    </div>
                    <div class="vessel-callout-detail">
                        <div class="vessel-callout-label">Heading</div>
                        <div class="vessel-callout-value">{{ selectedVesselData.heading }}</div>
                    </div>
                    <div class="vessel-callout-detail">
                        <div class="vessel-callout-label">Distance</div>
                        <div class="vessel-callout-value">{{ selectedVesselData.distance }}</div>
                    </div>
                    <div v-if="selectedVesselData.length" class="vessel-callout-detail">
                        <div class="vessel-callout-label">Length</div>
                        <div class="vessel-callout-value">{{ selectedVesselData.length }}</div>
                    </div>
                    <div v-if="selectedVesselData.flag" class="vessel-callout-detail">
                        <div class="vessel-callout-label">Flag</div>
                        <div class="vessel-callout-value">{{ selectedVesselData.flag }}</div>
                    </div>
                </div>
                <div class="vessel-callout-timestamp">{{ selectedVesselData.timestamp }}</div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import type { Passage, LocationInfo } from '~/types/passage'
import type { VesselEncounter, VesselPosition } from '~/types/vessel-encounter'
import { useMapKit } from '~/composables/useMapKit'
import { getPassageBounds, getAllPassagesBounds, getPositionAtTime, calculateSpeed, calculateBearing, calculateDistanceKm } from '~/utils/mapHelpers'
import { useVesselEncounters } from '~/composables/useVesselEncounters'
import { getVesselIcon, getVesselIconSize } from '~/utils/vesselIcons'
import { addVesselPositionToMap, removeVesselPositionFromMap, updateVesselPositionAnnotation, type VesselPositionAnnotation } from '~/composables/useVesselPositionAnnotation'
import { preloadVesselNameMap, getVesselDisplayNameSync } from '~/utils/vesselNameMapper'

interface Props {
    passages?: Passage[]
    selectedPassage?: Passage | null
    autoFit?: boolean
    currentTime?: string | null
    speedColorCoding?: boolean
    showFeatures?: boolean
    showVessels?: boolean
    lockTideye?: 'center' | 'locked' | null
}

const props = withDefaults(defineProps<Props>(), {
    passages: () => [],
    selectedPassage: null,
    autoFit: true,
    currentTime: null,
    speedColorCoding: false,
    showFeatures: true,
    showVessels: true,
    lockTideye: null,
})

const emit = defineEmits<{
    'update:lockTideye': [lock: 'center' | 'locked' | null]
    'time-update': [timestamp: string]
}>()

const mapContainer = ref<HTMLElement | null>(null)
const { mapInstance, initializeMap, isInitialized } = useMapKit()
// Use shallowRef to prevent deep reactivity on MapKit overlay objects
const overlays = shallowRef<Array<mapkit.Overlay>>([])
// Separate reference for time-based marker (using custom vessel position annotation)
const timeMarker = shallowRef<VesselPositionAnnotation | null>(null)
const markerImage = ref<HTMLImageElement | null>(null)
// Store polyline coordinates and positions for accurate marker placement
const currentPolylineCoordinates = shallowRef<Array<{ coord: mapkit.Coordinate; time?: string }>>([])
// Vessel encounters management
const { loadEncounters, getVisibleVessels, isVesselEntering, isVesselExiting } = useVesselEncounters()
// Track vessel markers separately for fade animations
// Store encounter and position data with each marker for callout display
const vesselMarkers = shallowRef<Map<string, { 
    marker: mapkit.ImageAnnotation
    opacity: number
    fadeTimeout?: number
    encounter?: VesselEncounter
    position?: VesselPosition
}>>(new Map())
// Track the current time being processed to prevent race conditions
const currentVesselUpdateTime = ref<string | null>(null)
// Cache for vessel icon images
const vesselIconCache = new Map<string, HTMLImageElement>()
// Flag to track programmatic region changes to avoid infinite loops when locked
const isProgrammaticRegionChange = ref(false)
// Note: speedColorCoding, showFeatures, showVessels, and lockTideye are now props
// Track feature markers (water features and attractions)
const featureMarkers = shallowRef<Array<mapkit.Annotation>>([])
// Vessel callout state
const selectedVesselData = ref<{
    name: string
    type?: string
    mmsi?: string
    speed: string
    heading: string
    distance: string
    length?: string
    flag?: string
    timestamp: string
} | null>(null)
const vesselCalloutRef = ref<HTMLElement | null>(null)
const vesselCalloutStyle = ref<{ top: string; left: string }>({ top: '0px', left: '0px'})

const waitForMapKit = (): Promise<void> => {
    return new Promise((resolve, reject) => {
        if (typeof window !== 'undefined' && window.mapkit) {
            resolve()
            return
        }

        let attempts = 0
        const maxAttempts = 50
        const interval = setInterval(() => {
            attempts++
            if (typeof window !== 'undefined' && window.mapkit) {
                clearInterval(interval)
                resolve()
            } else if (attempts >= maxAttempts) {
                clearInterval(interval)
                reject(new Error('MapKitJS failed to load'))
            }
        }, 100)
    })
}

onMounted(async () => {
    if (!mapContainer.value) return

    try {
        // Preload vessel name mapping
        await preloadVesselNameMap()

        await waitForMapKit()
        await initializeMap(mapContainer.value)

        // Set up map region change listener to update marker position when zooming/panning
        // This ensures the marker stays aligned with the polyline at all zoom levels
        if (mapInstance.value) {
            // MapKit JS uses addEventListener for region change events
            mapInstance.value.addEventListener('region-change-end', () => {
                // If locked and this wasn't a programmatic change, re-center on tideye
                if (props.lockTideye === 'locked' && !isProgrammaticRegionChange.value) {
                    const tideyeCoord = getTideyeCoordinate()
                    if (tideyeCoord && mapInstance.value) {
                        const currentRegion = mapInstance.value.region
                        const centerCoord = currentRegion.center
                        // Only re-center if tideye is not already at center (with small tolerance)
                        const latDiff = Math.abs(tideyeCoord.latitude - centerCoord.latitude)
                        const lonDiff = Math.abs(tideyeCoord.longitude - centerCoord.longitude)
                        // Re-center if tideye is more than ~10 meters away from center
                        if (latDiff > 0.0001 || lonDiff > 0.0001) {
                            isProgrammaticRegionChange.value = true
                            centerMapOnTideye()
                            // Reset flag after a short delay
                            setTimeout(() => {
                                isProgrammaticRegionChange.value = false
                            }, 100)
                        }
                    }
                }
                
                // Update marker position when map region changes to keep it aligned with polyline
                if (props.currentTime && markerImage.value && props.selectedPassage) {
                    // Small delay to ensure polyline rendering is complete
                    nextTick(() => {
                        updateTimeMarker()
                    })
                }
            })

            // Set up click listener to handle polyline clicks
            // MapKit JS uses 'single-tap' event for map clicks
            mapInstance.value.addEventListener('single-tap', (event: any) => {
                console.log('[PassageMap] Map click detected (single-tap):', event)
                handleMapClick(event)
            })
            
            // Set up annotation selection listener for vessel callouts
            mapInstance.value.addEventListener('select', (event: any) => {
                if (event.annotation) {
                    handleAnnotationSelect(event.annotation)
                }
            })
            
            // Close callout when annotation is deselected
            mapInstance.value.addEventListener('deselect', () => {
                closeVesselCallout()
            })
        }

        // Also set up DOM click listener as fallback
        // This works by listening to clicks on the map container and converting screen coordinates
        if (mapContainer.value && mapInstance.value) {
            const handleContainerClick = (e: MouseEvent) => {
                if (!mapInstance.value || !props.selectedPassage) return
                
                // Convert page coordinates to map coordinates using MapKit JS API
                // MapKit JS uses convertPointOnPageToCoordinate method
                try {
                    const point = new DOMPoint(e.clientX, e.clientY)
                    const coord = mapInstance.value.convertPointOnPageToCoordinate(point)
                    
                    if (coord) {
                        console.log('[PassageMap] Container click detected, converted to coordinate:', coord)
                        handleMapClick({ coordinate: coord })
                    }
                } catch (error) {
                    console.error('[PassageMap] Error converting click to coordinate:', error)
                }
            }
            
            mapContainer.value.addEventListener('click', handleContainerClick)
            
            // Store handler for cleanup
            ;(mapContainer.value as any).__clickHandler = handleContainerClick
        }

        // Load custom marker image (Tideye icon)
        const img = new Image()
        img.src = '/images/tideye-icon.svg'
        img.onload = () => {
            markerImage.value = img
            // If there's already a selected passage, draw it now that map is initialized
            if (props.selectedPassage) {
                nextTick(() => {
                    redrawSelectedPassage(props.selectedPassage!)
                })
            }
            // Update marker if currentTime is already set
            if (props.currentTime && props.selectedPassage) {
                nextTick(() => {
                    updateTimeMarker()
                    // Center map if lockTideye is 'locked'
                    if (props.lockTideye === 'locked') {
                        centerMapOnTideye()
                    }
                })
            }
        }
        img.onerror = () => {
            console.error('Failed to load marker image')
        }
    } catch (error) {
        console.error('Failed to initialize map:', error)
    }
})

const clearOverlays = () => {
    if (!mapInstance.value) return

    overlays.value.forEach((item) => {
        // All items in overlays array are Overlay types (PolylineOverlay, etc.)
        mapInstance.value!.removeOverlay(item)
    })
    overlays.value = []
    // Clear stored polyline coordinates
    currentPolylineCoordinates.value = []
}

const clearVesselMarkers = () => {
    if (!mapInstance.value) return

    vesselMarkers.value.forEach(({ marker, fadeTimeout }) => {
        if (fadeTimeout) {
            clearTimeout(fadeTimeout)
        }
        mapInstance.value!.removeAnnotation(marker)
    })
    vesselMarkers.value.clear()
}

const clearFeatureMarkers = () => {
    if (!mapInstance.value) return

    featureMarkers.value.forEach((marker) => {
        mapInstance.value!.removeAnnotation(marker)
    })
    featureMarkers.value = []
}

const removeTimeMarker = () => {
    if (!mapInstance.value || !timeMarker.value) return
    // Type assertion needed because mapInstance is readonly
    removeVesselPositionFromMap(mapInstance.value as mapkit.Map, timeMarker.value)
    timeMarker.value = null
}

/**
 * Calculate distance between two coordinates in meters using Haversine formula
 */
const calculateDistance = (coord1: mapkit.Coordinate, coord2: mapkit.Coordinate): number => {
    const R = 6371000 // Earth radius in meters
    const lat1 = coord1.latitude * Math.PI / 180
    const lat2 = coord2.latitude * Math.PI / 180
    const deltaLat = (coord2.latitude - coord1.latitude) * Math.PI / 180
    const deltaLon = (coord2.longitude - coord1.longitude) * Math.PI / 180

    const a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
        Math.cos(lat1) * Math.cos(lat2) *
        Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    return R * c
}

/**
 * Find the closest point on a line segment to a given point
 * Returns the closest point on the segment and the distance
 * Uses geographic coordinate calculations
 */
const findClosestPointOnSegment = (
    point: mapkit.Coordinate,
    segmentStart: mapkit.Coordinate,
    segmentEnd: mapkit.Coordinate
): { point: mapkit.Coordinate; distance: number; t: number } => {
    // For geographic coordinates, we need to use a different approach
    // We'll approximate by converting to a local coordinate system
    
    // Calculate distances to both endpoints
    const distToStart = calculateDistance(point, segmentStart)
    const distToEnd = calculateDistance(point, segmentEnd)
    const segmentLength = calculateDistance(segmentStart, segmentEnd)

    // If segment is very short, return the closer endpoint
    if (segmentLength < 1) { // less than 1 meter
        if (distToStart < distToEnd) {
            return {
                point: segmentStart,
                distance: distToStart,
                t: 0
            }
        } else {
            return {
                point: segmentEnd,
                distance: distToEnd,
                t: 1
            }
        }
    }

    // Use linear interpolation in lat/lon space (approximation)
    // For small segments, this is accurate enough
    const lat1 = segmentStart.latitude
    const lon1 = segmentStart.longitude
    const lat2 = segmentEnd.latitude
    const lon2 = segmentEnd.longitude
    const latP = point.latitude
    const lonP = point.longitude

    // Calculate parameter t using perpendicular projection approximation
    // This works well for short segments
    const dx = lat2 - lat1
    const dy = lon2 - lon1
    const d2 = dx * dx + dy * dy

    if (d2 < 1e-10) {
        return {
            point: segmentStart,
            distance: distToStart,
            t: 0
        }
    }

    const t = Math.max(0, Math.min(1, 
        ((latP - lat1) * dx + (lonP - lon1) * dy) / d2
    ))

    // Interpolate to find closest point
    const closestLat = lat1 + t * dx
    const closestLon = lon1 + t * dy

    const closestPoint = new window.mapkit.Coordinate(closestLat, closestLon)
    const distance = calculateDistance(point, closestPoint)

    return {
        point: closestPoint,
        distance,
        t
    }
}

/**
 * Handle map click events to find closest point on polyline and update timeline
 */
const handleMapClick = (event: any) => {
    console.log('[PassageMap] handleMapClick called:', {
        hasSelectedPassage: !!props.selectedPassage,
        hasMapInstance: !!mapInstance.value,
        coordinatesCount: currentPolylineCoordinates.value.length,
        event: event
    })

    if (!props.selectedPassage || !mapInstance.value || currentPolylineCoordinates.value.length === 0) {
        console.log('[PassageMap] handleMapClick: Missing requirements, returning early')
        return
    }

    // MapKit JS event structure: event.coordinate or event.location
    const clickCoord = (event.coordinate || event.location) as mapkit.Coordinate | undefined
    if (!clickCoord) {
        console.log('[PassageMap] handleMapClick: No coordinate in event')
        return
    }

    console.log('[PassageMap] Click coordinate:', clickCoord.latitude, clickCoord.longitude)
    
    // Log first few polyline coordinates for comparison
    if (currentPolylineCoordinates.value.length > 0) {
        console.log('[PassageMap] First polyline coordinate:', {
            lat: currentPolylineCoordinates.value[0]?.coord?.latitude,
            lon: currentPolylineCoordinates.value[0]?.coord?.longitude
        })
        if (currentPolylineCoordinates.value.length > 1) {
            console.log('[PassageMap] Second polyline coordinate:', {
                lat: currentPolylineCoordinates.value[1]?.coord?.latitude,
                lon: currentPolylineCoordinates.value[1]?.coord?.longitude
            })
        }
    }

    // Calculate threshold based on zoom level for better usability
    // When zoomed out (large area visible), use larger threshold for easier clicking
    // When zoomed in (small area visible), use smaller threshold for precision
    let threshold = 1000 // meters (default)
    if (mapInstance.value) {
        const span = mapInstance.value.region.span
        // Use latitude span as a proxy for zoom level
        // Larger span = more zoomed out = larger threshold needed
        const latSpanDegrees = span.latitudeDelta
        const latSpanMeters = latSpanDegrees * 111000 // approximate conversion
        
        // More aggressive scaling: 
        // - Very zoomed in (1km view): ~100m threshold
        // - Medium zoom (10km view): ~500m threshold  
        // - Zoomed out (100km view): ~5000m threshold
        // - Very zoomed out (1000km view): ~20000m threshold
        // Use a power function for smoother scaling
        if (latSpanMeters < 2000) {
            // Very zoomed in: 100-300m
            threshold = 100 + (latSpanMeters / 2000) * 200
        } else if (latSpanMeters < 50000) {
            // Medium zoom: 300-2000m
            threshold = 300 + ((latSpanMeters - 2000) / 48000) * 1700
        } else if (latSpanMeters < 500000) {
            // Zoomed out: 2000-10000m
            threshold = 2000 + ((latSpanMeters - 50000) / 450000) * 8000
        } else {
            // Very zoomed out: 10000-20000m
            threshold = Math.min(20000, 10000 + ((latSpanMeters - 500000) / 1000000) * 10000)
        }
        
        // Ensure minimum and maximum bounds
        threshold = Math.max(100, Math.min(20000, threshold))
    }
    
    console.log('[PassageMap] Using threshold:', threshold, 'meters (zoom-adaptive)')

    let closestDistance = Infinity
    let closestTime: string | null = null
    let closestSegmentIndex = -1

    // Check each segment of the polyline
    for (let i = 0; i < currentPolylineCoordinates.value.length - 1; i++) {
        const start = currentPolylineCoordinates.value[i]
        const end = currentPolylineCoordinates.value[i + 1]
        
        if (!start || !end || !start.coord || !end.coord) continue

        const result = findClosestPointOnSegment(clickCoord, start.coord, end.coord)
        
        // Debug first few segments to see what's happening
        if (i < 3) {
            console.log(`[PassageMap] Segment ${i}:`, {
                start: { lat: start.coord.latitude, lon: start.coord.longitude },
                end: { lat: end.coord.latitude, lon: end.coord.longitude },
                distance: result.distance,
                threshold: threshold,
                withinThreshold: result.distance < threshold
            })
        }
        
        if (result.distance < threshold && result.distance < closestDistance) {
            closestDistance = result.distance
            closestSegmentIndex = i
            
            // Interpolate time between start and end points
            if (start.time && end.time) {
                const startTime = Date.parse(start.time)
                const endTime = Date.parse(end.time)
                const interpolatedTime = startTime + (endTime - startTime) * result.t
                closestTime = new Date(interpolatedTime).toISOString()
            } else if (start.time) {
                closestTime = start.time
            } else if (end.time) {
                closestTime = end.time
            }
        }
    }
    
    // If no point found within threshold, find the absolute closest for debugging
    if (closestDistance === Infinity && currentPolylineCoordinates.value.length > 0) {
        let absoluteClosest = Infinity
        for (let i = 0; i < currentPolylineCoordinates.value.length - 1; i++) {
            const start = currentPolylineCoordinates.value[i]
            const end = currentPolylineCoordinates.value[i + 1]
            if (!start || !end || !start.coord || !end.coord) continue
            const result = findClosestPointOnSegment(clickCoord, start.coord, end.coord)
            if (result.distance < absoluteClosest) {
                absoluteClosest = result.distance
            }
        }
        console.log('[PassageMap] Absolute closest distance (for debugging):', absoluteClosest, 'meters')
    }

    console.log('[PassageMap] Closest point found:', {
        distance: closestDistance,
        time: closestTime
    })

    // If we found a close point, emit the time update
    if (closestTime) {
        console.log('[PassageMap] Emitting time-update:', closestTime)
        emit('time-update', closestTime)
    } else {
        console.log('[PassageMap] No close point found (closest distance:', closestDistance, 'meters)')
    }
}

/**
 * Get tideye's current coordinate based on currentTime
 */
const getTideyeCoordinate = (): mapkit.Coordinate | null => {
    if (!window.mapkit || !props.currentTime || !props.selectedPassage) {
        return null
    }

    const passage = props.selectedPassage
    const targetTime = Date.parse(props.currentTime)
    let coord: mapkit.Coordinate | null = null

    if (currentPolylineCoordinates.value.length > 0) {
        // Find the closest position in the polyline coordinates
        let closestIndex = 0
        let minTimeDiff = Infinity

        for (let i = 0; i < currentPolylineCoordinates.value.length; i++) {
            const pos = currentPolylineCoordinates.value[i]
            if (pos && pos.time) {
                const timeDiff = Math.abs(Date.parse(pos.time) - targetTime)
                if (timeDiff < minTimeDiff) {
                    minTimeDiff = timeDiff
                    closestIndex = i
                }
            }
        }

        // Use the exact coordinate from the polyline
        const closestPos = currentPolylineCoordinates.value[closestIndex]
        if (closestPos) {
            coord = closestPos.coord

            // If we're between two points, interpolate to get a more accurate position
            if (closestIndex < currentPolylineCoordinates.value.length - 1) {
                const currentPos = currentPolylineCoordinates.value[closestIndex]
                const nextPos = currentPolylineCoordinates.value[closestIndex + 1]

                if (currentPos && nextPos && currentPos.time && nextPos.time) {
                    const currentTime = Date.parse(currentPos.time)
                    const nextTime = Date.parse(nextPos.time)

                    if (targetTime >= currentTime && targetTime <= nextTime) {
                        const timeDiff = nextTime - currentTime
                        if (timeDiff > 0) {
                            const progress = (targetTime - currentTime) / timeDiff
                            const lat = currentPos.coord.latitude + (nextPos.coord.latitude - currentPos.coord.latitude) * progress
                            const lon = currentPos.coord.longitude + (nextPos.coord.longitude - currentPos.coord.longitude) * progress
                            coord = new window.mapkit.Coordinate(lat, lon)
                        }
                    }
                }
            }
        }
    } else {
        // Fallback to interpolation if no polyline coordinates are stored
        const position = getPositionAtTime(passage, props.currentTime)
        if (!position) {
            return null
        }
        coord = new window.mapkit.Coordinate(position.lat, position.lon)
    }

    return coord
}

const updateTimeMarker = () => {
    if (!mapInstance.value || !window.mapkit || !props.currentTime || !markerImage.value) {
        removeTimeMarker()
        return
    }

    // Only show time marker if we have a selected passage
    const passage = props.selectedPassage
    if (!passage) {
        removeTimeMarker()
        return
    }

    // Get tideye's current coordinate
    const coord = getTideyeCoordinate()
    if (!coord) {
        removeTimeMarker()
        return
    }

    const targetTime = Date.parse(props.currentTime)

    const currentDate = new Date(props.currentTime)

    // Calculate speed and heading if we have position data
    let speed: number | undefined
    let heading: number | undefined
    let distance: number | undefined

    if (passage.positions && passage.positions.length > 0) {
        // Find the closest position to current time
        let closestPosIndex = -1
        let minTimeDiff = Infinity

        for (let i = 0; i < passage.positions.length; i++) {
            const pos = passage.positions[i]
            if (!pos) continue
            const timeDiff = Math.abs(Date.parse(pos._time) - targetTime)
            if (timeDiff < minTimeDiff) {
                minTimeDiff = timeDiff
                closestPosIndex = i
            }
        }

        if (closestPosIndex >= 0) {
            const currentPos = passage.positions[closestPosIndex]
            const startPos = passage.positions[0]

            // Calculate distance from start
            if (startPos && currentPos) {
                distance = calculateDistanceKm(
                    startPos.lat,
                    startPos.lon,
                    currentPos.lat,
                    currentPos.lon
                )
            }

            // Calculate speed and heading from previous position
            if (closestPosIndex > 0 && currentPos) {
                const prevPos = passage.positions[closestPosIndex - 1]
                if (prevPos) {
                    speed = calculateSpeed(
                        prevPos.lat,
                        prevPos.lon,
                        prevPos._time,
                        currentPos.lat,
                        currentPos.lon,
                        currentPos._time
                    )
                    heading = calculateBearing(
                        prevPos.lat,
                        prevPos.lon,
                        currentPos.lat,
                        currentPos.lon
                    )
                }
            } else if (closestPosIndex < passage.positions.length - 1 && currentPos) {
                // If at first position, calculate from next position
                const nextPos = passage.positions[closestPosIndex + 1]
                if (nextPos) {
                    speed = calculateSpeed(
                        currentPos.lat,
                        currentPos.lon,
                        currentPos._time,
                        nextPos.lat,
                        nextPos.lon,
                        nextPos._time
                    )
                    heading = calculateBearing(
                        currentPos.lat,
                        currentPos.lon,
                        nextPos.lat,
                        nextPos.lon
                    )
                }
            }
        }
    }

    // Format time string
    const timeString = currentDate.toLocaleString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZoneName: 'short'
    })

    // Build subtitle with additional data
    const subtitleParts = [timeString]
    if (speed !== undefined && !isNaN(speed)) {
        subtitleParts.push(`${speed.toFixed(1)} kn`)
    }
    if (heading !== undefined && !isNaN(heading)) {
        subtitleParts.push(`Hdg: ${Math.round(heading)}°`)
    }
    if (distance !== undefined && !isNaN(distance)) {
        subtitleParts.push(`${distance.toFixed(1)} km`)
    }

    const newSubtitle = subtitleParts.join(' • ')

    // Update existing annotation if it exists, otherwise create a new one
    if (timeMarker.value && timeMarker.value.annotation) {
        // Update the existing annotation's coordinate and subtitle
        // This prevents blinking by avoiding removal and recreation
        updateVesselPositionAnnotation(timeMarker.value, coord, newSubtitle)
    } else {
        // Create vessel position annotation using the custom composable
        const vesselAnnotation = addVesselPositionToMap(mapInstance.value as mapkit.Map, {
            coordinate: coord,
            iconImage: markerImage.value,
            size: { width: 40, height: 40 },
            title: 'Vessel Position',
            subtitle: newSubtitle,
            displayPriority: 1000,
            showDebugBorder: false, // Debug border disabled
        })

        // Store the annotation reference for cleanup
        timeMarker.value = {
            annotation: markRaw(vesselAnnotation.annotation),
        }
    }
}

const drawPassage = (passage: Passage, color = '#007AFF') => {
    if (!mapInstance.value || !window.mapkit) return

    const coordinates: mapkit.Coordinate[] = []
    const allPositions: Array<{ coord: mapkit.Coordinate; time?: string }> = []

    if (passage.positions && passage.positions.length > 0) {
        // Sort positions by time to ensure correct route order
        const sortedPositions = [...passage.positions].sort((a, b) => {
            const timeA = new Date(a._time).getTime()
            const timeB = new Date(b._time).getTime()
            return timeA - timeB
        })

        // Use detailed positions if available
        sortedPositions.forEach((pos) => {
            const coord = new window.mapkit.Coordinate(pos.lat, pos.lon)
            coordinates.push(coord)
            allPositions.push({ coord, time: pos._time })
        })

        // Log position count for debugging
        console.log(`[PassageMap] Drawing passage "${passage.name || passage.id}":`, {
            totalPositions: passage.positions.length,
            coordinatesAdded: coordinates.length,
            filename: passage.filename || 'N/A',
        })
    } else {
        // Use start and end locations
        const startCoord = new window.mapkit.Coordinate(passage.startLocation.lat, passage.startLocation.lon)
        const endCoord = new window.mapkit.Coordinate(passage.endLocation.lat, passage.endLocation.lon)
        coordinates.push(startCoord, endCoord)
        allPositions.push({ coord: startCoord, time: passage.startTime })
        allPositions.push({ coord: endCoord, time: passage.endTime })
    }

    // Store coordinates for accurate marker placement
    currentPolylineCoordinates.value = allPositions

    // Helper function to get color based on speed
    const getSpeedColor = (speedKnots: number): string => {
        if (speedKnots < 5) return '#4CAF50' // Green for slow (0-5 kn)
        if (speedKnots < 10) return '#8BC34A' // Light green (5-10 kn)
        if (speedKnots < 15) return '#FFC107' // Yellow (10-15 kn)
        if (speedKnots < 20) return '#FF9800' // Orange (15-20 kn)
        return '#F44336' // Red for fast (20+ kn)
    }

    if (props.speedColorCoding && passage.positions && passage.positions.length > 1) {
        // Create multiple polyline segments with speed-based colors
        const sortedPositions = [...passage.positions].sort((a, b) => {
            const timeA = new Date(a._time).getTime()
            const timeB = new Date(b._time).getTime()
            return timeA - timeB
        })

        for (let i = 0; i < sortedPositions.length - 1; i++) {
            const pos1 = sortedPositions[i]
            const pos2 = sortedPositions[i + 1]
            if (!pos1 || !pos2) continue

            const speed = calculateSpeed(
                pos1.lat,
                pos1.lon,
                pos1._time,
                pos2.lat,
                pos2.lon,
                pos2._time
            )

            const segmentColor = getSpeedColor(speed)
            const coord1 = new window.mapkit.Coordinate(pos1.lat, pos1.lon)
            const coord2 = new window.mapkit.Coordinate(pos2.lat, pos2.lon)

            const segment = new window.mapkit.PolylineOverlay([coord1, coord2], {
                style: new window.mapkit.Style({
                    strokeColor: segmentColor,
                    lineWidth: 4,
                    lineCap: 'round',
                    lineJoin: 'round',
                }),
            })

            const rawSegment = markRaw(segment)
            mapInstance.value.addOverlay(rawSegment)
            overlays.value.push(rawSegment)
        }
    } else {
        // Create single polyline for route
        const polyline = new window.mapkit.PolylineOverlay(coordinates, {
            style: new window.mapkit.Style({
                strokeColor: color,
                lineWidth: 3,
                lineCap: 'round',
                lineJoin: 'round',
            }),
        })

        // Log polyline point count
        console.log(`[PassageMap] Polyline created with ${coordinates.length} points`)

        // Mark MapKit objects as non-reactive to prevent Vue reactivity warnings
        const rawPolyline = markRaw(polyline)
        mapInstance.value.addOverlay(rawPolyline)
        overlays.value.push(rawPolyline)
    }

    // No individual markers - we only show the polyline and a single custom marker
    // The custom marker is managed separately via updateTimeMarker()

    // Return null since we might have multiple overlays
    return null
}

const fitToPassages = (passages: Passage[]) => {
    if (!mapInstance.value || passages.length === 0) return

    const bounds = getAllPassagesBounds(passages)

    // Use exact bounds with no padding for tightest fit
    // Only add minimal padding if bounds are too small to prevent invalid regions
    const latSpan = bounds.north - bounds.south
    const lonSpan = bounds.east - bounds.west

    // Add tiny padding only if span is very small to prevent invalid coordinate regions
    const minSpan = 0.0001
    const latPadding = latSpan < minSpan ? minSpan : 0
    const lonPadding = lonSpan < minSpan ? minSpan : 0

    const paddedNorth = bounds.north + latPadding
    const paddedSouth = bounds.south - latPadding
    const paddedEast = bounds.east + lonPadding
    const paddedWest = bounds.west - lonPadding

    const region = new window.mapkit.CoordinateRegion(
        new window.mapkit.Coordinate((paddedNorth + paddedSouth) / 2, (paddedEast + paddedWest) / 2),
        new window.mapkit.CoordinateSpan(paddedNorth - paddedSouth, paddedEast - paddedWest)
    )

    mapInstance.value.setRegionAnimated(region, true)
}

const fitToPassage = (passage: Passage) => {
    if (!mapInstance.value) return

    const bounds = getPassageBounds(passage)

    // Log bounds for debugging
    console.log('[PassageMap] Fitting to passage:', {
        passageId: passage.id,
        hasPositions: passage.positions ? passage.positions.length : 0,
        bounds: bounds,
        lockTideye: props.lockTideye
    })

    // If locked, keep tideye centered and fit polyline in view
    if (props.lockTideye === 'locked' && props.currentTime) {
        const tideyeCoord = getTideyeCoordinate()
        if (tideyeCoord) {
            // Calculate the distance from tideye to each edge of the bounds
            const latDistNorth = Math.abs(bounds.north - tideyeCoord.latitude)
            const latDistSouth = Math.abs(tideyeCoord.latitude - bounds.south)
            const lonDistEast = Math.abs(bounds.east - tideyeCoord.longitude)
            const lonDistWest = Math.abs(tideyeCoord.longitude - bounds.west)
            
            // Use the maximum distance in each direction to ensure everything fits
            const maxLatSpan = Math.max(latDistNorth, latDistSouth) * 2
            const maxLonSpan = Math.max(lonDistEast, lonDistWest) * 2
            
            // Add small padding to ensure polyline is fully visible
            const padding = 0.1 // 10% padding
            const latSpan = maxLatSpan * (1 + padding)
            const lonSpan = maxLonSpan * (1 + padding)
            
            // Ensure minimum span to prevent invalid regions
            const minSpan = 0.0001
            const finalLatSpan = Math.max(latSpan, minSpan)
            const finalLonSpan = Math.max(lonSpan, minSpan)
            
            const region = new window.mapkit.CoordinateRegion(
                tideyeCoord, // Center on tideye
                new window.mapkit.CoordinateSpan(finalLatSpan, finalLonSpan)
            )
            
            isProgrammaticRegionChange.value = true
            mapInstance.value.setRegionAnimated(region, true)
            setTimeout(() => {
                isProgrammaticRegionChange.value = false
            }, 100)
            return
        }
    }

    // Default behavior: center on polyline bounds
    // Use exact bounds with no padding for tightest fit
    // Only add minimal padding if bounds are too small to prevent invalid regions
    const latSpan = bounds.north - bounds.south
    const lonSpan = bounds.east - bounds.west

    // Add tiny padding only if span is very small to prevent invalid coordinate regions
    const minSpan = 0.0001
    const latPadding = latSpan < minSpan ? minSpan : 0
    const lonPadding = lonSpan < minSpan ? minSpan : 0

    const paddedNorth = bounds.north + latPadding
    const paddedSouth = bounds.south - latPadding
    const paddedEast = bounds.east + lonPadding
    const paddedWest = bounds.west - lonPadding

    const region = new window.mapkit.CoordinateRegion(
        new window.mapkit.Coordinate((paddedNorth + paddedSouth) / 2, (paddedEast + paddedWest) / 2),
        new window.mapkit.CoordinateSpan(paddedNorth - paddedSouth, paddedEast - paddedWest)
    )

    isProgrammaticRegionChange.value = true
    mapInstance.value.setRegionAnimated(region, true)
    setTimeout(() => {
        isProgrammaticRegionChange.value = false
    }, 100)
}

watch(
    () => props.passages,
    (newPassages) => {
        if (!isInitialized.value) return

        clearOverlays()

        const colors = ['#007AFF', '#34C759', '#FF9500', '#FF3B30', '#AF52DE', '#FF2D55']
        newPassages.forEach((passage, index) => {
            const color = colors[index % colors.length]
            drawPassage(passage, color)
        })

        // Always fit to passages when polylines are shown
        if (newPassages.length > 0) {
            // Use a small delay to ensure overlays are rendered before fitting
            nextTick(() => {
                setTimeout(() => {
                    fitToPassages(newPassages)
                }, 100)
            })
        }
    },
    { deep: true }
)

/**
 * Parse points of interest and extract coordinates for features
 */
const parseFeaturePoints = (locations: LocationInfo[]): Array<{
    coord: mapkit.Coordinate
    name: string
    type: 'water' | 'attraction'
    distance?: string
}> => {
    const features: Array<{
        coord: mapkit.Coordinate
        name: string
        type: 'water' | 'attraction'
        distance?: string
    }> = []

    for (const location of locations) {
        if (!location.pointsOfInterest || location.pointsOfInterest.length === 0) {
            continue
        }

        const baseCoord = new window.mapkit.Coordinate(
            location.coordinate.lat,
            location.coordinate.lon
        )

        for (const poi of location.pointsOfInterest) {
            // Parse water features (🌊 prefix)
            if (poi.startsWith('🌊')) {
                const match = poi.match(/🌊\s*(.+?)\s*\(([^,]+),\s*([\d.]+)km away\)/)
                if (match) {
                    features.push({
                        coord: baseCoord, // Use location coordinate as approximation
                        name: match[1],
                        type: 'water',
                        distance: match[3] + 'km',
                    })
                }
            }
            // Parse attractions (📍 prefix)
            else if (poi.startsWith('📍')) {
                const match = poi.match(/📍\s*(.+?)\s*\(([\d.]+)km away\)/)
                if (match) {
                    features.push({
                        coord: baseCoord, // Use location coordinate as approximation
                        name: match[1],
                        type: 'attraction',
                        distance: match[2] + 'km',
                    })
                }
            }
        }
    }

    return features
}

/**
 * Create markers for water features and attractions
 */
const createFeatureMarkers = (passage: Passage) => {
    if (!mapInstance.value || !window.mapkit || !passage.locations) return

    clearFeatureMarkers()

    if (!props.showFeatures) return

    const features = parseFeaturePoints(passage.locations)

    for (const feature of features) {
        // Create a simple marker annotation
        // For water features, use anchor icon style; for attractions, use landmark style
        const marker = new window.mapkit.MarkerAnnotation(feature.coord, {
            title: feature.name,
            subtitle: feature.distance ? `${feature.distance} from route` : 'Near route',
            displayPriority: feature.type === 'water' ? 600 : 550,
            color: feature.type === 'water' ? '#0066CC' : '#FF6600', // Blue for water, orange for attractions
            glyphText: feature.type === 'water' ? '⚓' : '📍',
            selectedGlyphColor: '#FFFFFF',
        })

        const rawMarker = markRaw(marker)
        mapInstance.value.addAnnotation(rawMarker)
        featureMarkers.value.push(rawMarker)
    }

    if (features.length > 0) {
        console.log(`[PassageMap] Added ${features.length} feature markers (${features.filter(f => f.type === 'water').length} water, ${features.filter(f => f.type === 'attraction').length} attractions)`)
    }
}

const redrawSelectedPassage = async (passage: Passage) => {
    if (!isInitialized.value || !passage) return

    clearOverlays()
    clearVesselMarkers()
    clearFeatureMarkers()
    removeTimeMarker()
    drawPassage(passage, '#007AFF')
    
    // Create feature markers if locations are available
    if (passage.locations && passage.locations.length > 0) {
        createFeatureMarkers(passage)
    }

    // Load vessel encounters for this passage
    await loadEncounters(passage)

    // Always fit to passage when polyline is shown using getPassageBounds helper
    // This ensures we zoom to the full passage including all positions
    // Use a small delay to ensure overlay is rendered before fitting
    // Only fit if we have positions OR if we don't have a filename (meaning positions won't load)
    const shouldFitNow = passage.positions && passage.positions.length > 0 || !passage.filename

    if (shouldFitNow) {
        nextTick(() => {
            setTimeout(() => {
                // fitToPassage uses getPassageBounds which includes positions if available
                // If locked, fitToPassage will already keep tideye centered
                fitToPassage(passage)
                
                // After fitting to show all points, center on tideye if currentTime is set and not locked
                // (When locked, fitToPassage already handles centering)
                if (props.currentTime && props.lockTideye !== 'locked') {
                    setTimeout(() => {
                        centerMapOnTideye()
                    }, 50)
                }
            }, 100)
        })
    }
    // If passage has filename but no positions yet, the positions watcher will trigger fitToPassage

    // Update time marker and vessels if currentTime is set and image is loaded
    if (props.currentTime && markerImage.value) {
        nextTick(() => {
            updateTimeMarker()
            updateVesselMarkers()
        })
    }
}

watch(
    () => props.selectedPassage,
    (newPassage) => {
        if (newPassage) {
            redrawSelectedPassage(newPassage)
        } else {
            // Clear overlays when no passage is selected
            if (isInitialized.value) {
                clearOverlays()
                clearVesselMarkers()
                clearFeatureMarkers()
                removeTimeMarker()
            }
            // Reset lock state when passage is deselected
            emit('update:lockTideye', null)
        }
    }
)

// Watch for changes to positions array to redraw when positions are loaded
// This is important when loading from URL - passage might be selected before positions are loaded
// When positions load, we redraw the polyline and zoom to the passage using fitToPassage
watch(
    () => props.selectedPassage?.positions,
    (newPositions, oldPositions) => {
        // Only redraw if:
        // 1. We have a selected passage
        // 2. New positions exist and are different from old (positions were just loaded)
        // 3. Map is initialized
        const passage = props.selectedPassage
        if (passage && isInitialized.value && newPositions && newPositions !== oldPositions) {
            // Check if positions were actually added (went from undefined/empty to having data)
            const hadNoPositions = !oldPositions || oldPositions.length === 0
            const hasPositions = newPositions.length > 0

            if (hasPositions && (hadNoPositions || newPositions.length !== oldPositions?.length)) {
                console.log('[PassageMap] Positions loaded, redrawing passage:', {
                    passageId: passage.id,
                    positionsCount: newPositions.length,
                    hadNoPositions
                })

                // Redraw passage with positions and zoom to it using fitToPassage
                // fitToPassage uses getPassageBounds which will now include all the loaded positions
                clearOverlays()
                removeTimeMarker()
                drawPassage(passage, '#007AFF')

                // Now fit to passage with positions loaded - this is the key fix
                nextTick(() => {
                    setTimeout(() => {
                        // fitToPassage uses getPassageBounds which will now include all the loaded positions
                        // If locked, fitToPassage will already keep tideye centered
                        fitToPassage(passage)
                        
                        // After fitting to show all points, center on tideye if currentTime is set and not locked
                        // (When locked, fitToPassage already handles centering)
                        if (props.currentTime && props.lockTideye !== 'locked') {
                            setTimeout(() => {
                                centerMapOnTideye()
                            }, 50)
                        }
                    }, 150) // Slightly longer delay to ensure polyline is rendered
                })

                // Update time marker if currentTime is set and image is loaded
                if (props.currentTime && markerImage.value) {
                    nextTick(() => {
                        updateTimeMarker()
                    })
                }
                
                // Create feature markers if locations are available
                if (passage.locations && passage.locations.length > 0 && props.showFeatures) {
                    nextTick(() => {
                        createFeatureMarkers(passage)
                    })
                }
            }
        }
    }
)

/**
 * Load vessel icon image
 * Uses cache busting on first load to ensure new icons are loaded after updates
 * Ensures proper SVG icon paths and handles errors gracefully
 */
const loadVesselIcon = async (iconPath: string): Promise<HTMLImageElement> => {
    // Normalize icon path - ensure it starts with /images/
    const normalizedPath = iconPath.startsWith('/images/') 
        ? iconPath 
        : iconPath.startsWith('images/')
        ? `/${iconPath}`
        : `/images/${iconPath}`
    
    const cacheKey = normalizedPath
    
    if (vesselIconCache.has(cacheKey)) {
        const cached = vesselIconCache.get(cacheKey)!
        // Verify cached image is still valid
        if (cached && cached.src && cached.complete && !cached.naturalWidth) {
            // Image failed to load, remove from cache and retry
            vesselIconCache.delete(cacheKey)
        } else if (cached && cached.src) {
            return cached
        }
    }

    return new Promise((resolve, reject) => {
        const img = new Image()
        // Add cache busting only on first load to force browser to check for updates
        // Use a version constant that can be updated when icons change
        const version = '3' // Increment this when icons are updated
        const versionedPath = `${normalizedPath}?v=${version}`
        
        img.onload = () => {
            if (img.naturalWidth === 0 || img.naturalHeight === 0) {
                // Image loaded but has zero dimensions (likely invalid)
                console.warn(`Vessel icon loaded but has zero dimensions: ${normalizedPath}`)
                // Try fallback
                loadFallbackIcon(resolve, reject, normalizedPath)
            } else {
                vesselIconCache.set(cacheKey, img)
                resolve(img)
            }
        }
        
        img.onerror = () => {
            console.warn(`Failed to load vessel icon with version: ${versionedPath}, trying without version`)
            // If versioned load fails, try without version
            const img2 = new Image()
            img2.onload = () => {
                if (img2.naturalWidth === 0 || img2.naturalHeight === 0) {
                    loadFallbackIcon(resolve, reject, normalizedPath)
                } else {
                    vesselIconCache.set(cacheKey, img2)
                    resolve(img2)
                }
            }
            img2.onerror = () => {
                // Fallback to default icon
                console.warn(`Failed to load vessel icon: ${normalizedPath}, using default`)
                loadFallbackIcon(resolve, reject, normalizedPath)
            }
            img2.src = normalizedPath
        }
        
        img.src = versionedPath
    })
}

/**
 * Load fallback default icon
 */
const loadFallbackIcon = (
    resolve: (value: HTMLImageElement) => void,
    reject: (reason?: any) => void,
    originalPath: string
) => {
    const defaultIcon = '/images/vessel-marker.svg'
    if (vesselIconCache.has(defaultIcon)) {
        const cached = vesselIconCache.get(defaultIcon)!
        if (cached && cached.src) {
            resolve(cached)
            return
        }
    }
    
    const defaultImg = new Image()
    defaultImg.onload = () => {
        vesselIconCache.set(defaultIcon, defaultImg)
        resolve(defaultImg)
    }
    defaultImg.onerror = () => {
        console.error(`Failed to load default vessel icon: ${defaultIcon}`)
        reject(new Error(`Failed to load vessel icon: ${originalPath} and fallback ${defaultIcon}`))
    }
    defaultImg.src = defaultIcon
}

/**
 * Update vessel markers based on current time
 */
const handleZoomToFit = () => {
    if (!mapInstance.value) return

    if (props.selectedPassage) {
        fitToPassage(props.selectedPassage)
    } else if (props.passages.length > 0) {
        fitToPassages(props.passages)
    }
}

const centerMapOnTideye = () => {
    if (!mapInstance.value || !window.mapkit) return

    const coord = getTideyeCoordinate()
    if (!coord) return

    // Center the map on tideye's position with current zoom level
    const currentRegion = mapInstance.value.region
    const region = new window.mapkit.CoordinateRegion(
        coord,
        currentRegion.span
    )

    isProgrammaticRegionChange.value = true
    mapInstance.value.setRegionAnimated(region, true)
    setTimeout(() => {
        isProgrammaticRegionChange.value = false
    }, 100)
}

const centerMapOnTime = (timestamp: string) => {
    if (!mapInstance.value || !window.mapkit || !props.selectedPassage) return

    const position = getPositionAtTime(props.selectedPassage, timestamp)
    if (!position) return

    const coord = new window.mapkit.Coordinate(position.lat, position.lon)
    
    // Center the map on the position with current zoom level
    const currentRegion = mapInstance.value.region
    const region = new window.mapkit.CoordinateRegion(
        coord,
        currentRegion.span
    )

    mapInstance.value.setRegionAnimated(region, true)
    
    // Also update currentTime so the marker updates
    // We'll need to emit this or handle it via props
}

const handleCenterOnTideye = () => {
    if (!mapInstance.value || !window.mapkit || !props.selectedPassage || !props.currentTime) return

    // Cycle through states: null -> 'center' -> 'locked' -> null
    let newState: 'center' | 'locked' | null
    if (props.lockTideye === null) {
        // First click: center once
        newState = 'center'
        centerMapOnTideye()
    } else if (props.lockTideye === 'center') {
        // Second click: lock (auto-center)
        newState = 'locked'
        centerMapOnTideye()
    } else {
        // Third click: unlock
        newState = null
    }
    emit('update:lockTideye', newState)
}

/**
 * Handle annotation selection - show vessel details callout
 */
const handleAnnotationSelect = (annotation: mapkit.Annotation) => {
    // Find the vessel marker that corresponds to this annotation
    for (const [vesselId, { marker, encounter, position }] of vesselMarkers.value.entries()) {
        if (marker === annotation && encounter && position) {
            showVesselCallout(encounter, position, annotation)
            break
        }
    }
}

/**
 * Show vessel details callout popover
 */
const showVesselCallout = (
    encounter: VesselEncounter,
    position: VesselPosition,
    annotation: mapkit.Annotation
) => {
    const vessel = encounter.vessel
    const vesselName = getVesselDisplayNameSync(
        vessel.mmsi || vessel.id,
        vessel.name
    )
    
    // Format speed
    const speed = position.speed !== undefined 
        ? `${position.speed.toFixed(1)} knots`
        : 'N/A'
    
    // Format heading
    const heading = position.heading !== undefined
        ? `${Math.round(position.heading)}°`
        : 'N/A'
    
    // Calculate distance to our vessel (Tideye)
    let distanceText = 'N/A'
    if (props.selectedPassage && props.currentTime) {
        const tideyePos = getPositionAtTime(props.selectedPassage, props.currentTime)
        if (tideyePos) {
            const distance = calculateDistanceKm(tideyePos.lat, tideyePos.lon, position.lat, position.lon)
            distanceText = `${distance.toFixed(2)} km`
        }
    }
    
    // Format vessel type
    const vesselType = vessel.type && vessel.type !== 'vessel' && vessel.type !== 'unknown'
        ? vessel.type.charAt(0).toUpperCase() + vessel.type.slice(1)
        : undefined
    
    // Format timestamp
    const time = new Date(position.timestamp)
    const timestamp = time.toLocaleString('en-US', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
    })
    
    // Format length
    const lengthText = vessel.length
        ? typeof vessel.length === 'number' 
            ? `${vessel.length}m`
            : vessel.length
        : undefined
    
    selectedVesselData.value = {
        name: vesselName,
        type: vesselType,
        mmsi: vessel.mmsi,
        speed,
        heading,
        distance: distanceText,
        length: lengthText,
        flag: vessel.flag,
        timestamp,
    }
    
    // Position the callout near the annotation
    nextTick(() => {
        if (mapInstance.value && annotation && mapContainer.value) {
            // Convert annotation coordinate to screen point
            const point = mapInstance.value.convertCoordinateToPointOnPage(annotation.coordinate)
            if (point && vesselCalloutRef.value) {
                // Position callout above the annotation
                const calloutWidth = 320 // max-width from CSS
                const calloutHeight = vesselCalloutRef.value.offsetHeight || 200
                const offsetX = point.x - calloutWidth / 2
                const offsetY = point.y - calloutHeight - 60 // Above the marker
                
                vesselCalloutStyle.value = {
                    left: `${Math.max(10, Math.min(offsetX, window.innerWidth - calloutWidth - 10))}px`,
                    top: `${Math.max(10, offsetY)}px`,
                }
            }
        }
    })
}

/**
 * Close vessel callout
 */
const closeVesselCallout = () => {
    selectedVesselData.value = null
}

/**
 * Set up custom callout for a vessel annotation (legacy - now handled via selection events)
 */
const setupVesselCallout = (
    annotation: mapkit.ImageAnnotation,
    encounter: VesselEncounter,
    position: VesselPosition
) => {
    // Callout is now handled via annotation selection events
    // This function is kept for potential future use
}

const updateVesselMarkers = async () => {
    if (!mapInstance.value || !window.mapkit || !props.currentTime || !props.selectedPassage || !props.showVessels) {
        clearVesselMarkers()
        currentVesselUpdateTime.value = null
        return
    }

    // Store the time we're processing to prevent race conditions
    const processingTime = props.currentTime
    currentVesselUpdateTime.value = processingTime

    try {
        // CRITICAL FIX: Clear ALL pending fade-out timeouts at the start
        // This prevents vessels from disappearing when playback is paused
        // When paused, currentTime doesn't change, so updateVesselMarkers isn't called again,
        // but pending fade-out timeouts from previous updates would still execute
        vesselMarkers.value.forEach(({ fadeTimeout }) => {
            if (fadeTimeout) {
                clearTimeout(fadeTimeout)
            }
        })
        // Clear all fade timeouts from the markers
        vesselMarkers.value.forEach((markerData) => {
            markerData.fadeTimeout = undefined
        })

        const visibleVessels = getVisibleVessels(processingTime)
        console.log(`[PassageMap] Updating vessel markers for time ${processingTime}: ${visibleVessels.length} vessels visible`)
        
        // Check if another update has started while we were processing
        // If so, abort this update to prevent showing stale data
        if (currentVesselUpdateTime.value !== processingTime) {
            console.log('[PassageMap] Aborting vessel update - newer update in progress')
            return
        }
        const currentVesselIds = new Set<string>()

        // Build the set of visible vessel IDs and clear any pending fade-out timeouts
        for (const { encounter, position, segmentIndex } of visibleVessels) {
            const vesselId = `${encounter.vessel.id}-${segmentIndex}`
            currentVesselIds.add(vesselId)
            
            // If this vessel already exists, ensure no fade timeout is set
            if (vesselMarkers.value.has(vesselId)) {
                const existing = vesselMarkers.value.get(vesselId)!
                if (existing.fadeTimeout) {
                    clearTimeout(existing.fadeTimeout)
                    existing.fadeTimeout = undefined
                }
                // Ensure opacity is 1 (vessel should be visible)
                existing.opacity = 1
            }
        }

        // Update or create markers for visible vessels
        for (const { encounter, position, segmentIndex } of visibleVessels) {
            const vesselId = `${encounter.vessel.id}-${segmentIndex}`

            const iconPath = getVesselIcon(
                encounter.vessel.type, 
                encounter.vessel.name,
                encounter.vessel.id,
                encounter.vessel.mmsi
            )
            const iconSize = getVesselIconSize(encounter.vessel.type)
            
            // Debug logging for icon selection
            if (process.dev) {
                console.debug(`Vessel ${encounter.vessel.id} (${encounter.vessel.name}) type: "${encounter.vessel.type}" -> icon: ${iconPath}`)
            }
            
            // Load icon with error handling
            let iconImg: HTMLImageElement
            try {
                iconImg = await loadVesselIcon(iconPath)
            } catch (error) {
                console.error(`Failed to load vessel icon: ${iconPath}`, error)
                // Fallback to default icon
                iconImg = await loadVesselIcon('/images/vessel-marker.svg')
            }

            const coord = new window.mapkit.Coordinate(position.lat, position.lon)
            const anchorPoint = new DOMPoint(iconSize.width / 2, iconSize.height / 2)

            // Check if marker already exists
            if (vesselMarkers.value.has(vesselId)) {
                const existing = vesselMarkers.value.get(vesselId)!
                // Update position
                existing.marker.coordinate = coord
                // Update stored position data
                existing.position = position
                // Update icon if it changed (in case vessel type was updated)
                // Note: MapKit ImageAnnotation doesn't support updating the image URL directly,
                // so we'd need to recreate the marker. For now, we'll just update position.
                // Ensure opacity is 1 and no fade timeout
                existing.opacity = 1
                if (existing.fadeTimeout) {
                    clearTimeout(existing.fadeTimeout)
                    existing.fadeTimeout = undefined
                }
            } else {
                // Create new marker
                const vesselName = getVesselDisplayNameSync(
                    encounter.vessel.mmsi || encounter.vessel.id,
                    encounter.vessel.name
                )
                
                // Verify icon image is loaded before creating annotation
                if (!iconImg || !iconImg.src) {
                    console.warn(`Skipping vessel ${vesselId}: icon not loaded`)
                    continue
                }
                
                const marker = new window.mapkit.ImageAnnotation(coord, {
                    url: { 1: iconImg.src },
                    size: { width: iconSize.width, height: iconSize.height },
                    anchorOffset: anchorPoint,
                    title: vesselName,
                    subtitle: encounter.vessel.type || 'Unknown type',
                    displayPriority: 500,
                })

                const rawMarker = markRaw(marker)
                mapInstance.value.addAnnotation(rawMarker)

                // Store encounter and position data with marker for callout display
                vesselMarkers.value.set(vesselId, {
                    marker: rawMarker,
                    opacity: 1,
                    fadeTimeout: undefined, // Explicitly set to undefined
                    encounter,
                    position,
                })
                
                // Set up custom callout for vessel details
                setupVesselCallout(rawMarker, encounter, position)
            }
        }

        // Remove markers for vessels that are no longer visible
        // Only remove if they're not in the current visible set
        // IMPORTANT: Only remove vessels that are truly not visible anymore
        // This prevents vessels from disappearing when playback is paused
        for (const [vesselId, { marker, fadeTimeout }] of vesselMarkers.value.entries()) {
            if (!currentVesselIds.has(vesselId)) {
                // Clear any existing fade timeout before starting a new one
                if (fadeTimeout) {
                    clearTimeout(fadeTimeout)
                }
                // Only fade out if the vessel is truly not visible at this time
                // The fade-out will be cancelled if the vessel becomes visible again
                fadeOutMarker(vesselId)
            }
        }
        
        // Final check: make sure we're still processing the same time
        if (currentVesselUpdateTime.value !== processingTime) {
            // Another update started, clear what we just added
            for (const { encounter, segmentIndex } of visibleVessels) {
                const vesselId = `${encounter.vessel.id}-${segmentIndex}`
                if (vesselMarkers.value.has(vesselId)) {
                    const existing = vesselMarkers.value.get(vesselId)!
                    // Only remove if it was just added (not in the original set)
                    // Actually, let the next update handle it
                }
            }
        }
    } catch (error) {
        console.error('Error updating vessel markers:', error)
    } finally {
        // Clear the processing time if this was the latest update
        if (currentVesselUpdateTime.value === processingTime) {
            currentVesselUpdateTime.value = null
        }
    }
}

/**
 * Fade in a marker (using delayed appearance for smooth effect)
 */
const fadeInMarker = (vesselId: string) => {
    const vesselData = vesselMarkers.value.get(vesselId)
    if (!vesselData) return

    // Since MapKit doesn't support opacity, we'll use a delayed appearance
    // Start with marker already added but track it as "fading in"
    // The visual effect comes from the smooth transition when it first appears
    if (vesselData.opacity < 1) {
        vesselData.opacity = 1
        // Marker is already on map, just mark as fully visible
    }
}

/**
 * Fade out a marker and remove it (using delayed removal for smooth effect)
 */
const fadeOutMarker = (vesselId: string) => {
    const vesselData = vesselMarkers.value.get(vesselId)
    if (!vesselData) return

    // Use a short delay before removing to create a fade-out effect
    if (vesselData.fadeTimeout) {
        clearTimeout(vesselData.fadeTimeout)
    }

    vesselData.fadeTimeout = window.setTimeout(() => {
        const data = vesselMarkers.value.get(vesselId)
        if (data && mapInstance.value) {
            mapInstance.value.removeAnnotation(data.marker)
            vesselMarkers.value.delete(vesselId)
        }
    }, 300) // 300ms delay for fade-out effect
}

watch(
    () => props.currentTime,
    () => {
        if (!isInitialized.value) return
        // Only update if marker image is loaded
        if (markerImage.value) {
            updateTimeMarker()
            updateVesselMarkers()
        }
        // Auto-center if locked
        if (props.lockTideye === 'locked') {
            centerMapOnTideye()
        }
    }
)

// Watch lockTideye to center map when it becomes 'locked'
watch(
    () => props.lockTideye,
    (newLockState, oldLockState) => {
        if (!isInitialized.value) return
        // Center the map when lockTideye becomes 'locked' (from null or 'center')
        if (newLockState === 'locked' && oldLockState !== 'locked' && props.selectedPassage && props.currentTime) {
            // Small delay to ensure everything is ready
            nextTick(() => {
                centerMapOnTideye()
            })
        }
    }
)

// Watch showVessels toggle to update vessel markers visibility
watch(() => props.showVessels, (shouldShow) => {
    if (!isInitialized.value) return
    if (!shouldShow) {
        clearVesselMarkers()
    } else if (props.currentTime && props.selectedPassage && markerImage.value) {
        // Ensure vessels are displayed when showVessels is toggled on
        // This is important when playback is paused and currentTime hasn't changed
        updateVesselMarkers()
    }
})

// Watch for selectedPassage changes to ensure vessels are updated when passage changes
// This ensures vessels are displayed even if currentTime hasn't changed recently
watch(
    () => props.selectedPassage?.id,
    () => {
        if (!isInitialized.value) return
        // If all conditions are met for showing vessels, ensure they are displayed
        // This is important when passage changes or when playback is paused
        if (props.showVessels && props.currentTime && props.selectedPassage && markerImage.value) {
            // Use nextTick to avoid duplicate calls when currentTime watch also fires
            nextTick(() => {
                updateVesselMarkers()
            })
        }
    }
)

// Watch showFeatures toggle to update feature markers visibility
watch(() => props.showFeatures, (shouldShow) => {
    if (!isInitialized.value) return
    if (!shouldShow) {
        clearFeatureMarkers()
    } else if (props.selectedPassage) {
        createFeatureMarkers(props.selectedPassage)
    }
})

// Watch for location updates to refresh feature markers
watch(
    () => props.selectedPassage?.locations,
    () => {
        if (isInitialized.value && props.selectedPassage && props.showFeatures) {
            createFeatureMarkers(props.selectedPassage)
        }
    },
    { deep: true }
)

// Watch speedColorCoding prop to redraw passage with color coding
watch(() => props.speedColorCoding, () => {
    if (!isInitialized.value) return
    if (props.selectedPassage) {
        redrawSelectedPassage(props.selectedPassage)
    } else if (props.passages.length > 0) {
        clearOverlays()
        const colors = ['#007AFF', '#34C759', '#FF9500', '#FF3B30', '#AF52DE', '#FF2D55']
        props.passages.forEach((passage, index) => {
            const color = colors[index % colors.length]
            drawPassage(passage, color)
        })
        if (props.passages.length > 0) {
            nextTick(() => {
                setTimeout(() => {
                    fitToPassages(props.passages)
                }, 100)
            })
        }
    }
})

onUnmounted(() => {
    clearOverlays()
    clearVesselMarkers()
    clearFeatureMarkers()
    removeTimeMarker()
    
    // Clean up click handler
    if (mapContainer.value && (mapContainer.value as any).__clickHandler) {
        mapContainer.value.removeEventListener('click', (mapContainer.value as any).__clickHandler)
        delete (mapContainer.value as any).__clickHandler
    }
})

const handleResize = () => {
    if (!mapInstance.value) return
    // MapKit should automatically handle resize, but we can trigger it explicitly
    // by dispatching a resize event or calling map methods
    // MapKit JS automatically handles container size changes, but we can force a refresh
    if (mapInstance.value) {
        // Trigger a region update to ensure map recalculates its bounds
        const currentRegion = mapInstance.value.region
        if (currentRegion) {
            // Small delay to ensure DOM has updated
            nextTick(() => {
                // Force map to recalculate by setting the same region
                mapInstance.value?.setRegionAnimated(currentRegion, false)
            })
        }
    }
}

// Expose methods for parent component
defineExpose({
    centerMapOnTime,
    centerMapOnTideye,
    handleResize,
    handleZoomToFit,
    handleCenterOnTideye,
})
</script>

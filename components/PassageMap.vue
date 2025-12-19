<template>
    <div class="relative w-full h-full min-h-[400px] sm:min-h-[500px] lg:min-h-[600px]">
        <div ref="mapContainer" class="w-full h-full" />
        <!-- Map Controls -->
        <div v-if="props.selectedPassage || props.passages.length > 0"
            class="absolute top-2 right-2 z-10 flex flex-col gap-2">
            <UCard class="p-2 shadow-lg">
                <div class="flex flex-col gap-2">
                    <!-- Show Vessels Toggle -->
                    <UButton v-if="props.selectedPassage" :variant="showVessels ? 'solid' : 'outline'" size="xs"
                        icon="i-lucide-ship" @click="showVessels = !showVessels">
                        Vessels
                    </UButton>
                    <!-- Speed Color Coding Toggle -->
                    <UButton v-if="props.selectedPassage" :variant="speedColorCoding ? 'solid' : 'outline'" size="xs"
                        icon="i-lucide-palette" @click="speedColorCoding = !speedColorCoding">
                        Speed
                    </UButton>
                    <!-- Zoom to Fit -->
                    <UButton size="xs" variant="outline" icon="i-lucide-maximize" @click="handleZoomToFit">
                        Fit
                    </UButton>
                </div>
            </UCard>
        </div>
    </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { useMapKit } from '~/composables/useMapKit'
import { getPassageBounds, getAllPassagesBounds, getPositionAtTime, calculateSpeed, calculateBearing, calculateDistanceKm } from '~/utils/mapHelpers'
import { useVesselEncounters } from '~/composables/useVesselEncounters'
import { getVesselIcon, getVesselIconSize } from '~/utils/vesselIcons'
import { addVesselPositionToMap, removeVesselPositionFromMap, type VesselPositionAnnotation } from '~/composables/useVesselPositionAnnotation'
import { preloadVesselNameMap, getVesselDisplayNameSync } from '~/utils/vesselNameMapper'

interface Props {
    passages?: Passage[]
    selectedPassage?: Passage | null
    autoFit?: boolean
    currentTime?: string | null
}

const props = withDefaults(defineProps<Props>(), {
    passages: () => [],
    selectedPassage: null,
    autoFit: true,
    currentTime: null,
})

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
const vesselMarkers = shallowRef<Map<string, { marker: mapkit.ImageAnnotation; opacity: number; fadeTimeout?: number }>>(new Map())
// Cache for vessel icon images
const vesselIconCache = new Map<string, HTMLImageElement>()
// Map controls state
const showVessels = ref(true)
const speedColorCoding = ref(false)

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
                // Update marker position when map region changes to keep it aligned with polyline
                if (props.currentTime && markerImage.value && props.selectedPassage) {
                    // Small delay to ensure polyline rendering is complete
                    nextTick(() => {
                        updateTimeMarker()
                    })
                }
            })
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

const removeTimeMarker = () => {
    if (!mapInstance.value || !timeMarker.value) return
    // Type assertion needed because mapInstance is readonly
    removeVesselPositionFromMap(mapInstance.value as mapkit.Map, timeMarker.value)
    timeMarker.value = null
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

    // Find the exact coordinate from the polyline that matches the current time
    // This ensures the marker is always positioned at a point that exists on the polyline
    let coord: mapkit.Coordinate | null = null
    const targetTime = Date.parse(props.currentTime)

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
            removeTimeMarker()
            return
        }
        coord = new window.mapkit.Coordinate(position.lat, position.lon)
    }

    if (!coord) {
        removeTimeMarker()
        return
    }

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

    // Remove existing time marker if it exists
    if (timeMarker.value) {
        // Type assertion needed because mapInstance is readonly
        removeVesselPositionFromMap(mapInstance.value as mapkit.Map, timeMarker.value)
    }

    // Create vessel position annotation using the custom composable
    const vesselAnnotation = addVesselPositionToMap(mapInstance.value as mapkit.Map, {
        coordinate: coord,
        iconImage: markerImage.value,
        size: { width: 40, height: 40 },
        title: 'Vessel Position',
        subtitle: subtitleParts.join(' • '),
        displayPriority: 1000,
        showDebugBorder: false, // Debug border disabled
    })

    // Store the annotation reference for cleanup
    timeMarker.value = {
        annotation: markRaw(vesselAnnotation.annotation),
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

    if (speedColorCoding.value && passage.positions && passage.positions.length > 1) {
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
        bounds: bounds
    })

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

const redrawSelectedPassage = async (passage: Passage) => {
    if (!isInitialized.value || !passage) return

    clearOverlays()
    clearVesselMarkers()
    removeTimeMarker()
    drawPassage(passage, '#007AFF')

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
                fitToPassage(passage)
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
                removeTimeMarker()
            }
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
                        fitToPassage(passage)
                    }, 150) // Slightly longer delay to ensure polyline is rendered
                })

                // Update time marker if currentTime is set and image is loaded
                if (props.currentTime && markerImage.value) {
                    nextTick(() => {
                        updateTimeMarker()
                    })
                }
            }
        }
    }
)

/**
 * Load vessel icon image
 */
const loadVesselIcon = async (iconPath: string): Promise<HTMLImageElement> => {
    if (vesselIconCache.has(iconPath)) {
        return vesselIconCache.get(iconPath)!
    }

    return new Promise((resolve, reject) => {
        const img = new Image()
        img.src = iconPath
        img.onload = () => {
            vesselIconCache.set(iconPath, img)
            resolve(img)
        }
        img.onerror = () => {
            // Fallback to default icon
            const defaultIcon = '/images/vessel-marker.svg'
            if (vesselIconCache.has(defaultIcon)) {
                resolve(vesselIconCache.get(defaultIcon)!)
            } else {
                const defaultImg = new Image()
                defaultImg.src = defaultIcon
                defaultImg.onload = () => {
                    vesselIconCache.set(defaultIcon, defaultImg)
                    resolve(defaultImg)
                }
                defaultImg.onerror = reject
            }
        }
    })
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

const updateVesselMarkers = async () => {
    if (!mapInstance.value || !window.mapkit || !props.currentTime || !props.selectedPassage || !showVessels.value) {
        clearVesselMarkers()
        return
    }

    try {
        const visibleVessels = getVisibleVessels(props.currentTime)
        const currentVesselIds = new Set<string>()

        // Update or create markers for visible vessels
        for (const { encounter, position, segmentIndex } of visibleVessels) {
            const vesselId = `${encounter.vessel.id}-${segmentIndex}`
            currentVesselIds.add(vesselId)

            const iconPath = getVesselIcon(encounter.vessel.type)
            const iconSize = getVesselIconSize(encounter.vessel.type)
            const iconImg = await loadVesselIcon(iconPath)

            const coord = new window.mapkit.Coordinate(position.lat, position.lon)
            const anchorPoint = new DOMPoint(iconSize.width / 2, iconSize.height / 2)

            // Check if marker already exists
            if (vesselMarkers.value.has(vesselId)) {
                const existing = vesselMarkers.value.get(vesselId)!
                // Update position
                existing.marker.coordinate = coord
                // Clear any pending fade-out timeout since vessel is still visible
                if (existing.fadeTimeout) {
                    clearTimeout(existing.fadeTimeout)
                    existing.fadeTimeout = undefined
                }
                existing.opacity = 1
            } else {
                // Create new marker
                const vesselName = getVesselDisplayNameSync(
                    encounter.vessel.mmsi || encounter.vessel.id,
                    encounter.vessel.name
                )
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

                vesselMarkers.value.set(vesselId, {
                    marker: rawMarker,
                    opacity: 1,
                })
            }
        }

        // Remove markers for vessels that are no longer visible
        for (const [vesselId, { marker, fadeTimeout }] of vesselMarkers.value.entries()) {
            if (!currentVesselIds.has(vesselId)) {
                // Fade out before removing
                if (fadeTimeout) {
                    clearTimeout(fadeTimeout)
                }
                fadeOutMarker(vesselId)
            }
        }
    } catch (error) {
        console.error('Error updating vessel markers:', error)
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
    }
)

// Watch showVessels toggle to update vessel markers visibility
watch(showVessels, (shouldShow) => {
    if (!isInitialized.value) return
    if (!shouldShow) {
        clearVesselMarkers()
    } else if (props.currentTime && props.selectedPassage && markerImage.value) {
        updateVesselMarkers()
    }
})

// Watch speedColorCoding to redraw passage with color coding
watch(speedColorCoding, () => {
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
    removeTimeMarker()
})
</script>

/**
 * Composable for creating and managing vessel position annotations on MapKit maps
 * Uses Annotation with custom factory function for full control over styling and borders
 */

import type { Ref } from 'vue'

export interface VesselPositionOptions {
    /** Coordinate for the annotation */
    coordinate: mapkit.Coordinate
    /** Image source for the vessel icon */
    iconImage: HTMLImageElement
    /** Size of the icon (default: 40x40) */
    size?: { width: number; height: number }
    /** Title text for the annotation */
    title?: string
    /** Subtitle text for the annotation */
    subtitle?: string
    /** Display priority (higher = more visible) */
    displayPriority?: number
    /** Whether to show debug border */
    showDebugBorder?: boolean
    /** Debug border color (default: red) */
    debugBorderColor?: string
    /** Debug border width in pixels (default: 2) */
    debugBorderWidth?: number
}

export interface VesselPositionAnnotation {
    /** The main Annotation with custom factory */
    annotation: mapkit.Annotation
}

/**
 * Factory function to create a custom vessel position annotation view
 * This creates a DOM element with the vessel icon and optional debug border
 * 
 * @param coordinate The annotation coordinate
 * @param data The data object passed in the annotation options
 * @returns The DOM element representing the annotation
 */
function createVesselAnnotationView(
    coordinate: mapkit.Coordinate,
    data: any
): HTMLElement {
    // MapKit may pass the data property directly, or it might be wrapped
    // Handle both cases: data could be the options object, or data.data could be our custom data
    const actualData = data?.data || data || {}

    // Extract options from data - handle both HTMLImageElement and image source URL
    const {
        iconImage,
        iconImageSrc,
        size = { width: 40, height: 40 },
        showDebugBorder = false,
        debugBorderColor = '#FF0000',
        debugBorderWidth = 2,
        title = 'Vessel Position',
    } = actualData

    // Get image source - prefer iconImage.src if HTMLImageElement is available, otherwise use iconImageSrc
    const imageSrc = iconImage?.src || iconImageSrc || ''

    if (!imageSrc) {
        console.error('VesselPositionAnnotation: No image source provided', {
            data,
            actualData,
            iconImage,
            iconImageSrc,
        })
        // Return a fallback element so the annotation doesn't fail completely
        const fallback = document.createElement('div')
        fallback.className = 'vessel-position-annotation'
        fallback.style.width = '40px'
        fallback.style.height = '40px'
        fallback.style.border = '2px solid red'
        fallback.style.backgroundColor = 'rgba(255, 0, 0, 0.2)'
        return fallback
    }

    // Create the main container for the annotation
    const container = document.createElement('div')
    container.className = 'vessel-position-annotation'
    
    // Style the container
    container.style.display = 'flex'
    container.style.alignItems = 'center'
    container.style.justifyContent = 'center'
    container.style.width = `${size.width}px`
    container.style.height = `${size.height}px`
    container.style.position = 'relative'

    // Add debug border if requested
    if (showDebugBorder) {
        container.style.border = `${debugBorderWidth}px solid ${debugBorderColor}`
        container.style.borderRadius = '4px'
        container.style.boxSizing = 'border-box'
        // Add a subtle background to make border more visible
        container.style.backgroundColor = 'rgba(255, 0, 0, 0.05)'
    }

    // Create the image element for the vessel icon
    const img = document.createElement('img')
    img.src = imageSrc
    img.alt = title
    img.style.width = '100%'
    img.style.height = '100%'
    img.style.objectFit = 'contain'
    img.style.display = 'block'
    img.style.pointerEvents = 'none' // Prevent image from blocking clicks

    // Append the image to the container
    container.appendChild(img)

    // Set data attributes for potential CSS targeting
    container.setAttribute('data-annotation-type', 'vessel-position')
    if (showDebugBorder) {
        container.setAttribute('data-debug-border', 'true')
    }

    return container
}

/**
 * Creates a vessel position annotation using Annotation with custom factory
 * 
 * @param options Configuration options for the annotation
 * @returns Object containing the annotation
 */
export function createVesselPositionAnnotation(
    options: VesselPositionOptions
): VesselPositionAnnotation {
    const {
        coordinate,
        title = 'Vessel Position',
        subtitle = '',
        displayPriority = 1000,
    } = options

    if (!window.mapkit) {
        throw new Error('MapKit is not initialized')
    }

    // Create Annotation with custom factory function
    // The factory function receives the coordinate and data object (options)
    // MapKit JS Annotation constructor: new Annotation(coordinate, factoryFunction, options)
    // Custom options must be passed in the `data` property, not as top-level options
    // Ensure we always have a valid image source URL string
    const imageSrc = options.iconImage?.src || ''
    if (!imageSrc) {
        console.error('VesselPositionAnnotation: iconImage.src is empty or undefined', {
            iconImage: options.iconImage,
        })
    }

    const annotation = new window.mapkit.Annotation(
        coordinate,
        createVesselAnnotationView, // Factory function that creates the DOM element
        {
            title,
            subtitle,
            // Custom data must be passed in the `data` property
            data: {
                // Pass image source URL as a string (required - HTMLImageElement won't serialize)
                iconImageSrc: imageSrc,
                size: options.size || { width: 40, height: 40 },
                showDebugBorder: options.showDebugBorder ?? false,
                debugBorderColor: options.debugBorderColor || '#FF0000',
                debugBorderWidth: options.debugBorderWidth || 2,
                title, // Include title in data for factory function access
            },
        }
    )

    // Set display priority if supported
    if (displayPriority !== undefined && 'displayPriority' in annotation) {
        ;(annotation as any).displayPriority = displayPriority
    }

    return {
        annotation,
    }
}

/**
 * Adds a vessel position annotation to the map
 * 
 * @param map MapKit map instance (can be readonly ref)
 * @param options Configuration options
 * @returns Object containing the annotation reference for cleanup
 */
export function addVesselPositionToMap(
    map: mapkit.Map | Readonly<Ref<mapkit.Map | null>>,
    options: VesselPositionOptions
): VesselPositionAnnotation {
    const mapInstance = 'value' in map ? map.value : map
    if (!mapInstance) {
        throw new Error('Map instance is null')
    }
    
    const { annotation } = createVesselPositionAnnotation(options)

    // Add annotation to map
    mapInstance.addAnnotation(annotation)

    return {
        annotation,
    }
}

/**
 * Removes a vessel position annotation from the map
 * 
 * @param map MapKit map instance (can be readonly ref)
 * @param annotationRef Annotation reference returned from addVesselPositionToMap
 */
export function removeVesselPositionFromMap(
    map: mapkit.Map | Readonly<Ref<mapkit.Map | null>>,
    annotationRef: VesselPositionAnnotation
): void {
    const mapInstance = 'value' in map ? map.value : map
    if (!mapInstance) {
        return
    }
    mapInstance.removeAnnotation(annotationRef.annotation)
}

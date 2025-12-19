/**
 * Utility functions for getting vessel icons based on vessel type
 */

/**
 * Try to infer vessel type from vessel name
 * This is a fallback when type is generic or missing
 */
function inferTypeFromName(vesselName?: string): string | null {
  if (!vesselName) return null
  
  const name = vesselName.toLowerCase()
  
  // Common patterns in vessel names
  if (name.includes('tanker') || name.includes('tank') || name.includes('oil') || name.includes('crude')) {
    return 'tanker'
  }
  if (name.includes('cargo') || name.includes('container') || name.includes('freight') || name.includes('bulk')) {
    return 'cargo'
  }
  if (name.includes('fishing') || name.includes('fisher') || name.includes('trawler')) {
    return 'fishing'
  }
  if (name.includes('ferry') || name.includes('cruise') || name.includes('passenger') || name.includes('liner')) {
    return 'passenger'
  }
  if (name.includes('tug') || name.includes('tow')) {
    return 'tug'
  }
  if (name.includes('sail') || name.includes('yacht') || name.includes('sailing')) {
    return 'sail'
  }
  if (name.includes('navy') || name.includes('military') || name.includes('warship')) {
    return 'military'
  }
  
  return null
}

/**
 * Map vessel types to icon filenames
 * Returns a default icon if type is not recognized
 * 
 * @param vesselType - The vessel type string (e.g., "cargo", "tanker")
 * @param vesselName - Optional vessel name to infer type from if type is generic
 */
export function getVesselIcon(vesselType?: string, vesselName?: string): string {
  // If no type provided, try to infer from name
  if (!vesselType || vesselType.toLowerCase() === 'vessel' || vesselType.toLowerCase() === 'unknown') {
    const inferredType = inferTypeFromName(vesselName)
    if (inferredType) {
      vesselType = inferredType
    } else {
      return '/images/vessel-marker.svg' // Default icon
    }
  }

  const type = vesselType.toLowerCase()

  // Map common vessel types to icons
  // You can add more specific mappings as needed
  if (type.includes('cargo') || type.includes('freight')) {
    return '/images/vessel-cargo.svg'
  }
  if (type.includes('tanker')) {
    return '/images/vessel-tanker.svg'
  }
  if (type.includes('fishing') || type.includes('fish')) {
    return '/images/vessel-fishing.svg'
  }
  if (type.includes('passenger') || type.includes('ferry') || type.includes('cruise')) {
    return '/images/vessel-passenger.svg'
  }
  if (type.includes('tug') || type.includes('tow')) {
    return '/images/vessel-tug.svg'
  }
  if (type.includes('sail') || type.includes('yacht')) {
    return '/images/vessel-sail.svg'
  }
  if (type.includes('military') || type.includes('navy')) {
    return '/images/vessel-military.svg'
  }

  // Default icon for unknown types
  return '/images/vessel-marker.svg'
}

/**
 * Get icon size based on vessel type (optional customization)
 */
export function getVesselIconSize(_vesselType?: string): { width: number; height: number } {
  // All vessels use 40x40 to match the SVG icon dimensions
  return { width: 40, height: 40 }
}


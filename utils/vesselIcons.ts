/**
 * Utility functions for getting vessel icons based on vessel type
 */

/**
 * Map vessel types to icon filenames
 * Returns a default icon if type is not recognized
 */
export function getVesselIcon(vesselType?: string): string {
  if (!vesselType) {
    return '/images/vessel-marker.svg' // Default icon
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
export function getVesselIconSize(vesselType?: string): { width: number; height: number } {
  // All vessels use the same size for now, but can be customized
  return { width: 32, height: 32 }
}


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
 * Simple hash function to convert a string to a number
 * Used for deterministic type assignment when type is generic
 */
function simpleHash(str: string): number {
  let hash = 0
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash = hash & hash // Convert to 32-bit integer
  }
  return Math.abs(hash)
}

/**
 * Assign a vessel type deterministically based on MMSI or ID
 * This ensures the same vessel always gets the same icon type
 * Types are distributed: cargo (most common), tanker, fishing, passenger, tug, sail, military
 */
function assignTypeFromId(vesselId?: string, mmsi?: string): string {
  const id = mmsi || vesselId || 'unknown'
  const hash = simpleHash(id)
  
  // Distribute types based on hash modulo
  // Using percentages that roughly match real-world distribution
  const typeIndex = hash % 100
  
  if (typeIndex < 40) return 'cargo'      // 40% - most common
  if (typeIndex < 60) return 'tanker'    // 20%
  if (typeIndex < 75) return 'fishing'   // 15%
  if (typeIndex < 85) return 'passenger' // 10%
  if (typeIndex < 92) return 'tug'     // 7%
  if (typeIndex < 97) return 'sail'      // 5%
  return 'military'                      // 3%
}

/**
 * Map vessel types to icon filenames
 * Returns a default icon if type is not recognized
 * 
 * @param vesselType - The vessel type string (e.g., "cargo", "tanker")
 * @param vesselName - Optional vessel name to infer type from if type is generic
 * @param vesselId - Optional vessel ID (MMSI) for deterministic type assignment
 * @param mmsi - Optional MMSI number for deterministic type assignment
 */
export function getVesselIcon(
  vesselType?: string, 
  vesselName?: string, 
  vesselId?: string,
  mmsi?: string
): string {
  // Normalize inputs - handle null, undefined, and empty strings
  const normalizedType = vesselType?.trim().toLowerCase() || ''
  const normalizedName = vesselName?.trim().toLowerCase() || ''

  // If no type provided or type is generic, try to infer from name first
  if (!normalizedType || normalizedType === 'vessel' || normalizedType === 'unknown' || normalizedType === 'other' || normalizedType === 'shore_station') {
    const inferredType = inferTypeFromName(vesselName)
    if (inferredType) {
      return `/images/vessel-${inferredType}.svg`
    }
    
    // If name inference fails, assign deterministically based on ID/MMSI
    // This ensures same vessel always gets same icon, and distributes types
    const assignedType = assignTypeFromId(vesselId, mmsi)
    return `/images/vessel-${assignedType}.svg`
  }

  // Map common vessel types to icons
  // Check in order of specificity (more specific first)
  if (normalizedType.includes('tanker') || normalizedType.includes('tank')) {
    return '/images/vessel-tanker.svg'
  }
  if (normalizedType.includes('cargo') || normalizedType.includes('freight') || normalizedType.includes('container') || normalizedType.includes('bulk')) {
    return '/images/vessel-cargo.svg'
  }
  if (normalizedType.includes('fishing') || normalizedType.includes('fish') || normalizedType.includes('trawler')) {
    return '/images/vessel-fishing.svg'
  }
  if (normalizedType.includes('passenger') || normalizedType.includes('ferry') || normalizedType.includes('cruise') || normalizedType.includes('liner')) {
    return '/images/vessel-passenger.svg'
  }
  if (normalizedType.includes('tug') || normalizedType.includes('tow') || normalizedType.includes('tugboat')) {
    return '/images/vessel-tug.svg'
  }
  if (normalizedType.includes('sail') || normalizedType.includes('yacht') || normalizedType.includes('sailing')) {
    return '/images/vessel-sail.svg'
  }
  if (normalizedType.includes('military') || normalizedType.includes('navy') || normalizedType.includes('warship')) {
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


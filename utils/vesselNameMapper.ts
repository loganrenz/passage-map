/**
 * Utility for mapping MMSI numbers to vessel names
 */

let vesselNameMap: Record<string, string> | null = null

/**
 * Load the MMSI to vessel name mapping
 */
async function loadVesselNameMap(): Promise<Record<string, string>> {
  if (vesselNameMap !== null) {
    return vesselNameMap
  }

  try {
    const response = await fetch('/data/mmsi-to-vessel-name.json')
    if (response.ok) {
      const data = await response.json()
      vesselNameMap = data.mappings || {}
      return vesselNameMap
    }
  } catch (error) {
    console.warn('Failed to load vessel name mapping:', error)
  }

  vesselNameMap = {}
  return vesselNameMap
}

/**
 * Get vessel name by MMSI number
 * @param mmsi - The MMSI number (as string or number)
 * @returns The vessel name if found, otherwise returns null
 */
export async function getVesselNameByMmsi(mmsi: string | number | undefined | null): Promise<string | null> {
  if (!mmsi) return null

  const mmsiStr = String(mmsi)
  const map = await loadVesselNameMap()
  return map[mmsiStr] || null
}

/**
 * Get vessel name by MMSI number (synchronous version - requires map to be pre-loaded)
 * @param mmsi - The MMSI number (as string or number)
 * @returns The vessel name if found, otherwise returns null
 */
export function getVesselNameByMmsiSync(mmsi: string | number | undefined | null): string | null {
  if (!mmsi || vesselNameMap === null) return null

  const mmsiStr = String(mmsi)
  return vesselNameMap[mmsiStr] || null
}

/**
 * Get a display name for a vessel, using the mapping if available, otherwise falling back to a default
 * @param mmsi - The MMSI number
 * @param defaultName - Default name to use if mapping not found (e.g., "Vessel {mmsi}")
 * @returns The vessel name
 */
export async function getVesselDisplayName(
  mmsi: string | number | undefined | null,
  defaultName?: string
): Promise<string> {
  const mappedName = await getVesselNameByMmsi(mmsi)
  if (mappedName) {
    return mappedName
  }

  if (defaultName) {
    return defaultName
  }

  return mmsi ? `Vessel ${mmsi}` : 'Unknown Vessel'
}

/**
 * Get a display name for a vessel (synchronous version)
 * @param mmsi - The MMSI number
 * @param defaultName - Default name to use if mapping not found
 * @returns The vessel name
 */
export function getVesselDisplayNameSync(
  mmsi: string | number | undefined | null,
  defaultName?: string
): string {
  const mappedName = getVesselNameByMmsiSync(mmsi)
  if (mappedName) {
    return mappedName
  }

  if (defaultName) {
    return defaultName
  }

  return mmsi ? `Vessel ${mmsi}` : 'Unknown Vessel'
}

/**
 * Preload the vessel name mapping (useful for SSR or when you know you'll need it)
 */
export async function preloadVesselNameMap(): Promise<void> {
  await loadVesselNameMap()
}

/**
 * Clear the cached mapping (useful for testing or when the mapping file is updated)
 */
export function clearVesselNameMapCache(): void {
  vesselNameMap = null
}


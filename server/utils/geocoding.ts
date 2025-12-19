/**
 * Server-side reverse geocoding utility
 * Uses Apple Maps Server API
 */

export interface GeocodeResult {
  name?: string
  locality?: string
  administrativeArea?: string
  country?: string
  countryCode?: string
  formattedAddress?: string
}

/**
 * Get MapKit token for server-side API requests
 */
function getMapKitToken(): string {
  const config = useRuntimeConfig()
  const isProduction = process.env.NODE_ENV === 'production'
  
  // Use the same token logic as the token endpoint
  const providedToken = 'eyJraWQiOiI5NFU5UTMzSkE0IiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzY2MTc1NzkxLCJleHAiOjE3NjY4MjIzOTl9.toByslo5HcQh5isUL4cqg9aA-veRRbAfQTbIZinGXoczfTZVhtXqU6r-A-rh8Vh3PqBaWQv2I2ZA91KqbqJX0A'
  const token = providedToken || (isProduction ? config.mapkitProdToken : config.mapkitDevToken)
  
  if (!token) {
    throw new Error('MapKit token not configured')
  }
  
  return token
}

/**
 * Reverse geocode coordinates to get location information
 * Uses Apple Maps Server API
 */
export async function reverseGeocode(
  lat: number,
  lon: number
): Promise<GeocodeResult | null> {
  try {
    const token = getMapKitToken()
    
    // Apple Maps Server API reverse geocoding endpoint
    // Format: https://maps-api.apple.com/v1/reverseGeocode?latitude={lat}&longitude={lon}
    const url = `https://maps-api.apple.com/v1/reverseGeocode?latitude=${lat}&longitude=${lon}`
    
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    })

    if (!response.ok) {
      const errorText = await response.text().catch(() => 'Unknown error')
      console.warn(`Apple Maps Server API geocoding failed: ${response.status} ${response.statusText} - ${errorText}`)
      return null
    }

    const data = await response.json()

    // Apple Maps Server API response structure may vary
    // Handle both possible response formats
    let results: any[] = []
    
    if (data.results && Array.isArray(data.results)) {
      results = data.results
    } else if (data.result) {
      results = Array.isArray(data.result) ? data.result : [data.result]
    } else if (data.address) {
      results = [data]
    } else if (data.placemark || data.placemarks) {
      results = Array.isArray(data.placemark || data.placemarks) 
        ? (data.placemark || data.placemarks)
        : [data.placemark || data.placemarks]
    } else {
      // Try to use the data directly if it has address fields
      results = [data]
    }

    if (results.length === 0) {
      return null
    }
    
    // Try to find the best result - prefer results with locality or name
    let bestResult = results[0]
    for (const result of results) {
      const address = result.address || result
      // Prefer results that have locality (city/island name) or a meaningful name
      if (address.locality || (result.name && !result.name.match(/^\d+/))) {
        bestResult = result
        break
      }
    }
    
    const result = bestResult
    const address = result.address || result
    
    // Extract all possible location identifiers
    const geocodeResult: GeocodeResult = {
      name: result.name || address.name || undefined,
      locality: address.locality || address.subLocality || address.city || address.town || address.island || undefined,
      administrativeArea: address.administrativeArea || address.state || address.province || address.region || undefined,
      country: address.country || undefined,
      countryCode: address.countryCode || address.isoCountryCode || undefined,
      formattedAddress: result.formattedAddress || address.formattedAddress || result.displayName || result.formattedAddressLine || undefined,
    }

    return geocodeResult
  } catch (error) {
    console.error('Error in reverse geocoding with Apple Maps Server API:', error)
    return null
  }
}

/**
 * Extract island name from formatted address or name
 * Looks for patterns like "Island Name" or "Name Island"
 */
function extractIslandName(text: string): string | null {
  if (!text) return null
  
  // Common island name patterns
  const islandPatterns = [
    /(\w+(?:\s+\w+)*)\s+Island/i,
    /Island\s+of\s+(\w+(?:\s+\w+)*)/i,
    /(\w+(?:\s+\w+)*)\s+Islands?/i,
  ]
  
  for (const pattern of islandPatterns) {
    const match = text.match(pattern)
    if (match && match[1]) {
      return match[1].trim()
    }
  }
  
  return null
}

/**
 * Get the best location name from geocode result
 * Priority: locality > name (if meaningful) > island name from formatted address > administrativeArea > formattedAddress
 */
function getLocationName(location: GeocodeResult | null): string {
  if (!location) return 'Unknown'
  
  // Prefer locality (city/town/island name)
  if (location.locality) {
    return location.locality
  }
  
  // Check if name is meaningful (not just coordinates or numbers)
  if (location.name) {
    // Skip if name looks like coordinates or is just a number
    if (!location.name.match(/^\d+[°\s]/) && !location.name.match(/^[\d\s,.-]+$/)) {
      // Check if it contains island-related terms
      const islandName = extractIslandName(location.name)
      if (islandName) {
        return islandName
      }
      return location.name
    }
  }
  
  // Try to extract island name from formatted address
  if (location.formattedAddress) {
    const islandName = extractIslandName(location.formattedAddress)
    if (islandName) {
      return islandName
    }
    
    // Try to extract meaningful location from formatted address
    // Format is usually: "Name, Locality, AdministrativeArea, Country"
    const parts = location.formattedAddress.split(',').map(p => p.trim())
    
    // Skip the first part if it's just a number or coordinate
    for (const part of parts) {
      if (part && !part.match(/^\d+[°\s]/) && !part.match(/^[\d\s,.-]+$/)) {
        // Check if this part contains an island name
        const islandName = extractIslandName(part)
        if (islandName) {
          return islandName
        }
        // Use the first meaningful part
        if (part.length > 2 && !part.match(/^(The|A|An)\s+/i)) {
          return part
        }
      }
    }
    
    // Last resort: return first part even if it looks like coordinates
    if (parts.length > 0) {
      return parts[0]
    }
  }
  
  // Use administrative area (state/province) as fallback
  if (location.administrativeArea) {
    return location.administrativeArea
  }
  
  return 'Unknown'
}

/**
 * Generate a passage name from start and end locations
 * Format: "From [start location] to [end location]"
 * Always uses "From X to Y" format, even if locations are the same
 */
export function generatePassageName(
  startLocation: GeocodeResult | null,
  endLocation: GeocodeResult | null,
  fallbackName?: string
): string {
  const startName = getLocationName(startLocation)
  const endName = getLocationName(endLocation)

  // Always use "From X to Y" format, even if locations are the same
  return `From ${startName} to ${endName}`
}


# Vessel Name Mapping

This document describes the MMSI to vessel name mapping system.

## Overview

The application uses MMSI (Maritime Mobile Service Identity) numbers to identify vessels. This system provides a mapping from MMSI numbers to human-readable vessel names.

## Files

- **`public/data/mmsi-to-vessel-name.json`**: The mapping file containing MMSI to vessel name mappings
- **`public/data/mmsi-list.json`**: List of all unique MMSI numbers found in the passage data (3132 unique MMSIs)
- **`utils/vesselNameMapper.ts`**: Utility functions for looking up vessel names by MMSI
- **`scripts/fetch-vessel-names.ts`**: Script to help populate the mapping file (requires API implementation)

## Usage

### In Code

```typescript
import { getVesselDisplayName, preloadVesselNameMap } from '~/utils/vesselNameMapper'

// Preload the mapping (usually done once on app startup)
await preloadVesselNameMap()

// Get vessel name (async)
const name = await getVesselDisplayName(mmsi, defaultName)

// Get vessel name (sync - requires preload)
import { getVesselDisplayNameSync } from '~/utils/vesselNameMapper'
const name = getVesselDisplayNameSync(mmsi, defaultName)
```

### Mapping File Format

The mapping file has the following structure:

```json
{
  "_comment": "Mapping of MMSI numbers to vessel names",
  "_lastUpdated": "2025-01-20T00:00:00Z",
  "_totalMmsis": 3132,
  "mappings": {
    "215503000": "VESSEL NAME HERE",
    "538007209": "ANOTHER VESSEL NAME",
    ...
  }
}
```

## Populating the Mapping

### Manual Entry

You can manually edit `public/data/mmsi-to-vessel-name.json` to add vessel names:

```json
{
  "mappings": {
    "215503000": "MSC OSCAR",
    "538007209": "EVER GIVEN"
  }
}
```

### Using the Script

The `scripts/fetch-vessel-names.ts` script can help automate the process:

```bash
# Fetch name for a specific MMSI
npx tsx scripts/fetch-vessel-names.ts --mmsi 215503000

# Process all MMSIs from the list (with rate limiting)
npx tsx scripts/fetch-vessel-names.ts --file public/data/mmsi-list.json --delay 1000

# Process with a limit (for testing)
npx tsx scripts/fetch-vessel-names.ts --limit 10 --delay 2000
```

**Note**: The script currently has placeholder API implementation. You'll need to implement actual API calls to services like:
- MarineTraffic API (requires API key)
- VesselFinder API (requires API key)
- USCG VIVS (free but may have rate limits)
- Other maritime data providers

### API Implementation Example

To implement API fetching in `scripts/fetch-vessel-names.ts`, update the `fetchVesselNameFromAPI` function:

```typescript
async function fetchVesselNameFromAPI(mmsi: string): Promise<string | null> {
  try {
    // Example: Using a hypothetical API
    const response = await fetch(`https://api.example.com/vessel/${mmsi}`, {
      headers: {
        'Authorization': `Bearer ${process.env.API_KEY}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      return data.name || null
    }
  } catch (error) {
    console.error(`Error fetching MMSI ${mmsi}:`, error)
  }
  
  return null
}
```

## Data Sources

Potential sources for vessel name data:

1. **USCG VIVS** (Vessel Information Verification Service)
   - Free service from U.S. Coast Guard
   - URL: https://www.navcen.uscg.gov/ais-vivs-home
   - May have rate limits

2. **MarineTraffic**
   - Commercial API service
   - Requires API key
   - URL: https://www.marinetraffic.com/

3. **VesselFinder**
   - Commercial API service
   - Requires API key
   - URL: https://www.vesselfinder.com/

4. **AIS Vessel Tracker**
   - Web-based lookup
   - URL: https://aisvesseltracker.com/

## Current Status

- **Total MMSIs in data**: 3,132 unique MMSI numbers
- **Mapped**: 0 (mapping file is empty, ready for population)
- **Last Updated**: 2025-01-20

## Integration

The mapping is automatically used in:
- `components/PassageMap.vue`: Vessel markers on the map display mapped names
- Future components can use the `vesselNameMapper` utility

The system falls back to the original vessel name from the data (usually "Vessel {MMSI}") if no mapping is found.


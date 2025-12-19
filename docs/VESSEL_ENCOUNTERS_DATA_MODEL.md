# Vessel Encounters Data Model

## Overview

This document describes the data model for tracking vessel encounters during a passage. The model is designed to handle vessels that may come in and out of range over the course of an 8-day passage, allowing us to track multiple encounter segments per vessel.

## Key Concepts

### Encounter Segments

A vessel may appear and disappear multiple times during a passage. Each continuous period when a vessel is in range is called an **encounter segment**. If a vessel goes out of range for more than a specified time gap (default: 30 minutes), and then comes back, that creates a new segment.

### Example Scenario

```
Day 1: Vessel A appears at 12:00, visible until 14:00 (Segment 1)
Day 1: Vessel A disappears
Day 2: Vessel A reappears at 08:00, visible until 10:00 (Segment 2)
Day 3: Vessel A appears at 15:00, visible until 18:00 (Segment 3)
```

This vessel would have 3 encounter segments.

## Data Model Structure

### Core Types

#### `VesselPosition`
A single position point for a vessel at a specific time:
- `timestamp`: ISO 8601 timestamp
- `lat`, `lon`: Coordinates
- `speed`, `heading`, `altitude`, `accuracy`: Optional navigation data

#### `VesselMetadata`
Static information about a vessel:
- `id`: Unique identifier (often MMSI)
- `name`: Vessel name
- `mmsi`: Maritime Mobile Service Identity number
- `type`: Vessel type (cargo, tanker, fishing, etc.)
- `flag`: Country flag
- `length`, `beam`: Vessel dimensions
- `color`: Display color
- `description`: Additional info

#### `EncounterSegment`
A continuous period when a vessel is in range:
- `startTime`, `endTime`: Segment boundaries
- `duration`: Duration in hours
- `positions`: All position points during this segment
- `closestApproachDistance`: Closest distance to our vessel (nautical miles)
- `closestApproachTime`: When closest approach occurred
- `averageDistance`: Average distance during segment

#### `VesselEncounter`
Complete encounter information for a vessel:
- `vessel`: Vessel metadata
- `segments`: Array of all encounter segments (sorted by time)
- `firstSeen`, `lastSeen`: First and last sighting times
- `totalDuration`: Combined duration of all segments
- `totalPositionCount`: Total position points
- `overallClosestApproach`: Closest approach across all segments
- `overallClosestApproachTime`: When overall closest approach occurred

#### `PassageEncounters`
Complete encounter data for a passage:
- `passageId`: Associated passage ID
- `generatedAt`: When data was generated
- `encounters`: Array of all vessel encounters
- `totalVessels`: Count of unique vessels
- `totalSegments`: Total encounter segments

## Data Processing

### Processing Flow

1. **Load Raw Vessel Data**: Read from `vessels_tideye_passage_2025_06_26.json`
2. **Identify Self Vessel**: Find the vessel matching the passage timeline (usually Tideye)
3. **Filter Other Vessels**: Exclude self vessel from encounters
4. **Group into Segments**: Group positions by time gaps (default: 30 minutes)
5. **Calculate Distances**: For each segment, calculate distances to passage positions
6. **Aggregate Statistics**: Calculate overall closest approach, durations, etc.

### Key Functions

- `processVesselEncounters()`: Main processing function
- `groupIntoSegments()`: Groups positions into encounter segments
- `calculateDistanceNauticalMiles()`: Haversine distance calculation
- `identifySelfVessel()`: Finds the self vessel in raw data

## Usage Example

```typescript
import { processVesselEncounters, loadEncountersData } from '~/utils/encounterProcessor'
import type { Passage } from '~/types/passage'
import type { RawVesselData } from '~/utils/encounterProcessor'

// Load passage and raw vessel data
const passage: Passage = await loadPassage('passage_2025-06-26_tideye_passage_2025_06_26.json')
const rawData: RawVesselData = await fetch('/data/passages_vessel_data/vessels_tideye_passage_2025_06_26.json').then(r => r.json())

// Process encounters
const encounters = processVesselEncounters(rawData, passage, {
  maxEncounterDistance: 50, // nautical miles
  segmentGapMinutes: 30, // minutes
  calculateDistances: true
})

// Access encounter data
console.log(`Found ${encounters.totalVessels} vessels`)
encounters.encounters.forEach(encounter => {
  console.log(`${encounter.vessel.name}: ${encounter.segments.length} segments`)
  console.log(`  Closest approach: ${encounter.overallClosestApproach?.toFixed(2)} nm`)
})
```

## File Structure

- **Types**: `types/vessel-encounter.ts`
- **Processor**: `utils/encounterProcessor.ts`
- **Raw Data**: `public/data/passages_vessel_data/vessels_tideye_passage_2025_06_26.json`
- **Processed Data**: (To be generated) `public/data/passages_vessel_data/encounters_tideye_passage_2025_06_26.json`

## Future Enhancements

1. **Visualization**: Display vessel tracks on map with different colors per segment
2. **Filtering**: Filter encounters by distance, duration, vessel type
3. **Timeline Integration**: Show vessel appearances on passage timeline
4. **Closest Approach Markers**: Highlight closest approach points on map
5. **Encounter Statistics**: Summary dashboard of all encounters


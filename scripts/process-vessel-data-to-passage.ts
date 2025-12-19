import { readFile, writeFile } from 'fs/promises'
import { join } from 'path'
import type { Passage, PassagePosition } from '../types/passage'

interface VesselData {
  vessels: Array<{
    vessel: {
      id: string
      name: string
      mmsi?: string
      type?: string
    }
    track: Array<{
      coordinate: {
        latitude: number
        longitude: number
      }
      timestamp: string
      speed?: number
      heading?: number
    }>
  }>
}

// Calculate distance between two coordinates using Haversine formula (in kilometers)
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371 // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

async function processVesselDataToPassage() {
  const inputFile = join(process.cwd(), 'public', 'data', 'passages_vessel_data', 'vessels_tideye_passage_2025_06_26.json')
  const outputDir = join(process.cwd(), 'public', 'data', 'passages')

  console.log('📖 Reading vessel data file...')
  const fileContent = await readFile(inputFile, 'utf-8')
  const vesselData: VesselData = JSON.parse(fileContent)

  console.log(`   Found ${vesselData.vessels.length} vessels`)

  // Find the vessel with the most track points (likely the self vessel/Tideye)
  // or look for a vessel with track points in the date range 2025-06-26 to 2025-07-04
  let targetVessel = vesselData.vessels[0]
  let maxTrackPoints = 0
  let targetVesselIndex = 0

  for (let i = 0; i < vesselData.vessels.length; i++) {
    const vessel = vesselData.vessels[i]
    const trackPoints = vessel.track.length
    
    if (trackPoints > maxTrackPoints) {
      maxTrackPoints = trackPoints
      targetVessel = vessel
      targetVesselIndex = i
    }
  }

  console.log(`\n🎯 Selected vessel: ${targetVessel.vessel.name} (ID: ${targetVessel.vessel.id})`)
  console.log(`   Track points: ${targetVessel.track.length}`)
  if (targetVessel.vessel.mmsi) {
    console.log(`   MMSI: ${targetVessel.vessel.mmsi}`)
  }

  // Sort track points by timestamp
  const sortedTrack = [...targetVessel.track].sort((a, b) => {
    return new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
  })

  if (sortedTrack.length === 0) {
    throw new Error('No track points found for the selected vessel')
  }

  const firstPoint = sortedTrack[0]
  const lastPoint = sortedTrack[sortedTrack.length - 1]

  const startTime = firstPoint.timestamp
  const endTime = lastPoint.timestamp
  const startLocation = {
    lat: firstPoint.coordinate.latitude,
    lon: firstPoint.coordinate.longitude,
  }
  const endLocation = {
    lat: lastPoint.coordinate.latitude,
    lon: lastPoint.coordinate.longitude,
  }

  console.log(`\n📍 Passage details:`)
  console.log(`   Start: ${startTime} (${startLocation.lat.toFixed(4)}, ${startLocation.lon.toFixed(4)})`)
  console.log(`   End: ${endTime} (${endLocation.lat.toFixed(4)}, ${endLocation.lon.toFixed(4)})`)

  // Calculate total distance
  let totalDistance = 0
  let maxSpeed = 0
  const speeds: number[] = []

  for (let i = 1; i < sortedTrack.length; i++) {
    const prev = sortedTrack[i - 1]
    const curr = sortedTrack[i]
    
    const segmentDistance = calculateDistance(
      prev.coordinate.latitude,
      prev.coordinate.longitude,
      curr.coordinate.latitude,
      curr.coordinate.longitude
    )
    totalDistance += segmentDistance

    // Calculate speed if timestamps are available
    const timeDiff = new Date(curr.timestamp).getTime() - new Date(prev.timestamp).getTime()
    const timeDiffHours = timeDiff / (1000 * 60 * 60)
    
    if (timeDiffHours > 0 && segmentDistance > 0) {
      const segmentSpeed = segmentDistance / timeDiffHours // km/h
      speeds.push(segmentSpeed)
      maxSpeed = Math.max(maxSpeed, segmentSpeed)
    } else if (curr.speed !== undefined && curr.speed > 0) {
      // Use speed from data if available (assuming it's in knots, convert to km/h)
      const speedKmh = curr.speed * 1.852 // knots to km/h
      speeds.push(speedKmh)
      maxSpeed = Math.max(maxSpeed, speedKmh)
    }
  }

  // Calculate duration
  const startDate = new Date(startTime)
  const endDate = new Date(endTime)
  const durationMs = endDate.getTime() - startDate.getTime()
  const durationHours = durationMs / (1000 * 60 * 60)

  // Calculate average speed
  const avgSpeed = durationHours > 0 ? totalDistance / durationHours : 0

  console.log(`\n📊 Statistics:`)
  console.log(`   Duration: ${durationHours.toFixed(2)} hours (${(durationHours / 24).toFixed(2)} days)`)
  console.log(`   Distance: ${totalDistance.toFixed(2)} km`)
  console.log(`   Avg Speed: ${avgSpeed.toFixed(2)} km/h`)
  console.log(`   Max Speed: ${maxSpeed.toFixed(2)} km/h`)
  console.log(`   Position points: ${sortedTrack.length}`)

  // Convert track points to PassagePosition format
  const positions: PassagePosition[] = sortedTrack.map(point => ({
    _time: point.timestamp,
    lat: point.coordinate.latitude,
    lon: point.coordinate.longitude,
  }))

  // Create passage ID from start date
  const startDateStr = startTime.split('T')[0].replace(/-/g, '_')
  const passageId = `tideye_passage_${startDateStr}`
  const filename = `passage_${startTime.split('T')[0]}_${passageId}.json`

  // Format route string
  const route = `${startLocation.lat.toFixed(2)}, ${startLocation.lon.toFixed(2)} → ${endLocation.lat.toFixed(2)}, ${endLocation.lon.toFixed(2)}`

  // Create passage object
  const passage: Passage = {
    id: passageId,
    startTime,
    endTime,
    duration: durationHours,
    avgSpeed,
    maxSpeed,
    distance: totalDistance,
    startLocation,
    endLocation,
    description: `Tideye passage from ${startTime.split('T')[0]}`,
    name: `Tideye Passage - ${startTime.split('T')[0]}`,
    route,
    exportTimestamp: new Date().toISOString(),
    filename,
    positions,
  }

  // Write to file
  const outputPath = join(outputDir, filename)
  await writeFile(outputPath, JSON.stringify(passage, null, 2), 'utf-8')

  console.log(`\n✅ Passage file created: ${filename}`)
  console.log(`   Location: ${outputPath}`)
}

// Run the script
processVesselDataToPassage().catch((error) => {
  console.error('❌ Error processing vessel data:', error)
  process.exit(1)
})


import { InfluxDB, flux } from '@influxdata/influxdb-client'
import { writeFile } from 'fs/promises'
import { join } from 'path'
import type { Passage, PassagePosition } from '../types/passage'

// Calculate distance between two coordinates using Haversine formula
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

async function fetchPassageFromInfluxDB() {
  const startDate = '2025-06-26'
  const startTime = `${startDate}T00:00:00Z`
  // Use a wide end range - we'll find the actual end from the data
  // Try a broader range to find any data
  const endTime = '2025-08-01T00:00:00Z'
  const resolution = 60 // 60 seconds = 1 minute resolution

  // Get InfluxDB config from environment
  const influxUrl = process.env.INFLUX_URL || 'http://influx.tideye.com:8086'
  const influxToken = process.env.INFLUX_API_KEY
  const influxOrgId = process.env.INFLUX_ORG_ID
  const influxBucket = process.env.INFLUX_BUCKET_DEFAULT || 'Tideye'

  if (!influxToken || !influxOrgId) {
    throw new Error('Missing InfluxDB configuration. Please set INFLUX_API_KEY and INFLUX_ORG_ID environment variables.')
  }

  console.log(`🔍 Fetching passage data from InfluxDB...`)
  console.log(`   URL: ${influxUrl}`)
  console.log(`   Bucket: ${influxBucket}`)
  console.log(`   Start: ${startTime}`)
  console.log(`   End range: ${endTime}`)
  console.log(`   Resolution: ${resolution}s`)

  try {
    const influxDB = new InfluxDB({
      url: influxUrl,
      token: influxToken,
    })

    const queryApi = influxDB.getQueryApi(influxOrgId)

    // First, explore what measurements are available (without self filter to see all data)
    console.log(`\n🔍 Exploring available measurements...`)
    const exploreQuery = `
      from(bucket: "${influxBucket}")
        |> range(start: ${startTime}, stop: ${endTime})
        |> limit(n: 100)
    `

    const measurements = new Set<string>()
    const fields = new Set<string>()

    await new Promise<void>((resolve, reject) => {
      let rowCount = 0
      queryApi.queryRows(exploreQuery, {
        next(row, tableMeta) {
          rowCount++
          const tableObject = tableMeta.toObject(row)
          console.log(`   Sample row ${rowCount}:`, {
            measurement: tableObject._measurement,
            field: tableObject._field,
            time: tableObject._time,
            value: tableObject._value,
            tags: Object.keys(tableObject).filter(k => !k.startsWith('_')),
          })
          if (tableObject._measurement) {
            measurements.add(tableObject._measurement as string)
          }
          if (tableObject._field) {
            fields.add(tableObject._field as string)
          }
        },
        error(error) {
          console.error('❌ Explore query error:', error)
          // Don't reject, just continue
          resolve()
        },
        complete() {
          console.log(`   Processed ${rowCount} rows`)
          resolve()
        },
      })
    })

    console.log(`   Found ${measurements.size} measurements:`, Array.from(measurements))
    console.log(`   Sample fields:`, Array.from(fields).slice(0, 10))

    // Try to find position-related measurements
    const positionMeasurements = Array.from(measurements).filter(m => 
      m.toLowerCase().includes('position') || 
      m.toLowerCase().includes('navigation') ||
      m.toLowerCase().includes('location')
    )

    if (positionMeasurements.length === 0) {
      console.log(`\n⚠️  No position measurements found. Trying all measurements...`)
      // Try querying without measurement filter and self filter
      const allMeasurementsQuery = `
        from(bucket: "${influxBucket}")
          |> range(start: ${startTime}, stop: ${endTime})
          |> filter(fn: (r) => r["_field"] == "lat" or r["_field"] == "lon")
          |> limit(n: 10)
      `
      
      let foundPositionData = false
      await new Promise<void>((resolve, reject) => {
        queryApi.queryRows(allMeasurementsQuery, {
          next(row, tableMeta) {
            const tableObject = tableMeta.toObject(row)
            if (tableObject._measurement) {
              measurements.add(tableObject._measurement as string)
              foundPositionData = true
            }
          },
          error(error) {
            reject(error)
          },
          complete() {
            resolve()
          },
        })
      })

      if (!foundPositionData) {
        throw new Error('No position data (lat/lon fields) found in InfluxDB for the specified time range')
      }
    }

    // Query for position data - try different measurement names
    // If we found a specific measurement, use it; otherwise try common names
    const measurementName = positionMeasurements[0] || 'navigation.position'
    console.log(`\n📊 Querying measurement: ${measurementName}`)

    // Build query - try with self filter first, then without if needed
    let fluxQuery = `
      from(bucket: "${influxBucket}")
        |> range(start: ${startTime}, stop: ${endTime})
        |> filter(fn: (r) => r["_field"] == "lat" or r["_field"] == "lon")
    `
    
    // Add measurement filter if we found one
    if (measurementName && measurementName !== 'navigation.position') {
      fluxQuery += `\n        |> filter(fn: (r) => r["_measurement"] == "${measurementName}")`
    }
    
    // Try with self filter, but we'll fall back without it
    fluxQuery += `
        |> filter(fn: (r) => r["self"] == "t")
        |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
        |> filter(fn: (r) => exists r.lat and exists r.lon)
        |> aggregateWindow(every: ${resolution}s, fn: first, createEmpty: false)
        |> sort(columns: ["_time"])
        |> yield(name: "positions")
    `

    const positions: Array<{ time: string; lat: number; lon: number }> = []

    await new Promise<void>((resolve, reject) => {
      queryApi.queryRows(fluxQuery, {
        next(row, tableMeta) {
          const tableObject = tableMeta.toObject(row)
          const time = tableObject._time as string
          const lat = tableObject.lat as number | undefined
          const lon = tableObject.lon as number | undefined
          
          if (lat !== undefined && lon !== undefined && !isNaN(lat) && !isNaN(lon)) {
            positions.push({
              time,
              lat,
              lon,
            })
          }
        },
        error(error) {
          console.error('❌ InfluxDB query error:', error)
          reject(error)
        },
        complete() {
          resolve()
        },
      })
    })

    if (positions.length === 0) {
      throw new Error('No position data found in InfluxDB for the specified time range')
    }

    console.log(`✅ Found ${positions.length} position points`)

    // Find actual start and end times from data
    const firstPosition = positions[0]
    const lastPosition = positions[positions.length - 1]
    
    if (!firstPosition || !lastPosition) {
      throw new Error('Invalid position data')
    }

    const actualStartTime = firstPosition.time
    const actualEndTime = lastPosition.time

    console.log(`   Actual start: ${actualStartTime}`)
    console.log(`   Actual end: ${actualEndTime}`)

    // Calculate statistics
    const startLocation = { lat: firstPosition.lat, lon: firstPosition.lon }
    const endLocation = { lat: lastPosition.lat, lon: lastPosition.lon }

    // Calculate total distance in km
    let totalDistanceKm = 0
    for (let i = 1; i < positions.length; i++) {
      const prev = positions[i - 1]
      const curr = positions[i]
      totalDistanceKm += calculateDistance(prev.lat, prev.lon, curr.lat, curr.lon)
    }

    // Convert distance from km to nautical miles (1 nm = 1.852 km)
    const totalDistanceNm = totalDistanceKm / 1.852

    // Calculate duration in hours
    const startDateObj = new Date(actualStartTime)
    const endDateObj = new Date(actualEndTime)
    const durationMs = endDateObj.getTime() - startDateObj.getTime()
    const durationHours = durationMs / (1000 * 60 * 60)

    // Calculate speeds in knots (distance in nm / time in hours)
    const avgSpeedKnots = durationHours > 0 ? totalDistanceNm / durationHours : 0
    
    // Calculate max speed between consecutive points in knots
    let maxSpeedKnots = 0
    for (let i = 1; i < positions.length; i++) {
      const prev = positions[i - 1]
      const curr = positions[i]
      const segmentDistanceKm = calculateDistance(prev.lat, prev.lon, curr.lat, curr.lon)
      const segmentDistanceNm = segmentDistanceKm / 1.852 // Convert to nautical miles
      const segmentTimeMs = new Date(curr.time).getTime() - new Date(prev.time).getTime()
      const segmentTimeHours = segmentTimeMs / (1000 * 60 * 60)
      if (segmentTimeHours > 0) {
        const segmentSpeedKnots = segmentDistanceNm / segmentTimeHours
        maxSpeedKnots = Math.max(maxSpeedKnots, segmentSpeedKnots)
      }
    }

    // Format route string
    const route = `${startLocation.lat.toFixed(2)}, ${startLocation.lon.toFixed(2)} → ${endLocation.lat.toFixed(2)}, ${endLocation.lon.toFixed(2)}`

    // Create passage ID from start date
    const passageId = `influxdb_passage_${startDate.replace(/-/g, '_')}`
    const filename = `passage_${startDate}_${passageId}.json`

    // Convert positions to PassagePosition format
    const passagePositions: PassagePosition[] = positions.map(p => ({
      _time: p.time,
      lat: p.lat,
      lon: p.lon,
    }))

    // Create passage object
    const passage: Passage = {
      id: passageId,
      startTime: actualStartTime,
      endTime: actualEndTime,
      duration: durationHours,
      avgSpeed: avgSpeedKnots,
      maxSpeed: maxSpeedKnots,
      distance: totalDistanceNm,
      startLocation,
      endLocation,
      description: `Passage data fetched from InfluxDB starting ${startDate}`,
      name: `InfluxDB Passage - ${startDate}`,
      route,
      exportTimestamp: new Date().toISOString(),
      filename,
      positions: passagePositions,
    }

    // Write to file
    const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
    const filePath = join(passagesDir, filename)

    await writeFile(filePath, JSON.stringify(passage, null, 2), 'utf-8')

    console.log(`\n✅ Passage file created: ${filename}`)
    console.log(`   Duration: ${durationHours.toFixed(2)} hours`)
    console.log(`   Distance: ${totalDistanceNm.toFixed(2)} nm`)
    console.log(`   Avg Speed: ${avgSpeedKnots.toFixed(2)} knots`)
    console.log(`   Max Speed: ${maxSpeedKnots.toFixed(2)} knots`)
    console.log(`   Positions: ${passagePositions.length}`)
  } catch (error: any) {
    console.error('❌ Error fetching passage from InfluxDB:', error)
    process.exit(1)
  }
}

// Run the script
fetchPassageFromInfluxDB()


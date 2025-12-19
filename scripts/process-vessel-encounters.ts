/**
 * Script to process raw vessel data into encounter format
 * 
 * Usage: npx tsx scripts/process-vessel-encounters.ts <passage-filename>
 * Example: npx tsx scripts/process-vessel-encounters.ts passage_2025-06-26_tideye_passage_2025_06_26.json
 */

import { readFile, writeFile, readdir } from 'fs/promises'
import { join } from 'path'
import type { Passage } from '../types/passage'
import type { RawVesselData } from '../utils/encounterProcessor'
import { processVesselEncounters } from '../utils/encounterProcessor'

async function processEncounters() {
  const passageFilename = process.argv[2]

  if (!passageFilename) {
    console.error('Usage: npx tsx scripts/process-vessel-encounters.ts <passage-filename>')
    console.error('Example: npx tsx scripts/process-vessel-encounters.ts passage_2025-06-26_tideye_passage_2025_06_26.json')
    process.exit(1)
  }

  const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
  const vesselDataDir = join(process.cwd(), 'public', 'data', 'passages_vessel_data')
  const outputDir = vesselDataDir

  console.log('📖 Loading passage data...')
  const passagePath = join(passagesDir, passageFilename)
  const passageContent = await readFile(passagePath, 'utf-8')
  const passage: Passage = JSON.parse(passageContent)

  console.log(`   Passage: ${passage.name || passage.id}`)
  console.log(`   Duration: ${passage.duration.toFixed(2)} hours`)

  // Find corresponding vessel data file
  // Try multiple naming patterns
  let vesselFilename: string | null = null
  let vesselDataPath: string | null = null

  if (passage.filename) {
    // Pattern 1: vessels_<passage-filename-without-passage-prefix>
    const pattern1 = `vessels_${passage.filename.replace('passage_', '')}`
    const path1 = join(vesselDataDir, pattern1)
    
    // Pattern 2: vessels_<id> (for tideye format)
    const pattern2 = `vessels_${passage.id}.json`
    const path2 = join(vesselDataDir, pattern2)
    
    // Pattern 3: vessels_<id-with-dashes>
    const pattern3 = `vessels_${passage.id.replace(/_/g, '-')}.json`
    const path3 = join(vesselDataDir, pattern3)

    // Try each pattern
    try {
      await readFile(path1, 'utf-8')
      vesselFilename = pattern1
      vesselDataPath = path1
    } catch {
      try {
        await readFile(path2, 'utf-8')
        vesselFilename = pattern2
        vesselDataPath = path2
      } catch {
        try {
          await readFile(path3, 'utf-8')
          vesselFilename = pattern3
          vesselDataPath = path3
        } catch {
          // List available files to help user
          const files = await readdir(vesselDataDir)
          const vesselFiles = files.filter(f => f.startsWith('vessels_') && f.endsWith('.json'))
          console.error(`\n❌ Cannot find vessel data file. Tried:`)
          console.error(`   - ${pattern1}`)
          console.error(`   - ${pattern2}`)
          console.error(`   - ${pattern3}`)
          console.error(`\n   Available vessel files:`)
          vesselFiles.slice(0, 10).forEach(f => console.error(`     - ${f}`))
          if (vesselFiles.length > 10) {
            console.error(`     ... and ${vesselFiles.length - 10} more`)
          }
          process.exit(1)
        }
      }
    }
  }

  if (!vesselFilename || !vesselDataPath) {
    console.error('❌ Cannot determine vessel data filename from passage')
    process.exit(1)
  }

  console.log(`\n📊 Loading vessel data from: ${vesselFilename}`)

  try {
    const vesselDataContent = await readFile(vesselDataPath, 'utf-8')
    const vesselData: RawVesselData = JSON.parse(vesselDataContent)

    console.log(`   Found ${vesselData.vessels.length} vessels in raw data`)

    // Process encounters
    console.log('\n🔄 Processing encounters...')
    const encounters = processVesselEncounters(vesselData, passage, {
      maxEncounterDistance: 50, // nautical miles
      segmentGapMinutes: 30, // minutes
      calculateDistances: true,
    })

    console.log(`   Processed ${encounters.totalVessels} unique vessels`)
    console.log(`   Total encounter segments: ${encounters.totalSegments}`)

    // Save processed encounters
    const outputFilename = `encounters_${passage.filename.replace('passage_', '')}`
    const outputPath = join(outputDir, outputFilename)
    await writeFile(outputPath, JSON.stringify(encounters, null, 2), 'utf-8')

    console.log(`\n✅ Encounters saved to: ${outputFilename}`)
    console.log(`   Location: ${outputPath}`)

    // Update passage file with encounters filename
    passage.encountersFilename = outputFilename
    await writeFile(passagePath, JSON.stringify(passage, null, 2), 'utf-8')
    console.log(`\n✅ Updated passage file with encounters filename`)

    // Print summary statistics
    console.log('\n📈 Encounter Statistics:')
    const byType = new Map<string, number>()
    encounters.encounters.forEach((enc) => {
      const type = enc.vessel.type || 'Unknown'
      byType.set(type, (byType.get(type) || 0) + 1)
    })

    console.log('   Vessels by type:')
    Array.from(byType.entries())
      .sort((a, b) => b[1] - a[1])
      .forEach(([type, count]) => {
        console.log(`     ${type}: ${count}`)
      })

    const closestApproaches = encounters.encounters
      .filter((enc) => enc.overallClosestApproach !== undefined)
      .sort((a, b) => (a.overallClosestApproach || Infinity) - (b.overallClosestApproach || Infinity))
      .slice(0, 5)

    if (closestApproaches.length > 0) {
      console.log('\n   Closest approaches:')
      closestApproaches.forEach((enc, idx) => {
        console.log(
          `     ${idx + 1}. ${enc.vessel.name} (${enc.vessel.type || 'Unknown'}): ${enc.overallClosestApproach?.toFixed(2)} nm`
        )
      })
    }
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
      console.error(`❌ Vessel data file not found: ${vesselDataPath}`)
      console.error('   Make sure the vessel data file exists in the passages_vessel_data directory')
    } else {
      console.error('❌ Error processing encounters:', error)
    }
    process.exit(1)
  }
}

processEncounters().catch((error) => {
  console.error('❌ Fatal error:', error)
  process.exit(1)
})


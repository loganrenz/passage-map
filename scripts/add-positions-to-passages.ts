import * as fs from 'fs/promises';
import * as fsSync from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

interface PassageLocation {
  lat: number;
  lon: number;
}

interface PassagePosition {
  _time: string;
  lat: number;
  lon: number;
}

interface Passage {
  id: string;
  startTime: string;
  endTime: string;
  duration: number;
  avgSpeed: number;
  maxSpeed: number;
  distance: number;
  startLocation: PassageLocation;
  endLocation: PassageLocation;
  description: string;
  name: string;
  route: string;
  exportTimestamp?: string;
  filename?: string;
  positions?: PassagePosition[];
}

interface TrackPoint {
  coordinate: {
    latitude: number;
    longitude: number;
  };
  timestamp: string;
  speed?: number;
  heading?: number;
}

interface Vessel {
  vessel?: unknown;
  track: TrackPoint[];
}

interface VesselData {
  vessels: Array<Vessel>;
}

async function addPositionsToPassages() {
  console.log('🚀 Adding positions to passage files...');

  try {
    const passagesDir = path.join(__dirname, '..', 'public', 'data', 'passages');
    const vesselDataDir = path.join(__dirname, '..', 'public', 'data', 'passages_vessel_data');

    if (!fsSync.existsSync(passagesDir)) {
      throw new Error(`Passages directory not found: ${passagesDir}`);
    }

    if (!fsSync.existsSync(vesselDataDir)) {
      throw new Error(`Vessel data directory not found: ${vesselDataDir}`);
    }

    // Read all passage files
    const passageFiles = await fs.readdir(passagesDir);
    const jsonFiles = passageFiles.filter((f) => f.endsWith('.json') && f !== 'passages_list.json');

    console.log(`📊 Found ${jsonFiles.length} passage files`);

    // Read all vessel data files
    const vesselFiles = await fs.readdir(vesselDataDir);
    const vesselJsonFiles = vesselFiles.filter((f) => f.endsWith('.json'));

    console.log(`📊 Found ${vesselJsonFiles.length} vessel data files`);

    // Create a map of passage IDs to vessel data
    const vesselDataMap = new Map<string, TrackPoint[]>();
    const vesselDataByTimestamp = new Map<string, TrackPoint[]>();

    for (const vesselFile of vesselJsonFiles) {
      const vesselFilePath = path.join(vesselDataDir, vesselFile);
      const vesselDataContent = await fs.readFile(vesselFilePath, 'utf8');
      const vesselData: VesselData = JSON.parse(vesselDataContent);

      if (vesselData.vessels && vesselData.vessels.length > 0) {
        const vessel = vesselData.vessels[0];
        if (vessel?.track && vessel.track.length > 0) {
          // Try to match by filename pattern (tideye_passage format)
          const passageIdMatch = vesselFile.match(/passage_(\d{4}_\d{2}_\d{2})/);
          if (passageIdMatch && passageIdMatch[1]) {
            const dateStr = passageIdMatch[1].replace(/_/g, '-');
            vesselDataMap.set(dateStr, vessel.track);
          }

          // Also match by timestamp (vessels_passage_<timestamp>.json format)
          const timestampMatch = vesselFile.match(/passage_(\d+)/);
          if (timestampMatch && timestampMatch[1]) {
            const timestamp = timestampMatch[1];
            vesselDataByTimestamp.set(timestamp, vessel.track);
          }
        }
      }
    }

    let updatedCount = 0;
    let skippedCount = 0;

    // Process each passage file
    for (const passageFile of jsonFiles) {
      const passageFilePath = path.join(passagesDir, passageFile);
      const passageContent = await fs.readFile(passageFilePath, 'utf8');
      const passage: Passage = JSON.parse(passageContent);

      // Skip if already has positions
      if (passage.positions && passage.positions.length > 0) {
        console.log(`⏭️  Skipping ${passageFile} - already has positions`);
        skippedCount++;
        continue;
      }

      // Try to find matching vessel data
      let trackData: TrackPoint[] | undefined;

      // Try matching by timestamp in passage ID
      const passageTimestampMatch = passage.id.match(/(\d{13})/);
      if (passageTimestampMatch && passageTimestampMatch[1]) {
        const timestamp = passageTimestampMatch[1];
        trackData = vesselDataByTimestamp.get(timestamp);
        if (trackData) {
          console.log(`   Found matching track data by timestamp for ${passageFile}`);
        }
      }

      // Try matching by date in filename
      if (!trackData) {
        const dateMatch = passageFile.match(/passage_(\d{4}-\d{2}-\d{2})/);
        if (dateMatch && dateMatch[1]) {
          const dateStr = dateMatch[1];
          trackData = vesselDataMap.get(dateStr);
          if (trackData) {
            console.log(`   Found matching track data by date for ${passageFile}`);
          }
        }
      }

      // If not found, try to find by passage date range
      if (!trackData) {
        const passageStartDate = new Date(passage.startTime);
        const dateStr = passageStartDate.toISOString().split('T')[0];
        if (dateStr) {
          trackData = vesselDataMap.get(dateStr);
        }
        if (trackData) {
          console.log(`   Found matching track data by start date for ${passageFile}`);
        }
      }

      // If still not found, try to find any vessel data that overlaps with passage time range
      if (!trackData) {
        for (const [, track] of vesselDataMap.entries()) {
          if (track.length > 0) {
            const firstPoint = track[0]
            const lastPoint = track[track.length - 1]
            if (firstPoint && lastPoint) {
              const trackStart = new Date(firstPoint.timestamp);
              const trackEnd = new Date(lastPoint.timestamp);
              const passageStart = new Date(passage.startTime);
              const passageEnd = new Date(passage.endTime);

              // Check if there's overlap
              if (
                (trackStart <= passageEnd && trackEnd >= passageStart) ||
                (passageStart <= trackEnd && passageEnd >= trackStart)
              ) {
                trackData = track;
                console.log(`   Found matching track data by time range for ${passageFile}`);
                break;
              }
            }
          }
        }
      }

      if (!trackData || trackData.length === 0) {
        console.log(`⚠️  No vessel data found for ${passageFile}`);
        skippedCount++;
        continue;
      }

      // Filter track points to passage time range
      const passageStart = new Date(passage.startTime);
      const passageEnd = new Date(passage.endTime);

      const filteredTrack = trackData.filter((point) => {
        const pointTime = new Date(point.timestamp);
        return pointTime >= passageStart && pointTime <= passageEnd;
      });

      if (filteredTrack.length === 0) {
        console.log(`⚠️  No track points in time range for ${passageFile}`);
        skippedCount++;
        continue;
      }

      // Convert track points to positions
      const positions: PassagePosition[] = filteredTrack.map((point) => ({
        _time: point.timestamp,
        lat: point.coordinate.latitude,
        lon: point.coordinate.longitude,
      }));

      // Update passage with positions
      const updatedPassage: Passage = {
        ...passage,
        positions,
      };

      // Write updated passage back to file
      await fs.writeFile(passageFilePath, JSON.stringify(updatedPassage, null, 2));

      console.log(`✅ Updated ${passageFile} with ${positions.length} positions`);
      updatedCount++;
    }

    console.log(`\n📋 Summary:`);
    console.log(`   Updated: ${updatedCount} passages`);
    console.log(`   Skipped: ${skippedCount} passages`);
  } catch (error) {
    console.error('❌ Error adding positions to passages:', error);
    throw error;
  }
}

// Run the script
addPositionsToPassages().catch(console.error);


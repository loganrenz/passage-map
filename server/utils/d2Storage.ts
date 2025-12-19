/**
 * D2 Database storage utilities for Cloudflare D2
 * Provides typed access to passages and locations stored in D2
 */

export interface D2Database {
  prepare(query: string): D2PreparedStatement
  exec(query: string): Promise<D2ExecResult>
  batch<T = unknown>(statements: D2PreparedStatement[]): Promise<D2Result<T>[]>
}

export interface D2PreparedStatement {
  bind(...values: unknown[]): D2PreparedStatement
  first<T = unknown>(): Promise<T | null>
  run<T = unknown>(): Promise<D2Result<T>>
  all<T = unknown>(): Promise<D2Result<T>>
}

export interface D2Result<T = unknown> {
  success: boolean
  meta: {
    duration: number
    rows_read: number
    rows_written: number
    changed_db: boolean
    last_row_id: number
    changed_rows: number
    size_after: number
  }
  results?: T[]
}

export interface D2ExecResult {
  count: number
  duration: number
}

/**
 * Get D2 database binding from environment
 */
export function getD2Database(env?: { [key: string]: unknown }): D2Database | null {
  if (!env) {
    if (process.env.NODE_ENV !== 'production') {
      console.log('getD2Database: No env provided')
    }
    return null
  }
  
  // Try both binding names (passage_map_db and PASSAGES_DB)
  let db = (env['passage_map_db'] || env['PASSAGES_DB']) as D2Database | undefined
  
  // Try alternative paths
  if (!db && (env as any).cloudflare?.env) {
    db = ((env as any).cloudflare.env['passage_map_db'] || (env as any).cloudflare.env['PASSAGES_DB']) as D2Database | undefined
  }
  
  if (db && typeof db === 'object' && 'prepare' in db && 'exec' in db) {
    // Always log in production to help diagnose issues
    if (process.env.NODE_ENV === 'production') {
      console.log('✅ D1 database binding found and available (passage_map_db)')
    } else {
      console.log('✅ D1 database binding found and available')
    }
    return db
  }
  
  // In local development, D1 bindings aren't available - this is expected
  // The code will fall back to D2 API client or local D1 access via wrangler commands
  // Only log if we're in a context where D1 should be available (production or explicit debug)
  if (process.env.NODE_ENV === 'production' || process.env.DEBUG_D2) {
    console.warn('⚠️  D1 database binding not found')
    console.warn('   Looking for binding: passage_map_db or PASSAGES_DB')
    console.warn('   Available env keys:', Object.keys(env || {}))
    if ((env as any)?.cloudflare?.env) {
      console.warn('   Cloudflare env keys:', Object.keys((env as any).cloudflare.env))
    }
    if (process.env.NODE_ENV === 'production' && !process.env.VERCEL) {
      console.warn('   This is Cloudflare Pages production - D1 binding must be configured in Pages settings')
    }
  }
  
  return null
}

/**
 * Initialize D2 database schema
 */
export async function initD2Schema(db: D2Database): Promise<void> {
  const schema = `
    -- Passages table
    CREATE TABLE IF NOT EXISTS passages (
      id TEXT PRIMARY KEY,
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      duration INTEGER NOT NULL,
      avg_speed REAL NOT NULL,
      max_speed REAL NOT NULL,
      distance REAL NOT NULL,
      start_lat REAL NOT NULL,
      start_lon REAL NOT NULL,
      end_lat REAL NOT NULL,
      end_lon REAL NOT NULL,
      description TEXT,
      name TEXT NOT NULL,
      route TEXT,
      export_timestamp TEXT,
      filename TEXT,
      query_metadata TEXT,  -- JSON string
      encounters_filename TEXT,
      created_at INTEGER DEFAULT (unixepoch()),
      updated_at INTEGER DEFAULT (unixepoch())
    );

    -- Passage positions table (for detailed route data)
    CREATE TABLE IF NOT EXISTS passage_positions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      passage_id TEXT NOT NULL,
      time TEXT NOT NULL,
      lat REAL NOT NULL,
      lon REAL NOT NULL,
      speed REAL,
      heading REAL,
      distance REAL,
      FOREIGN KEY (passage_id) REFERENCES passages(id) ON DELETE CASCADE,
      UNIQUE(passage_id, time)
    );

    -- Location information table (geocoded locations along routes)
    CREATE TABLE IF NOT EXISTS passage_locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      passage_id TEXT NOT NULL,
      time TEXT NOT NULL,
      lat REAL NOT NULL,
      lon REAL NOT NULL,
      name TEXT,
      locality TEXT,
      administrative_area TEXT,
      country TEXT,
      country_code TEXT,
      formatted_address TEXT,
      points_of_interest TEXT,  -- JSON array string
      created_at INTEGER DEFAULT (unixepoch()),
      FOREIGN KEY (passage_id) REFERENCES passages(id) ON DELETE CASCADE
    );

    -- Indexes for performance
    CREATE INDEX IF NOT EXISTS idx_passages_start_time ON passages(start_time);
    CREATE INDEX IF NOT EXISTS idx_passages_end_time ON passages(end_time);
    CREATE INDEX IF NOT EXISTS idx_passage_positions_passage_id ON passage_positions(passage_id);
    CREATE INDEX IF NOT EXISTS idx_passage_positions_time ON passage_positions(time);
    CREATE INDEX IF NOT EXISTS idx_passage_locations_passage_id ON passage_locations(passage_id);
    CREATE INDEX IF NOT EXISTS idx_passage_locations_time ON passage_locations(time);
  `

  await db.exec(schema)
}

/**
 * Insert or update a passage in D2
 */
export async function upsertPassage(
  db: D2Database,
  passage: {
    id: string
    startTime: string
    endTime: string
    duration: number
    avgSpeed: number
    maxSpeed: number
    distance: number
    startLocation: { lat: number; lon: number }
    endLocation: { lat: number; lon: number }
    description: string
    name: string
    route: string
    exportTimestamp?: string
    filename?: string
    queryMetadata?: unknown
    encountersFilename?: string
  }
): Promise<void> {
  const query = `
    INSERT INTO passages (
      id, start_time, end_time, duration, avg_speed, max_speed, distance,
      start_lat, start_lon, end_lat, end_lon, description, name, route,
      export_timestamp, filename, query_metadata, encounters_filename, updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, unixepoch())
    ON CONFLICT(id) DO UPDATE SET
      start_time = excluded.start_time,
      end_time = excluded.end_time,
      duration = excluded.duration,
      avg_speed = excluded.avg_speed,
      max_speed = excluded.max_speed,
      distance = excluded.distance,
      start_lat = excluded.start_lat,
      start_lon = excluded.start_lon,
      end_lat = excluded.end_lat,
      end_lon = excluded.end_lon,
      description = excluded.description,
      name = excluded.name,
      route = excluded.route,
      export_timestamp = excluded.export_timestamp,
      filename = excluded.filename,
      query_metadata = excluded.query_metadata,
      encounters_filename = excluded.encounters_filename,
      updated_at = unixepoch()
  `

  await db
    .prepare(query)
    .bind(
      passage.id,
      passage.startTime,
      passage.endTime,
      passage.duration,
      passage.avgSpeed,
      passage.maxSpeed,
      passage.distance,
      passage.startLocation.lat,
      passage.startLocation.lon,
      passage.endLocation.lat,
      passage.endLocation.lon,
      passage.description,
      passage.name,
      passage.route,
      passage.exportTimestamp || null,
      passage.filename || null,
      passage.queryMetadata ? JSON.stringify(passage.queryMetadata) : null,
      passage.encountersFilename || null
    )
    .run()
}

/**
 * Insert passage positions in batch
 */
export async function insertPassagePositions(
  db: D2Database,
  passageId: string,
  positions: Array<{
    _time: string
    lat: number
    lon: number
    speed?: number
    heading?: number
    distance?: number
  }>
): Promise<void> {
  if (positions.length === 0) return

  // Delete existing positions for this passage
  await db.prepare('DELETE FROM passage_positions WHERE passage_id = ?').bind(passageId).run()

  // Insert in batches of 100
  const batchSize = 100
  for (let i = 0; i < positions.length; i += batchSize) {
    const batch = positions.slice(i, i + batchSize)
    const statements = batch.map((pos) =>
      db
        .prepare(
          'INSERT INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance) VALUES (?, ?, ?, ?, ?, ?, ?)'
        )
        .bind(
          passageId,
          pos._time,
          pos.lat,
          pos.lon,
          pos.speed || null,
          pos.heading || null,
          pos.distance || null
        )
    )
    await db.batch(statements)
  }
}

/**
 * Insert passage locations in batch
 */
export async function insertPassageLocations(
  db: D2Database,
  passageId: string,
  locations: Array<{
    coordinate: { lat: number; lon: number }
    time: string
    name?: string
    locality?: string
    administrativeArea?: string
    country?: string
    countryCode?: string
    formattedAddress?: string
    pointsOfInterest?: string[]
  }>
): Promise<void> {
  if (locations.length === 0) return

  // Delete existing locations for this passage
  await db.prepare('DELETE FROM passage_locations WHERE passage_id = ?').bind(passageId).run()

  // Insert in batches
  const batchSize = 100
  for (let i = 0; i < locations.length; i += batchSize) {
    const batch = locations.slice(i, i + batchSize)
    const statements = batch.map((loc) =>
      db
        .prepare(
          'INSERT INTO passage_locations (passage_id, time, lat, lon, name, locality, administrative_area, country, country_code, formatted_address, points_of_interest) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
        )
        .bind(
          passageId,
          loc.time,
          loc.coordinate.lat,
          loc.coordinate.lon,
          loc.name || null,
          loc.locality || null,
          loc.administrativeArea || null,
          loc.country || null,
          loc.countryCode || null,
          loc.formattedAddress || null,
          loc.pointsOfInterest ? JSON.stringify(loc.pointsOfInterest) : null
        )
    )
    await db.batch(statements)
  }
}

/**
 * Get a passage by ID with positions and locations
 */
export async function getPassage(
  db: D2Database,
  passageId: string
): Promise<{
  passage: any
  positions: any[]
  locations: any[]
} | null> {
  const passage = await db
    .prepare('SELECT * FROM passages WHERE id = ?')
    .bind(passageId)
    .first()

  if (!passage) {
    return null
  }

  const positions = await db
    .prepare('SELECT * FROM passage_positions WHERE passage_id = ? ORDER BY time')
    .bind(passageId)
    .all()

  const locations = await db
    .prepare('SELECT * FROM passage_locations WHERE passage_id = ? ORDER BY time')
    .bind(passageId)
    .all()

  return {
    passage,
    positions: positions.results || [],
    locations: locations.results || [],
  }
}

/**
 * List all passages (metadata only, no positions/locations)
 */
export async function listPassages(
  db: D2Database,
  limit?: number,
  offset?: number
): Promise<any[]> {
  let query = 'SELECT * FROM passages ORDER BY start_time DESC'
  const params: unknown[] = []

  if (limit) {
    query += ' LIMIT ?'
    params.push(limit)
    if (offset) {
      query += ' OFFSET ?'
      params.push(offset)
    }
  }

  const result = await db.prepare(query).bind(...params).all()
  return result.results || []
}

/**
 * Update passage name in D2
 */
export async function updatePassageName(
  db: D2Database,
  passageId: string,
  name: string
): Promise<void> {
  const query = `
    UPDATE passages
    SET name = ?, updated_at = unixepoch()
    WHERE id = ?
  `

  const result = await db.prepare(query).bind(name, passageId).run()
  
  if (result.meta.changed_rows === 0) {
    throw new Error(`Passage ${passageId} not found`)
  }
}


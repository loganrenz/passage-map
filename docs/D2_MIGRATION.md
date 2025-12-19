# D2 Database Migration Guide

This guide explains how to migrate passage data from JSON files to Cloudflare D2 (D1) database.

## Overview

D2 (D1) is Cloudflare's SQLite-based database that provides:
- Fast queries with SQL
- Automatic scaling
- Integrated with Cloudflare Workers
- Free tier with generous limits

## Prerequisites

1. Install Wrangler CLI: `npm install -g wrangler`
2. Authenticate with Cloudflare: `wrangler login`
3. Ensure you have a Cloudflare account with D2 access

## Setup Steps

### 1. Create D2 Database

```bash
wrangler d1 create passage-map-db
```

This will output a database ID. Copy it.

### 2. Update wrangler.toml

Update the `database_id` in `wrangler.toml` with the ID from step 1:

```toml
[[d1_databases]]
binding = "PASSAGES_DB"
database_name = "passage-map-db"
database_id = "YOUR_DATABASE_ID_HERE"
```

### 3. Run Geocoding Script

First, geocode all passages to add location information:

```bash
npx tsx scripts/geocode-passages.ts
```

This script:
- Reads all passage JSON files
- Samples key points along each route
- Reverse geocodes coordinates to get city/town names
- Saves location data back to JSON files

**Note:** The script uses OpenStreetMap Nominatim API (free, no key required) with rate limiting (1 request/second).

### 4. Generate Migration SQL

Generate SQL statements to migrate data:

```bash
npx tsx scripts/migrate-to-d2.ts
```

This creates a `migration.sql` file with all INSERT statements.

### 5. Apply Migration

Apply the migration to D2:

```bash
wrangler d1 execute passage-map-db --file=./migration.sql
```

### 6. Verify Migration

Check that data was migrated:

```bash
# Count passages
wrangler d1 execute passage-map-db --command="SELECT COUNT(*) as count FROM passages;"

# List first few passages
wrangler d1 execute passage-map-db --command="SELECT id, name, start_time FROM passages LIMIT 5;"

# Check locations
wrangler d1 execute passage-map-db --command="SELECT COUNT(*) as count FROM passage_locations;"
```

## Automated Setup

You can use the setup script to do all of the above:

```bash
./scripts/setup-d2.sh
```

## Database Schema

### passages
Main passage metadata:
- `id` (TEXT PRIMARY KEY)
- `start_time`, `end_time` (TEXT)
- `duration`, `avg_speed`, `max_speed`, `distance` (REAL/INTEGER)
- `start_lat`, `start_lon`, `end_lat`, `end_lon` (REAL)
- `description`, `name`, `route` (TEXT)
- `filename`, `export_timestamp` (TEXT)
- `query_metadata` (TEXT - JSON string)
- `encounters_filename` (TEXT)

### passage_positions
Detailed position data along the route:
- `id` (INTEGER PRIMARY KEY)
- `passage_id` (TEXT - FK to passages)
- `time` (TEXT)
- `lat`, `lon` (REAL)
- `speed`, `heading`, `distance` (REAL, nullable)

### passage_locations
Geocoded location information:
- `id` (INTEGER PRIMARY KEY)
- `passage_id` (TEXT - FK to passages)
- `time` (TEXT)
- `lat`, `lon` (REAL)
- `name`, `locality`, `administrative_area`, `country`, `country_code` (TEXT, nullable)
- `formatted_address` (TEXT, nullable)
- `points_of_interest` (TEXT - JSON array string, nullable)

## Using D2 in Code

The `server/utils/d2Storage.ts` module provides utilities for:
- `initD2Schema(db)` - Initialize database schema
- `upsertPassage(db, passage)` - Insert or update passage
- `insertPassagePositions(db, passageId, positions)` - Insert positions
- `insertPassageLocations(db, passageId, locations)` - Insert locations
- `getPassage(db, passageId)` - Get passage with positions and locations
- `listPassages(db, limit?, offset?)` - List all passages

## Local Development

For local development, you can use Wrangler's local D2:

```bash
# Start local D2
wrangler d1 execute passage-map-db --local --file=./migration.sql

# Query local D2
wrangler d1 execute passage-map-db --local --command="SELECT * FROM passages LIMIT 5;"
```

## Next Steps

After migration:
1. Update API endpoints to read from D2 instead of JSON files
2. Update storage utilities to use D2 as primary storage
3. Keep JSON files as backup or remove them after verification
4. Update frontend to work with D2-backed APIs


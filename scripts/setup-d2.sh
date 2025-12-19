#!/bin/bash
# Setup script for D2 database migration
# This script helps set up the D2 database and run migrations

set -e

echo "🚀 Setting up D2 database for passage-map..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI not found. Please install it:"
    echo "   npm install -g wrangler"
    exit 1
fi

# Create D2 database
echo "📦 Creating D2 database..."
DB_OUTPUT=$(wrangler d1 create passage-map-db 2>&1)
echo "$DB_OUTPUT"

# Extract database ID from output
DB_ID=$(echo "$DB_OUTPUT" | grep -oP 'database_id = "\K[^"]+' | head -1)

if [ -z "$DB_ID" ]; then
    echo "⚠️  Could not extract database ID. Please manually update wrangler.toml with the database_id"
    echo "   Look for 'database_id' in the output above"
else
    echo "✅ Database ID: $DB_ID"
    
    # Update wrangler.toml with the database ID
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/database_id = \"placeholder\"/database_id = \"$DB_ID\"/" wrangler.toml
    else
        # Linux
        sed -i "s/database_id = \"placeholder\"/database_id = \"$DB_ID\"/" wrangler.toml
    fi
    
    echo "✅ Updated wrangler.toml with database ID"
fi

# Run geocoding script first
echo ""
echo "🌍 Running geocoding script to add location data..."
if [ -f "scripts/geocode-passages.ts" ]; then
    npx tsx scripts/geocode-passages.ts
else
    echo "⚠️  Geocoding script not found, skipping..."
fi

# Generate migration SQL
echo ""
echo "📝 Generating migration SQL..."
if [ -f "scripts/migrate-to-d2.ts" ]; then
    npx tsx scripts/migrate-to-d2.ts
else
    echo "⚠️  Migration script not found, skipping..."
fi

# Apply migration
if [ -f "migration.sql" ]; then
    echo ""
    echo "🗄️  Applying migration to D2 database..."
    wrangler d1 execute passage-map-db --file=./migration.sql
    
    echo ""
    echo "✅ Migration complete!"
    echo ""
    echo "Next steps:"
    echo "1. Verify data: wrangler d1 execute passage-map-db --command='SELECT COUNT(*) FROM passages;'"
    echo "2. Update your code to use D2 storage instead of JSON files"
else
    echo "⚠️  Migration SQL file not found. Run migrate-to-d2.ts first."
fi


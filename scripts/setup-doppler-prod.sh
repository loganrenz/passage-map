#!/bin/bash

# Script to set up production MapKit token in Doppler
# Usage: ./scripts/setup-doppler-prod.sh

set -e

PROJECT="passage-map"
CONFIG="prd"
PROD_TOKEN="eyJraWQiOiI0NTg4MzYyWlFQIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzI4MDQ4MDk3LCJvcmlnaW4iOiIqLnRpZGV5ZS5jb20ifQ.Jfhf-mI5ZnYIum_XA9lX8Z1HYte-T4kzt2ouDMgCubwlvrP1G4YZAFy2b66uWUhPr4Nqkcozofg9sxAEVR7Aiw"

echo "🚀 Setting up production MapKit token in Doppler..."
echo ""

# Check if Doppler CLI is installed
if ! command -v doppler &> /dev/null; then
    echo "❌ Doppler CLI is not installed."
    echo "   Install it with: brew install dopplerhq/cli/doppler"
    exit 1
fi

# Check if user is logged in
if ! doppler me &> /dev/null; then
    echo "⚠️  Not logged into Doppler. Please run: doppler login"
    exit 1
fi

echo "📦 Project: $PROJECT"
echo "⚙️  Config: $CONFIG"
echo ""

# Set up the production config
echo "Setting up production config..."
doppler setup --project "$PROJECT" --config "$CONFIG" --no-interactive

# Set the production token
echo "Setting MAPKIT_PROD_TOKEN..."
doppler secrets set MAPKIT_PROD_TOKEN="$PROD_TOKEN" --no-interactive

# Verify the token was set
echo ""
echo "✅ Verifying token was set..."
VERIFIED_TOKEN=$(doppler secrets get MAPKIT_PROD_TOKEN --plain --no-interactive)
if [ "$VERIFIED_TOKEN" = "$PROD_TOKEN" ]; then
    echo "✅ Production token successfully configured!"
else
    echo "❌ Token verification failed"
    exit 1
fi

echo ""
echo "🎉 Production MapKit token is now configured in Doppler!"
echo ""
echo "Next steps:"
echo "1. Install Doppler integration in Vercel:"
echo "   vercel integrations add doppler"
echo ""
echo "2. Or set it up via Vercel dashboard:"
echo "   https://vercel.com/[your-team]/[your-project]/settings/integrations"
echo ""
echo "3. Select project: $PROJECT, config: $CONFIG"
echo ""


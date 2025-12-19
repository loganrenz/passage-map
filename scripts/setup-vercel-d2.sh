#!/bin/bash
# Setup script for configuring Vercel to access D2 via Cloudflare Worker API

set -e

echo "🚀 Setting up Vercel D2 access..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI not found. Please install it:"
    echo "   npm install -g wrangler"
    exit 1
fi

# Check if doppler is installed
if ! command -v doppler &> /dev/null; then
    echo "⚠️  Doppler CLI not found. You'll need to set environment variables manually in Vercel."
    USE_DOPPLER=false
else
    USE_DOPPLER=true
fi

# Deploy D2 API Worker
echo ""
echo "📦 Deploying D2 API Worker..."
cd workers/d2-api
wrangler deploy

# Get the worker URL
WORKER_URL=$(wrangler deployments list --format json | jq -r '.[0].url' 2>/dev/null || echo "")
if [ -z "$WORKER_URL" ]; then
    echo "⚠️  Could not determine worker URL. Please check wrangler deployments list"
    echo "   Then manually set D2_API_URL in Vercel/Doppler"
else
    echo "✅ Worker deployed at: $WORKER_URL"
fi

cd ../..

# Set API key (optional but recommended)
echo ""
read -p "Do you want to set an API key for the worker? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -sp "Enter API key: " API_KEY
    echo
    if [ ! -z "$API_KEY" ]; then
        cd workers/d2-api
        echo "$API_KEY" | wrangler secret put D2_API_KEY
        cd ../..
        echo "✅ API key set"
    fi
fi

# Configure environment variables
echo ""
if [ "$USE_DOPPLER" = true ]; then
    echo "📝 Configuring Doppler environment variables..."
    
    # Set D2 API URL
    if [ ! -z "$WORKER_URL" ]; then
        doppler secrets set D2_API_URL="$WORKER_URL" --config prd
        echo "✅ Set D2_API_URL in Doppler"
    fi
    
    # Set API key if provided
    if [ ! -z "$API_KEY" ]; then
        doppler secrets set D2_API_KEY="$API_KEY" --config prd
        echo "✅ Set D2_API_KEY in Doppler"
    fi
    
    echo ""
    echo "✅ Configuration complete!"
    echo ""
    echo "Next steps:"
    echo "1. Verify Doppler sync in Vercel: vercel env ls"
    echo "2. Test the API: curl $WORKER_URL/health"
    if [ ! -z "$API_KEY" ]; then
        echo "3. Test authenticated endpoint: curl -H 'Authorization: Bearer $API_KEY' $WORKER_URL/passages"
    fi
else
    echo "📝 Manual Vercel Configuration Required:"
    echo ""
    echo "Go to Vercel Dashboard → Your Project → Settings → Environment Variables"
    echo "Add the following:"
    if [ ! -z "$WORKER_URL" ]; then
        echo "  - D2_API_URL: $WORKER_URL"
    fi
    if [ ! -z "$API_KEY" ]; then
        echo "  - D2_API_KEY: $API_KEY"
    fi
    echo ""
    echo "Or use Vercel CLI:"
    if [ ! -z "$WORKER_URL" ]; then
        echo "  vercel env add D2_API_URL production"
        echo "  (Enter: $WORKER_URL)"
    fi
    if [ ! -z "$API_KEY" ]; then
        echo "  vercel env add D2_API_KEY production"
        echo "  (Enter: $API_KEY)"
    fi
fi

echo ""
echo "📚 See docs/VERCEL_D2_SETUP.md for more details"


#!/bin/bash
# Script to start both D2 API worker and Nuxt dev server with Doppler

set -e

echo "🚀 Starting development servers with Doppler..."

# Load Doppler secrets and start both services
doppler run --config dev -- npx concurrently \
  --names "D2-API,NUXT" \
  --prefix-colors "cyan,magenta" \
  "cd workers/d2-api && wrangler dev" \
  "sleep 5 && nuxt dev"


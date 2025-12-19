# Vercel D2 Database Setup

This guide explains how to configure Vercel to access Cloudflare D2 database via a Cloudflare Worker API.

## Overview

Since D2 (D1) is a Cloudflare-specific service, Vercel cannot directly access it. We use a Cloudflare Worker as a REST API proxy to bridge this gap.

## Architecture

```
Vercel (Nuxt App) → Cloudflare Worker API → D2 Database
```

## Setup Steps

### 1. Deploy the D2 API Worker

The worker is located in `workers/d2-api/`. Deploy it to Cloudflare:

```bash
cd workers/d2-api
wrangler deploy
```

This will output a URL like: `https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev`

### 2. (Optional) Set API Key for Authentication

For production, it's recommended to secure the API with an API key:

```bash
cd workers/d2-api
wrangler secret put D2_API_KEY
# Enter your API key when prompted
```

### 3. Configure Vercel Environment Variables

Add these environment variables in Vercel (via Doppler or directly):

#### Via Doppler (Recommended)

```bash
# Set the D2 API URL
doppler secrets set D2_API_URL="https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev" --config prd

# Set the API key (if you configured one)
doppler secrets set D2_API_KEY="your-api-key-here" --config prd
```

#### Via Vercel Dashboard

1. Go to your Vercel project → Settings → Environment Variables
2. Add:
   - `D2_API_URL`: `https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev`
   - `D2_API_KEY`: (optional) Your API key if you set one

### 4. Update Code to Use D2 API Client

The code automatically detects if `D2_API_URL` is set and uses the API client instead of direct D2 access.

In your server code:

```typescript
import { getD2ApiClient } from '~/server/utils/d2ApiClient'

// Get client (returns null if D2_API_URL not set)
const d2Client = getD2ApiClient()

if (d2Client) {
  // Use API client (Vercel)
  const passages = await d2Client.listPassages()
} else {
  // Use direct D2 access (Cloudflare Workers/Pages)
  const db = getD2Database(env)
  const passages = await listPassages(db)
}
```

## API Endpoints

The D2 API Worker exposes these endpoints:

### Health Check
```
GET /health
```

### Execute Query
```
POST /query
Body: { "query": "SELECT * FROM passages", "params": [] }
```

### Execute Batch Queries
```
POST /batch
Body: { "queries": [{ "query": "...", "params": [] }] }
```

### Get Passage
```
GET /passages/{passageId}
Returns: { passage, positions, locations }
```

### List Passages
```
GET /passages?limit=100&offset=0
Returns: Passage[]
```

## Local Development

For local development, you can either:

### Option 1: Use Local D2 (Recommended)

```bash
# Run worker locally
cd workers/d2-api
wrangler dev

# Set D2_API_URL to local worker
export D2_API_URL="http://localhost:8787"
```

### Option 2: Use Direct D2 Access

Don't set `D2_API_URL`, and the code will use direct D2 bindings (if available in your environment).

## Security Considerations

1. **API Key**: Always use an API key in production
2. **CORS**: The worker allows all origins by default. For production, restrict CORS to your Vercel domain
3. **Rate Limiting**: Consider adding rate limiting to the worker
4. **Query Validation**: The worker doesn't validate queries. Be careful with user input

## Troubleshooting

### Worker not responding
- Check worker logs: `wrangler tail`
- Verify worker is deployed: `wrangler deployments list`

### Authentication errors
- Verify `D2_API_KEY` matches in both Vercel and Worker
- Check Authorization header format: `Bearer {key}`

### Database connection errors
- Verify D2 database ID in `workers/d2-api/wrangler.toml`
- Check database exists: `wrangler d1 list`

### CORS errors
- Ensure worker CORS headers are set correctly
- Check if API URL is correct in Vercel environment variables

## Testing

Test the API locally:

```bash
# Health check
curl https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev/health

# List passages
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev/passages
```


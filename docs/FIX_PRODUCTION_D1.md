# Fix Production D1 Database Access

## Current Situation

- ✅ D1 database exists and has 31 passages
- ✅ Database ID: `6dae99e4-d07d-44f0-96a7-84a66a70ed6b`
- ❌ App is deployed to **Vercel** (not Cloudflare Pages)
- ❌ D2 API Worker is **not deployed**
- ❌ `D2_API_URL` is likely not set in Vercel

## Solution: Deploy D2 API Worker and Configure Vercel

Since Vercel can't directly access Cloudflare D1 bindings, we need to use a Cloudflare Worker as a proxy.

### Step 1: Deploy the D2 API Worker

```bash
cd workers/d2-api
npm run d2:api:deploy
# or
wrangler deploy
```

This will output a URL like:
```
https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev
```

**Save this URL** - you'll need it for the next step.

### Step 2: (Optional) Set API Key for Security

For production, it's recommended to secure the API:

```bash
cd workers/d2-api
wrangler secret put D2_API_KEY
# Enter a secure API key when prompted
```

**Save this API key** - you'll need it for Vercel.

### Step 3: Configure Vercel Environment Variables

You have two options:

#### Option A: Via Doppler (Recommended)

If you're using Doppler for secrets management:

```bash
# Set the D2 API URL (use the URL from Step 1)
doppler secrets set D2_API_URL="https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev" --config prd

# Set the API key (if you set one in Step 2)
doppler secrets set D2_API_KEY="your-api-key-here" --config prd
```

Then ensure Vercel is connected to Doppler (see [DOPPLER_SETUP.md](./DOPPLER_SETUP.md)).

#### Option B: Via Vercel Dashboard

1. Go to: https://vercel.com/dashboard
2. Select your project: **passage-map**
3. Go to: **Settings** → **Environment Variables**
4. Add these variables:

   **For Production:**
   - Name: `D2_API_URL`
   - Value: `https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev`
   - Environment: Production

   **If you set an API key:**
   - Name: `D2_API_KEY`
   - Value: `your-api-key-here`
   - Environment: Production

5. Click **Save**

### Step 4: Redeploy Vercel

After setting the environment variables:

1. Go to your Vercel project → **Deployments**
2. Click **Redeploy** on the latest deployment
3. Or push a new commit to trigger a deployment

### Step 5: Verify It Works

1. Visit your production URL
2. Check the browser console for errors
3. The passages list should load successfully
4. Check Vercel function logs for:
   - `✅ D2 API client configured with URL: ...`
   - `✅ Successfully fetched X passages from D1`

## Troubleshooting

### Error: "D2_API_URL not set"

- Verify `D2_API_URL` is set in Vercel environment variables
- Make sure it's set for the **Production** environment
- Redeploy after adding the variable

### Error: "D2 API request failed"

- Check that the worker is deployed: `wrangler deployments list` (from `workers/d2-api/`)
- Test the worker directly:
  ```bash
  curl https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev/health
  ```
- Verify the URL in Vercel matches the deployed worker URL

### Error: "401 Unauthorized" or "403 Forbidden"

- If you set an API key, verify `D2_API_KEY` matches in both:
  - Vercel environment variables
  - Cloudflare Worker secrets (`wrangler secret list`)

### Worker not responding

- Check worker logs:
  ```bash
  cd workers/d2-api
  wrangler tail
  ```
- Verify the worker has D1 binding configured correctly
- Check `workers/d2-api/wrangler.toml` has the correct database ID

## Quick Verification Commands

```bash
# Check if worker is deployed
cd workers/d2-api
wrangler deployments list

# Check worker health
curl https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev/health

# Test listing passages (if no API key)
curl https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev/passages

# Test with API key
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://passage-map-d2-api.YOUR_SUBDOMAIN.workers.dev/passages

# Verify D1 database has data
wrangler d1 execute passage-map-db --remote --command="SELECT COUNT(*) FROM passages;"
```

## Architecture

```
┌─────────────┐         ┌──────────────────────┐         ┌──────────┐
│   Vercel    │────────▶│  D2 API Worker       │────────▶│   D1 DB  │
│  (Nuxt App) │         │  (Cloudflare)        │         │          │
└─────────────┘         └──────────────────────┘         └──────────┘
     │                           │
     │                           │
     └─── D2_API_URL ────────────┘
     └─── D2_API_KEY (optional) ─┘
```

## Related Documentation

- [VERCEL_D2_SETUP.md](./VERCEL_D2_SETUP.md) - Detailed Vercel setup guide
- [DOPPLER_SETUP.md](./DOPPLER_SETUP.md) - Doppler secrets management
- [CLOUDFLARE_PAGES_D1_SETUP.md](./CLOUDFLARE_PAGES_D1_SETUP.md) - If you switch to Cloudflare Pages


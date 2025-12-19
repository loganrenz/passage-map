# Architecture Explanation

## Overview

Your application uses a **two-tier architecture** to access Cloudflare D1 database from Vercel:

```
┌─────────────┐         ┌──────────────────────┐         ┌──────────┐
│   Vercel    │────────▶│  D2 API Worker       │────────▶│   D1 DB  │
│  (Nuxt App) │         │  (Cloudflare)        │         │          │
└─────────────┘         └──────────────────────┘         └──────────┘
     │                           │
     │                           │
     └─── D2_API_URL ──────────┘
     └─── (no D1 binding)        └─── D1 binding (passage_map_db)
```

## Component 1: Vercel App (Nuxt)

**Location**: Deployed on Vercel  
**Needs**: 
- ✅ `D2_API_URL` environment variable
- ❌ **NO D1 binding needed** (Vercel can't access D1 directly)

**Configuration**:
- Environment variable: `D2_API_URL = https://passage-map-d2-api.narduk.workers.dev`
- Set in: Vercel Dashboard → Settings → Environment Variables
- Or synced from: Doppler (prd config)

## Component 2: D2 API Worker (Cloudflare Worker)

**Location**: Deployed on Cloudflare Workers  
**Needs**:
- ✅ **D1 binding** (passage_map_db → passage-map-db)
- ✅ This is what you just added!

**Configuration**:
- Worker name: `passage-map-d2-api`
- D1 binding: `passage_map_db`
- Database: `passage-map-db` (ID: 6dae99e4-d07d-44f0-96a7-84a66a70ed6b)
- Configured in: `workers/d2-api/wrangler.toml`

## Why This Architecture?

**Problem**: Vercel cannot directly access Cloudflare D1 database bindings (they're Cloudflare-specific)

**Solution**: Use a Cloudflare Worker as a proxy
- The Worker CAN access D1 (it's a Cloudflare service)
- The Worker exposes a REST API
- Vercel calls the Worker API via HTTP
- The Worker queries D1 and returns results

## What You Just Did

You added the D1 binding to the **D2 API Worker** - this is correct and necessary!

The binding you added:
- **Type**: D1 database
- **Name**: `passage_map_db`
- **Value**: `passage-map-db`

This allows the worker to access the D1 database.

## What's Already Set Up

✅ D2 API Worker deployed  
✅ D1 binding added to worker (you just did this!)  
✅ `D2_API_URL` set in Vercel  
✅ Code updated to use D2 API client  

## Next Steps

1. **Verify the worker can access D1**:
   ```bash
   curl https://passage-map-d2-api.narduk.workers.dev/health
   ```

2. **Test listing passages**:
   ```bash
   curl https://passage-map-d2-api.narduk.workers.dev/passages?limit=5
   ```

3. **Redeploy Vercel** (if not already done):
   - The app will use `D2_API_URL` to connect to the worker
   - The worker will use the D1 binding to query the database

## Summary

- **Vercel App**: No D1 binding needed, uses `D2_API_URL` ✅
- **D2 API Worker**: Needs D1 binding (which you just added) ✅
- **Everything is configured correctly!** 🎉


# Production D1 Database Setup

This guide explains how to configure D1 database access for production deployments.

**Note:** This app is deployed to **Vercel**, not Cloudflare Pages. For Vercel deployments, see the [Vercel D2 Setup Guide](./VERCEL_D2_SETUP.md) instead.

## Cloudflare Pages D1 Database Setup

If you're deploying to Cloudflare Pages, this guide explains how to configure D1 database bindings.

## Overview

The D1 database is configured in `wrangler.toml`, but for Cloudflare Pages deployments, you also need to link the D1 database in the Cloudflare Pages dashboard.

## Current Configuration

- **Database ID**: `6dae99e4-d07d-44f0-96a7-84a66a70ed6b`
- **Database Name**: `passage-map-db`
- **Binding Name**: `passage_map_db`

## Verify Database Status

Run the verification script to check if your D1 database is accessible and has data:

```bash
npm run verify:d1
# or
npx tsx scripts/verify-d1-config.ts
```

This will check:
- ✅ Local database accessibility
- ✅ Remote (production) database accessibility
- ✅ Passage count in both databases

## Linking D1 Database in Cloudflare Pages

### Method 1: Cloudflare Dashboard (Recommended)

1. **Go to Cloudflare Dashboard**
   - Visit: https://dash.cloudflare.com/
   - Navigate to: **Workers & Pages** → Your Project

2. **Open Project Settings**
   - Click on your project name
   - Go to **Settings** tab

3. **Configure D1 Database Binding**
   - Scroll to **Functions** section
   - Find **D1 Database bindings**
   - Click **Add binding**

4. **Add the Binding**
   - **Variable name**: `passage_map_db` (must match exactly)
   - **D1 database**: Select `passage-map-db` from the dropdown
     - Or enter database ID: `6dae99e4-d07d-44f0-96a7-84a66a70ed6b`
   - Click **Save**

5. **Redeploy**
   - After saving, trigger a new deployment
   - The binding will be available in your next deployment

### Method 2: Wrangler CLI

You can also link the database using Wrangler (if you have the project set up):

```bash
# List your Pages projects
wrangler pages project list

# Note: D1 bindings for Pages are typically configured via the dashboard
# Wrangler CLI doesn't have a direct command to add D1 bindings to Pages
```

## Verification

After linking the database:

1. **Check the deployment logs**
   - Go to your Pages project → **Deployments**
   - Check the latest deployment logs
   - Look for D1 binding initialization messages

2. **Test the API**
   - Visit your Pages deployment URL
   - Try accessing `/api/passages/list`
   - Should return passage data instead of an error

3. **Check server logs**
   - In production, you should see: `✅ D1 database binding found and available (passage_map_db)`
   - If you see: `⚠️  D1 database binding not found`, the binding isn't configured

## Troubleshooting

### Error: "D1 database binding not configured"

**Symptoms:**
- API returns 503 error
- Logs show: `⚠️  D1 database binding not found`
- Error message mentions binding configuration

**Solutions:**

1. **Verify binding name matches exactly**
   - Binding name must be: `passage_map_db` (lowercase, underscore)
   - Check Cloudflare Pages settings → Functions → D1 Database bindings

2. **Check database ID**
   - Verify the database ID in Pages settings matches: `6dae99e4-d07d-44f0-96a7-84a66a70ed6b`
   - Run: `wrangler d1 list` to see all your databases

3. **Redeploy after configuration**
   - D1 bindings only take effect after a new deployment
   - Trigger a new deployment after adding the binding

4. **Check account permissions**
   - Ensure your Cloudflare account has access to D1
   - Verify you're logged in: `wrangler login`

### Database has no data

If the database is linked but has no passages:

1. **Check remote database**
   ```bash
   wrangler d1 execute passage-map-db --remote --command="SELECT COUNT(*) FROM passages;"
   ```

2. **Migrate data if needed**
   - See [D2_MIGRATION.md](./D2_MIGRATION.md) for migration instructions
   - Or use: `./scripts/setup-d2.sh`

### Binding works locally but not in production

- **Local development** uses `wrangler.toml` directly
- **Cloudflare Pages** requires dashboard configuration
- Make sure you've linked the database in the Pages dashboard, not just in `wrangler.toml`

## Related Documentation

- [D2_MIGRATION.md](./D2_MIGRATION.md) - Database migration guide
- [WRANGLER_SETUP.md](./WRANGLER_SETUP.md) - Wrangler and R2 setup
- [LOCAL_DEV_D1.md](./LOCAL_DEV_D1.md) - Local development with D1

## Quick Reference

```bash
# Verify D1 configuration
npm run verify:d1

# Check remote database
wrangler d1 execute passage-map-db --remote --command="SELECT COUNT(*) FROM passages;"

# List all D1 databases
wrangler d1 list

# Check Pages projects
wrangler pages project list
```


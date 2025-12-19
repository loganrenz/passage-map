# Verify Doppler Sync with Vercel

## Quick Verification

The presence of these environment variables in Vercel indicates Doppler integration is configured:
- ✅ `DOPPLER_PROJECT`
- ✅ `DOPPLER_ENVIRONMENT` 
- ✅ `DOPPLER_CONFIG`
- ✅ `D2_API_URL` (recently added)

## Verify Integration Status

### Option 1: Check Doppler Dashboard

1. Go to: https://dashboard.doppler.com/
2. Select project: **passage-map**
3. Go to: **Integrations** tab
4. Look for **Vercel** integration
5. Verify it's connected and active
6. Check that it's syncing:
   - Project: `passage-map`
   - Config: `prd` for Production
   - Config: `stg` for Preview (if configured)

### Option 2: Check Vercel Dashboard

1. Go to: https://vercel.com/dashboard
2. Select project: **passage-map**
3. Go to: **Settings** → **Integrations**
4. Look for **Doppler** integration
5. Verify it's connected and syncing

### Option 3: Check Environment Variables

In Vercel Dashboard → Settings → Environment Variables:

- Variables synced from Doppler will have a **Doppler logo** next to them
- If `D2_API_URL` has the Doppler logo, it's synced
- If it doesn't, it was manually added and may need to be removed to allow Doppler sync

## Current Status

- ✅ `D2_API_URL` is set in Doppler (`prd` config)
- ✅ `D2_API_URL` exists in Vercel (created ~1 minute ago)
- ✅ Doppler integration variables present (`DOPPLER_PROJECT`, `DOPPLER_ENVIRONMENT`, `DOPPLER_CONFIG`)

## If Sync is Not Working

### Remove Manual Variables

If `D2_API_URL` was manually added to Vercel (no Doppler logo):

1. Go to Vercel Dashboard → Settings → Environment Variables
2. Find `D2_API_URL` without Doppler logo
3. Delete it
4. Wait for Doppler to sync it automatically (or trigger a sync)

### Re-sync Integration

1. In Doppler Dashboard → Integrations → Vercel
2. Click on the integration
3. Click **Sync Now** or **Re-sync**

### Reinstall Integration

If the integration is not working:

```bash
# Remove existing integration (via dashboard)
# Then reinstall:
vercel integrations add doppler
```

Select:
- Project: `passage-map`
- Config: `prd` for Production
- Config: `stg` for Preview (optional)

## Verify Values Match

```bash
# Check Doppler value
doppler secrets get D2_API_URL --config prd --plain

# Should be:
# https://passage-map-d2-api.narduk.workers.dev
```

The value in Vercel should match this (you can't decrypt it, but if it was synced recently, it should be correct).

## Next Steps

After verifying sync:

1. **Redeploy Vercel** to ensure new environment variables are loaded
2. **Test production** to verify passages load correctly
3. **Check logs** if issues persist


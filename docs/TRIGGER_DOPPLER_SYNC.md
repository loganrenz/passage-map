# Trigger Doppler Sync to Vercel

## Quick Sync via Doppler Dashboard (Recommended)

1. **Go to Doppler Dashboard**:
   - Visit: https://dashboard.doppler.com/
   - Select project: **passage-map**

2. **Navigate to Integrations**:
   - Click on **Integrations** tab in the left sidebar
   - Find **Vercel** integration

3. **Trigger Sync**:
   - Click on the Vercel integration
   - Click **Sync Now** or **Re-sync** button
   - Wait for sync to complete (usually takes a few seconds)

4. **Verify Sync**:
   - Go to Vercel Dashboard → Your Project → Settings → Environment Variables
   - Check that `D2_API_URL` has the Doppler logo (indicating it's synced)
   - Verify the value matches: `https://passage-map-d2-api.narduk.workers.dev`

## Alternative: Via Vercel Dashboard

1. **Go to Vercel Dashboard**:
   - Visit: https://vercel.com/dashboard
   - Select project: **passage-map**

2. **Check Integration**:
   - Go to **Settings** → **Integrations**
   - Find **Doppler** integration
   - Click on it to view details

3. **Trigger Sync**:
   - If there's a "Sync Now" button, click it
   - Or disconnect and reconnect the integration

## Verify Sync Status

After syncing, verify the values match:

```bash
# Check Doppler value
doppler secrets get D2_API_URL --config prd --plain

# Should be: https://passage-map-d2-api.narduk.workers.dev
```

In Vercel Dashboard → Settings → Environment Variables:
- `D2_API_URL` should show the Doppler logo
- Value should match the Doppler value

## If Sync Doesn't Work

1. **Remove manual variables** (if any):
   - In Vercel, delete `D2_API_URL` if it doesn't have Doppler logo
   - Let Doppler sync it automatically

2. **Reinstall integration**:
   ```bash
   # Via Vercel CLI (if needed)
   vercel integrations add doppler
   ```
   Select:
   - Project: `passage-map`
   - Config: `prd` for Production
   - Config: `stg` for Preview (optional)

3. **Check for conflicts**:
   - Ensure no duplicate variables exist
   - Variables synced from Doppler will have the Doppler logo

## After Syncing

1. **Redeploy Vercel** to pick up new/updated variables:
   - Go to Deployments tab
   - Click "Redeploy" on latest deployment
   - Or push a new commit

2. **Test production**:
   - Visit your production URL
   - Verify passages load correctly
   - Check browser console for errors


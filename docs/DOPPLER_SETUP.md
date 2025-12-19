# Doppler Setup

This project uses [Doppler](https://www.doppler.com/) for managing secrets and environment variables in both local development and production (via Vercel integration).

## Quick Reference

### Setup Production Token
```bash
# Automated setup
./scripts/setup-doppler-prod.sh

# Or manually
doppler setup --project passage-map --config prd
doppler secrets set MAPKIT_PROD_TOKEN="eyJraWQiOiI0NTg4MzYyWlFQIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzI4MDQ4MDk3LCJvcmlnaW4iOiIqLnRpZGV5ZS5jb20ifQ.Jfhf-mI5ZnYIum_XA9lX8Z1HYte-T4kzt2ouDMgCubwlvrP1G4YZAFy2b66uWUhPr4Nqkcozofg9sxAEVR7Aiw"
```

### Link Doppler to Vercel
```bash
# Install integration via CLI
vercel integrations add doppler

# Or verify existing setup
vercel env ls
```

## Overview

We use pre-generated MapKit JS tokens stored in Doppler:
- **Development**: Token configured for `*.curl-banjo.ts.net` domain
- **Production**: Token configured for `*.tideye.com` domain

The application automatically selects the appropriate token based on the environment (NODE_ENV).

## Prerequisites

1. Install the Doppler CLI:
   ```bash
   # macOS
   brew install dopplerhq/cli/doppler
   
   # Or using the install script
   curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sh
   ```

2. Authenticate with Doppler:
   ```bash
   doppler login
   ```

3. The project is already configured in Doppler:
   - **Project**: `passage-map`
   - **Configs**: `dev` (for local development) and `prd` (for production)
   - The `.doppler.yaml` file in the project root contains the dev configuration

## Environment Variables

The following environment variables are required:

### MapKit Configuration

#### Development (`dev` config)
- `MAPKIT_DEV_TOKEN`: Pre-generated MapKit JS token for local dev
  - **Description**: Local Dev
  - **Domain**: `*.curl-banjo.ts.net`
  - **Token**: `eyJraWQiOiJMUTMzNzk2QkNLIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzU2NzY1NjI4LCJvcmlnaW4iOiIqLmN1cmwtYmFuam8udHMubmV0In0.mmnNH7Ncawf_uJrM5wX0AFS52l8HjlwPC2gDlfxBHuLxDHfFJ-n6tGgyMpcxHWAiAZta9j5AoFquJVWrZ-oA_w`

#### Production (`prd` config)
- `MAPKIT_PROD_TOKEN`: Pre-generated MapKit JS token for production
  - **Description**: Production
  - **Domain**: `*.tideye.com`
  - **Token**: `eyJraWQiOiI0NTg4MzYyWlFQIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzI4MDQ4MDk3LCJvcmlnaW4iOiIqLnRpZGV5ZS5jb20ifQ.Jfhf-mI5ZnYIum_XA9lX8Z1HYte-T4kzt2ouDMgCubwlvrP1G4YZAFy2b66uWUhPr4Nqkcozofg9sxAEVR7Aiw`

### InfluxDB Configuration

- `INFLUX_URL`: InfluxDB server URL
  - **Value**: `http://influx.tideye.com:8086`
  - **Note**: This domain is configured in Cloudflare to point to `tideye-server.curl-banjo.ts.net:8086`
- `INFLUX_API_KEY`: InfluxDB API token for authentication
- `INFLUX_ORG_ID`: InfluxDB organization ID
- `INFLUX_USER_ID`: InfluxDB user ID
- `INFLUX_BUCKET_DEFAULT`: Default InfluxDB bucket name (defaults to `Tideye`)

### AIS Hub Configuration

- `AIS_HUB_API_KEY`: API key for AIS Hub service
  - **Value**: `AH_3819_4C57E4B4`

## Running the Development Server

The development server is configured to run on `phantom.curl-banjo.ts.net` by default. To start the server with Doppler secrets:

```bash
doppler run -- npm run dev
```

This will:
1. Load environment variables from Doppler
2. Start the Nuxt dev server on `phantom.curl-banjo.ts.net`
3. Use the `MAPKIT_DEV_TOKEN` from Doppler instead of generating JWT tokens

## How It Works

The token endpoint (`/api/mapkit/token`) automatically selects the appropriate token based on the environment:
- **Development** (`NODE_ENV !== 'production'`): Returns `MAPKIT_DEV_TOKEN` for `*.curl-banjo.ts.net` domains
- **Production** (`NODE_ENV === 'production'`): Returns `MAPKIT_PROD_TOKEN` for `*.tideye.com` domains

The tokens are stored in Doppler and injected as environment variables at runtime.

## Production Setup (Vercel)

To use Doppler secrets in production on Vercel:

### 1. Create Production Config in Doppler

You can set up the production config manually or use the automated script:

#### Option A: Automated Setup Script (Recommended)

```bash
# Run the setup script
./scripts/setup-doppler-prod.sh
```

This script will:
- Set up the `prd` config in Doppler
- Configure the `MAPKIT_PROD_TOKEN` with the production token
- Verify the configuration

#### Option B: Manual Setup

```bash
# Switch to production config
doppler setup --project passage-map --config prd

# Set the production MapKit token
doppler secrets set MAPKIT_PROD_TOKEN="eyJraWQiOiI0NTg4MzYyWlFQIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzI4MDQ4MDk3LCJvcmlnaW4iOiIqLnRpZGV5ZS5jb20ifQ.Jfhf-mI5ZnYIum_XA9lX8Z1HYte-T4kzt2ouDMgCubwlvrP1G4YZAFy2b66uWUhPr4Nqkcozofg9sxAEVR7Aiw"

# Also set other required production secrets (InfluxDB, etc.)
doppler secrets set INFLUX_URL="http://influx.tideye.com:8086"
# ... set other production secrets as needed
```

### 2. Install Doppler Integration in Vercel

You can install the Doppler integration using either the Vercel CLI or the dashboard:

#### Option A: Using Vercel CLI (Recommended)

```bash
# Make sure you're logged into Vercel CLI
vercel login

# Link your project (if not already linked)
vercel link

# Install the Doppler integration
vercel integrations add doppler
```

After running the command, you'll be prompted to:
1. Authenticate with Doppler (opens browser)
2. Select the `passage-map` project
3. Select the `prd` config
4. Choose which Vercel environments to sync (Production, Preview, Development)

#### Option B: Using Vercel Dashboard

1. Go to your Vercel project settings
2. Navigate to **Integrations** → **Doppler**
3. Click **Add Integration**
4. Authenticate with Doppler
5. Select the `passage-map` project
6. Select the `prd` config
7. Enable **Sync Environment Variables**

### 3. Alternative: Manual Setup with Doppler Service Token

If you prefer to use a service token:

1. Create a service token in Doppler:
   ```bash
   doppler service-tokens create vercel-prd --project passage-map --config prd
   ```

2. In Vercel, go to **Settings** → **Environment Variables**
3. Add a new variable:
   - **Name**: `DOPPLER_TOKEN`
   - **Value**: The service token from step 1
   - **Environment**: Production (and Preview if desired)

4. Install `@dopplerhq/cli` in your project (if not already installed):
   ```bash
   npm install --save-dev @dopplerhq/cli
   ```

5. Update your Vercel build command to use Doppler:
   ```json
   {
     "scripts": {
       "build": "doppler run -- nuxt build"
     }
   }
   ```

### 4. Verify the Integration

You can verify the integration is set up correctly:

```bash
# Check Vercel environment variables (after integration is set up)
vercel env ls

# Verify the production token is set in Doppler
doppler secrets get MAPKIT_PROD_TOKEN --config prd
```

### 5. Verify Production Token After Deployment

After deployment, verify the production token is being used:
- The token endpoint should return the production token when `NODE_ENV=production`
- Check that MapKit works on your production domain (`*.tideye.com`)
- You can check the environment variables in Vercel: `vercel env ls`

## Troubleshooting

### Token not working (Development)
- Ensure you're accessing the app via `phantom.curl-banjo.ts.net` (or another `*.curl-banjo.ts.net` domain)
- Verify the token is correctly set in Doppler: `doppler secrets get MAPKIT_DEV_TOKEN`

### Token not working (Production)
- Verify the production token is set in Doppler: `doppler secrets get MAPKIT_PROD_TOKEN --config prd`
- Check that Vercel has synced the environment variables from Doppler
- Ensure `NODE_ENV=production` is set in Vercel (this is automatic)
- Verify you're accessing the app via a `*.tideye.com` domain

### Doppler not found
- Make sure Doppler CLI is installed and in your PATH
- Run `doppler --version` to verify installation

### Server not starting on correct host (Development)
- Check `nuxt.config.ts` has `devServer.host` set to `phantom.curl-banjo.ts.net`
- Ensure you're running with `doppler run -- npm run dev`

### Vercel Build Failing
- Verify the Doppler integration is properly configured
- Check that all required environment variables are set in the `prd` config
- Review Vercel build logs for specific error messages


# Doppler Setup for Local Development

This project uses [Doppler](https://www.doppler.com/) for managing secrets and environment variables in local development.

## Overview

For local development, we use a pre-generated MapKit JS token stored in Doppler. This token is configured for the domain `*.curl-banjo.ts.net` and is used instead of generating JWT tokens dynamically.

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
   - **Config**: `dev`
   - The `.doppler.yaml` file in the project root contains this configuration

## Environment Variables

The following environment variables are required for local development:

### MapKit Configuration

- `MAPKIT_DEV_TOKEN`: Pre-generated MapKit JS token for local dev
  - **Description**: Local Dev
  - **Domain**: `*.curl-banjo.ts.net`
  - **Token**: `eyJraWQiOiJMUTMzNzk2QkNLIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzU2NzY1NjI4LCJvcmlnaW4iOiIqLmN1cmwtYmFuam8udHMubmV0In0.mmnNH7Ncawf_uJrM5wX0AFS52l8HjlwPC2gDlfxBHuLxDHfFJ-n6tGgyMpcxHWAiAZta9j5AoFquJVWrZ-oA_w`

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

The token endpoint (`/api/mapkit/token`) returns the static token from Doppler. The token is configured for the domain `*.curl-banjo.ts.net` and is valid for local development use.

## Troubleshooting

### Token not working
- Ensure you're accessing the app via `phantom.curl-banjo.ts.net` (or another `*.curl-banjo.ts.net` domain)
- Verify the token is correctly set in Doppler: `doppler secrets get MAPKIT_DEV_TOKEN`

### Doppler not found
- Make sure Doppler CLI is installed and in your PATH
- Run `doppler --version` to verify installation

### Server not starting on correct host
- Check `nuxt.config.ts` has `devServer.host` set to `phantom.curl-banjo.ts.net`
- Ensure you're running with `doppler run -- npm run dev`


# Local Development Setup

This guide explains how to set up and run the application locally with D1 database access.

## Quick Start

Run everything together (D2 API worker + Nuxt dev server):

```bash
npm run dev
```

This single command will:
- Start the D2 API worker on `http://localhost:8787`
- Start the Nuxt dev server on `phantom.curl-banjo.ts.net:3102`
- Load all environment variables from Doppler
- Connect to D1 database via the D2 API worker

## Prerequisites

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up Doppler:**
   - Install Doppler CLI: `brew install dopplerhq/cli/doppler` (or see [Doppler Setup](./docs/DOPPLER_SETUP.md))
   - Authenticate: `doppler login`
   - The project is already configured with `dev` and `prd` configs

3. **Configure D2_API_URL in Doppler:**
   ```bash
   doppler secrets set D2_API_URL="http://localhost:8787" --config dev
   ```

4. **Authenticate with Cloudflare (for D1 access):**
   ```bash
   wrangler login
   ```

## Available Scripts

- `npm run dev` - Start both D2 API worker and Nuxt dev server (recommended)
- `npm run dev:all` - Same as `npm run dev` (alias)
- `npm run dev:nuxt-only` - Start only Nuxt dev server with Doppler (requires D2_API_URL to be set)
- `npm run dev:nuxt` - Start only Nuxt dev server (without Doppler)
- `npm run d2:api:dev` - Start only the D2 API worker

## How It Works

1. **D2 API Worker** (`workers/d2-api/`):
   - Runs on `http://localhost:8787` (default wrangler dev port)
   - Provides REST API access to D1 database
   - Uses D1 bindings from `wrangler.toml` with `remote = true` (connects to production D1)

2. **Nuxt Dev Server**:
   - Runs on `phantom.curl-banjo.ts.net:3102`
   - Loads `D2_API_URL` from Doppler
   - Connects to D1 via the D2 API worker
   - Uses other secrets from Doppler (MapKit tokens, InfluxDB config, etc.)

## Troubleshooting

### "D1 database is not available"

- Check that `D2_API_URL` is set in Doppler: `doppler secrets get D2_API_URL --config dev`
- Verify the D2 API worker is running: Check for "D2-API" process in terminal
- Check that wrangler is authenticated: `wrangler whoami`

### Port conflicts

- If port 8787 is taken, wrangler will use the next available port
- Update `D2_API_URL` in Doppler to match the actual port
- Check wrangler output for the actual port number

### Environment variables not loading

- Verify Doppler is configured: `doppler setup --project passage-map --config dev`
- Check secrets are set: `doppler secrets list --config dev`
- Ensure you're running with `doppler run --` or `npm run dev:all`

## Development Workflow

1. Start development: `npm run dev`
2. Make code changes - both servers support hot reloading
3. Access the app at `http://phantom.curl-banjo.ts.net:3102`
4. D1 database access works automatically via the D2 API worker

## Notes

- The D2 API worker connects to the **production D1 database** (remote = true)
- Be careful with write operations in local dev
- All data is shared between local dev and production
- For isolated local testing, you can use local D1 by removing `remote = true` from `wrangler.toml`


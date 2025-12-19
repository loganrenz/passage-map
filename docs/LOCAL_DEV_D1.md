# Local Development with D1 Database

This guide explains how to run the application locally with D1 database access.

## Option 1: Use D2 API Worker (Recommended for Local Dev)

This is the easiest way to develop locally with D1 access.

### 1. Start the D2 API Worker Locally

In one terminal:

```bash
cd workers/d2-api
npm run d2:api:dev
```

This will start the worker on `http://localhost:8787` (or another port if 8787 is taken).

### 2. Set D2_API_URL Environment Variable

In another terminal, set the environment variable:

```bash
export D2_API_URL="http://localhost:8787"
```

Or add it to your `.env` file or Doppler config.

### 3. Start the Nuxt Dev Server

```bash
npm run dev
```

The application will now use the D2 API worker to access D1.

## Option 2: Use Wrangler Pages Dev (Advanced)

This method uses wrangler directly to run the application with D1 bindings.

### 1. Build the Application

```bash
npm run build
```

### 2. Run with Wrangler

```bash
npm run dev:wrangler
```

This uses `wrangler pages dev` which provides D1 bindings directly.

**Note:** This method requires rebuilding after code changes, so it's less convenient for active development.

## Option 3: Use Remote D1 Bindings

The `wrangler.toml` is configured with `remote = true` for D1, which means when using wrangler, it will connect to the remote (production) D1 database.

**Warning:** Be careful with write operations when using remote bindings, as they will affect production data.

## Troubleshooting

### "D1 database is not available"

- Check that `D2_API_URL` is set correctly
- Verify the D2 API worker is running
- Check that `wrangler.toml` has the correct D1 database ID
- Ensure you're authenticated with Cloudflare: `wrangler login`

### D2 API Worker Not Starting

- Check that port 8787 (or the configured port) is available
- Verify the worker dependencies are installed: `cd workers/d2-api && npm install`
- Check worker logs for errors

### Bindings Not Available

- The Cloudflare preset in Nitro requires wrangler to provide bindings
- Use Option 1 (D2 API worker) for the best local dev experience
- Option 2 (wrangler pages dev) also provides bindings but requires rebuilding

## Recommended Setup

For the best local development experience:

1. **Start D2 API worker**: `cd workers/d2-api && npm run d2:api:dev`
2. **Set D2_API_URL**: `export D2_API_URL="http://localhost:8787"`
3. **Run Nuxt dev**: `npm run dev`

This gives you:
- Hot module reloading
- Direct D1 access via the API worker
- No need to rebuild after changes
- Same data as production (if using remote D1)


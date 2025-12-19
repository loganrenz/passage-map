# Wrangler R2 Storage Setup

This project uses Cloudflare R2 for storing passage data, vessel encounter data, and query metadata.

## Prerequisites

1. **Enable R2 in Cloudflare Dashboard**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Navigate to R2 in the sidebar
   - Enable R2 for your account (if not already enabled)

2. **Authenticate Wrangler**
   ```bash
   npx wrangler login
   ```
   This will open a browser window to authenticate with Cloudflare.

## Creating R2 Buckets

The project requires three R2 buckets:

1. **passage-map-passages** - Stores passage JSON files
2. **passage-map-vessel-data** - Stores vessel encounter data
3. **passage-map-queries** - Stores query metadata

### Create Buckets

```bash
# Create all three buckets
npm run r2:create passage-map-passages
npm run r2:create passage-map-vessel-data
npm run r2:create passage-map-queries
```

Or use Wrangler directly:

```bash
npx wrangler r2 bucket create passage-map-passages
npx wrangler r2 bucket create passage-map-vessel-data
npx wrangler r2 bucket create passage-map-queries
```

### List Buckets

```bash
npm run r2:list
# or
npx wrangler r2 bucket list
```

## Configuration

The buckets are configured in `wrangler.toml`:

```toml
[[r2_buckets]]
binding = "PASSAGES_BUCKET"
bucket_name = "passage-map-passages"

[[r2_buckets]]
binding = "VESSEL_DATA_BUCKET"
bucket_name = "passage-map-vessel-data"

[[r2_buckets]]
binding = "QUERIES_BUCKET"
bucket_name = "passage-map-queries"
```

## Storage Adapter

The project uses a storage abstraction layer (`server/utils/storage.ts`) that:

- **In production/Cloudflare Workers**: Uses R2 buckets directly
- **In local development**: Falls back to filesystem storage in `public/data/`

This allows you to develop locally without needing R2, while production uses Cloudflare R2.

## Migrating Existing Data

To migrate existing passage data from the filesystem to R2:

1. **Using Wrangler CLI** (recommended for bulk uploads):
   ```bash
   # Upload a single file
   npx wrangler r2 object put passage-map-passages/passage_2024-11-02_passage_1730556000000.json --file=public/data/passages/passage_2024-11-02_passage_1730556000000.json
   
   # Or use a script to upload all files
   ```

2. **Using the application**: The application will automatically write to R2 when running in a Cloudflare Workers environment.

## Local Development with R2

For local development, you can use Wrangler's local R2 emulator:

```bash
npx wrangler dev
```

This starts a local development server with R2 emulation. However, the current setup uses filesystem fallback for local development, which is simpler for most use cases.

## Production Deployment

When deploying to Cloudflare Pages or Workers:

1. Ensure R2 buckets are created
2. The `wrangler.toml` configuration will automatically bind the buckets
3. The storage adapter will detect R2 bindings and use them instead of filesystem

## Troubleshooting

### "Please enable R2 through the Cloudflare Dashboard"

- Go to Cloudflare Dashboard → R2
- Enable R2 for your account
- Wait a few minutes for the service to activate

### "Authentication required"

- Run `npx wrangler login` to authenticate

### Bucket not found errors

- Verify buckets exist: `npm run r2:list`
- Check `wrangler.toml` bucket names match actual bucket names
- Ensure you're authenticated: `npx wrangler whoami`

## Additional Resources

- [Wrangler R2 Documentation](https://developers.cloudflare.com/r2/data-access/wrangler/)
- [Cloudflare R2 Documentation](https://developers.cloudflare.com/r2/)


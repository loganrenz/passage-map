# Free Sources for Vessel Name Mapping

Here are **free alternatives** to get vessel names from MMSI numbers:

## ✅ AISHub API (Currently Configured!)

**Status**: ✅ Working - Key retrieved from Doppler

- **Cost**: Free (requires contributing AIS data or having access)
- **Rate Limit**: 1 request per minute (60 second delay required)
- **Coverage**: Only vessels currently/recently transmitting AIS
- **Usage**: Already configured! The script automatically:
  - Retrieves your AISHub key from Doppler (`AIS_HUB_API_KEY`)
  - Uses 60 second delay between requests
  - Handles rate limits gracefully

**To use**:
```bash
# The script automatically detects AISHub and uses appropriate delays
npx tsx scripts/fetch-vessel-names.ts --limit 10
# Note: With 60s delay, 10 requests = 10 minutes
```

**Note**: AISHub only has data for vessels that are actively transmitting AIS. Historical vessels or vessels not currently transmitting will return "0 records".

## Option 1: Download a Vessel Database (Recommended)

### Datalastic Maritime Database
- **URL**: https://datalastic.com/maritime-database/
- **Format**: CSV download
- **Cost**: Paid, but comprehensive (750,000+ vessels)
- **Usage**: Download the CSV, then run:
  ```bash
  npx tsx scripts/import-vessel-database.ts path/to/datalastic-database.csv --format csv
  ```

### Other Database Sources
- Look for public AIS datasets on GitHub
- Check NOAA's Marine Cadastre data
- Search for "AIS vessel database CSV" or "MMSI vessel name database"

## Option 2: Free APIs (May Require Registration)

### Marinesia API
- **URL**: https://docs.marinesia.com/
- **Cost**: Free
- **Status**: Check their documentation for actual endpoints
- **Note**: The script tries multiple endpoint variations automatically

### Global Fishing Watch API
- **URL**: https://globalfishingwatch.org/our-apis/documentation
- **Cost**: Free (requires API token - free to register)
- **How to use**:
  1. Register at https://globalfishingwatch.org/
  2. Get your API token
  3. Set environment variable: `export GFW_API_TOKEN="your-token"`
  4. Run the script: `npx tsx scripts/fetch-vessel-names.ts --limit 100`

### AISHub
- **URL**: https://www.aishub.net/
- **Cost**: Free if you contribute AIS data
- **Note**: Requires sharing your own AIS feed to get access

## Option 3: Manual Entry

For a small number of vessels, you can manually edit the mapping file:

```bash
# Edit the file directly
code public/data/mmsi-to-vessel-name.json
```

Add entries like:
```json
{
  "mappings": {
    "215503000": "MSC OSCAR",
    "538007209": "EVER GIVEN"
  }
}
```

## Option 4: Web Scraping (Use with Caution)

Some websites like VesselFinder and MarineTraffic show vessel names on their public pages, but:
- ⚠️ May violate Terms of Service
- ⚠️ Requires JavaScript rendering (complex)
- ⚠️ May have rate limits or blocking

## Recommended Approach

1. **Start with manual entry** for vessels you encounter frequently
2. **Try Global Fishing Watch API** (free token, good coverage)
3. **Consider purchasing a database** if you need comprehensive coverage
4. **Use the import script** to bulk import from any CSV/JSON database you find

## Scripts Available

1. **`scripts/fetch-vessel-names.ts`** - Fetches names from APIs
   ```bash
   npx tsx scripts/fetch-vessel-names.ts --limit 10 --delay 2000
   ```

2. **`scripts/import-vessel-database.ts`** - Imports from CSV/JSON files
   ```bash
   npx tsx scripts/import-vessel-database.ts database.csv --format csv
   ```

## Current Status

- **Total MMSIs in your data**: 3,132
- **Mapped**: 0 (ready to populate)
- **Best free option**: Global Fishing Watch API (register for free token)


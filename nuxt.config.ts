// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: ['@nuxt/ui', '@nuxt/eslint'],
  // Nuxt 4 uses app/ directory structure, but css can still be in assets/
  css: ['~/assets/css/main.css'],
  runtimeConfig: {
    // Server-side only (private)
    mapkitDevToken: process.env.MAPKIT_DEV_TOKEN || 'eyJraWQiOiJMUTMzNzk2QkNLIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzU2NzY1NjI4LCJvcmlnaW4iOiIqLmN1cmwtYmFuam8udHMubmV0In0.mmnNH7Ncawf_uJrM5wX0AFS52l8HjlwPC2gDlfxBHuLxDHfFJ-n6tGgyMpcxHWAiAZta9j5AoFquJVWrZ-oA_w', // Dev token from Doppler or fallback
    mapkitProdToken: process.env.MAPKIT_PROD_TOKEN, // Production token from Doppler (for *.tideye.com)
    // InfluxDB URL - configured in Cloudflare to point to tideye-server.curl-banjo.ts.net:8086
    influxUrl: process.env.INFLUX_URL || 'http://influx.tideye.com:8086',
    influxToken: process.env.INFLUX_API_KEY,
    influxOrgId: process.env.INFLUX_ORG_ID,
    influxBucket: process.env.INFLUX_BUCKET_DEFAULT || 'Tideye',
    // R2 S3 API credentials (fallback when bindings aren't available)
    r2AccessKeyId: process.env.R2_ACCESS_KEY_ID,
    r2SecretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
    // D2 API configuration (for Vercel/external access)
    d2ApiUrl: process.env.D2_API_URL, // Cloudflare Worker URL for D2 API
    d2ApiKey: process.env.D2_API_KEY, // Optional API key for authentication
  },
  nitro: {
    preset: 'cloudflare-pages',
    // Use wrangler.toml for local development bindings
    cloudflare: {
      configPath: 'wrangler.toml',
    },
  },
  devServer: {
    host: 'phantom.curl-banjo.ts.net',
    port: 3102,
  },
  app: {
    head: {
      title: 'Passage Map',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      ],
      script: [
        {
          src: 'https://cdn.apple-mapkit.com/mk/5.x.x/mapkit.js',
          defer: true,
          crossorigin: 'anonymous',
        },
      ],
    },
  },
})


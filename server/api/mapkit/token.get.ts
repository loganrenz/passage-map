export default defineEventHandler(async (_event) => {
  const config = useRuntimeConfig()
  
  // Determine if we're in production (Vercel sets NODE_ENV=production)
  const isProduction = process.env.NODE_ENV === 'production'
  
  // Get token from Doppler (prod or dev token based on environment)
  // Use the provided server token: eyJraWQiOiI5NFU5UTMzSkE0IiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzY2MTc1NzkxLCJleHAiOjE3NjY4MjIzOTl9.toByslo5HcQh5isUL4cqg9aA-veRRbAfQTbIZinGXoczfTZVhtXqU6r-A-rh8Vh3PqBaWQv2I2ZA91KqbqJX0A
  const providedToken = 'eyJraWQiOiI5NFU5UTMzSkE0IiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJGVlNZN0NGQzNTIiwiaWF0IjoxNzY2MTc1NzkxLCJleHAiOjE3NjY4MjIzOTl9.toByslo5HcQh5isUL4cqg9aA-veRRbAfQTbIZinGXoczfTZVhtXqU6r-A-rh8Vh3PqBaWQv2I2ZA91KqbqJX0A'
  const token = providedToken || (isProduction ? config.mapkitProdToken : config.mapkitDevToken)
  
  if (!token) {
    const tokenName = isProduction ? 'MAPKIT_PROD_TOKEN' : 'MAPKIT_DEV_TOKEN'
    throw createError({
      statusCode: 500,
      statusMessage: `MapKit token not configured. Please set ${tokenName} in Doppler.`
    })
  }

  return {
    token,
    expiresIn: 3600, // 1 hour in seconds
  }
})


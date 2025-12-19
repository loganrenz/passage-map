export default defineEventHandler(async (_event) => {
  const config = useRuntimeConfig()
  
  // Get token from Doppler (dev token)
  const token = config.mapkitDevToken
  
  if (!token) {
    throw createError({
      statusCode: 500,
      statusMessage: 'MapKit token not configured. Please set MAPKIT_DEV_TOKEN in Doppler.'
    })
  }

  return {
    token,
    expiresIn: 3600, // 1 hour in seconds
  }
})


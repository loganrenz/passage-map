export const useMapKit = () => {
  // Use shallowRef to prevent deep reactivity on MapKit objects
  const mapInstance = shallowRef<mapkit.Map | null>(null)
  const isInitialized = ref(false)
  let cachedToken: string | null = null
  let tokenExpiry: number = 0

  const fetchToken = async (): Promise<string> => {
    // Check if we have a valid cached token
    const now = Date.now() / 1000
    if (cachedToken && tokenExpiry > now + 300) {
      // Return cached token if it's still valid (with 5 minute buffer)
      return cachedToken
    }

    try {
      // Fetch fresh token from API
      const response = await $fetch<{ token: string; expiresIn: number }>('/api/mapkit/token')
      cachedToken = response.token
      tokenExpiry = now + response.expiresIn
      return response.token
    } catch (error) {
      console.error('Failed to fetch MapKit token:', error)
      throw error
    }
  }

  const initializeMap = async (element: HTMLElement, options?: mapkit.MapConstructorOptions) => {
    if (typeof window === 'undefined' || !window.mapkit) {
      console.error('MapKitJS is not loaded')
      return null
    }

    try {
      // Only initialize MapKit if it hasn't been initialized yet
      // Use a window-level flag that persists across hot module reloads
      interface WindowWithMapKit extends Window {
        __mapkitInitialized?: boolean
      }
      if (typeof window !== 'undefined' && !(window as WindowWithMapKit).__mapkitInitialized) {
        try {
          window.mapkit.init({
            authorizationCallback: async (done) => {
              try {
                const token = await fetchToken()
                done(token)
              } catch (error) {
                console.error('Error fetching MapKit token:', error)
                done('') // Pass empty string on error
              }
            },
          })
          ;(window as WindowWithMapKit).__mapkitInitialized = true
        } catch (error: unknown) {
          // If MapKit is already initialized, it will throw/error but we can continue
          // The error message indicates it's already initialized, so mark it as such
          const errorMessage = error instanceof Error ? error.message : String(error)
          if (errorMessage.includes('already initialized')) {
            ;(window as WindowWithMapKit).__mapkitInitialized = true
          }
        }
      }

      const map = new window.mapkit.Map(element, {
        showsUserLocationControl: false,
        showsZoomControl: true,
        showsCompass: window.mapkit.FeatureVisibility.Hidden, // Hide compass since rotation is disabled by default
        isRotationEnabled: false, // Explicitly disable rotation
        ...options,
      })

      // Mark MapKit objects as non-reactive to prevent Vue from tracking their internal state
      mapInstance.value = markRaw(map)
      isInitialized.value = true

      return map
    } catch (error) {
      console.error('Error initializing MapKit:', error)
      return null
    }
  }

  const cleanup = () => {
    if (mapInstance.value) {
      // MapKit doesn't have explicit cleanup, but we can remove the reference
      mapInstance.value = null
      isInitialized.value = false
    }
  }

  onUnmounted(() => {
    cleanup()
  })

  return {
    mapInstance: readonly(mapInstance),
    isInitialized: readonly(isInitialized),
    initializeMap,
    cleanup,
  }
}

declare global {
  interface Window {
    mapkit: typeof mapkit
  }
}


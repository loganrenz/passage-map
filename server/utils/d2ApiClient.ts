/**
 * D2 API Client for accessing D2 database via Cloudflare Worker API
 * Use this when running on Vercel or other platforms that can't directly access D2
 */

export interface D2ApiConfig {
  apiUrl: string
  apiKey?: string
}

export class D2ApiClient {
  constructor(private config: D2ApiConfig) {}

  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${this.config.apiUrl}${endpoint}`
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options?.headers,
    }

    if (this.config.apiKey) {
      headers['Authorization'] = `Bearer ${this.config.apiKey}`
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      })

      if (!response.ok) {
        let errorMessage = `HTTP ${response.status}`
        try {
          const error = await response.json()
          errorMessage = error.error || error.message || errorMessage
          if (error.message && error.message !== error.error) {
            errorMessage += `: ${error.message}`
          }
        } catch {
          // If response isn't JSON, try to get text
          const text = await response.text().catch(() => '')
          if (text) {
            errorMessage = text
          }
        }
        throw new Error(errorMessage)
      }

      return response.json()
    } catch (error) {
      if (error instanceof Error) {
        // Re-throw with more context
        throw new Error(`D2 API request failed: ${error.message}`)
      }
      throw error
    }
  }

  async healthCheck(): Promise<{ status: string; database: string }> {
    return this.request('/health')
  }

  async query<T = unknown>(query: string, params?: unknown[]): Promise<{ results?: T[] }> {
    return this.request('/query', {
      method: 'POST',
      body: JSON.stringify({ query, params }),
    })
  }

  async batch(queries: Array<{ query: string; params?: unknown[] }>): Promise<unknown[]> {
    return this.request('/batch', {
      method: 'POST',
      body: JSON.stringify({ queries }),
    })
  }

  async getPassage(passageId: string): Promise<{
    passage: any
    positions: any[]
    locations: any[]
  }> {
    return this.request(`/passages/${passageId}`)
  }

  async listPassages(limit = 100, offset = 0): Promise<any[]> {
    return this.request(`/passages?limit=${limit}&offset=${offset}`)
  }
}

/**
 * Get D2 API client from environment
 * Checks both process.env and runtime config (for Nuxt)
 */
export function getD2ApiClient(): D2ApiClient | null {
  // Try to get from runtime config first (Nuxt way)
  let apiUrl: string | undefined
  let apiKey: string | undefined
  
  try {
    const config = useRuntimeConfig()
    apiUrl = config.d2ApiUrl || process.env.D2_API_URL
    apiKey = config.d2ApiKey || process.env.D2_API_KEY
  } catch {
    // If useRuntimeConfig fails (not in Nuxt context), fall back to process.env
    apiUrl = process.env.D2_API_URL
    apiKey = process.env.D2_API_KEY
  }

  if (!apiUrl) {
    if (process.env.NODE_ENV !== 'production') {
      console.log('⚠️  D2_API_URL not set. D2 API client will not be available.')
      console.log('   Set D2_API_URL in Doppler or environment variables to use D2 API worker.')
    }
    return null
  }

  if (process.env.NODE_ENV !== 'production') {
    console.log(`✅ D2 API client configured with URL: ${apiUrl}`)
  }

  return new D2ApiClient({
    apiUrl,
    apiKey,
  })
}


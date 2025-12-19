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

    const response = await fetch(url, {
      ...options,
      headers,
    })

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Unknown error' }))
      throw new Error(error.error || `HTTP ${response.status}`)
    }

    return response.json()
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
 */
export function getD2ApiClient(): D2ApiClient | null {
  const apiUrl = process.env.D2_API_URL
  if (!apiUrl) {
    return null
  }

  return new D2ApiClient({
    apiUrl,
    apiKey: process.env.D2_API_KEY,
  })
}


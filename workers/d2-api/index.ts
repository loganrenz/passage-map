/**
 * Cloudflare Worker API for D2 Database Access
 * This worker exposes a REST API to access D2 from external services like Vercel
 */

export interface Env {
  passage_map_db: D1Database
  D2_API_KEY?: string // Optional API key for authentication
}

interface D2QueryRequest {
  query: string
  params?: unknown[]
}

interface D2BatchRequest {
  queries: Array<{
    query: string
    params?: unknown[]
  }>
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    }

    // Handle preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders })
    }

    // Optional: Check API key if configured
    if (env.D2_API_KEY) {
      const authHeader = request.headers.get('Authorization')
      if (authHeader !== `Bearer ${env.D2_API_KEY}`) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    const url = new URL(request.url)
    const path = url.pathname

    try {
      // Health check
      if (path === '/health' && request.method === 'GET') {
        return new Response(JSON.stringify({ status: 'ok', database: 'connected' }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      // Execute query
      if (path === '/query' && request.method === 'POST') {
        const body: D2QueryRequest = await request.json()
        const { query, params = [] } = body

        if (!query) {
          return new Response(JSON.stringify({ error: 'Query is required' }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        }

        const stmt = env.passage_map_db.prepare(query)
        const boundStmt = params.length > 0 ? stmt.bind(...params) : stmt
        const result = await boundStmt.all()

        return new Response(JSON.stringify(result), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      // Execute batch queries
      if (path === '/batch' && request.method === 'POST') {
        const body: D2BatchRequest = await request.json()
        const { queries } = body

        if (!queries || !Array.isArray(queries)) {
          return new Response(JSON.stringify({ error: 'Queries array is required' }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        }

        const statements = queries.map((q) => {
          const stmt = env.passage_map_db.prepare(q.query)
          return q.params && q.params.length > 0 ? stmt.bind(...q.params) : stmt
        })

        const results = await env.passage_map_db.batch(statements)

        return new Response(JSON.stringify(results), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      // Get passage by ID
      if (path.startsWith('/passages/') && request.method === 'GET') {
        const passageId = path.split('/passages/')[1]
        if (!passageId) {
          return new Response(JSON.stringify({ error: 'Passage ID required' }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        }

        // Get passage
        const passage = await env.passage_map_db
          .prepare('SELECT * FROM passages WHERE id = ?')
          .bind(passageId)
          .first()

        if (!passage) {
          return new Response(JSON.stringify({ error: 'Passage not found' }), {
            status: 404,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        }

        // Get positions
        const positions = await env.passage_map_db
          .prepare('SELECT * FROM passage_positions WHERE passage_id = ? ORDER BY time')
          .bind(passageId)
          .all()

        // Get locations
        const locations = await env.passage_map_db
          .prepare('SELECT * FROM passage_locations WHERE passage_id = ? ORDER BY time')
          .bind(passageId)
          .all()

        return new Response(
          JSON.stringify({
            passage,
            positions: positions.results || [],
            locations: locations.results || [],
          }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      // List passages
      if (path === '/passages' && request.method === 'GET') {
        const limit = parseInt(url.searchParams.get('limit') || '100')
        const offset = parseInt(url.searchParams.get('offset') || '0')

        const result = await env.passage_map_db
          .prepare('SELECT * FROM passages ORDER BY start_time DESC LIMIT ? OFFSET ?')
          .bind(limit, offset)
          .all()

        return new Response(JSON.stringify(result.results || []), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      return new Response(JSON.stringify({ error: 'Not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    } catch (error) {
      console.error('D2 API error:', error)
      return new Response(
        JSON.stringify({
          error: 'Internal server error',
          message: error instanceof Error ? error.message : String(error),
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }
  },
}


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

    // Verify database binding is available
    if (!env.passage_map_db) {
      return new Response(
        JSON.stringify({
          error: 'Database binding not available',
          message: 'The passage_map_db binding is not configured. Check your wrangler.toml file.',
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
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
        try {
          // Test database connection with a simple query
          const testResult = await env.passage_map_db.prepare('SELECT 1 as test').first()
          return new Response(
            JSON.stringify({
              status: 'ok',
              database: 'connected',
              test: testResult,
            }),
            {
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : String(error)
          console.error('Health check failed:', errorMessage)
          
          // Provide helpful error message for common D1 errors
          let helpfulMessage = errorMessage
          if (errorMessage.includes('1031') || errorMessage.includes('D1_ERROR')) {
            helpfulMessage = 'D1 database connection failed. This usually means:\n' +
              '1. You need to authenticate: run "wrangler login"\n' +
              '2. The database might not exist or be accessible\n' +
              '3. Check your wrangler.toml configuration\n' +
              `Original error: ${errorMessage}`
          }
          
          return new Response(
            JSON.stringify({
              status: 'error',
              database: 'connection failed',
              message: helpfulMessage,
            }),
            {
              status: 503,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }
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

        if (!env.passage_map_db) {
          return new Response(
            JSON.stringify({ error: 'Database binding not available' }),
            {
              status: 500,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
          )
        }

        try {
          const result = await env.passage_map_db
            .prepare('SELECT * FROM passages ORDER BY start_time DESC LIMIT ? OFFSET ?')
            .bind(limit, offset)
            .all()

          return new Response(JSON.stringify(result.results || []), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          })
        } catch (dbError) {
          console.error('Database query error:', dbError)
          const errorMessage = dbError instanceof Error ? dbError.message : String(dbError)
          
          // Check for specific D1 error codes
          if (errorMessage.includes('1031') || errorMessage.includes('D1_ERROR')) {
            console.error('D1 connection error detected. This may indicate:')
            console.error('1. Database is not accessible (check wrangler login)')
            console.error('2. Database binding is misconfigured')
            console.error('3. Remote database connection failed')
            throw new Error(`D1 database connection error: ${errorMessage}. Please check your wrangler configuration and ensure you're logged in with 'wrangler login'`)
          }
          
          throw new Error(`Database query failed: ${errorMessage}`)
        }
      }

      return new Response(JSON.stringify({ error: 'Not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    } catch (error) {
      console.error('D2 API error:', error)
      const errorMessage = error instanceof Error ? error.message : String(error)
      const errorStack = error instanceof Error ? error.stack : undefined
      
      // Log full error details for debugging
      if (errorStack) {
        console.error('Error stack:', errorStack)
      }
      
      return new Response(
        JSON.stringify({
          error: 'Internal server error',
          message: errorMessage,
          ...(process.env.NODE_ENV === 'development' && errorStack ? { stack: errorStack } : {}),
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }
  },
}


import { getQueriesStorage } from './storage'

export interface QueryMetadata {
  id: string
  query: string
  parameters?: Record<string, unknown>
  passageId?: string
  timestamp: string
  description?: string
  passageFilename?: string
}

const QUERIES_FILE = 'queries.json'

/**
 * Get storage adapter for queries
 */
function getStorage(
  env?: { [key: string]: unknown},
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
) {
  return getQueriesStorage(env, config)
}

/**
 * Load all queries from registry
 */
export async function loadQueries(
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata[]> {
  const storage = getStorage(env, config)

  try {
    const data = await storage.readJSON<{ queries: QueryMetadata[] }>(QUERIES_FILE)
    return Array.isArray(data?.queries) ? data.queries : []
  } catch (error) {
    console.error('Error loading queries:', error)
    return []
  }
}

/**
 * Save queries to registry
 */
export async function saveQueries(
  queries: QueryMetadata[],
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<void> {
  const storage = getStorage(env, config)

  const data = {
    queries,
    updatedAt: new Date().toISOString(),
  }

  await storage.writeJSON(QUERIES_FILE, data)
}

/**
 * Add a query to the registry
 */
export async function addQuery(
  query: Omit<QueryMetadata, 'id' | 'timestamp'>,
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata> {
  const queries = await loadQueries(env, config)
  
  const newQuery: QueryMetadata = {
    ...query,
    id: `query_${Date.now()}_${Math.random().toString(36).substring(7)}`,
    timestamp: new Date().toISOString(),
  }

  queries.push(newQuery)
  await saveQueries(queries, env, config)

  return newQuery
}

/**
 * Get query by ID
 */
export async function getQueryById(
  id: string,
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata | null> {
  const queries = await loadQueries(env, config)
  return queries.find((q) => q.id === id) || null
}

/**
 * Get queries by passage ID
 */
export async function getQueriesByPassageId(
  passageId: string,
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata[]> {
  const queries = await loadQueries(env, config)
  return queries.filter((q) => q.passageId === passageId)
}

/**
 * Get queries by passage filename
 */
export async function getQueriesByFilename(
  filename: string,
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata[]> {
  const queries = await loadQueries(env, config)
  return queries.filter((q) => q.passageFilename === filename)
}

/**
 * Update a query in the registry
 */
export async function updateQuery(
  id: string,
  updates: Partial<Omit<QueryMetadata, 'id' | 'timestamp'>>,
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata | null> {
  const queries = await loadQueries(env, config)
  const index = queries.findIndex((q) => q.id === id)

  if (index === -1) {
    return null
  }

  queries[index] = {
    ...queries[index],
    ...updates,
  }

  await saveQueries(queries, env, config)
  return queries[index]
}

/**
 * Delete a query from the registry
 */
export async function deleteQuery(
  id: string,
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<boolean> {
  const queries = await loadQueries(env, config)
  const filtered = queries.filter((q) => q.id !== id)

  if (filtered.length === queries.length) {
    return false // Query not found
  }

  await saveQueries(filtered, env, config)
  return true
}

/**
 * Get all queries sorted by timestamp (newest first)
 */
export async function getAllQueries(
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): Promise<QueryMetadata[]> {
  const queries = await loadQueries(env, config)
  return queries.sort((a, b) => {
    const timeA = new Date(a.timestamp).getTime()
    const timeB = new Date(b.timestamp).getTime()
    return timeB - timeA
  })
}


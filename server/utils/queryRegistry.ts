import { readFile, writeFile, mkdir } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'

export interface QueryMetadata {
  id: string
  query: string
  parameters?: Record<string, unknown>
  passageId?: string
  timestamp: string
  description?: string
  passageFilename?: string
}

const QUERIES_DIR = join(process.cwd(), 'public', 'data', 'passages')
const QUERIES_FILE = join(QUERIES_DIR, 'queries.json')

/**
 * Ensure queries directory exists
 */
async function ensureQueriesDir(): Promise<void> {
  if (!existsSync(QUERIES_DIR)) {
    await mkdir(QUERIES_DIR, { recursive: true })
  }
}

/**
 * Load all queries from registry
 */
export async function loadQueries(): Promise<QueryMetadata[]> {
  await ensureQueriesDir()

  if (!existsSync(QUERIES_FILE)) {
    return []
  }

  try {
    const content = await readFile(QUERIES_FILE, 'utf-8')
    const data = JSON.parse(content)
    return Array.isArray(data.queries) ? data.queries : []
  } catch (error) {
    console.error('Error loading queries:', error)
    return []
  }
}

/**
 * Save queries to registry
 */
export async function saveQueries(queries: QueryMetadata[]): Promise<void> {
  await ensureQueriesDir()

  const data = {
    queries,
    updatedAt: new Date().toISOString(),
  }

  await writeFile(QUERIES_FILE, JSON.stringify(data, null, 2), 'utf-8')
}

/**
 * Add a query to the registry
 */
export async function addQuery(query: Omit<QueryMetadata, 'id' | 'timestamp'>): Promise<QueryMetadata> {
  const queries = await loadQueries()
  
  const newQuery: QueryMetadata = {
    ...query,
    id: `query_${Date.now()}_${Math.random().toString(36).substring(7)}`,
    timestamp: new Date().toISOString(),
  }

  queries.push(newQuery)
  await saveQueries(queries)

  return newQuery
}

/**
 * Get query by ID
 */
export async function getQueryById(id: string): Promise<QueryMetadata | null> {
  const queries = await loadQueries()
  return queries.find((q) => q.id === id) || null
}

/**
 * Get queries by passage ID
 */
export async function getQueriesByPassageId(passageId: string): Promise<QueryMetadata[]> {
  const queries = await loadQueries()
  return queries.filter((q) => q.passageId === passageId)
}

/**
 * Get queries by passage filename
 */
export async function getQueriesByFilename(filename: string): Promise<QueryMetadata[]> {
  const queries = await loadQueries()
  return queries.filter((q) => q.passageFilename === filename)
}

/**
 * Update a query in the registry
 */
export async function updateQuery(
  id: string,
  updates: Partial<Omit<QueryMetadata, 'id' | 'timestamp'>>
): Promise<QueryMetadata | null> {
  const queries = await loadQueries()
  const index = queries.findIndex((q) => q.id === id)

  if (index === -1) {
    return null
  }

  queries[index] = {
    ...queries[index],
    ...updates,
  }

  await saveQueries(queries)
  return queries[index]
}

/**
 * Delete a query from the registry
 */
export async function deleteQuery(id: string): Promise<boolean> {
  const queries = await loadQueries()
  const filtered = queries.filter((q) => q.id !== id)

  if (filtered.length === queries.length) {
    return false // Query not found
  }

  await saveQueries(filtered)
  return true
}

/**
 * Get all queries sorted by timestamp (newest first)
 */
export async function getAllQueries(): Promise<QueryMetadata[]> {
  const queries = await loadQueries()
  return queries.sort((a, b) => {
    const timeA = new Date(a.timestamp).getTime()
    const timeB = new Date(b.timestamp).getTime()
    return timeB - timeA
  })
}


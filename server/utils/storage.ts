/**
 * Storage abstraction layer
 * Supports both local filesystem (dev) and Cloudflare R2 (production)
 */

import { readFile, writeFile, readdir, mkdir } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'
import type { R2Bucket } from './r2Storage'
import { readR2JSON, writeR2JSON, listR2Objects, readR2Text } from './r2Storage'
import { R2S3Storage } from './r2S3Storage'
import { getD2Database } from './d2Storage'

export interface StorageAdapter {
  readJSON<T = unknown>(key: string): Promise<T | null>
  readText(key: string): Promise<string | null>
  writeJSON(key: string, data: unknown): Promise<void>
  list(prefix?: string): Promise<string[]>
  exists(key: string): Promise<boolean>
}

/**
 * Filesystem storage adapter (for local development)
 */
class FilesystemStorage implements StorageAdapter {
  constructor(private baseDir: string) {}

  private getPath(key: string): string {
    return join(this.baseDir, key)
  }

  async readJSON<T = unknown>(key: string): Promise<T | null> {
    try {
      const path = this.getPath(key)
      if (!existsSync(path)) {
        return null
      }
      const content = await readFile(path, 'utf-8')
      return JSON.parse(content) as T
    } catch (error) {
      console.error(`Error reading file ${key}:`, error)
      return null
    }
  }

  async readText(key: string): Promise<string | null> {
    try {
      const path = this.getPath(key)
      if (!existsSync(path)) {
        return null
      }
      return await readFile(path, 'utf-8')
    } catch (error) {
      console.error(`Error reading file ${key}:`, error)
      return null
    }
  }

  async writeJSON(key: string, data: unknown): Promise<void> {
    const path = this.getPath(key)
    const dir = join(path, '..')
    if (!existsSync(dir)) {
      await mkdir(dir, { recursive: true })
    }
    await writeFile(path, JSON.stringify(data, null, 2), 'utf-8')
  }

  async list(prefix?: string): Promise<string[]> {
    try {
      const dir = this.baseDir
      if (!existsSync(dir)) {
        return []
      }
      const files = await readdir(dir, { withFileTypes: true })
      let result = files
        .filter((f) => f.isFile())
        .map((f) => f.name)
      
      // Filter by prefix if provided
      if (prefix) {
        result = result.filter((f) => f.startsWith(prefix))
      }
      
      return result
    } catch (error) {
      console.error(`Error listing directory ${prefix}:`, error)
      return []
    }
  }

  async exists(key: string): Promise<boolean> {
    return existsSync(this.getPath(key))
  }
}

/**
 * R2 storage adapter (for production/Cloudflare)
 */
class R2Storage implements StorageAdapter {
  constructor(private bucket: R2Bucket) {}

  async readJSON<T = unknown>(key: string): Promise<T | null> {
    return readR2JSON<T>(this.bucket, key)
  }

  async readText(key: string): Promise<string | null> {
    return readR2Text(this.bucket, key)
  }

  async writeJSON(key: string, data: unknown): Promise<void> {
    await writeR2JSON(this.bucket, key, data)
  }

  async list(prefix?: string): Promise<string[]> {
    const objects = await listR2Objects(this.bucket, prefix)
    return objects.map((obj) => obj.key)
  }

  async exists(key: string): Promise<boolean> {
    const obj = await this.bucket.head(key)
    return obj !== null
  }
}

/**
 * Get storage adapter based on environment
 * Priority: 1. R2 bindings, 2. R2 S3 API, 3. Filesystem
 */
export function getStorageAdapter(
  bucketName: 'passages' | 'vessel-data' | 'queries',
  env?: { [key: string]: unknown },
  config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }
): StorageAdapter {
  // Try to get R2 bucket from environment (Cloudflare Workers)
  // Match wrangler.toml bindings: PASSAGES_BUCKET, VESSEL_DATA_BUCKET, QUERIES_BUCKET
  const bucketBindings = {
    passages: 'PASSAGES_BUCKET',
    'vessel-data': 'VESSEL_DATA_BUCKET',
    queries: 'QUERIES_BUCKET',
  }

  const binding = bucketBindings[bucketName]
  
  // Try multiple ways to access the R2 binding (for different Nitro/Cloudflare setups)
  let r2Bucket: R2Bucket | undefined
  
  if (env) {
    // Standard way: env[binding]
    r2Bucket = env[binding] as R2Bucket | undefined
    
    // Alternative: try accessing via cloudflare.env if env itself is not the bindings
    if (!r2Bucket && (env as any).cloudflare?.env) {
      r2Bucket = (env as any).cloudflare.env[binding] as R2Bucket | undefined
    }
  }
  
  // Check if we have a valid R2 bucket binding
  if (r2Bucket && typeof r2Bucket === 'object' && 'get' in r2Bucket && 'put' in r2Bucket) {
    if (process.env.NODE_ENV !== 'production') {
      console.log(`Using R2 bindings for ${bucketName} bucket`)
    }
    return new R2Storage(r2Bucket)
  }

  // Try R2 S3 API as fallback (if credentials are available)
  const bucketNames = {
    passages: 'passage-map-passages',
    'vessel-data': 'passage-map-vessel-data',
    queries: 'passage-map-queries',
  }

  const r2AccessKeyId = config?.r2AccessKeyId || process.env.R2_ACCESS_KEY_ID
  const r2SecretAccessKey = config?.r2SecretAccessKey || process.env.R2_SECRET_ACCESS_KEY

  if (r2AccessKeyId && r2SecretAccessKey) {
    if (process.env.NODE_ENV !== 'production') {
      console.log(`Using R2 S3 API for ${bucketName} bucket`)
    }
    return new R2S3Storage(bucketNames[bucketName], r2AccessKeyId, r2SecretAccessKey)
  }

  // Fall back to filesystem (local development)
  if (process.env.NODE_ENV !== 'production') {
    console.log(`Using filesystem storage for ${bucketName} bucket (R2 not available)`)
  }
  const baseDirs = {
    passages: join(process.cwd(), 'public', 'data', 'passages'),
    'vessel-data': join(process.cwd(), 'public', 'data', 'passages_vessel_data'),
    queries: join(process.cwd(), 'public', 'data', 'passages'),
  }

  return new FilesystemStorage(baseDirs[bucketName])
}

/**
 * Get passages storage
 * Priority: R2 bindings > R2 S3 API > Filesystem
 * Note: D2 is checked directly in API endpoints, not through this storage adapter
 * This storage adapter is used as a fallback when D2 is not available
 */
export function getPassagesStorage(env?: { [key: string]: unknown }, config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }): StorageAdapter {
  // Check if D2 is available
  const d2Db = getD2Database(env)
  if (d2Db) {
    if (process.env.NODE_ENV !== 'production') {
      console.log('D2 database available. API endpoints will use D2 directly. This storage adapter is for fallback only.')
    }
  }
  
  return getStorageAdapter('passages', env, config)
}

/**
 * Get vessel data storage
 */
export function getVesselDataStorage(env?: { [key: string]: unknown }, config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }): StorageAdapter {
  return getStorageAdapter('vessel-data', env, config)
}

/**
 * Get queries storage
 */
export function getQueriesStorage(env?: { [key: string]: unknown }, config?: { r2AccessKeyId?: string; r2SecretAccessKey?: string }): StorageAdapter {
  return getStorageAdapter('queries', env, config)
}


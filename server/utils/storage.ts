/**
 * Storage abstraction layer
 * Supports both local filesystem (dev) and Cloudflare R2 (production)
 */

import { readFile, writeFile, readdir, mkdir } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'
import type { R2Bucket } from './r2Storage'
import { readR2JSON, writeR2JSON, listR2Objects, readR2Text } from './r2Storage'

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
 * Uses R2 if available, otherwise falls back to filesystem
 */
export function getStorageAdapter(
  bucketName: 'passages' | 'vessel-data' | 'queries',
  env?: { [key: string]: unknown }
): StorageAdapter {
  // Try to get R2 bucket from environment (Cloudflare Workers)
  // Match wrangler.toml bindings: PASSAGES_BUCKET, VESSEL_DATA_BUCKET, QUERIES_BUCKET
  const bucketBindings = {
    passages: 'PASSAGES_BUCKET',
    'vessel-data': 'VESSEL_DATA_BUCKET',
    queries: 'QUERIES_BUCKET',
  }

  const binding = bucketBindings[bucketName]
  const r2Bucket = env?.[binding] as R2Bucket | undefined

  if (r2Bucket) {
    return new R2Storage(r2Bucket)
  }

  // Fall back to filesystem (local development)
  const baseDirs = {
    passages: join(process.cwd(), 'public', 'data', 'passages'),
    'vessel-data': join(process.cwd(), 'public', 'data', 'passages_vessel_data'),
    queries: join(process.cwd(), 'public', 'data', 'passages'),
  }

  return new FilesystemStorage(baseDirs[bucketName])
}

/**
 * Get passages storage
 */
export function getPassagesStorage(env?: { [key: string]: unknown }): StorageAdapter {
  return getStorageAdapter('passages', env)
}

/**
 * Get vessel data storage
 */
export function getVesselDataStorage(env?: { [key: string]: unknown }): StorageAdapter {
  return getStorageAdapter('vessel-data', env)
}

/**
 * Get queries storage
 */
export function getQueriesStorage(env?: { [key: string]: unknown }): StorageAdapter {
  return getStorageAdapter('queries', env)
}


/**
 * R2 Storage utilities for Cloudflare R2 buckets
 * Works in both Node.js (local dev) and Cloudflare Workers environments
 */

export interface R2Bucket {
  get(key: string): Promise<R2ObjectBody | null>
  put(key: string, value: ReadableStream | ArrayBuffer | ArrayBufferView | string | null | Blob, options?: R2PutOptions): Promise<R2Object>
  list(options?: R2ListOptions): Promise<R2Objects>
  delete(keys: string[]): Promise<void>
  head(key: string): Promise<R2Object | null>
}

export interface R2Object {
  key: string
  size: number
  etag: string
  uploaded: Date
  checksums: R2Checksums
  httpEtag: string
  httpMetadata?: R2HTTPMetadata
  customMetadata?: Record<string, string>
}

export interface R2ObjectBody extends R2Object {
  body: ReadableStream
  bodyUsed: boolean
  arrayBuffer(): Promise<ArrayBuffer>
  text(): Promise<string>
  json<T = unknown>(): Promise<T>
  blob(): Promise<Blob>
}

export interface R2PutOptions {
  httpMetadata?: R2HTTPMetadata
  customMetadata?: Record<string, string>
  onlyIf?: R2Conditional
}

export interface R2ListOptions {
  limit?: number
  prefix?: string
  cursor?: string
  delimiter?: string
  include?: ('httpMetadata' | 'customMetadata')[]
}

export interface R2Objects {
  objects: R2Object[]
  truncated: boolean
  cursor?: string
  delimitedPrefixes: string[]
}

export interface R2HTTPMetadata {
  contentType?: string
  contentLanguage?: string
  contentDisposition?: string
  contentEncoding?: string
  cacheControl?: string
  cacheExpiry?: Date
}

export interface R2Checksums {
  md5?: ArrayBuffer
  sha1?: ArrayBuffer
  sha256?: ArrayBuffer
  sha384?: ArrayBuffer
  sha512?: ArrayBuffer
}

export interface R2Conditional {
  etagMatches?: string
  etagDoesNotMatch?: string
  uploadedBefore?: Date
  uploadedAfter?: Date
}

/**
 * Get R2 bucket binding from environment
 * In Cloudflare Workers, this comes from the env parameter
 * In local dev, we'll need to use Wrangler's local R2 or mock it
 */
export function getR2Bucket(
  env: { [key: string]: unknown } | undefined,
  binding: string
): R2Bucket | null {
  if (!env) {
    return null
  }
  return (env[binding] as R2Bucket) || null
}

/**
 * Read a JSON file from R2
 */
export async function readR2JSON<T = unknown>(
  bucket: R2Bucket,
  key: string
): Promise<T | null> {
  try {
    const object = await bucket.get(key)
    if (!object) {
      return null
    }
    return await object.json<T>()
  } catch (error) {
    console.error(`Error reading R2 object ${key}:`, error)
    return null
  }
}

/**
 * Read a text file from R2
 */
export async function readR2Text(bucket: R2Bucket, key: string): Promise<string | null> {
  try {
    const object = await bucket.get(key)
    if (!object) {
      return null
    }
    return await object.text()
  } catch (error) {
    console.error(`Error reading R2 object ${key}:`, error)
    return null
  }
}

/**
 * Write a JSON file to R2
 */
export async function writeR2JSON(
  bucket: R2Bucket,
  key: string,
  data: unknown,
  options?: R2PutOptions
): Promise<R2Object> {
  const jsonString = JSON.stringify(data, null, 2)
  return await bucket.put(key, jsonString, {
    httpMetadata: {
      contentType: 'application/json',
      ...options?.httpMetadata,
    },
    ...options,
  })
}

/**
 * List all objects in R2 with a given prefix
 */
export async function listR2Objects(
  bucket: R2Bucket,
  prefix?: string,
  limit?: number
): Promise<R2Object[]> {
  try {
    const result = await bucket.list({
      prefix,
      limit,
    })
    return result.objects
  } catch (error) {
    console.error(`Error listing R2 objects with prefix ${prefix}:`, error)
    return []
  }
}

/**
 * Delete an object from R2
 */
export async function deleteR2Object(bucket: R2Bucket, key: string): Promise<boolean> {
  try {
    await bucket.delete([key])
    return true
  } catch (error) {
    console.error(`Error deleting R2 object ${key}:`, error)
    return false
  }
}

/**
 * Check if an object exists in R2
 */
export async function existsR2Object(bucket: R2Bucket, key: string): Promise<boolean> {
  try {
    const object = await bucket.head(key)
    return object !== null
  } catch (error) {
    console.error(`Error checking R2 object ${key}:`, error)
    return false
  }
}


/**
 * R2 Storage using S3-compatible API
 * Fallback option when R2 bindings aren't available
 */

import { S3Client, GetObjectCommand, PutObjectCommand, ListObjectsV2Command, HeadObjectCommand } from '@aws-sdk/client-s3'
import type { StorageAdapter } from './storage'

// R2 S3 API endpoint
const R2_ENDPOINT = 'https://d715f0aeb6b2e7b10f54e9e72fba8fdd.r2.cloudflarestorage.com'

/**
 * S3-based R2 storage adapter
 */
export class R2S3Storage implements StorageAdapter {
  private s3Client: S3Client
  private bucketName: string

  constructor(bucketName: string, accessKeyId?: string, secretAccessKey?: string) {
    this.bucketName = bucketName
    
    // Create S3 client configured for R2
    this.s3Client = new S3Client({
      region: 'auto', // R2 uses 'auto' region
      endpoint: R2_ENDPOINT,
      credentials: accessKeyId && secretAccessKey
        ? {
            accessKeyId,
            secretAccessKey,
          }
        : undefined,
    })
  }

  async readJSON<T = unknown>(key: string): Promise<T | null> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      })

      const response = await this.s3Client.send(command)
      
      if (!response.Body) {
        return null
      }

      // Convert stream to string
      const chunks: Uint8Array[] = []
      for await (const chunk of response.Body as any) {
        chunks.push(chunk)
      }
      const bodyString = Buffer.concat(chunks).toString('utf-8')
      
      return JSON.parse(bodyString) as T
    } catch (error: any) {
      // 404 Not Found means the object doesn't exist, which is fine
      if (error.name === 'NoSuchKey' || error.$metadata?.httpStatusCode === 404) {
        return null
      }
      console.error(`Error reading R2 S3 object ${key}:`, error)
      return null
    }
  }

  async readText(key: string): Promise<string | null> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      })

      const response = await this.s3Client.send(command)
      
      if (!response.Body) {
        return null
      }

      // Convert stream to string
      const chunks: Uint8Array[] = []
      for await (const chunk of response.Body as any) {
        chunks.push(chunk)
      }
      
      return Buffer.concat(chunks).toString('utf-8')
    } catch (error: any) {
      // 404 Not Found means the object doesn't exist, which is fine
      if (error.name === 'NoSuchKey' || error.$metadata?.httpStatusCode === 404) {
        return null
      }
      console.error(`Error reading R2 S3 object ${key}:`, error)
      return null
    }
  }

  async writeJSON(key: string, data: unknown): Promise<void> {
    try {
      const jsonString = JSON.stringify(data, null, 2)
      
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key,
        Body: jsonString,
        ContentType: 'application/json',
      })

      await this.s3Client.send(command)
    } catch (error) {
      console.error(`Error writing R2 S3 object ${key}:`, error)
      throw error
    }
  }

  async list(prefix?: string): Promise<string[]> {
    try {
      const keys: string[] = []
      let continuationToken: string | undefined

      do {
        const command = new ListObjectsV2Command({
          Bucket: this.bucketName,
          Prefix: prefix,
          ContinuationToken: continuationToken,
        })

        const response = await this.s3Client.send(command)
        
        if (response.Contents) {
          for (const object of response.Contents) {
            if (object.Key) {
              keys.push(object.Key)
            }
          }
        }

        continuationToken = response.NextContinuationToken
      } while (continuationToken)

      return keys
    } catch (error) {
      console.error(`Error listing R2 S3 objects with prefix ${prefix}:`, error)
      return []
    }
  }

  async exists(key: string): Promise<boolean> {
    try {
      const command = new HeadObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      })

      await this.s3Client.send(command)
      return true
    } catch (error: any) {
      // 404 Not Found means the object doesn't exist
      if (error.name === 'NotFound' || error.$metadata?.httpStatusCode === 404) {
        return false
      }
      console.error(`Error checking R2 S3 object ${key}:`, error)
      return false
    }
  }
}


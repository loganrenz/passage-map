import type { Passage } from '~/types/passage'
import { getPassagesStorage } from '~/server/utils/storage'
import { getCloudflareEnv } from '~/server/utils/cloudflareEnv'

export default defineEventHandler(async (event) => {
  try {
    // Get storage adapter (R2 bindings > R2 S3 API > filesystem)
    const env = getCloudflareEnv(event)
    const config = useRuntimeConfig(event)
    
    if (process.env.NODE_ENV !== 'production') {
      console.log('Accessing storage - env keys:', Object.keys(env))
    }
    const storage = getPassagesStorage(env, {
      r2AccessKeyId: config.r2AccessKeyId,
      r2SecretAccessKey: config.r2SecretAccessKey,
    })
    
    // List all passage files
    const files = await storage.list('passage_')
    if (process.env.NODE_ENV !== 'production') {
      console.log(`Found ${files.length} files with prefix 'passage_'`)
    }
    
    // Filter for passage JSON files (exclude index/list files)
    const passageFiles = files.filter(
      (file) => file.startsWith('passage_') && file.endsWith('.json')
    )
    
    // Load and parse each passage file to extract metadata
    const passages: Passage[] = []
    
    for (const filename of passageFiles) {
      try {
        const passage = await storage.readJSON<Passage>(filename)
        
        if (!passage) {
          continue
        }
        
        // Ensure filename is set
        if (!passage.filename) {
          passage.filename = filename
        }
        
        // Add to list (only include if it has required fields)
        if (passage.id && passage.startTime && passage.endTime) {
          // Return metadata only (exclude positions array for performance)
          const { positions, ...metadata } = passage
          passages.push(metadata as Passage)
        }
      } catch (err) {
        console.error(`Error reading passage file ${filename}:`, err)
        // Continue with other files even if one fails
      }
    }
    
    // Sort passages by start time (most recent first)
    passages.sort((a, b) => {
      const timeA = new Date(a.startTime).getTime()
      const timeB = new Date(b.startTime).getTime()
      return timeB - timeA
    })
    
    return passages
  } catch (error) {
    console.error('Error listing passages:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to list passages',
    })
  }
})


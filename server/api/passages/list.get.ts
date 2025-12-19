import { readdir, readFile } from 'fs/promises'
import { join } from 'path'
import type { Passage } from '~/types/passage'

export default defineEventHandler(async (_event) => {
  try {
    const passagesDir = join(process.cwd(), 'public', 'data', 'passages')
    
    // Read all files in the passages directory
    const files = await readdir(passagesDir)
    
    // Filter for passage JSON files (exclude index/list files)
    const passageFiles = files.filter(
      (file) => file.startsWith('passage_') && file.endsWith('.json')
    )
    
    // Load and parse each passage file to extract metadata
    const passages: Passage[] = []
    
    for (const filename of passageFiles) {
      try {
        const filePath = join(passagesDir, filename)
        const fileContent = await readFile(filePath, 'utf-8')
        const passage: Passage = JSON.parse(fileContent)
        
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


import type { Passage } from '~/types/passage'

export async function loadPassage(filename: string): Promise<Passage | null> {
  try {
    const response = await fetch(`/data/passages/${filename}`)
    if (!response.ok) {
      throw new Error(`Failed to load passage: ${response.statusText}`)
    }
    const data = await response.json()
    return data as Passage
  } catch (error) {
    console.error(`Error loading passage ${filename}:`, error)
    return null
  }
}

export async function loadPassagesList(): Promise<Passage[]> {
  try {
    const response = await fetch('/api/passages/list')
    if (!response.ok) {
      throw new Error(`Failed to load passages list: ${response.statusText}`)
    }
    const data = await response.json()
    return Array.isArray(data) ? data : []
  } catch (error) {
    console.error('Error loading passages list:', error)
    return []
  }
}

export function validatePassage(passage: unknown): passage is Passage {
  if (typeof passage !== 'object' || passage === null) {
    return false
  }
  
  const p = passage as Record<string, unknown>
  
  return (
    typeof p.id === 'string' &&
    typeof p.startTime === 'string' &&
    typeof p.endTime === 'string' &&
    typeof p.duration === 'number' &&
    typeof p.avgSpeed === 'number' &&
    typeof p.maxSpeed === 'number' &&
    typeof p.distance === 'number' &&
    typeof p.startLocation === 'object' &&
    p.startLocation !== null &&
    typeof (p.startLocation as Record<string, unknown>).lat === 'number' &&
    typeof (p.startLocation as Record<string, unknown>).lon === 'number' &&
    typeof p.endLocation === 'object' &&
    p.endLocation !== null &&
    typeof (p.endLocation as Record<string, unknown>).lat === 'number' &&
    typeof (p.endLocation as Record<string, unknown>).lon === 'number'
  )
}


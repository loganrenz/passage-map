import type { Passage } from '~/types/passage'
import { loadPassagesList, loadPassage, validatePassage } from '~/utils/passageLoader'

export const usePassageData = () => {
  const passages = ref<Passage[]>([])
  const selectedPassage = ref<Passage | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const loadAllPassages = async () => {
    isLoading.value = true
    error.value = null

    try {
      const data = await loadPassagesList()
      // Convert readonly arrays to mutable arrays
      passages.value = data.filter(validatePassage).map(p => ({
        ...p,
        positions: p.positions ? [...p.positions] : undefined
      }))
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to load passages'
      console.error('Error loading passages:', err)
    } finally {
      isLoading.value = false
    }
  }

  const loadPassageById = async (passageId: string) => {
    isLoading.value = true
    error.value = null

    try {
      const passage = passages.value.find((p) => p.id === passageId)
      if (passage && passage.filename) {
        const fullPassage = await loadPassage(passage.filename)
        if (fullPassage && validatePassage(fullPassage)) {
          // Convert readonly arrays to mutable arrays
          const mutablePassage = {
            ...fullPassage,
            positions: fullPassage.positions ? [...fullPassage.positions] : undefined
          }
          selectedPassage.value = mutablePassage
          return mutablePassage
        }
      }
      error.value = 'Passage not found'
      return null
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to load passage'
      console.error('Error loading passage:', err)
      return null
    } finally {
      isLoading.value = false
    }
  }

  const selectPassage = (passage: Passage | null) => {
    selectedPassage.value = passage
  }

  return {
    passages: readonly(passages),
    selectedPassage: readonly(selectedPassage),
    isLoading: readonly(isLoading),
    error: readonly(error),
    loadAllPassages,
    loadPassageById,
    selectPassage,
  }
}


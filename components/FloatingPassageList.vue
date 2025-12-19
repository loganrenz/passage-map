<template>
  <div
    ref="panelRef"
    class="floating-panel"
    :style="{
      left: `${position.x}px`,
      top: `${position.y}px`,
    }"
  >
    <UCard class="w-full h-full flex flex-col">
      <!-- Panel Header (draggable) -->
      <template #header>
        <div
          ref="dragHandleRef"
          class="flex items-center justify-between cursor-move select-none"
          @mousedown="startDrag"
          @touchstart="startDrag"
        >
          <div class="flex items-center gap-2 flex-1">
            <UIcon name="i-lucide-grip-vertical" class="text-gray-400" />
            <h2 class="text-base sm:text-lg font-semibold">Passages</h2>
          </div>
          <div class="flex items-center gap-1">
            <UButton
              v-if="isCollapsed"
              icon="i-lucide-maximize-2"
              size="xs"
              variant="ghost"
              color="gray"
              @click.stop="isCollapsed = false"
            />
            <UButton
              v-else
              icon="i-lucide-chevron-up"
              size="xs"
              variant="ghost"
              color="gray"
              @click.stop="isCollapsed = true"
            />
          </div>
        </div>
      </template>

      <!-- Panel Content -->
      <div v-if="!isCollapsed" class="flex-1 overflow-y-auto min-h-0">
        <PassageList
          :passages="passages"
          :selected-passage="selectedPassage"
          :is-loading="isLoading"
          :error="error"
          @select="handleSelect"
        />
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'

interface Props {
  passages: Passage[]
  selectedPassage?: Passage | null
  isLoading?: boolean
  error?: string | null
}

const props = withDefaults(defineProps<Props>(), {
  selectedPassage: null,
  isLoading: false,
  error: null,
})

const emit = defineEmits<{
  select: [passage: Passage]
}>()

const panelRef = ref<HTMLElement | null>(null)
const dragHandleRef = ref<HTMLElement | null>(null)
const isCollapsed = ref(false)

// Panel position - default to top-left, but lower to leave room for title
const position = ref({ x: 20, y: 100 })

// Drag state
const isDragging = ref(false)
const dragStart = ref({ x: 0, y: 0 })
const panelStart = ref({ x: 0, y: 0 })

const startDrag = (e: MouseEvent | TouchEvent) => {
  if (isCollapsed.value) return
  
  isDragging.value = true
  const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX
  const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY
  
  dragStart.value = { x: clientX, y: clientY }
  panelStart.value = { ...position.value }

  document.addEventListener('mousemove', handleDrag)
  document.addEventListener('mouseup', stopDrag)
  document.addEventListener('touchmove', handleDrag, { passive: false })
  document.addEventListener('touchend', stopDrag)
  
  e.preventDefault()
}

const handleDrag = (e: MouseEvent | TouchEvent) => {
  if (!isDragging.value) return
  
  const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX
  const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY
  
  const deltaX = clientX - dragStart.value.x
  const deltaY = clientY - dragStart.value.y

  const newX = panelStart.value.x + deltaX
  const newY = panelStart.value.y + deltaY

  // Constrain to viewport bounds
  const maxX = window.innerWidth - (panelRef.value?.offsetWidth || 380)
  const maxY = window.innerHeight - (panelRef.value?.offsetHeight || 600)

  position.value = {
    x: Math.max(0, Math.min(newX, maxX)),
    y: Math.max(0, Math.min(newY, maxY)),
  }
  
  if ('touches' in e) {
    e.preventDefault()
  }
}

const stopDrag = () => {
  isDragging.value = false
  document.removeEventListener('mousemove', handleDrag)
  document.removeEventListener('mouseup', stopDrag)
  document.removeEventListener('touchmove', handleDrag)
  document.removeEventListener('touchend', stopDrag)
}

const handleSelect = (passage: Passage) => {
  emit('select', passage)
}

// Initialize position on mount
onMounted(() => {
  if (panelRef.value) {
    position.value = { x: 20, y: 100 }
  }
})

onUnmounted(() => {
  stopDrag()
})
</script>

<style scoped>
.floating-panel {
  position: fixed;
  width: 380px;
  max-width: calc(100vw - 40px);
  max-height: 250px;
  z-index: 999;
  transition: transform 0.3s ease, opacity 0.3s ease;
  transform-origin: top left;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.floating-panel .cursor-move {
  cursor: move;
}

.floating-panel .cursor-move:active {
  cursor: grabbing;
}

@media (max-width: 640px) {
  .floating-panel {
    width: calc(100vw - 40px);
    max-height: 200px;
  }
}
</style>


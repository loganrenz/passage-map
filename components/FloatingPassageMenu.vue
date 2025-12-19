<template>
  <div
    ref="panelRef"
    :class="[
      'floating-panel',
      { 'panel-hidden': isHidden }
    ]"
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
          class="flex items-center justify-between cursor-move select-none touch-manipulation"
          @mousedown="startDrag"
          @touchstart.prevent="startDrag"
        >
          <div class="flex items-center gap-2 flex-1">
            <UIcon name="i-lucide-grip-vertical" class="text-gray-400" />
            <h2 class="text-base sm:text-lg font-semibold">Passages</h2>
          </div>
          <div class="flex items-center gap-1">
            <UButton
              icon="i-lucide-minimize-2"
              size="xs"
              variant="ghost"
              color="gray"
              @click.stop="toggleHide"
              @touchstart.stop.prevent="toggleHide"
            />
            <UButton
              v-if="isCollapsed"
              icon="i-lucide-maximize-2"
              size="xs"
              variant="ghost"
              color="gray"
              @click.stop="isCollapsed = false"
              @touchstart.stop.prevent="isCollapsed = false"
            />
            <UButton
              v-else
              icon="i-lucide-chevron-up"
              size="xs"
              variant="ghost"
              color="gray"
              @click.stop="isCollapsed = true"
              @touchstart.stop.prevent="isCollapsed = true"
            />
          </div>
        </div>
      </template>

      <!-- Panel Content -->
      <div v-if="!isCollapsed" class="flex-1 overflow-hidden flex flex-col min-h-0">
        <div class="flex gap-2 border-b pb-2 mb-2">
          <UButton
            :variant="activeTab === 'list' ? 'solid' : 'ghost'"
            size="xs"
            @click="activeTab = 'list'"
            @touchstart.prevent="activeTab = 'list'"
          >
            List
          </UButton>
          <UButton
            :variant="activeTab === 'info' ? 'solid' : 'ghost'"
            size="xs"
            @click="activeTab = 'info'"
            @touchstart.prevent="activeTab = 'info'"
            :disabled="!selectedPassage"
          >
            Details
          </UButton>
        </div>

        <div class="flex-1 overflow-y-auto min-h-0">
          <!-- Passage List Tab -->
          <div v-show="activeTab === 'list'">
            <PassageList
              :passages="passages"
              :selected-passage="selectedPassage"
              :is-loading="isLoading"
              :error="error"
              @select="handleSelect"
            />
          </div>

          <!-- Passage Info Tab -->
          <div v-show="activeTab === 'info'" class="space-y-4">
            <PassageInfo :passage="selectedPassage" />
            <PassageLocations :passage="selectedPassage" @update:locations="handleLocationsUpdate" />
          </div>
        </div>
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
  'update:locations': [locations: Passage['locations']]
}>()

const panelRef = ref<HTMLElement | null>(null)
const dragHandleRef = ref<HTMLElement | null>(null)
const isHidden = ref(false)
const isCollapsed = ref(false)
const activeTab = ref<'list' | 'info'>('list')

// Panel position
const position = ref({ x: 20, y: 80 })

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
  const maxX = window.innerWidth - (panelRef.value?.offsetWidth || 400)
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

const toggleHide = () => {
  isHidden.value = !isHidden.value
}

const handleSelect = (passage: Passage) => {
  emit('select', passage)
  activeTab.value = 'info'
}

const handleLocationsUpdate = (locations: Passage['locations']) => {
  emit('update:locations', locations)
}

// Auto-switch to info tab when a passage is selected
watch(() => props.selectedPassage, (newPassage) => {
  if (newPassage && activeTab.value === 'list') {
    activeTab.value = 'info'
  }
})

// Initialize position on mount
onMounted(() => {
  // Set initial position (top-left with some padding)
  if (panelRef.value) {
    position.value = { x: 20, y: 80 }
  }
})

onUnmounted(() => {
  stopDrag()
})
</script>

<style scoped>
.floating-panel {
  position: fixed;
  width: 400px;
  max-width: calc(100vw - 40px);
  max-height: calc(100vh - 250px);
  z-index: 999;
  transition: transform 0.3s ease, opacity 0.3s ease;
  transform-origin: top left;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.panel-hidden {
  transform: translateX(calc(-100% + 50px));
  opacity: 0.3;
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
    max-height: calc(100vh - 150px);
  }
}
</style>


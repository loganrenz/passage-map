<template>
  <div
    v-if="selectedPassage"
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
            <h2 class="text-base sm:text-lg font-semibold truncate">{{ props.selectedPassage?.name }}</h2>
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
      <div v-if="!isCollapsed" class="flex-1 overflow-y-auto min-h-0 space-y-4">
        <!-- Date/Time Picker for Centering -->
        <div class="p-3 bg-gray-50 rounded-lg border">
          <label class="text-xs font-medium text-gray-700 mb-2 block">
            Jump to Date/Time
          </label>
          <div class="flex gap-2">
            <UInput
              v-model="selectedDateTime"
              type="datetime-local"
              :min="minDateTime"
              :max="maxDateTime"
              size="sm"
              class="flex-1"
            />
            <UButton
              icon="i-lucide-map-pin"
              size="sm"
              color="primary"
              :disabled="!selectedDateTime"
              @click="handleCenterOnDate"
              @touchstart.prevent="!selectedDateTime || handleCenterOnDate()"
            >
              Center
            </UButton>
          </div>
        </div>
        
        <PassageInfo :passage="props.selectedPassage" />
        <PassageLocations :passage="props.selectedPassage" @update:locations="handleLocationsUpdate" />
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'

interface Props {
  selectedPassage?: Passage | null
}

const props = withDefaults(defineProps<Props>(), {
  selectedPassage: null,
})

const emit = defineEmits<{
  'update:locations': [locations: Passage['locations']]
  'center-on-date': [timestamp: string]
}>()

const selectedDateTime = ref<string>('')

const minDateTime = computed(() => {
  if (!props.selectedPassage) return ''
  const date = new Date(props.selectedPassage.startTime)
  // Format as YYYY-MM-DDTHH:mm for datetime-local input
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day}T${hours}:${minutes}`
})

const maxDateTime = computed(() => {
  if (!props.selectedPassage) return ''
  const date = new Date(props.selectedPassage.endTime)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day}T${hours}:${minutes}`
})

const handleCenterOnDate = () => {
  if (!selectedDateTime.value || !props.selectedPassage) return
  
  // datetime-local input gives us a string in format "YYYY-MM-DDTHH:mm"
  // We need to create a Date object treating it as local time
  // Then convert to ISO string
  const localDate = new Date(selectedDateTime.value)
  
  // Check if date is valid
  if (isNaN(localDate.getTime())) {
    console.error('Invalid date selected')
    return
  }
  
  // Convert to ISO string (this will convert from local to UTC)
  const isoString = localDate.toISOString()
  
  emit('center-on-date', isoString)
}

const panelRef = ref<HTMLElement | null>(null)
const dragHandleRef = ref<HTMLElement | null>(null)
const isHidden = ref(false)
const isCollapsed = ref(false)

// Panel position - default to left side, stacked below the list panel
const position = ref({ x: 20, y: 520 })

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

const toggleHide = () => {
  isHidden.value = !isHidden.value
}

const handleLocationsUpdate = (locations: Passage['locations']) => {
  emit('update:locations', locations)
}

// Reset date picker when passage changes
watch(() => props.selectedPassage, (newPassage) => {
  if (newPassage) {
    // Set default to start time
    const startDate = new Date(newPassage.startTime)
    const year = startDate.getFullYear()
    const month = String(startDate.getMonth() + 1).padStart(2, '0')
    const day = String(startDate.getDate()).padStart(2, '0')
    const hours = String(startDate.getHours()).padStart(2, '0')
    const minutes = String(startDate.getMinutes()).padStart(2, '0')
    selectedDateTime.value = `${year}-${month}-${day}T${hours}:${minutes}`
  } else {
    selectedDateTime.value = ''
  }
}, { immediate: true })

// Initialize position on mount
onMounted(() => {
  if (panelRef.value && typeof window !== 'undefined') {
    // Stack below the list panel (list panel is ~400px high at y: 100, so start at ~520)
    position.value = { x: 20, y: 520 }
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
  max-height: 400px;
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


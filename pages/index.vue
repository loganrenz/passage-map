<template>
  <div class="fullscreen-map-container">
    <!-- Full Screen Map -->
    <div class="map-wrapper" :class="{ 'details-collapsed': isDetailsCollapsed && selectedPassage, 'has-timeline': selectedPassage }">
      <PassageMap ref="mapRef" :passages="displayedPassages" :selected-passage="mutableSelectedPassage" :auto-fit="true"
        :current-time="currentTime" />

      <!-- Map Controls Overlay -->
      <div class="map-controls-overlay">
        <div class="flex items-center justify-between w-full">
          <div class="flex items-center gap-2">
            <h1 class="text-xl font-bold text-white drop-shadow-lg">Passage Map</h1>
            <ClientOnly>
              <UButton variant="ghost" icon="i-lucide-database" to="/queries" size="sm"
                class="text-white hover:bg-white/20">
                Queries
              </UButton>
              <template #fallback>
                <div />
              </template>
            </ClientOnly>
          </div>
        </div>
      </div>
    </div>

    <!-- Passage List Modal Button -->
    <div class="absolute top-[280px] right-4 z-[1001]">
      <UCard class="p-2 shadow-lg bg-white/95 backdrop-blur-sm">
        <UButton
          icon="i-lucide-list"
          size="xs"
          variant="outline"
          @click="isPassageModalOpen = true"
        >
          Passages
        </UButton>
      </UCard>
    </div>

    <!-- Passage List Modal -->
    <UModal
      v-model:open="isPassageModalOpen"
      title="Select Passage"
      :ui="{ width: 'w-full sm:max-w-2xl' }"
      scrollable
    >
      <template #body>
        <div class="max-h-[60vh]">
          <PassageList
            :passages="mutablePassages"
            :selected-passage="mutableSelectedPassage"
            :is-loading="isLoading"
            :error="error"
            @select="handlePassageSelectFromModal"
          />
        </div>
      </template>
    </UModal>

    <!-- Details and Timeline at Bottom -->
    <div v-if="selectedPassage" class="timeline-bottom" :class="{ 'details-collapsed': isDetailsCollapsed }">
      <!-- Details Section Header -->
      <div class="details-header">
        <div class="flex items-center justify-between">
          <UTabs v-model="activeTab" :items="tabItems" class="flex-1" />
          <UButton
            :icon="isDetailsCollapsed ? 'i-lucide-chevron-down' : 'i-lucide-chevron-up'"
            size="xs"
            variant="ghost"
            color="neutral"
            class="ml-2"
            @click="toggleDetails"
          />
        </div>
        <!-- Collapsible Date/Time Picker -->
        <UButton
          v-if="!isDatePickerVisible"
          icon="i-lucide-calendar"
          size="xs"
          variant="ghost"
          color="neutral"
          class="mt-2"
          @click="isDatePickerVisible = true"
        >
          Jump to Date/Time
        </UButton>
        <div v-if="isDatePickerVisible" class="date-picker-compact">
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
            >
              Center
            </UButton>
            <UButton
              icon="i-lucide-x"
              size="sm"
              variant="ghost"
              @click="isDatePickerVisible = false"
            />
          </div>
        </div>
      </div>

      <!-- Details Section -->
      <div v-if="!isDetailsCollapsed" class="details-section">
        <div v-if="activeTab === 'overview'">
          <PassageInfo :passage="mutableSelectedPassage" />
        </div>
        <div v-else-if="activeTab === 'locations'">
          <PassageLocations :passage="mutableSelectedPassage" @update:locations="handleLocationsUpdate" />
        </div>
      </div>

      <!-- Timeline -->
      <PassageTimeline :passage="mutableSelectedPassage!" @time-update="handleTimeUpdate" />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Passage, PassageLocation } from '~/types/passage'
import { usePassageData } from '~/composables/usePassageData'

const route = useRoute()
const router = useRouter()

const { passages, selectedPassage, isLoading, error, loadAllPassages, selectPassage, loadPassageById } =
  usePassageData()

// Helper to convert readonly arrays to mutable arrays
type ReadonlyPassage = {
  readonly id: string
  readonly startTime: string
  readonly endTime: string
  readonly duration: number
  readonly avgSpeed: number
  readonly maxSpeed: number
  readonly distance: number
  readonly startLocation: PassageLocation
  readonly endLocation: PassageLocation
  readonly description: string
  readonly name: string
  readonly route: string
  readonly exportTimestamp?: string
  readonly filename?: string
  readonly positions?: readonly {
    readonly _time: string
    readonly lat: number
    readonly lon: number
  }[]
}

const toMutablePassage = (passage: ReadonlyPassage | Passage): Passage => ({
  ...passage,
  positions: passage.positions ? [...passage.positions] : undefined
})

// Computed properties for template use
const mutablePassages = computed(() => {
  return passages.value.map(toMutablePassage)
})

const mutableSelectedPassage = computed(() => {
  return selectedPassage.value ? toMutablePassage(selectedPassage.value) : null
})

const displayedPassages = computed(() => {
  if (selectedPassage.value) {
    return [toMutablePassage(selectedPassage.value)]
  }
  return mutablePassages.value
})

// Timeline state
const currentTime = ref<string | null>(null)

const handleTimeUpdate = (timestamp: string) => {
  currentTime.value = timestamp
}

// Details collapse state
const isDetailsCollapsed = ref(false)

// Passage modal state
const isPassageModalOpen = ref(false)

// Tab state
const activeTab = ref('overview')
const tabItems = [
  { label: 'Overview', value: 'overview' },
  { label: 'Locations', value: 'locations' },
]

// Date picker visibility
const isDatePickerVisible = ref(false)

const toggleDetails = () => {
  isDetailsCollapsed.value = !isDetailsCollapsed.value
  // Trigger map resize after details section toggles
  // MapKit should automatically detect container size changes
  nextTick(() => {
    // Small delay to ensure DOM has updated and CSS transition has started
    setTimeout(() => {
      if (mapRef.value && 'handleResize' in mapRef.value) {
        (mapRef.value as { handleResize: () => void }).handleResize()
      }
      // Also trigger window resize event for MapKit to recalculate
      window.dispatchEvent(new Event('resize'))
    }, 350) // Wait for CSS transition to complete (300ms + 50ms buffer)
  })
}

// Date/Time picker state
const selectedDateTime = ref<string>('')

const minDateTime = computed(() => {
  if (!mutableSelectedPassage.value) return ''
  const date = new Date(mutableSelectedPassage.value.startTime)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day}T${hours}:${minutes}`
})

const maxDateTime = computed(() => {
  if (!mutableSelectedPassage.value) return ''
  const date = new Date(mutableSelectedPassage.value.endTime)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day}T${hours}:${minutes}`
})

const handleCenterOnDate = () => {
  if (!selectedDateTime.value || !mutableSelectedPassage.value) return

  const localDate = new Date(selectedDateTime.value)

  if (isNaN(localDate.getTime())) {
    console.error('Invalid date selected')
    return
  }

  const isoString = localDate.toISOString()
  currentTime.value = isoString
  nextTick(() => {
    if (mapRef.value) {
      mapRef.value.centerMapOnTime(isoString)
    }
  })
}

// Reset date picker when passage changes
watch(() => mutableSelectedPassage.value, (newPassage) => {
  if (newPassage) {
    const startDate = new Date(newPassage.startTime)
    const year = startDate.getFullYear()
    const month = String(startDate.getMonth() + 1).padStart(2, '0')
    const day = String(startDate.getDate()).padStart(2, '0')
    const hours = String(startDate.getHours()).padStart(2, '0')
    const minutes = String(startDate.getMinutes()).padStart(2, '0')
    selectedDateTime.value = `${year}-${month}-${day}T${hours}:${minutes}`
    isDatePickerVisible.value = false
  } else {
    selectedDateTime.value = ''
    isDatePickerVisible.value = false
  }
}, { immediate: true })

// Flag to prevent infinite loops when updating URL
const isUpdatingFromUrl = ref(false)

const handlePassageSelect = async (passage: Passage, updateUrl = true) => {
  // If passage has filename, load full passage data
  if (passage.filename) {
    await loadPassageById(passage.id)
  } else {
    // Convert readonly arrays to mutable arrays
    const mutablePassage = {
      ...passage,
      positions: passage.positions ? [...passage.positions] : undefined
    }
    selectPassage(mutablePassage)
  }

  // Reset timeline to start when passage changes
  currentTime.value = passage.startTime

  // Update URL with passage ID (unless we're loading from URL)
  if (updateUrl && !isUpdatingFromUrl.value) {
    await router.push({ query: { passage: passage.id } })
  }
}

const handlePassageSelectFromModal = async (passage: Passage) => {
  await handlePassageSelect(passage, true)
  // Close modal after selection
  isPassageModalOpen.value = false
}

const handleLocationsUpdate = (locations: Passage['locations']) => {
  if (mutableSelectedPassage.value && selectedPassage.value) {
    // Create updated passage with locations
    const updatedPassage: Passage = {
      ...toMutablePassage(selectedPassage.value),
      locations,
    }
    // Update the selected passage in the store
    selectPassage(updatedPassage)
  }
}

const mapRef = ref<{ centerMapOnTime: (timestamp: string) => void } | null>(null)

// Function to load passage from URL
const loadPassageFromUrl = async () => {
  const passageId = route.query.passage as string | undefined
  if (passageId) {
    const passage = passages.value.find((p) => p.id === passageId)
    if (passage) {
      isUpdatingFromUrl.value = true
      const mutablePassage = toMutablePassage(passage)
      await handlePassageSelect(mutablePassage, false)
      isUpdatingFromUrl.value = false
    }
  } else {
    // No passage in URL, clear selection
    if (selectedPassage.value) {
      isUpdatingFromUrl.value = true
      selectPassage(null)
      currentTime.value = null
      isUpdatingFromUrl.value = false
    }
  }
}

// Watch for route changes (browser back/forward)
watch(() => route.query.passage, async () => {
  if (passages.value.length > 0) {
    await loadPassageFromUrl()
  }
})

onMounted(async () => {
  await loadAllPassages()

  // Check if there's a passage ID in the URL after loading passages
  await loadPassageFromUrl()
})
</script>

<style scoped>
.fullscreen-map-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}

.map-wrapper {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  transition: bottom 0.3s ease;
}

/* Adjust map bottom when timeline exists */
.map-wrapper.has-timeline:not(.details-collapsed) {
  bottom: 35vh;
}

.map-wrapper.has-timeline.details-collapsed {
  bottom: 80px;
}

.map-controls-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  padding: 1rem;
  background: linear-gradient(to bottom, rgba(0, 0, 0, 0.5), transparent);
  pointer-events: none;
}

.map-controls-overlay>* {
  pointer-events: all;
}

.timeline-bottom {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 998;
  padding: 0.75rem 1rem;
  background: linear-gradient(to top, rgba(255, 255, 255, 0.95), rgba(255, 255, 255, 0.9));
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  max-height: 35vh;
  overflow-y: auto;
  transition: max-height 0.3s ease;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.timeline-bottom.details-collapsed {
  max-height: 80px;
}

.details-header {
  flex-shrink: 0;
}

.details-section {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  max-height: 25vh;
}

.date-picker-compact {
  margin-top: 0.5rem;
  padding: 0.5rem;
  background: rgba(0, 0, 0, 0.02);
  border-radius: 0.375rem;
}

@media (max-width: 640px) {
  .timeline-bottom {
    padding: 0.75rem;
    max-height: 50vh;
  }

  .timeline-bottom.details-collapsed {
    max-height: 80px;
  }

  .details-section {
    max-height: 35vh;
  }
}
</style>

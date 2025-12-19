<template>
  <div class="app-container">
    <!-- Header: Passage Summary Bar -->
    <PassageHeader v-if="selectedPassage" :passage="mutableSelectedPassage" />

    <!-- Main Layout: Sidebar + Map -->
    <div class="main-layout">
      <!-- Left Sidebar -->
      <PassageSidebar
        v-if="selectedPassage"
        :passage="mutableSelectedPassage"
        :layers="layers"
        :view-mode="viewMode"
        @update:layers="layers = $event"
        @update:view-mode="viewMode = $event"
        @export-gpx="handleExportGPX"
        @export-geojson="handleExportGeoJSON"
        @generate-report="handleGenerateReport"
      />

      <!-- Map Canvas -->
      <div class="map-container">
        <PassageMap
          ref="mapRef"
          :passages="displayedPassages"
          :selected-passage="mutableSelectedPassage"
          :auto-fit="true"
          :current-time="currentTime"
          :speed-color-coding="layers.speed"
          :show-features="layers.waypoints"
          :show-vessels="showVessels"
          :lock-tideye="lockTideye"
          @update:lock-tideye="lockTideye = $event"
          @time-update="handleTimeUpdate"
        />

        <!-- Map Controls: Positioned to the left of map type selector -->
        <div class="map-controls-top">
          <!-- Vessels Button -->
          <UButton
            v-if="selectedPassage"
            :variant="showVessels ? 'solid' : 'outline'"
            size="sm"
            icon="i-lucide-ship"
            class="shadow-lg w-auto"
            :class="showVessels ? 'bg-primary-600 text-white hover:bg-primary-700' : ''"
            @click="showVessels = !showVessels"
          >
            Vessels
          </UButton>
          
          <!-- Fit Button -->
          <UButton
            size="sm"
            variant="outline"
            icon="i-lucide-maximize"
            class="shadow-lg w-auto"
            @click="handleMapFit"
          >
            Fit
          </UButton>
          
          <!-- Center Button -->
          <UButton
            v-if="selectedPassage && currentTime"
            size="sm"
            :variant="lockTideye === 'locked' ? 'solid' : lockTideye === 'center' ? 'soft' : 'outline'"
            :icon="lockTideye === 'locked' ? 'i-lucide-lock' : 'i-lucide-crosshair'"
            class="shadow-lg w-auto"
            :class="lockTideye === 'locked' ? 'bg-primary-600 text-white hover:bg-primary-700' : ''"
            @click="handleCenterToggle"
          >
            {{ lockTideye === 'locked' ? 'Locked' : lockTideye === 'center' ? 'Centered' : 'Center' }}
          </UButton>
        </div>

        <!-- Right Panel: Passages and Queries -->
        <PassageRightPanel
          :passages="mutablePassages"
          :selected-passage="mutableSelectedPassage"
          :is-loading="isLoading"
          :error="error"
          @select="handlePassageSelect"
          @close="() => {}"
        />
      </div>
    </div>

    <!-- Details Panel (Collapsible) -->
    <div v-if="selectedPassage && !isDetailsCollapsed" class="details-panel">
      <div class="details-header-controls">
        <UButton
          icon="i-lucide-x"
          size="xs"
          variant="ghost"
          color="neutral"
          @click="isDetailsCollapsed = true"
        >
          Close
        </UButton>
      </div>
      <PassageDetailsCollapsible :passage="mutableSelectedPassage" :default-expanded="['stats']">
        <template #stats="{ passage }">
          <div class="stats-content">
            <div class="stat-item">
              <span class="stat-label">Distance</span>
              <span class="stat-value">{{ formatDistance(passage.distance) }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Duration</span>
              <span class="stat-value">{{ formatDuration(passage.duration) }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Average Speed</span>
              <span class="stat-value">{{ passage.avgSpeed.toFixed(1) }} kt</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">Max Speed</span>
              <span class="stat-value">{{ passage.maxSpeed.toFixed(1) }} kt</span>
            </div>
          </div>
        </template>
        <template #start-end="{ passage }">
          <div class="location-content">
            <div class="location-item">
              <span class="location-label">Start</span>
              <span class="location-time">{{ formatDateTime(passage.startTime) }}</span>
              <span class="location-coords">{{ passage.startLocation.lat.toFixed(4) }}, {{ passage.startLocation.lon.toFixed(4) }}</span>
            </div>
            <div class="location-item">
              <span class="location-label">End</span>
              <span class="location-time">{{ formatDateTime(passage.endTime) }}</span>
              <span class="location-coords">{{ passage.endLocation.lat.toFixed(4) }}, {{ passage.endLocation.lon.toFixed(4) }}</span>
            </div>
          </div>
        </template>
        <template #performance="{ passage }">
          <div class="performance-content">
            <div class="performance-item">
              <span class="performance-label">Route</span>
              <span class="performance-value">{{ passage.route || 'N/A' }}</span>
            </div>
          </div>
        </template>
        <template #notes="{ passage }">
          <div class="notes-content">
            <p class="text-sm text-gray-500">Notes feature coming soon...</p>
          </div>
        </template>
      </PassageDetailsCollapsible>
    </div>

    <!-- Timeline Strip at Bottom -->
    <PassageTimelineEnhanced
      v-if="selectedPassage"
      :passage="mutableSelectedPassage"
      :show-speed-graph="true"
      :current-time="currentTime"
      @time-update="handleTimeUpdate"
    />
  </div>
</template>

<script setup lang="ts">
import type { Passage, PassageLocation } from '~/types/passage'
import { usePassageData } from '~/composables/usePassageData'
import { formatDuration, formatDistance } from '~/utils/mapHelpers'

const route = useRoute()
const router = useRouter()

const { passages, selectedPassage, isLoading, error, loadAllPassages, selectPassage, loadPassageById } =
  usePassageData()

// Layer and view mode state
const layers = ref({
  track: true,
  speed: false,
  wind: false,
  currents: false,
  waypoints: false,
  ais: false,
})

const viewMode = ref<'clean' | 'analysis' | 'playback'>('clean')

// Details panel state
const isDetailsCollapsed = ref(true)

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

// Vessels and lock state
const showVessels = ref(true)
const lockTideye = ref<'center' | 'locked' | null>(null)

// Export handlers
const handleExportGPX = () => {
  // TODO: Implement GPX export
  console.log('Export GPX')
}

const handleExportGeoJSON = () => {
  // TODO: Implement GeoJSON export
  console.log('Export GeoJSON')
}

const handleGenerateReport = () => {
  // TODO: Implement PDF report generation
  console.log('Generate Report')
}

const formatDateTime = (dateString: string) => {
  return new Date(dateString).toLocaleString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

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

const handleMapFit = () => {
  if (mapRef.value && 'handleZoomToFit' in mapRef.value) {
    ;(mapRef.value as any).handleZoomToFit()
  }
}

const handleMapCenter = () => {
  if (mapRef.value && 'handleCenterOnTideye' in mapRef.value) {
    ;(mapRef.value as any).handleCenterOnTideye()
  }
}

const handleCenterToggle = () => {
  // Toggle lockTideye: null -> 'center' -> 'locked' -> null
  if (lockTideye.value === null) {
    lockTideye.value = 'center'
    handleMapCenter()
  } else if (lockTideye.value === 'center') {
    lockTideye.value = 'locked'
    handleMapCenter()
  } else {
    lockTideye.value = null
  }
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

const mapRef = ref<{ 
  centerMapOnTime: (timestamp: string) => void
  handleZoomToFit?: () => void
  handleCenterOnTideye?: () => void
} | null>(null)

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
.app-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.main-layout {
  display: flex;
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.map-container {
  flex: 1;
  position: relative;
  min-width: 0;
}

.map-controls-top {
  position: fixed;
  top: 1rem;
  right: 4rem;
  z-index: 1002;
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.25rem;
  pointer-events: auto;
}

.details-panel {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  width: 400px;
  max-width: 90vw;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  border-left: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.05);
  z-index: 999;
  overflow-y: auto;
  padding: 1rem;
}

.details-header-controls {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 1rem;
}

.stats-content {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.stat-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.stat-label {
  font-size: 0.75rem;
  color: #6b7280;
  font-weight: 500;
}

.stat-value {
  font-size: 1.125rem;
  font-weight: 600;
  color: #111827;
}

.location-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.location-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.location-label {
  font-size: 0.75rem;
  color: #6b7280;
  font-weight: 500;
}

.location-time {
  font-size: 0.875rem;
  color: #111827;
  font-weight: 500;
}

.location-coords {
  font-size: 0.75rem;
  color: #9ca3af;
  font-family: ui-monospace, monospace;
}

.performance-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.performance-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.performance-label {
  font-size: 0.75rem;
  color: #6b7280;
  font-weight: 500;
}

.performance-value {
  font-size: 0.875rem;
  color: #111827;
}

.notes-content {
  padding: 1rem 0;
}

@media (max-width: 1024px) {
  .main-layout {
    flex-direction: column;
  }

  .details-panel {
    position: fixed;
    top: auto;
    bottom: 0;
    left: 0;
    right: 0;
    width: 100%;
    max-width: 100%;
    max-height: 50vh;
    border-left: none;
    border-top: 1px solid rgba(0, 0, 0, 0.08);
  }
}
</style>

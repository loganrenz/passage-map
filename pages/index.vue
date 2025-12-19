<template>
  <div class="app-container">
    <!-- Main Layout: Sidebar + Map -->
    <div class="main-layout">
      <!-- Mobile Menu Toggle Button -->
      <UButton
        icon="i-lucide-menu"
        size="lg"
        color="white"
        variant="solid"
        class="mobile-menu-toggle"
        @click="isSidebarOpen = true"
      />

      <!-- Left Sidebar -->
      <div 
        class="sidebar-wrapper" 
        :class="{ 'sidebar-open': isSidebarOpen }"
      >
        <div class="sidebar-overlay" @click="isSidebarOpen = false"></div>
        <div 
          class="sidebar-content" 
          :class="{ 'swiping': sidebarSwipeStart !== null }"
          :style="sidebarSwipeOffset !== 0 ? { transform: `translateX(${sidebarSwipeOffset}px)` } : {}"
          @touchstart="handleSidebarTouchStart"
          @touchmove="handleSidebarTouchMove"
          @touchend="handleSidebarTouchEnd"
        >
          <div class="sidebar-header">
            <h2 class="sidebar-title">Menu</h2>
            <UButton
              icon="i-lucide-x"
              size="sm"
              variant="ghost"
              color="neutral"
              class="sidebar-close"
              title="Close menu"
              @click="isSidebarOpen = false"
            />
          </div>
          <PassageSidebar
            :passage="mutableSelectedPassage"
            :passages="mutablePassages"
            :selected-passage="mutableSelectedPassage"
            :is-loading="isLoading"
            :error="error"
            :layers="layers"
            :view-mode="viewMode"
            @update:layers="layers = $event"
            @update:view-mode="viewMode = $event"
            @export-gpx="handleExportGPX"
            @export-geojson="handleExportGeoJSON"
            @generate-report="handleGenerateReport"
            @select-passage="handlePassageSelect"
          />
        </div>
      </div>

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

        <!-- Map Controls: Positioned to the bottom left -->
        <div class="map-controls-bottom-left">
          <!-- Vessels Button -->
          <UButton
            v-if="selectedPassage"
            :variant="showVessels ? 'solid' : 'outline'"
            size="sm"
            icon="i-lucide-ship"
            class="shadow-lg map-control-btn"
            :class="showVessels ? 'bg-primary-600 text-white hover:bg-primary-700' : ''"
            @click="showVessels = !showVessels"
          >
            <span class="map-control-label">Vessels</span>
          </UButton>
          
          <!-- Fit Button -->
          <UButton
            size="sm"
            variant="outline"
            icon="i-lucide-maximize"
            class="shadow-lg map-control-btn"
            @click="handleMapFit"
          >
            <span class="map-control-label">Fit</span>
          </UButton>
          
          <!-- Center Button -->
          <UButton
            v-if="selectedPassage && currentTime"
            size="sm"
            :variant="lockTideye === 'locked' ? 'solid' : lockTideye === 'center' ? 'soft' : 'outline'"
            :icon="lockTideye === 'locked' ? 'i-lucide-lock' : 'i-lucide-crosshair'"
            class="shadow-lg map-control-btn"
            :class="lockTideye === 'locked' ? 'bg-primary-600 text-white hover:bg-primary-700' : ''"
            @click="handleCenterToggle"
          >
            <span class="map-control-label">{{ lockTideye === 'locked' ? 'Locked' : lockTideye === 'center' ? 'Centered' : 'Center' }}</span>
          </UButton>
        </div>
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
      :show-passage-info="true"
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

// Mobile sidebar state
const isSidebarOpen = ref(false)

// Swipe gesture state for mobile menu
const sidebarSwipeStart = ref<{ x: number; y: number; time: number } | null>(null)
const sidebarSwipeOffset = ref(0)
const SWIPE_THRESHOLD = 50 // Minimum distance to trigger close

const handleSidebarTouchStart = (e: TouchEvent) => {
  if (!isSidebarOpen.value) return
  const touch = e.touches[0]
  sidebarSwipeStart.value = { x: touch.clientX, y: touch.clientY, time: Date.now() }
  sidebarSwipeOffset.value = 0
}

const handleSidebarTouchMove = (e: TouchEvent) => {
  if (!isSidebarOpen.value || !sidebarSwipeStart.value) return
  
  const touch = e.touches[0]
  const deltaX = touch.clientX - sidebarSwipeStart.value.x
  const deltaY = Math.abs(touch.clientY - sidebarSwipeStart.value.y)
  
  // Only allow horizontal swipe (not vertical scrolling)
  if (Math.abs(deltaX) > deltaY && deltaX < 0) {
    sidebarSwipeOffset.value = Math.max(deltaX, -280) // Limit to sidebar max width
    e.preventDefault()
  }
}

const handleSidebarTouchEnd = () => {
  if (!isSidebarOpen.value || !sidebarSwipeStart.value) return
  
  const shouldClose = sidebarSwipeOffset.value < -SWIPE_THRESHOLD
  
  if (shouldClose) {
    isSidebarOpen.value = false
  }
  
  // Reset
  sidebarSwipeStart.value = null
  sidebarSwipeOffset.value = 0
}

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
const lockTideye = ref<'center' | 'locked' | null>('locked')

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

  // Close mobile sidebar after selection
  isSidebarOpen.value = false

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

  // If no passage is selected and we have passages, automatically select the first one
  if (!selectedPassage.value && passages.value.length > 0) {
    const firstPassage = toMutablePassage(passages.value[0])
    await handlePassageSelect(firstPassage, true)
  }
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
  position: relative;
}

/* Mobile Menu Toggle */
.mobile-menu-toggle {
  display: none;
  position: fixed;
  top: 1rem;
  left: 1rem;
  z-index: 1001;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Sidebar Wrapper */
.sidebar-wrapper {
  position: relative;
  display: block;
}

.sidebar-overlay {
  display: none;
}

.sidebar-content {
  height: 100%;
  width: 100%;
}

.sidebar-header {
  display: none;
}

/* Map Container */
.map-container {
  flex: 1;
  position: relative;
  min-width: 0;
}

.map-controls-bottom-left {
  position: fixed;
  top: 1rem;
  right: 1rem;
  z-index: 1002;
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
  pointer-events: auto;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 0.5rem;
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(0, 0, 0, 0.08);
}

.map-control-btn {
  white-space: nowrap;
}

.map-control-label {
  display: inline;
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

/* Tablet and below */
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
    max-height: 60vh;
    border-left: none;
    border-top: 1px solid rgba(0, 0, 0, 0.08);
    border-radius: 1rem 1rem 0 0;
  }

  .stats-content {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.75rem;
  }
}

/* Mobile styles */
@media (max-width: 768px) {
  .mobile-menu-toggle {
    display: block;
  }

  .sidebar-wrapper {
    position: fixed;
    inset: 0;
    z-index: 1000;
    pointer-events: none;
    transition: opacity 0.2s ease;
    display: block;
  }

  .sidebar-wrapper:not(.sidebar-open) {
    opacity: 0;
    visibility: hidden;
  }

  .sidebar-wrapper.sidebar-open {
    opacity: 1;
    visibility: visible;
    pointer-events: auto;
  }

  .sidebar-overlay {
    display: block;
  }

  .sidebar-content {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 75%;
    max-width: 280px;
    background: white;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.15);
    transform: translateX(-100%);
    transition: transform 0.3s ease;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch;
    touch-action: pan-y;
  }

  .sidebar-wrapper.sidebar-open .sidebar-content:not(.swiping) {
    transform: translateX(0);
  }

  /* Disable transition during swipe gesture */
  .sidebar-content.swiping {
    transition: none !important;
  }

  .sidebar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    border-bottom: 1px solid rgba(0, 0, 0, 0.08);
    background: rgba(255, 255, 255, 0.98);
    backdrop-filter: blur(10px);
    position: sticky;
    top: 0;
    z-index: 10;
  }


  .sidebar-title {
    font-size: 1.125rem;
    font-weight: 600;
    color: #111827;
    margin: 0;
  }

  .map-controls-bottom-left {
    top: auto;
    bottom: calc(240px + 0.75rem);
    right: auto;
    left: 0.75rem;
    padding: 0.25rem;
    gap: 0.25rem;
    flex-wrap: wrap;
    max-width: calc(100vw - 5rem);
  }

  .map-control-label {
    display: none;
  }

  .map-control-btn {
    min-width: 36px !important;
    min-height: 36px !important;
    padding: 0.375rem !important;
    font-size: 0.75rem;
  }

  .details-panel {
    max-height: 70vh;
    padding: 0.75rem;
  }

  .stats-content {
    grid-template-columns: 1fr;
    gap: 0.5rem;
  }

  .stat-value {
    font-size: 1rem;
  }
}

/* Small mobile */
@media (max-width: 640px) {
  .mobile-menu-toggle {
    top: 0.75rem;
    left: 0.75rem;
    min-width: 44px;
    min-height: 44px;
  }

  .map-controls-bottom-left {
    bottom: calc(260px + 0.5rem);
    left: 0.5rem;
    padding: 0.25rem;
    gap: 0.25rem;
  }

  .map-control-btn {
    min-width: 32px !important;
    min-height: 32px !important;
    padding: 0.25rem !important;
    font-size: 0.6875rem;
  }

  .details-panel {
    max-height: 75vh;
    padding: 0.5rem;
  }
}
</style>

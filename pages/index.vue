<template>
  <div class="app-container">
    <!-- Main Layout: Sidebar + Map -->
    <div class="main-layout flex flex-1 min-h-0 overflow-hidden relative flex-col md:flex-row">
      <!-- Mobile Menu Toggle Button -->
      <UButton v-if="!isSidebarOpen" icon="i-lucide-menu" size="lg" color="neutral" variant="solid"
        class="mobile-menu-toggle block md:hidden fixed top-4 left-4 z-1001 shadow-lg" @click="isSidebarOpen = true"
        @touchstart.prevent="isSidebarOpen = true" />

      <!-- Left Sidebar -->
      <div class="sidebar-wrapper relative block md:w-80 md:shrink-0" :class="{ 'sidebar-open': isSidebarOpen }">
        <div class="sidebar-overlay hidden md:hidden" :class="{ 'block': isSidebarOpen }" @click="isSidebarOpen = false"
          @touchstart.prevent="isSidebarOpen = false"></div>
        <div class="sidebar-content h-full w-full md:relative" :class="{ 'swiping': sidebarSwipeStart !== null }"
          :style="sidebarSwipeOffset !== 0 ? { transform: `translateX(${sidebarSwipeOffset}px)` } : {}"
          @touchstart="handleSidebarTouchStart" @touchmove="handleSidebarTouchMove" @touchend="handleSidebarTouchEnd">
          <div class="sidebar-header hidden md:hidden">
            <h2 class="sidebar-title">Menu</h2>
            <UButton icon="i-lucide-x" size="sm" variant="ghost" color="neutral" class="sidebar-close"
              title="Close menu" @click="isSidebarOpen = false" @touchstart.prevent="isSidebarOpen = false" />
          </div>
          <PassageSidebar :passage="mutableSelectedPassage" :passages="mutablePassages"
            :selected-passage="mutableSelectedPassage" :is-loading="isLoading" :error="error" :layers="layers"
            :view-mode="viewMode" @update:layers="(newLayers) => { if (newLayers) layers = newLayers }"
            @update:view-mode="viewMode = $event" @export-gpx="handleExportGPX" @export-geojson="handleExportGeoJSON"
            @generate-report="handleGenerateReport" @select-passage="handlePassageSelect" />
        </div>
      </div>

      <!-- Map Canvas -->
      <div class="map-container flex-1 relative min-w-0 overflow-visible">
        <PassageMap ref="mapRef" :passages="displayedPassages" :selected-passage="mutableSelectedPassage"
          :auto-fit="true" :current-time="currentTime" :speed-color-coding="layers.speed"
          :show-features="layers.waypoints" :show-vessels="showVessels" :lock-tideye="lockTideye"
          @update:lock-tideye="lockTideye = $event" @time-update="handleTimeUpdate" />

        <!-- Map Controls: Positioned to the bottom left -->
        <div class="map-controls-bottom-left">
          <!-- Vessels Button -->
          <UButton v-if="selectedPassage" :variant="showVessels ? 'solid' : 'outline'" size="sm" icon="i-lucide-ship"
            class="map-control-btn shadow-lg"
            :class="showVessels ? 'bg-primary-600 text-white hover:bg-primary-700' : ''"
            @click="showVessels = !showVessels" @touchstart.prevent="showVessels = !showVessels">
            <span class="map-control-label">Vessels</span>
          </UButton>

          <!-- Fit Button -->
          <UButton size="sm" variant="outline" icon="i-lucide-maximize" class="map-control-btn shadow-lg"
            @click="handleMapFit" @touchstart.prevent="handleMapFit">
            <span class="map-control-label">Fit</span>
          </UButton>

          <!-- Center Button -->
          <UButton v-if="selectedPassage && currentTime" size="sm"
            :variant="lockTideye === 'locked' ? 'solid' : lockTideye === 'center' ? 'soft' : 'outline'"
            :icon="lockTideye === 'locked' ? 'i-lucide-lock' : 'i-lucide-crosshair'" class="map-control-btn shadow-lg"
            :class="lockTideye === 'locked' ? 'bg-primary-600 text-white hover:bg-primary-700' : ''"
            @click="handleCenterToggle" @touchstart.prevent="handleCenterToggle">
            <span class="map-control-label">{{ lockTideye === 'locked' ? 'Locked' : lockTideye === 'center' ? 'Centered'
              : 'Center' }}</span>
          </UButton>
        </div>
      </div>
    </div>

    <!-- Details Panel (Collapsible) -->
    <div v-if="selectedPassage && !isDetailsCollapsed" class="details-panel">
      <div class="details-header-controls flex justify-end mb-4">
        <UButton icon="i-lucide-x" size="xs" variant="ghost" color="neutral" @click="isDetailsCollapsed = true"
          @touchstart.prevent="isDetailsCollapsed = true">
          Close
        </UButton>
      </div>
      <PassageDetailsCollapsible :passage="mutableSelectedPassage" :default-expanded="['stats']">
        <template #stats="{ passage }">
          <div class="stats-content grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="stat-item flex flex-col gap-1">
              <span class="stat-label text-xs text-gray-500 font-medium">Distance</span>
              <span class="stat-value text-lg font-semibold text-gray-900">{{ formatDistance(passage.distance) }}</span>
            </div>
            <div class="stat-item flex flex-col gap-1">
              <span class="stat-label text-xs text-gray-500 font-medium">Duration</span>
              <span class="stat-value text-lg font-semibold text-gray-900">{{ formatDuration(passage.duration) }}</span>
            </div>
            <div class="stat-item flex flex-col gap-1">
              <span class="stat-label text-xs text-gray-500 font-medium">Average Speed</span>
              <span class="stat-value text-lg font-semibold text-gray-900">{{ passage.avgSpeed.toFixed(1) }} kt</span>
            </div>
            <div class="stat-item flex flex-col gap-1">
              <span class="stat-label text-xs text-gray-500 font-medium">Max Speed</span>
              <span class="stat-value text-lg font-semibold text-gray-900">{{ passage.maxSpeed.toFixed(1) }} kt</span>
            </div>
          </div>
        </template>
        <template #start-end="{ passage }">
          <div class="location-content flex flex-col gap-4">
            <div class="location-item flex flex-col gap-1">
              <span class="location-label text-xs text-gray-500 font-medium">Start</span>
              <span class="location-time text-sm text-gray-900 font-medium">{{ formatDateTime(passage.startTime)
              }}</span>
              <span class="location-coords text-xs text-gray-400 font-mono">{{ passage.startLocation.lat.toFixed(4) }},
                {{
                  passage.startLocation.lon.toFixed(4) }}</span>
            </div>
            <div class="location-item flex flex-col gap-1">
              <span class="location-label text-xs text-gray-500 font-medium">End</span>
              <span class="location-time text-sm text-gray-900 font-medium">{{ formatDateTime(passage.endTime) }}</span>
              <span class="location-coords text-xs text-gray-400 font-mono">{{ passage.endLocation.lat.toFixed(4) }}, {{
                passage.endLocation.lon.toFixed(4) }}</span>
            </div>
          </div>
        </template>
        <template #performance="{ passage }">
          <div class="performance-content flex flex-col gap-4">
            <div class="performance-item flex flex-col gap-1">
              <span class="performance-label text-xs text-gray-500 font-medium">Route</span>
              <span class="performance-value text-sm text-gray-900">{{ passage.route || 'N/A' }}</span>
            </div>
          </div>
        </template>
        <template #notes>
          <div class="notes-content py-4">
            <p class="text-sm text-gray-500">Notes feature coming soon...</p>
          </div>
        </template>
      </PassageDetailsCollapsible>
    </div>

    <!-- Timeline Strip at Bottom -->
    <div v-if="selectedPassage" class="timeline-wrapper relative w-full"
      :class="{ 'timeline-hidden': !isTimelineVisible }">
      <div class="timeline-toggle-container">
        <UButton :icon="isTimelineVisible ? 'i-lucide-chevron-down' : 'i-lucide-chevron-up'" size="xs" variant="ghost"
          color="neutral" class="timeline-toggle-btn" :title="isTimelineVisible ? 'Hide timeline' : 'Show timeline'"
          @click="isTimelineVisible = !isTimelineVisible"
          @touchstart.prevent="isTimelineVisible = !isTimelineVisible" />
      </div>
      <!-- Always render component to preserve playback state, use CSS to hide -->
      <div class="timeline-content-wrapper">
        <PassageTimelineEnhanced :passage="mutableSelectedPassage" :show-speed-graph="true" :current-time="currentTime"
          :show-passage-info="true" @time-update="handleTimeUpdate" />
      </div>
    </div>
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

// Timeline visibility state
const isTimelineVisible = ref(true)

// Mobile sidebar state
const isSidebarOpen = ref(false)

// Swipe gesture state for mobile menu
const sidebarSwipeStart = ref<{ x: number; y: number; time: number } | null>(null)
const sidebarSwipeOffset = ref(0)
const SWIPE_THRESHOLD = 50 // Minimum distance to trigger close

const handleSidebarTouchStart = (e: TouchEvent) => {
  if (!isSidebarOpen.value) return
  const touch = e.touches[0]
  if (!touch) return
  sidebarSwipeStart.value = { x: touch.clientX, y: touch.clientY, time: Date.now() }
  sidebarSwipeOffset.value = 0
}

const handleSidebarTouchMove = (e: TouchEvent) => {
  if (!isSidebarOpen.value || !sidebarSwipeStart.value) return

  const touch = e.touches[0]
  if (!touch) return
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
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ; (mapRef.value as any).handleZoomToFit()
  }
}

const handleMapCenter = () => {
  if (mapRef.value && 'handleCenterOnTideye' in mapRef.value) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ; (mapRef.value as any).handleCenterOnTideye()
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

// Reserved for future use when PassageLocations is added to details panel
const _handleLocationsUpdate = (locations: Passage['locations']) => {
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

// Handle Safari address bar show/hide
const handleViewportResize = () => {
  // Force a reflow to update viewport height when Safari address bar appears/disappears
  const vh = window.innerHeight * 0.01
  document.documentElement.style.setProperty('--vh', `${vh}px`)
}

// Track scroll listener for cleanup
let scrollHeightChecker: (() => void) | null = null

onMounted(async () => {
  await loadAllPassages()

  // Check if there's a passage ID in the URL after loading passages
  await loadPassageFromUrl()

  // If no passage is selected and we have passages, automatically select the first one
  if (!selectedPassage.value && passages.value.length > 0 && passages.value[0]) {
    const firstPassage = toMutablePassage(passages.value[0])
    await handlePassageSelect(firstPassage, true)
  }

  // Handle Safari address bar show/hide
  handleViewportResize()
  window.addEventListener('resize', handleViewportResize)
  window.addEventListener('orientationchange', handleViewportResize)
  // Also listen for scroll events which can trigger address bar show/hide
  let lastHeight = window.innerHeight
  scrollHeightChecker = () => {
    const currentHeight = window.innerHeight
    if (Math.abs(currentHeight - lastHeight) > 50) {
      // Significant height change, likely address bar
      handleViewportResize()
      lastHeight = currentHeight
    }
  }
  window.addEventListener('scroll', scrollHeightChecker, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('resize', handleViewportResize)
  window.removeEventListener('orientationchange', handleViewportResize)
  if (scrollHeightChecker) {
    window.removeEventListener('scroll', scrollHeightChecker)
  }
})
</script>

<style scoped>
/* App container - viewport height handling for iOS Safari */
.app-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  height: 100dvh;
  height: calc(var(--vh, 1vh) * 100);
  height: -webkit-fill-available;
  width: 100vw;
  overflow: hidden;
  position: fixed;
  min-height: -webkit-fill-available;
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* Mobile menu toggle - iOS jittering prevention */
.mobile-menu-toggle {
  -webkit-transform: translateZ(0);
  transform: translateZ(0);
  will-change: transform;
}

/* Sidebar overlay - only visible on mobile when open */
.sidebar-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

/* Sidebar content - mobile slide animation */
.sidebar-content {
  -webkit-overflow-scrolling: touch;
  touch-action: pan-y;
  -webkit-transform: translateZ(0);
  transform: translateZ(0);
  will-change: transform;
}

.sidebar-content.swiping {
  transition: none !important;
}

/* Desktop: sidebar should always be visible */
@media (min-width: 769px) {
  .sidebar-wrapper {
    opacity: 1 !important;
    visibility: visible !important;
    pointer-events: auto !important;
    position: relative !important;
  }

  .sidebar-content {
    transform: none !important;
    position: relative !important;
  }

  .sidebar-overlay {
    display: none !important;
  }

  .sidebar-header {
    display: none !important;
  }
}

/* Mobile: hide sidebar when not open */
@media (max-width: 768px) {
  .sidebar-wrapper:not(.sidebar-open) {
    opacity: 0;
    visibility: hidden;
  }

  .sidebar-wrapper.sidebar-open .sidebar-content:not(.swiping) {
    transform: translateX(0);
  }
}

/* Map container - iOS jittering prevention */
.map-container {
  -webkit-transform: translateZ(0);
  transform: translateZ(0);
  will-change: transform;
}

/* Map controls positioning */
.map-controls-bottom-left {
  position: fixed;
  bottom: 1rem;
  left: 1rem;
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
  display: flex;
  align-items: center;
  justify-content: center;
}

.map-control-btn :deep(svg) {
  margin: 0;
}

.map-control-label {
  display: inline;
}

/* Details panel */
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

/* Timeline wrapper */
.timeline-content-wrapper {
  transition: transform 0.3s ease, opacity 0.3s ease, max-height 0.3s ease;
  max-height: 1000px;
  overflow: hidden;
}

.timeline-wrapper.timeline-hidden .timeline-content-wrapper {
  transform: translateY(100%);
  opacity: 0;
  max-height: 0;
  pointer-events: none;
  /* Keep component mounted but visually hidden */
  visibility: hidden;
}

.timeline-toggle-container {
  position: absolute;
  top: -2.5rem;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1003;
  display: flex;
  justify-content: center;
  pointer-events: auto;
  opacity: 1;
  visibility: visible;
}

.timeline-toggle-btn {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 0.5rem 0.5rem 0 0;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
  min-width: 44px;
  min-height: 36px;
  padding: 0.375rem 0.75rem;
  touch-action: manipulation;
  -webkit-tap-highlight-color: transparent;
  -webkit-transform: translateZ(0);
  transform: translateZ(0);
  will-change: transform;
}

/* Desktop styles */
@media (min-width: 769px) {
  .map-controls-bottom-left {
    z-index: 1001;
  }

  .map-container :deep(div[class*="mapkitjs"]) {
    z-index: 1003;
  }

  .sidebar-wrapper.sidebar-open .mobile-menu-toggle {
    display: none !important;
  }
}

/* Tablet styles */
@media (max-width: 1024px) {
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
}

/* Mobile styles */
@media (max-width: 768px) {
  .sidebar-wrapper {
    position: fixed;
    inset: 0;
    z-index: 1000;
    pointer-events: none;
    transition: opacity 0.2s ease;
    -webkit-transform: translateZ(0);
    transform: translateZ(0);
    will-change: transform, opacity;
  }

  .sidebar-wrapper.sidebar-open {
    opacity: 1;
    visibility: visible;
    pointer-events: auto;
  }

  .sidebar-content {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 75%;
    max-width: 280px;
    background: #ffffff;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.15);
    transform: translateX(-100%);
    transition: transform 0.3s ease;
    overflow-y: auto;
  }

  .sidebar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    border-bottom: 1px solid rgba(0, 0, 0, 0.08);
    background: #ffffff;
    position: sticky;
    top: 0;
    z-index: 10;
  }

  .map-controls-bottom-left {
    position: absolute !important;
    bottom: 0.5rem !important;
    left: 0.5rem !important;
    padding: 0.25rem;
    gap: 0.25rem;
    flex-wrap: wrap;
    max-width: calc(50vw - 1rem);
    z-index: 1001 !important;
  }

  .map-container :deep(div[class*="mapkitjs"]) {
    z-index: 1003;
  }

  .map-control-label {
    display: none;
  }

  .map-control-btn {
    min-width: 32px !important;
    min-height: 32px !important;
    padding: 0.25rem !important;
    font-size: 0.75rem;
  }

  .map-control-btn :deep(svg) {
    margin: 0 !important;
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

  .timeline-toggle-container {
    top: -2rem;
  }

  .timeline-toggle-btn {
    min-width: 40px;
    min-height: 32px;
    padding: 0.25rem 0.5rem;
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
    padding: 0.25rem;
    gap: 0.25rem;
  }

  .map-control-btn {
    min-width: 28px !important;
    min-height: 28px !important;
    font-size: 0.6875rem;
  }

  .details-panel {
    max-height: 75vh;
    padding: 0.5rem;
  }
}
</style>

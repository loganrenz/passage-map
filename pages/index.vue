<template>
  <div class="min-h-screen bg-gray-50">
    <UContainer class="py-2 sm:py-4 px-2 sm:px-4">
      <div>
        <div class="mb-3 sm:mb-4">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Passage Map</h1>
              <p class="text-sm sm:text-base text-gray-600 mt-1">Visualize vessel passages on an interactive map</p>
            </div>
            <ClientOnly>
              <UButton variant="ghost" icon="i-lucide-database" to="/queries" class="hidden sm:flex">
                Queries
              </UButton>
              <template #fallback>
                <div class="hidden sm:flex"></div>
              </template>
            </ClientOnly>
          </div>
        </div>

        <!-- Mobile: Tab Navigation -->
        <ClientOnly>
          <div v-if="isMounted" class="lg:hidden mb-4">
            <div class="flex gap-1.5 sm:gap-2 bg-gray-100 p-1 rounded-lg">
              <button v-for="tab in tabs" :key="tab.value" :class="[
                'flex-1 flex items-center justify-center gap-1 sm:gap-1.5 px-2 sm:px-3 py-2 rounded-md transition-all touch-manipulation',
                'min-h-[44px]',
                activeTab === tab.value
                  ? 'bg-white text-primary-600 shadow-sm'
                  : 'text-gray-600 hover:text-gray-900'
              ]" :aria-label="tab.label" :title="tab.label" @click="activeTab = tab.value">
                <UIcon :name="tab.icon" class="w-4 h-4 sm:w-5 sm:h-5 flex-shrink-0" />
                <span class="text-[10px] sm:text-xs font-medium truncate max-w-[60px] sm:max-w-none">{{ tab.label
                  }}</span>
              </button>
            </div>
          </div>
        </ClientOnly>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-3 sm:gap-4">
          <!-- Sidebar -->
          <div class="lg:col-span-1 space-y-3 sm:space-y-4 lg:block"
            v-show="!isMounted || !isMobile || activeTab === 'list' || activeTab === 'info'">
            <!-- Mobile: Show list tab, Desktop: Always show -->
            <div class="lg:block" v-show="!isMounted || !isMobile || activeTab === 'list'">
              <UCard>
                <template #header>
                  <h2 class="text-base sm:text-lg font-semibold">Passages</h2>
                </template>
                <PassageList :passages="mutablePassages" :selected-passage="mutableSelectedPassage"
                  :is-loading="isLoading" :error="error" @select="handlePassageSelect" />
              </UCard>
            </div>

            <!-- Mobile: Show info tab, Desktop: Always show -->
            <div class="lg:block" v-show="!isMounted || !isMobile || activeTab === 'info'">
              <PassageInfo :passage="mutableSelectedPassage" />
            </div>
          </div>

          <!-- Map -->
          <div class="lg:col-span-2 lg:block" v-show="!isMounted || !isMobile || activeTab === 'map'">
            <UCard class="h-full">
              <template #header>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2 sm:gap-0">
                  <h2 class="text-base sm:text-lg font-semibold">Map</h2>
                  <div class="flex gap-2 w-full sm:w-auto">
                    <UButton v-if="selectedPassage" color="neutral" variant="ghost" size="sm"
                      class="flex-1 sm:flex-none" @click="clearSelection">
                      Clear
                    </UButton>
                    <UButton v-if="passages.length > 0" color="primary" variant="ghost" size="sm"
                      class="flex-1 sm:flex-none" @click="showAllPassages">
                      Show All
                    </UButton>
                  </div>
                </div>
              </template>
              <div class="h-[400px] sm:h-[500px] lg:h-[600px]">
                <PassageMap :passages="displayedPassages" :selected-passage="mutableSelectedPassage" :auto-fit="true"
                  :current-time="currentTime" />
              </div>
              <!-- Timeline Viewer -->
              <div v-if="selectedPassage" class="mt-3 sm:mt-4">
                <PassageTimeline :passage="mutableSelectedPassage!" @time-update="handleTimeUpdate" />
              </div>
            </UCard>
          </div>
        </div>
      </div>
    </UContainer>
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

// Flag to prevent infinite loops when updating URL
const isUpdatingFromUrl = ref(false)

// Mobile tab navigation
// Initialize with safe defaults for SSR
const isMobile = ref(false)
const activeTab = ref('map')
const isMounted = ref(false)

const tabs = [
  { label: 'Map', value: 'map', icon: 'i-lucide-map' },
  { label: 'List', value: 'list', icon: 'i-lucide-list' },
  { label: 'Details', value: 'info', icon: 'i-lucide-info' },
]

const checkMobile = () => {
  if (typeof window !== 'undefined') {
    isMobile.value = window.innerWidth < 1024 // lg breakpoint
    if (!isMobile.value) {
      activeTab.value = 'map' // Reset to map view on desktop
    }
  }
}

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

  // On mobile, switch to map tab when a passage is selected
  if (isMobile.value) {
    activeTab.value = 'map'
  }
}

const clearSelection = async () => {
  selectPassage(null)
  currentTime.value = null
  // Remove passage from URL
  await router.push({ query: {} })
}

const showAllPassages = async () => {
  selectPassage(null)
  currentTime.value = null
  // Remove passage from URL
  await router.push({ query: {} })
}

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
  isMounted.value = true
  await loadAllPassages()
  checkMobile()
  if (typeof window !== 'undefined') {
    window.addEventListener('resize', checkMobile)
  }

  // Check if there's a passage ID in the URL after loading passages
  await loadPassageFromUrl()
})

onUnmounted(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('resize', checkMobile)
  }
})
</script>

<template>
  <!-- Collapsed state - show button to expand -->
  <div v-if="isClosed" class="passage-right-panel-collapsed">
    <UButton icon="i-lucide-chevron-left" size="sm" variant="solid" color="primary" @click="handleClose"
      class="shadow-lg">
      {{ tabNames[activeTab] }}
    </UButton>
  </div>

  <!-- Expanded state -->
  <div v-else class="passage-right-panel" :class="{ 'has-timeline': selectedPassage }">
    <UCard class="w-full h-full flex flex-col shadow-xl border-0"
      style="display: flex; flex-direction: column; height: 100%; position: relative;">
      <!-- Disclosure Triangle in Upper Right -->
      <UButton icon="i-lucide-chevron-right" size="xs" variant="ghost" color="gray"
        class="absolute top-2 right-2 z-10 shrink-0" @click="handleClose" />

      <!-- Header with Tabs -->
      <div
        class="flex items-center border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900/50 px-3 pt-4 pb-2 pr-10">
        <div class="flex gap-1 flex-1">
          <UButton :variant="activeTab === 'passages' ? 'solid' : 'ghost'" size="xs" @click="activeTab = 'passages'"
            class="flex-1 font-medium"
            :class="activeTab === 'passages' ? 'bg-primary-600 text-white' : 'text-gray-600 dark:text-gray-400'">
            Passages
          </UButton>
          <UButton :variant="activeTab === 'queries' ? 'solid' : 'ghost'" size="xs" @click="activeTab = 'queries'"
            class="flex-1 font-medium"
            :class="activeTab === 'queries' ? 'bg-primary-600 text-white' : 'text-gray-600 dark:text-gray-400'">
            Queries
          </UButton>
        </div>
      </div>

      <!-- Tab Content -->
      <div class="tab-content-wrapper">
        <!-- Passages Tab -->
        <div v-if="activeTab === 'passages'" class="tab-content scrollable-content">
          <div class="p-3">
            <PassageList :passages="passages" :selected-passage="selectedPassage" :is-loading="isLoading" :error="error"
              @select="handleSelect" />
          </div>
        </div>

        <!-- Queries Tab -->
        <div v-if="activeTab === 'queries'" class="tab-content scrollable-content">
          <div class="p-3">
            <PassageQueries />
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
  close: []
}>()

// State persistence keys
const STORAGE_KEY_PANEL_CLOSED = 'passage-panel-closed'
const STORAGE_KEY_ACTIVE_TAB = 'passage-panel-active-tab'

// Initialize with consistent defaults (same on server and client)
const activeTab = ref<'passages' | 'queries'>('passages')
const isClosed = ref(false)

// Load persisted state only on client after mount to avoid hydration mismatch
onMounted(() => {
  if (typeof window !== 'undefined') {
    const savedClosed = localStorage.getItem(STORAGE_KEY_PANEL_CLOSED)
    const savedTab = localStorage.getItem(STORAGE_KEY_ACTIVE_TAB)

    if (savedClosed === 'true') {
      isClosed.value = true
    }
    if (savedTab === 'passages' || savedTab === 'queries') {
      activeTab.value = savedTab
    }
  }
})

// Tab names for display
const tabNames = {
  passages: 'Passages',
  queries: 'Queries'
} as const

// Persist state changes
watch(activeTab, (newTab) => {
  if (typeof window !== 'undefined') {
    localStorage.setItem(STORAGE_KEY_ACTIVE_TAB, newTab)
  }
})

watch(isClosed, (closed) => {
  if (typeof window !== 'undefined') {
    localStorage.setItem(STORAGE_KEY_PANEL_CLOSED, String(closed))
  }
})

const handleSelect = (passage: Passage) => {
  emit('select', passage)
}

const handleClose = () => {
  isClosed.value = !isClosed.value
  emit('close')
}
</script>

<style scoped>
.passage-right-panel {
  position: absolute;
  top: 4rem;
  right: 1rem;
  bottom: 1rem;
  /* Default bottom margin */
  width: 360px;
  max-width: calc(100vw - 2rem);
  height: auto;
  /* Let top and bottom determine height */
  z-index: 1001;
}

.passage-right-panel.has-timeline {
  bottom: 13rem;
  /* Account for timeline at bottom (~200px) + margin when timeline is visible */
}

.passage-right-panel-collapsed {
  position: absolute;
  top: 4rem;
  right: 1rem;
  z-index: 1001;
}

.passage-right-panel :deep(.card) {
  height: 100%;
  max-height: 100%;
  display: flex;
  flex-direction: column;
  border-radius: 0.75rem;
  overflow: hidden;
}

/* Tab content wrapper - critical for scrolling */
.tab-content-wrapper {
  flex: 1 1 0%;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: white;
}

.dark .tab-content-wrapper {
  background: rgb(3 7 18);
  /* gray-950 */
}

.tab-content {
  flex: 1 1 0%;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
}

/* Custom scrollbar for better appearance */
.scrollable-content {
  scrollbar-width: thin;
  scrollbar-color: rgba(156, 163, 175, 0.5) transparent;
  overflow-y: auto !important;
  overflow-x: hidden;
}

.scrollable-content::-webkit-scrollbar {
  width: 8px;
}

.scrollable-content::-webkit-scrollbar-track {
  background: transparent;
  margin: 4px 0;
}

.scrollable-content::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.5);
  border-radius: 4px;
  border: 2px solid transparent;
  background-clip: padding-box;
}

.scrollable-content::-webkit-scrollbar-thumb:hover {
  background-color: rgba(156, 163, 175, 0.7);
}

@media (max-width: 640px) {
  .passage-right-panel {
    width: calc(100vw - 2rem);
    max-height: calc(100vh - 6rem);
  }
}
</style>

<template>
  <div class="passage-sidebar">
    <UAccordion 
      type="multiple" 
      :items="accordionItems"
      class="sidebar-accordion"
    >
      <template #passages>
        <div class="accordion-content">
          <PassageList
            :passages="passages"
            :selected-passage="selectedPassage"
            :is-loading="isLoading"
            :error="error"
            @select="handlePassageSelect"
          />
        </div>
      </template>

      <template #queries>
        <div class="accordion-content">
          <PassageQueries />
        </div>
      </template>

      <template #layers>
        <div class="accordion-content">
          <div class="sidebar-options">
            <label class="sidebar-option">
              <input type="checkbox" :checked="layers.track" @change="updateLayer('track', $event)" />
              <span>Track</span>
            </label>
            <label class="sidebar-option">
              <input type="checkbox" :checked="layers.speed" @change="updateLayer('speed', $event)" />
              <span>Speed (colorized)</span>
            </label>
            <label class="sidebar-option">
              <input type="checkbox" :checked="layers.wind" @change="updateLayer('wind', $event)" />
              <span>Wind</span>
            </label>
            <label class="sidebar-option">
              <input type="checkbox" :checked="layers.currents" @change="updateLayer('currents', $event)" />
              <span>Currents</span>
            </label>
            <label class="sidebar-option">
              <input type="checkbox" :checked="layers.waypoints" @change="updateLayer('waypoints', $event)" />
              <span>Waypoints</span>
            </label>
            <label class="sidebar-option">
              <input type="checkbox" :checked="layers.ais" @change="updateLayer('ais', $event)" disabled />
              <span class="disabled">AIS (future)</span>
            </label>
          </div>
        </div>
      </template>

      <template #view-mode>
        <div class="accordion-content">
          <div class="sidebar-radio-group">
            <label class="sidebar-radio-option">
              <input 
                type="radio" 
                name="viewMode" 
                value="clean" 
                :checked="viewMode === 'clean'"
                @change="updateViewMode('clean')"
              />
              <span>Clean</span>
            </label>
            <label class="sidebar-radio-option">
              <input 
                type="radio" 
                name="viewMode" 
                value="analysis" 
                :checked="viewMode === 'analysis'"
                @change="updateViewMode('analysis')"
              />
              <span>Analysis</span>
            </label>
            <label class="sidebar-radio-option">
              <input 
                type="radio" 
                name="viewMode" 
                value="playback" 
                :checked="viewMode === 'playback'"
                @change="updateViewMode('playback')"
              />
              <span>Playback</span>
            </label>
          </div>
        </div>
      </template>

      <template #tools>
        <div class="accordion-content">
          <div class="sidebar-actions">
            <UButton 
              variant="outline" 
              size="sm" 
              icon="i-lucide-download"
              class="sidebar-action-btn"
              @click="exportGPX"
              @touchstart.prevent="exportGPX"
            >
              Export GPX
            </UButton>
            <UButton 
              variant="outline" 
              size="sm" 
              icon="i-lucide-download"
              class="sidebar-action-btn"
              @click="exportGeoJSON"
              @touchstart.prevent="exportGeoJSON"
            >
              Export GeoJSON
            </UButton>
            <UButton 
              variant="outline" 
              size="sm" 
              icon="i-lucide-file-text"
              class="sidebar-action-btn"
              @click="generateReport"
              @touchstart.prevent="generateReport"
            >
              Generate Report
            </UButton>
          </div>
        </div>
      </template>
    </UAccordion>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import type { AccordionItem } from '@nuxt/ui'

interface Props {
  passage?: Passage | null
  passages?: Passage[]
  selectedPassage?: Passage | null
  isLoading?: boolean
  error?: string | null
  layers?: {
    track: boolean
    speed: boolean
    wind: boolean
    currents: boolean
    waypoints: boolean
    ais: boolean
  }
  viewMode?: 'clean' | 'analysis' | 'playback'
}

const props = withDefaults(defineProps<Props>(), {
  passages: () => [],
  selectedPassage: null,
  isLoading: false,
  error: null,
  layers: () => ({
    track: true,
    speed: false,
    wind: false,
    currents: false,
    waypoints: false,
    ais: false,
  }),
  viewMode: 'clean',
})

const emit = defineEmits<{
  'update:layers': [layers: Props['layers']]
  'update:viewMode': [mode: 'clean' | 'analysis' | 'playback']
  'export-gpx': []
  'export-geojson': []
  'generate-report': []
  'select-passage': [passage: Passage]
}>()

const accordionItems: AccordionItem[] = [
  {
    label: 'Passages',
    icon: 'i-lucide-list',
    slot: 'passages',
    value: 'passages',
  },
  {
    label: 'Passage Queries',
    icon: 'i-lucide-database',
    slot: 'queries',
    value: 'queries',
  },
  {
    label: 'Layers',
    icon: 'i-lucide-layers',
    slot: 'layers',
    value: 'layers',
  },
  {
    label: 'View Mode',
    icon: 'i-lucide-eye',
    slot: 'view-mode',
    value: 'view-mode',
  },
  {
    label: 'Passage Tools',
    icon: 'i-lucide-wrench',
    slot: 'tools',
    value: 'tools',
  },
]

const updateLayer = (layer: keyof NonNullable<Props['layers']>, event: Event) => {
  const target = event.target as HTMLInputElement
  const newLayers = {
    ...props.layers,
    [layer]: target.checked,
  }
  emit('update:layers', newLayers)
}

const updateViewMode = (mode: 'clean' | 'analysis' | 'playback') => {
  emit('update:viewMode', mode)
}

const exportGPX = () => {
  emit('export-gpx')
}

const exportGeoJSON = () => {
  emit('export-geojson')
}

const generateReport = () => {
  emit('generate-report')
}

const handlePassageSelect = (passage: Passage) => {
  emit('select-passage', passage)
}
</script>

<style scoped>
.passage-sidebar {
  width: 320px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-right: 1px solid rgba(0, 0, 0, 0.08);
  padding: 1rem;
  overflow-y: auto;
  height: 100%;
  -webkit-overflow-scrolling: touch;
}

.sidebar-accordion {
  width: 100%;
}

.accordion-content {
  padding: 0.5rem 0;
  max-height: 70vh;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

/* Special handling for passages list to allow more height */
.accordion-content:has(.space-y-3) {
  max-height: 75vh;
}

.sidebar-options {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 0.5rem 0;
  font-size: 0.875rem;
  color: #374151;
  user-select: none;
  min-height: 44px;
  touch-action: manipulation;
}

.sidebar-option:hover {
  color: #111827;
}

.sidebar-option input[type="checkbox"] {
  width: 1.125rem;
  height: 1.125rem;
  cursor: pointer;
  flex-shrink: 0;
}

.sidebar-option .disabled {
  color: #9ca3af;
  font-style: italic;
}

.sidebar-radio-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 0.5rem 0;
  font-size: 0.875rem;
  color: #374151;
  user-select: none;
  min-height: 44px;
  touch-action: manipulation;
}

.sidebar-radio-option:hover {
  color: #111827;
}

.sidebar-radio-option input[type="radio"] {
  width: 1.125rem;
  height: 1.125rem;
  cursor: pointer;
  flex-shrink: 0;
}

.sidebar-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-action-btn {
  width: 100%;
  justify-content: flex-start;
  min-height: 44px;
}

@media (max-width: 1024px) {
  .passage-sidebar {
    width: 100%;
    height: auto;
  }
}

@media (max-width: 768px) {
  .passage-sidebar {
    width: 100%;
    padding: 0 1rem 1rem 1rem;
    background: transparent;
    border-right: none;
  }

  .accordion-content {
    max-height: none;
  }

  .accordion-content:has(.space-y-3) {
    max-height: none;
  }
}
</style>


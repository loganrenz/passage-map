<template>
  <div v-if="passage" class="passage-sidebar">
    <!-- Layers Section -->
    <div class="sidebar-section">
      <h3 class="sidebar-section-title">Layers</h3>
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

    <!-- Visualization Modes -->
    <div class="sidebar-section">
      <h3 class="sidebar-section-title">View Mode</h3>
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

    <!-- Passage Tools -->
    <div class="sidebar-section">
      <h3 class="sidebar-section-title">Passage Tools</h3>
      <div class="sidebar-actions">
        <UButton 
          variant="outline" 
          size="sm" 
          icon="i-lucide-download"
          class="sidebar-action-btn"
          @click="exportGPX"
        >
          Export GPX
        </UButton>
        <UButton 
          variant="outline" 
          size="sm" 
          icon="i-lucide-download"
          class="sidebar-action-btn"
          @click="exportGeoJSON"
        >
          Export GeoJSON
        </UButton>
        <UButton 
          variant="outline" 
          size="sm" 
          icon="i-lucide-file-text"
          class="sidebar-action-btn"
          @click="generateReport"
        >
          Generate Report
        </UButton>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'

interface Props {
  passage?: Passage | null
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
}>()

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
</script>

<style scoped>
.passage-sidebar {
  width: 280px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-right: 1px solid rgba(0, 0, 0, 0.08);
  padding: 1.5rem;
  overflow-y: auto;
  height: 100%;
}

.sidebar-section {
  margin-bottom: 2rem;
}

.sidebar-section:last-child {
  margin-bottom: 0;
}

.sidebar-section-title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #6b7280;
  margin-bottom: 0.75rem;
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
  padding: 0.375rem 0;
  font-size: 0.875rem;
  color: #374151;
  user-select: none;
}

.sidebar-option:hover {
  color: #111827;
}

.sidebar-option input[type="checkbox"] {
  width: 1rem;
  height: 1rem;
  cursor: pointer;
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
  padding: 0.375rem 0;
  font-size: 0.875rem;
  color: #374151;
  user-select: none;
}

.sidebar-radio-option:hover {
  color: #111827;
}

.sidebar-radio-option input[type="radio"] {
  width: 1rem;
  height: 1rem;
  cursor: pointer;
}

.sidebar-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sidebar-action-btn {
  width: 100%;
  justify-content: flex-start;
}

@media (max-width: 1024px) {
  .passage-sidebar {
    width: 100%;
    height: auto;
    border-right: none;
    border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  }
}
</style>


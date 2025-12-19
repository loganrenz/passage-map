<template>
  <div v-if="passage" class="timeline-enhanced">
    <!-- Playback Controls -->
    <div class="timeline-controls">
      <UButton
        :icon="isPlaying ? 'i-heroicons-pause' : 'i-heroicons-play'"
        size="sm"
        color="primary"
        variant="solid"
        @click="togglePlayback"
      />
      <div class="speed-controls">
        <UButton
          v-for="option in speedOptions"
          :key="option.value"
          size="xs"
          :color="playbackSpeed === option.value ? 'primary' : 'neutral'"
          :variant="playbackSpeed === option.value ? 'solid' : 'ghost'"
          @click="playbackSpeed = option.value"
        >
          {{ option.label }}
        </UButton>
      </div>
    </div>

    <!-- Data Visualization -->
    <div class="timeline-data">
      <div class="data-row" v-if="showSpeedGraph">
        <div class="data-label">Speed</div>
        <div class="data-graph" ref="speedGraphRef" @mousemove="handleGraphHover($event, 'speed')" @mouseleave="hoverData = null">
          <svg :width="graphWidth" :height="graphHeight" class="graph-svg">
            <path
              :d="speedPath"
              fill="none"
              stroke="#3b82f6"
              stroke-width="2"
              class="graph-line"
            />
            <rect
              v-if="hoverData"
              :x="hoverData.x - 2"
              y="0"
              width="4"
              :height="graphHeight"
              fill="rgba(59, 130, 246, 0.2)"
              class="graph-hover-line"
            />
          </svg>
        </div>
      </div>
    </div>

    <!-- Time Display and Slider -->
    <div class="timeline-scrubbing">
      <div class="time-display">
        <span class="current-time">{{ formatTime(currentTimestamp) }}</span>
        <span class="time-range">{{ formatTime(passage.startTime) }} → {{ formatTime(passage.endTime) }}</span>
      </div>
      <div class="slider-container">
        <USlider
          v-model="currentTimeValue"
          :min="timeRange.start"
          :max="timeRange.end"
          :step="stepSize"
          :disabled="!passage"
          @update:model-value="handleTimeChange"
        />
        <!-- Hover tooltip -->
        <div v-if="hoverData" class="hover-tooltip" :style="{ left: hoverData.x + 'px' }">
          <div class="tooltip-content">
            <div class="tooltip-time">{{ formatFullTime(hoverData.time) }}</div>
            <div v-if="hoverData.speed" class="tooltip-metric">
              SOG: {{ hoverData.speed.toFixed(1) }} kt
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { getTimeRange, calculateSpeed } from '~/utils/mapHelpers'

interface Props {
  passage?: Passage | null
  showSpeedGraph?: boolean
  currentTime?: string | null
}

const props = withDefaults(defineProps<Props>(), {
  showSpeedGraph: true,
  currentTime: null,
})

const emit = defineEmits<{
  'time-update': [timestamp: string]
}>()

const isPlaying = ref(false)
const playbackSpeed = ref(1)
const animationFrameId = ref<number | null>(null)
const lastUpdateTime = ref<number>(0)
const speedGraphRef = ref<HTMLElement | null>(null)
const hoverData = ref<{ x: number; time: string; speed?: number } | null>(null)

const graphWidth = ref(400)
const graphHeight = 40

const BASELINE_SPEED = 1800

const speedOptions = [
  { label: '1x', value: 1 },
  { label: '2x', value: 2 },
  { label: '4x', value: 4 },
  { label: '8x', value: 8 },
] as const

const actualPlaybackSpeed = computed(() => {
  return BASELINE_SPEED * playbackSpeed.value
})

const timeRange = computed(() => {
  if (!props.passage) {
    return { start: 0, end: 0 }
  }
  return getTimeRange(props.passage)
})

const stepSize = computed(() => {
  const range = timeRange.value.end - timeRange.value.start
  return Math.min(1000, Math.max(100, Math.floor(range / 1000)))
})

const currentTimeValue = ref(0)

const currentTimestamp = computed(() => {
  const value = currentTimeValue.value
  if (typeof value !== 'number' || isNaN(value)) {
    return new Date().toISOString()
  }
  const date = new Date(value)
  if (isNaN(date.getTime())) {
    return new Date().toISOString()
  }
  return date.toISOString()
})

// Calculate speed data for graph
const speedData = computed(() => {
  if (!props.passage?.positions || props.passage.positions.length < 2) {
    return []
  }

  const sortedPositions = [...props.passage.positions].sort((a, b) => {
    return new Date(a._time).getTime() - new Date(b._time).getTime()
  })

  const speeds: Array<{ time: number; speed: number }> = []
  
  for (let i = 0; i < sortedPositions.length - 1; i++) {
    const pos1 = sortedPositions[i]
    const pos2 = sortedPositions[i + 1]
    if (!pos1 || !pos2) continue

    const speed = calculateSpeed(
      pos1.lat,
      pos1.lon,
      pos1._time,
      pos2.lat,
      pos2.lon,
      pos2._time
    )

    speeds.push({
      time: new Date(pos1._time).getTime(),
      speed,
    })
  }

  return speeds
})

// Generate SVG path for speed graph
const speedPath = computed(() => {
  if (speedData.value.length === 0) return ''

  const { start, end } = timeRange.value
  const range = end - start
  if (range === 0) return ''

  const maxSpeed = Math.max(...speedData.value.map(d => d.speed), 1)
  const minSpeed = Math.min(...speedData.value.map(d => d.speed), 0)

  const speedRange = maxSpeed - minSpeed || 1

  const points = speedData.value.map((data, index) => {
    const x = ((data.time - start) / range) * graphWidth.value
    const y = graphHeight - ((data.speed - minSpeed) / speedRange) * graphHeight
    return `${index === 0 ? 'M' : 'L'} ${x} ${y}`
  })

  return points.join(' ')
})

const formatTime = (timestamp: string) => {
  if (!timestamp) return '--:--:--'
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) {
    return '--:--:--'
  }
  return date.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  })
}

const formatFullTime = (timestamp: string) => {
  if (!timestamp) return '--:--:--'
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) {
    return '--:--:--'
  }
  return date.toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  })
}

const handleTimeChange = (value: number | number[] | undefined) => {
  const numericValue = Array.isArray(value) ? value[0] : value
  if (typeof numericValue !== 'number' || isNaN(numericValue)) {
    return
  }
  currentTimeValue.value = numericValue
  emit('time-update', currentTimestamp.value)
}

const handleGraphHover = (event: MouseEvent, type: 'speed') => {
  if (!speedGraphRef.value || !props.passage) return

  const rect = speedGraphRef.value.getBoundingClientRect()
  const x = event.clientX - rect.left
  const percent = x / graphWidth.value

  const { start, end } = timeRange.value
  const hoverTime = start + (end - start) * percent

  if (type === 'speed') {
    // Find closest speed data point
    const closest = speedData.value.reduce((prev, curr) => {
      const prevDiff = Math.abs(prev.time - hoverTime)
      const currDiff = Math.abs(curr.time - hoverTime)
      return currDiff < prevDiff ? curr : prev
    }, speedData.value[0])

    hoverData.value = {
      x,
      time: new Date(closest.time).toISOString(),
      speed: closest.speed,
    }
  }
}

const togglePlayback = () => {
  if (isPlaying.value) {
    pausePlayback()
  } else {
    startPlayback()
  }
}

const startPlayback = () => {
  if (!props.passage) return

  isPlaying.value = true
  lastUpdateTime.value = performance.now()

  const update = (timestamp: number) => {
    if (!isPlaying.value) return

    const elapsed = timestamp - lastUpdateTime.value
    const timeDelta = elapsed * actualPlaybackSpeed.value

    const newTime = currentTimeValue.value + timeDelta

    if (newTime >= timeRange.value.end) {
      currentTimeValue.value = timeRange.value.end
      handleTimeChange(timeRange.value.end)
      pausePlayback()
      return
    }

    currentTimeValue.value = newTime
    handleTimeChange(newTime)
    lastUpdateTime.value = timestamp

    animationFrameId.value = requestAnimationFrame(update)
  }

  animationFrameId.value = requestAnimationFrame(update)
}

const pausePlayback = () => {
  isPlaying.value = false
  if (animationFrameId.value !== null) {
    cancelAnimationFrame(animationFrameId.value)
    animationFrameId.value = null
  }
}

// Update graph width on resize
const updateGraphWidth = () => {
  if (speedGraphRef.value) {
    graphWidth.value = speedGraphRef.value.offsetWidth
  }
}

onMounted(() => {
  updateGraphWidth()
  window.addEventListener('resize', updateGraphWidth)
})

onUnmounted(() => {
  pausePlayback()
  window.removeEventListener('resize', updateGraphWidth)
})

// Watch for external time updates (e.g., from map clicks)
watch(
  () => props.currentTime,
  (newTime) => {
    if (newTime && props.passage) {
      const timeValue = Date.parse(newTime)
      const { start, end } = timeRange.value
      
      // Only update if the time is within the passage range and different from current
      if (timeValue >= start && timeValue <= end && timeValue !== currentTimeValue.value) {
        currentTimeValue.value = timeValue
        // Don't emit time-update here to avoid circular updates
        // The parent already knows about this time change
      }
    }
  }
)

// Initialize current time when passage changes
watch(
  () => props.passage,
  (newPassage) => {
    pausePlayback()
    playbackSpeed.value = 1
    if (newPassage && timeRange.value.start > 0 && timeRange.value.end > 0) {
      // Use currentTime prop if available, otherwise start at beginning
      if (props.currentTime) {
        const timeValue = Date.parse(props.currentTime)
        const { start, end } = timeRange.value
        if (timeValue >= start && timeValue <= end) {
          currentTimeValue.value = timeValue
        } else {
          currentTimeValue.value = timeRange.value.start
          handleTimeChange(timeRange.value.start)
        }
      } else {
        currentTimeValue.value = timeRange.value.start
        handleTimeChange(timeRange.value.start)
      }
    } else {
      currentTimeValue.value = 0
    }
    nextTick(() => {
      updateGraphWidth()
    })
  },
  { immediate: true }
)
</script>

<style scoped>
.timeline-enhanced {
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.08);
  padding: 1rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.timeline-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.speed-controls {
  display: flex;
  gap: 0.25rem;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 0.5rem;
  padding: 0.25rem;
  background: rgba(0, 0, 0, 0.02);
}

.timeline-data {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.data-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.data-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7280;
  min-width: 60px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.data-graph {
  flex: 1;
  height: 40px;
  position: relative;
  cursor: crosshair;
}

.graph-svg {
  width: 100%;
  height: 100%;
}

.graph-line {
  stroke-linecap: round;
  stroke-linejoin: round;
}

.graph-hover-line {
  pointer-events: none;
}

.timeline-scrubbing {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.time-display {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.current-time {
  font-size: 0.875rem;
  font-weight: 600;
  color: #111827;
}

.time-range {
  font-size: 0.75rem;
  color: #6b7280;
}

.slider-container {
  position: relative;
  width: 100%;
}

.hover-tooltip {
  position: absolute;
  bottom: 100%;
  margin-bottom: 0.5rem;
  transform: translateX(-50%);
  pointer-events: none;
  z-index: 10;
}

.tooltip-content {
  background: rgba(0, 0, 0, 0.9);
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 0.375rem;
  font-size: 0.75rem;
  white-space: nowrap;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.tooltip-time {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.tooltip-metric {
  color: rgba(255, 255, 255, 0.8);
}

@media (max-width: 640px) {
  .timeline-enhanced {
    padding: 0.875rem 1rem;
  }

  .timeline-controls {
    flex-wrap: wrap;
  }

  .data-label {
    min-width: 50px;
    font-size: 0.6875rem;
  }
}
</style>


<template>
  <div v-if="passage" class="timeline-enhanced">
    <!-- Passage Info (if enabled) -->
    <div v-if="showPassageInfo" class="passage-info-header">
      <h2 class="passage-title">{{ passage.name }}</h2>
      <div class="passage-metrics">
        <span class="passage-metric-item">{{ formatDateRange(passage.startTime, passage.endTime) }}</span>
        <span class="passage-separator">•</span>
        <span class="passage-metric-item">{{ formatDistance(passage.distance) }}</span>
        <span class="passage-separator">•</span>
        <span class="passage-metric-item">{{ formatDuration(passage.duration) }}</span>
        <span class="passage-separator">•</span>
        <span class="passage-metric-item">Avg {{ passage.avgSpeed.toFixed(1) }} kt</span>
        <span class="passage-separator">•</span>
        <span class="passage-metric-item">Max {{ passage.maxSpeed.toFixed(1) }} kt</span>
      </div>
    </div>

    <!-- Playback Controls -->
    <div class="timeline-controls">
      <UButton
        :icon="isPlaying ? 'i-heroicons-pause' : 'i-heroicons-play'"
        size="sm"
        color="primary"
        variant="solid"
        @click="togglePlayback"
        @touchstart.prevent="togglePlayback()"
      />
      <div class="speed-controls">
        <UButton
          v-for="option in speedOptions"
          :key="option.value"
          size="xs"
          :color="playbackSpeed === option.value ? 'primary' : 'neutral'"
          :variant="playbackSpeed === option.value ? 'solid' : 'ghost'"
          @click="playbackSpeed = option.value"
          @touchstart.prevent="playbackSpeed = option.value"
        >
          {{ option.label }}
        </UButton>
      </div>
    </div>

    <!-- Data Visualization -->
    <div class="timeline-data">
      <div class="data-row" v-if="showSpeedGraph">
        <div class="data-label">Speed</div>
        <div class="data-graph touch-manipulation" ref="speedGraphRef" @mousemove="handleGraphHover($event, 'speed')" @mouseleave="hoverData = null" @click="handleGraphClick($event, 'speed')" @touchstart.prevent="handleGraphTouch($event, 'speed')" @touchmove.prevent="handleGraphTouch($event, 'speed')" @touchend.prevent="hoverData = null">
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
      <div class="time-display-container">
        <!-- Current Date/Time -->
        <div class="current-datetime">
          <div class="datetime-label">Current Time</div>
          <div class="datetime-value">{{ formatDateTime(currentTimestamp) }}</div>
        </div>
        
        <!-- Elapsed and Remaining Time -->
        <div class="time-progress">
          <div class="time-progress-item elapsed">
            <div class="time-progress-label">Elapsed</div>
            <div class="time-progress-value">{{ formatElapsedTime }}</div>
          </div>
          <div class="time-progress-separator">/</div>
          <div class="time-progress-item remaining">
            <div class="time-progress-label">Remaining</div>
            <div class="time-progress-value">{{ formatRemainingTime }}</div>
          </div>
        </div>
        
        <!-- Start/End Times -->
        <div class="time-range">
          <div class="time-range-item">
            <span class="time-range-label">Start:</span>
            <span class="time-range-value">{{ formatDateTime(passage.startTime) }}</span>
          </div>
          <div class="time-range-separator">→</div>
          <div class="time-range-item">
            <span class="time-range-label">End:</span>
            <span class="time-range-value">{{ formatDateTime(passage.endTime) }}</span>
          </div>
        </div>
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
import { getTimeRange, calculateSpeed, formatDuration, formatDistance } from '~/utils/mapHelpers'

interface Props {
  passage?: Passage | null
  showSpeedGraph?: boolean
  showPassageInfo?: boolean
  currentTime?: string | null
}

const props = withDefaults(defineProps<Props>(), {
  showSpeedGraph: true,
  showPassageInfo: false,
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
const graphHeight = 32

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

// Generate SVG path for speed graph with smooth curves
const speedPath = computed(() => {
  if (speedData.value.length === 0) return ''

  const { start, end } = timeRange.value
  const range = end - start
  if (range === 0) return ''

  const maxSpeed = Math.max(...speedData.value.map(d => d.speed), 1)
  const minSpeed = Math.min(...speedData.value.map(d => d.speed), 0)

  const speedRange = maxSpeed - minSpeed || 1

  // Convert speed data to x,y coordinates
  const points = speedData.value.map((data) => {
    const x = ((data.time - start) / range) * graphWidth.value
    const y = graphHeight - ((data.speed - minSpeed) / speedRange) * graphHeight
    return { x, y }
  })

  if (points.length === 0) return ''
  if (points.length === 1) return `M ${points[0].x} ${points[0].y}`
  if (points.length === 2) return `M ${points[0].x} ${points[0].y} L ${points[1].x} ${points[1].y}`

  // Use smooth curve interpolation with cubic bezier curves
  let path = `M ${points[0].x} ${points[0].y}`

  // Smoothing factor (0.25 = smooth curves, adjust for more/less smoothing)
  const smoothing = 0.25

  for (let i = 0; i < points.length - 1; i++) {
    const p0 = i > 0 ? points[i - 1] : points[i]
    const p1 = points[i]
    const p2 = points[i + 1]
    const p3 = i < points.length - 2 ? points[i + 2] : p2

    // Calculate control points for smooth cubic bezier curve
    // This creates a Catmull-Rom spline-like effect
    const cp1x = p1.x + (p2.x - p0.x) * smoothing
    const cp1y = p1.y + (p2.y - p0.y) * smoothing
    const cp2x = p2.x - (p3.x - p1.x) * smoothing
    const cp2y = p2.y - (p3.y - p1.y) * smoothing

    path += ` C ${cp1x.toFixed(2)} ${cp1y.toFixed(2)}, ${cp2x.toFixed(2)} ${cp2y.toFixed(2)}, ${p2.x.toFixed(2)} ${p2.y.toFixed(2)}`
  }

  return path
})

const formatTime = (timestamp: string) => {
  if (!timestamp) return '--:--:-- --'
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) {
    return '--:--:-- --'
  }
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  })
}

const formatFullTime = (timestamp: string) => {
  if (!timestamp) return '-- --, ---- --:--:-- --'
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) {
    return '-- --, ---- --:--:-- --'
  }
  return date.toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  })
}

// Format date and time in American standard format (12-hour with AM/PM)
const formatDateTime = (timestamp: string): string => {
  if (!timestamp) return '-- --, ---- --:--:-- --'
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) {
    return '-- --, ---- --:--:-- --'
  }
  
  // Format: "Jan 15, 2024 2:30:45 PM"
  const dateStr = date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
  const timeStr = date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    second: '2-digit',
    hour12: true,
  })
  
  return `${dateStr} ${timeStr}`
}

// Format duration in human-readable format (days, hours, minutes) from milliseconds
const formatDurationFromMs = (milliseconds: number): string => {
  if (milliseconds < 0) return '0 minutes'
  
  const totalSeconds = Math.floor(milliseconds / 1000)
  const days = Math.floor(totalSeconds / 86400)
  const hours = Math.floor((totalSeconds % 86400) / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const seconds = totalSeconds % 60
  
  const parts: string[] = []
  
  if (days > 0) {
    parts.push(`${days} ${days === 1 ? 'day' : 'days'}`)
  }
  if (hours > 0) {
    parts.push(`${hours} ${hours === 1 ? 'hour' : 'hours'}`)
  }
  if (minutes > 0 || parts.length === 0) {
    parts.push(`${minutes} ${minutes === 1 ? 'minute' : 'minutes'}`)
  }
  // Only show seconds if less than a minute
  if (totalSeconds < 60 && seconds > 0) {
    parts.push(`${seconds} ${seconds === 1 ? 'second' : 'seconds'}`)
  }
  
  return parts.join(', ')
}

// Calculate elapsed time (from start to current)
const elapsedTime = computed(() => {
  if (!props.passage) return 0
  const current = currentTimeValue.value
  const start = timeRange.value.start
  return Math.max(0, current - start)
})

// Calculate remaining time (from current to end)
const remainingTime = computed(() => {
  if (!props.passage) return 0
  const current = currentTimeValue.value
  const end = timeRange.value.end
  return Math.max(0, end - current)
})

// Formatted elapsed time
const formatElapsedTime = computed(() => {
  return formatDurationFromMs(elapsedTime.value)
})

// Formatted remaining time
const formatRemainingTime = computed(() => {
  return formatDurationFromMs(remainingTime.value)
})

const formatDateRange = (startTime: string, endTime: string): string => {
  const start = new Date(startTime)
  const end = new Date(endTime)
  
  const formatDate = (date: Date) => {
    const month = date.toLocaleDateString('en-US', { month: 'short' })
    const day = date.getDate()
    const year = date.getFullYear()
    return `${month} ${day}, ${year}`
  }
  
  const startStr = formatDate(start)
  const endStr = formatDate(end)
  
  // If same year, only show year once
  if (start.getFullYear() === end.getFullYear()) {
    const startMonthDay = start.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    const endMonthDay = end.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    return `${startMonthDay} – ${endMonthDay}, ${start.getFullYear()}`
  }
  
  return `${startStr} – ${endStr}`
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

const handleGraphClick = (event: MouseEvent, type: 'speed') => {
  if (!speedGraphRef.value || !props.passage) return

  const rect = speedGraphRef.value.getBoundingClientRect()
  const x = event.clientX - rect.left
  const percent = x / graphWidth.value

  const { start, end } = timeRange.value
  const clickTime = start + (end - start) * percent

  if (type === 'speed') {
    // Find closest speed data point
    const closest = speedData.value.reduce((prev, curr) => {
      const prevDiff = Math.abs(prev.time - clickTime)
      const currDiff = Math.abs(curr.time - clickTime)
      return currDiff < prevDiff ? curr : prev
    }, speedData.value[0])

    // Update timeline to the clicked time
    currentTimeValue.value = closest.time
    handleTimeChange(closest.time)
    
    // Pause playback if it's playing
    if (isPlaying.value) {
      pausePlayback()
    }
  }
}

const handleGraphTouch = (event: TouchEvent, type: 'speed') => {
  if (!speedGraphRef.value || !props.passage) return

  const touch = event.touches[0] || event.changedTouches[0]
  if (!touch) return

  const rect = speedGraphRef.value.getBoundingClientRect()
  const x = touch.clientX - rect.left
  const percent = x / graphWidth.value

  const { start, end } = timeRange.value
  const touchTime = start + (end - start) * percent

  if (type === 'speed') {
    // Find closest speed data point
    const closest = speedData.value.reduce((prev, curr) => {
      const prevDiff = Math.abs(prev.time - touchTime)
      const currDiff = Math.abs(curr.time - touchTime)
      return currDiff < prevDiff ? curr : prev
    }, speedData.value[0])

    // Show hover data
    hoverData.value = {
      x,
      time: new Date(closest.time).toISOString(),
      speed: closest.speed,
    }

    // On touchend, update timeline
    if (event.type === 'touchend') {
      // Update timeline to the touched time
      currentTimeValue.value = closest.time
      handleTimeChange(closest.time)
      
      // Pause playback if it's playing
      if (isPlaying.value) {
        pausePlayback()
      }
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
  padding: 0.625rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.passage-info-header {
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  margin-bottom: 0.25rem;
}

.passage-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #111827;
  line-height: 1.2;
  margin: 0 0 0.375rem 0;
}

.passage-metrics {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
  font-size: 0.75rem;
  color: #6b7280;
}

.passage-metric-item {
  font-weight: 500;
  color: #374151;
}

.passage-separator {
  color: #d1d5db;
}

.timeline-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.speed-controls {
  display: flex;
  gap: 0.375rem;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 0.5rem;
  padding: 0.25rem;
  background: rgba(0, 0, 0, 0.02);
  align-items: center;
}

.speed-controls :deep(button) {
  min-width: 40px;
  min-height: 32px;
  font-weight: 600;
  transition: all 0.2s ease;
}

.timeline-data {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.data-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.data-label {
  font-size: 0.6875rem;
  font-weight: 600;
  color: #6b7280;
  min-width: 50px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.data-graph {
  flex: 1;
  height: 32px;
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
  gap: 0.75rem;
}

.time-display-container {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.current-datetime {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.datetime-label {
  font-size: 0.6875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #6b7280;
}

.datetime-value {
  font-size: 0.9375rem;
  font-weight: 600;
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
  color: #111827;
  letter-spacing: -0.01em;
}

.time-progress {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: rgba(59, 130, 246, 0.05);
  border: 1px solid rgba(59, 130, 246, 0.15);
  border-radius: 0.5rem;
}

.time-progress-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
}

.time-progress-item.elapsed {
  text-align: left;
}

.time-progress-item.remaining {
  text-align: right;
}

.time-progress-label {
  font-size: 0.6875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #6b7280;
}

.time-progress-value {
  font-size: 1rem;
  font-weight: 700;
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
  color: #1e40af;
  letter-spacing: -0.01em;
}

.time-progress-item.remaining .time-progress-value {
  color: #7c3aed;
}

.time-progress-separator {
  font-size: 1.125rem;
  font-weight: 400;
  color: #9ca3af;
  padding: 0 0.25rem;
}

.time-range {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: rgba(0, 0, 0, 0.02);
  border-radius: 0.375rem;
  font-size: 0.75rem;
}

.time-range-item {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  flex: 1;
}

.time-range-item:first-child {
  justify-content: flex-start;
}

.time-range-item:last-child {
  justify-content: flex-end;
}

.time-range-label {
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  font-size: 0.625rem;
  letter-spacing: 0.05em;
}

.time-range-value {
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
  color: #374151;
  font-weight: 500;
}

.time-range-separator {
  color: #9ca3af;
  font-weight: 500;
  padding: 0 0.25rem;
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

@media (max-width: 768px) {
  .timeline-enhanced {
    padding: 0.5rem 1rem;
  }

  .passage-info-header {
    padding-bottom: 0.375rem;
    margin-bottom: 0.25rem;
  }

  .passage-title {
    font-size: 1rem;
    margin-bottom: 0.25rem;
  }

  .passage-metrics {
    font-size: 0.6875rem;
    gap: 0.25rem;
  }

  .passage-separator {
    display: none;
  }

  .passage-metric-item {
    padding: 0.125rem 0.375rem;
    background: rgba(0, 0, 0, 0.04);
    border-radius: 0.25rem;
    margin-right: 0.25rem;
  }

  .timeline-controls {
    flex-wrap: wrap;
    gap: 0.25rem;
  }

  .speed-controls {
    flex: 1;
    min-width: 0;
    padding: 0.25rem;
    gap: 0.375rem;
    justify-content: center;
  }

  .speed-controls :deep(button) {
    min-width: 44px !important;
    min-height: 36px !important;
    padding: 0.375rem 0.5rem !important;
    font-size: 0.75rem !important;
    font-weight: 600 !important;
    flex: 1;
    max-width: 60px;
  }

  .timeline-controls > :deep(button:first-child) {
    min-width: 36px !important;
    min-height: 36px !important;
    padding: 0.375rem !important;
  }

  .timeline-controls > :deep(button:first-child) {
    min-width: 32px !important;
    min-height: 32px !important;
    padding: 0.375rem !important;
  }

  .data-label {
    min-width: 45px;
    font-size: 0.625rem;
  }

  .time-display-container {
    gap: 0.5rem;
  }

  .datetime-value {
    font-size: 0.8125rem;
  }

  .time-progress {
    padding: 0.5rem;
    gap: 0.5rem;
  }

  .time-progress-value {
    font-size: 0.875rem;
  }

  .time-range {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.375rem;
    padding: 0.5rem;
  }

  .time-range-item {
    width: 100%;
    justify-content: space-between !important;
  }

  .time-range-separator {
    display: none;
  }

  .time-range-value {
    font-size: 0.6875rem;
  }
}

@media (max-width: 640px) {
  .timeline-enhanced {
    padding: 0.5rem 0.75rem;
    gap: 0.5rem;
  }

  .passage-info-header {
    padding-bottom: 0.25rem;
    margin-bottom: 0.25rem;
  }

  .passage-title {
    font-size: 0.9375rem;
    margin-bottom: 0.375rem;
  }

  .passage-metrics {
    font-size: 0.625rem;
    gap: 0.25rem;
  }

  .passage-metric-item {
    padding: 0.125rem 0.25rem;
    font-size: 0.625rem;
  }

  .timeline-controls {
    gap: 0.25rem;
  }

  .speed-controls {
    order: 2;
    width: 100%;
    margin-top: 0.375rem;
    padding: 0.375rem;
    gap: 0.5rem;
    justify-content: stretch;
  }

  .speed-controls :deep(button) {
    min-width: 48px !important;
    min-height: 40px !important;
    padding: 0.5rem 0.625rem !important;
    font-size: 0.8125rem !important;
    font-weight: 600 !important;
    flex: 1;
    border-radius: 0.5rem !important;
  }

  .timeline-controls > :deep(button:first-child) {
    min-width: 40px !important;
    min-height: 40px !important;
    padding: 0.5rem !important;
  }

  .data-label {
    min-width: 40px;
    font-size: 0.5625rem;
  }

  .data-graph {
    height: 28px;
  }

  .time-display-container {
    gap: 0.375rem;
  }

  .datetime-label {
    font-size: 0.625rem;
  }

  .datetime-value {
    font-size: 0.75rem;
  }

  .time-progress {
    padding: 0.375rem;
    gap: 0.375rem;
  }

  .time-progress-label {
    font-size: 0.625rem;
  }

  .time-progress-value {
    font-size: 0.75rem;
  }

  .time-progress-separator {
    font-size: 0.875rem;
  }

  .time-range {
    padding: 0.375rem;
    font-size: 0.6875rem;
    gap: 0.25rem;
  }

  .time-range-label {
    font-size: 0.5625rem;
  }

  .time-range-value {
    font-size: 0.625rem;
  }
}
</style>


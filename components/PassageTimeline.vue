<template>
  <div v-if="passage" class="timeline-bar">
    <div class="timeline-content">
      <!-- Play/Pause Button -->
      <UButton
        :icon="isPlaying ? 'i-heroicons-pause' : 'i-heroicons-play'"
        size="sm"
        color="primary"
        variant="solid"
        class="timeline-play-btn"
        @click="togglePlayback"
      />
      
      <!-- Speed Controls -->
      <div class="timeline-speed-controls">
        <UButton
          v-for="option in speedOptions"
          :key="option.value"
          size="xs"
          :color="playbackSpeed === option.value ? 'primary' : 'neutral'"
          :variant="playbackSpeed === option.value ? 'solid' : 'ghost'"
          class="timeline-speed-btn"
          @click="playbackSpeed = option.value"
        >
          {{ option.label }}
        </UButton>
      </div>

      <!-- Time Display -->
      <div class="timeline-time-display">
        <span class="timeline-current-time">{{ formatTime(currentTimestamp) }}</span>
        <span class="timeline-range">
          {{ formatTime(passage.startTime) }} → {{ formatTime(passage.endTime) }}
        </span>
      </div>

      <!-- Slider -->
      <div class="timeline-slider">
        <USlider
          v-model="currentTimeValue"
          :min="timeRange.start"
          :max="timeRange.end"
          :step="stepSize"
          :disabled="!passage"
          @update:model-value="handleTimeChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { getTimeRange } from '~/utils/mapHelpers'

interface Props {
  passage?: Passage | null
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'time-update': [timestamp: string]
}>()

const isPlaying = ref(false)
const playbackSpeed = ref(1)
const animationFrameId = ref<number | null>(null)
const lastUpdateTime = ref<number>(0)

// Baseline: 1 second of playback = 30 minutes of passage time
// 30 minutes = 30 * 60 * 1000 = 1,800,000 ms
// So baseline speed = 1,800,000 ms passage per 1000 ms real = 1800x
const BASELINE_SPEED = 1800 // 1 sec playback = 30 mins passage

// Speed options: multipliers on top of baseline (1 sec = 30 mins)
const speedOptions = [
  { label: '1x', value: 1 },   // 1 sec = 30 mins
  { label: '2x', value: 2 },   // 1 sec = 15 mins
  { label: '4x', value: 4 },   // 1 sec = 7.5 mins
  { label: '8x', value: 8 },   // 1 sec = 3.75 mins
] as const

// Calculate actual playback speed multiplier
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
  // Use 1 second steps, or smaller if passage is very short
  return Math.min(1000, Math.max(100, Math.floor(range / 1000)))
})

const currentTimeValue = ref(0)

const currentTimestamp = computed(() => {
  const value = currentTimeValue.value
  if (typeof value !== 'number' || isNaN(value)) {
    return new Date().toISOString() // Fallback to current time if invalid
  }
  const date = new Date(value)
  if (isNaN(date.getTime())) {
    return new Date().toISOString() // Fallback if date is invalid
  }
  return date.toISOString()
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

const handleTimeChange = (value: number | number[] | undefined) => {
  // USlider can return an array even for single values, so extract the first element
  const numericValue = Array.isArray(value) ? value[0] : value
  if (typeof numericValue !== 'number' || isNaN(numericValue)) {
    return
  }
  currentTimeValue.value = numericValue
  emit('time-update', currentTimestamp.value)
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
      // Reached the end
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

const resetToStart = () => {
  if (props.passage) {
    currentTimeValue.value = timeRange.value.start
    handleTimeChange(timeRange.value.start)
  }
}

// Initialize current time when passage changes
watch(
  () => props.passage,
  (newPassage) => {
    pausePlayback()
    // Reset playback speed to 1x (baseline) when passage changes
    playbackSpeed.value = 1
    if (newPassage && timeRange.value.start > 0 && timeRange.value.end > 0) {
      currentTimeValue.value = timeRange.value.start
      handleTimeChange(timeRange.value.start)
    } else {
      currentTimeValue.value = 0
    }
  },
  { immediate: true }
)

// Cleanup on unmount
onUnmounted(() => {
  // Don't pause playback when component is unmounted (e.g., when timeline is hidden)
  // Playback should continue even when controls are not visible
})

// Expose reset method for parent component
defineExpose({
  resetToStart,
  pausePlayback,
})
</script>

<style scoped>
.timeline-bar {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.1);
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.05);
  padding: 0.75rem 1rem;
  min-height: 60px;
}

.timeline-content {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.timeline-play-btn {
  flex-shrink: 0;
  min-width: 44px;
  min-height: 44px;
}

.timeline-speed-controls {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 0.5rem;
  padding: 0.25rem;
  background: rgba(0, 0, 0, 0.02);
}

.timeline-speed-btn {
  min-width: 40px;
  min-height: 32px;
  font-size: 0.75rem;
  font-weight: 600;
  transition: all 0.2s ease;
}

.timeline-time-display {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  flex-shrink: 0;
  min-width: 140px;
}

.timeline-current-time {
  font-size: 0.875rem;
  font-weight: 600;
  color: #111827;
  line-height: 1.2;
}

.timeline-range {
  font-size: 0.75rem;
  color: #6b7280;
  line-height: 1.2;
}

.timeline-slider {
  flex: 1;
  min-width: 200px;
}

@media (max-width: 640px) {
  .timeline-bar {
    padding: 0.875rem 1rem;
    min-height: 70px;
  }

  .timeline-content {
    gap: 0.5rem;
  }

  .timeline-speed-controls {
    width: 100%;
    padding: 0.375rem;
    gap: 0.5rem;
    margin-top: 0.25rem;
    justify-content: stretch;
  }

  .timeline-speed-btn {
    min-width: 48px !important;
    min-height: 40px !important;
    font-size: 0.8125rem !important;
    flex: 1;
  }

  .timeline-play-btn {
    min-width: 40px;
    min-height: 40px;
  }

  .timeline-time-display {
    min-width: 120px;
  }

  .timeline-current-time {
    font-size: 0.8125rem;
  }

  .timeline-range {
    font-size: 0.6875rem;
  }

  .timeline-slider {
    width: 100%;
    order: -1;
  }
}
</style>

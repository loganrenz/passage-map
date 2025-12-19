<template>
  <UCard v-if="passage">
    <template #header>
      <div class="flex justify-between items-center">
        <h3 class="text-sm font-semibold">Timeline</h3>
        <div class="flex items-center gap-2">
          <UButton :icon="isPlaying ? 'i-heroicons-pause' : 'i-heroicons-play'" size="xs" color="primary"
            variant="ghost" @click="togglePlayback" />
          <div class="flex items-center gap-1 border rounded-md p-0.5">
            <UButton v-for="option in speedOptions" :key="option.value" size="xs"
              :color="playbackSpeed === option.value ? 'primary' : 'neutral'"
              :variant="playbackSpeed === option.value ? 'solid' : 'ghost'" class="min-w-10"
              @click="playbackSpeed = option.value">
              {{ option.label }}
            </UButton>
          </div>
        </div>
      </div>
    </template>

    <div class="space-y-3">
      <!-- Time Display -->
      <div class="flex justify-between items-center text-sm">
        <div>
          <span class="text-gray-500">Current:</span>
          <span class="ml-2 font-medium">{{ formatTime(currentTimestamp) }}</span>
        </div>
        <div class="text-gray-500">
          {{ formatTime(passage.startTime) }} → {{ formatTime(passage.endTime) }}
        </div>
      </div>

      <!-- Slider -->
      <USlider v-model="currentTimeValue" :min="timeRange.start" :max="timeRange.end" :step="stepSize"
        :disabled="!passage" @update:model-value="handleTimeChange" />

      <!-- Progress Bar -->
      <div class="flex items-center gap-2 text-xs text-gray-500">
        <div class="flex-1 bg-gray-200 rounded-full h-1.5 overflow-hidden">
          <div class="bg-primary h-full transition-all duration-100" :style="{ width: `${progressPercentage}%` }" />
        </div>
        <span>{{ Math.round(progressPercentage) }}%</span>
      </div>
    </div>
  </UCard>
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

const progressPercentage = computed(() => {
  if (!props.passage || timeRange.value.end === timeRange.value.start) {
    return 0
  }
  return ((currentTimeValue.value - timeRange.value.start) / (timeRange.value.end - timeRange.value.start)) * 100
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
  pausePlayback()
})

// Expose reset method for parent component
defineExpose({
  resetToStart,
  pausePlayback,
})
</script>

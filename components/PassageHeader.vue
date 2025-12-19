<template>
  <div v-if="passage" class="passage-header">
    <div class="header-content">
      <h1 class="header-title">{{ passage.name }}</h1>
      <div class="header-metrics">
        <span class="header-date">{{ formatDateRange(passage.startTime, passage.endTime) }}</span>
        <span class="header-separator">•</span>
        <span class="header-metric">{{ formatDistance(passage.distance) }}</span>
        <span class="header-separator">•</span>
        <span class="header-metric">{{ formatDuration(passage.duration) }}</span>
        <span class="header-separator">•</span>
        <span class="header-metric">Avg {{ passage.avgSpeed.toFixed(1) }} kt</span>
        <span class="header-separator">•</span>
        <span class="header-metric">Max {{ passage.maxSpeed.toFixed(1) }} kt</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { formatDuration, formatDistance } from '~/utils/mapHelpers'

interface Props {
  passage?: Passage | null
}

defineProps<Props>()

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
</script>

<style scoped>
.passage-header {
  position: sticky;
  top: 0;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.header-content {
  padding: 1rem 1.5rem;
  max-width: 100%;
}

.header-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
  line-height: 1.3;
  margin-bottom: 0.5rem;
}

.header-metrics {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
  font-size: 0.875rem;
  color: #6b7280;
}

.header-date {
  font-weight: 500;
  color: #374151;
}

.header-separator {
  color: #d1d5db;
}

.header-metric {
  font-weight: 500;
  color: #374151;
}

@media (max-width: 768px) {
  .header-content {
    padding: 0.875rem 1rem;
  }

  .header-title {
    font-size: 1.25rem;
  }

  .header-metrics {
    font-size: 0.8125rem;
    gap: 0.5rem;
  }
}
</style>


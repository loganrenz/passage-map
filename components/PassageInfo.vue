<template>
    <div v-if="passage" class="passage-info-compact">
        <!-- Route -->
        <div class="info-section">
            <span class="info-label">Route:</span>
            <span class="info-value">{{ passage.route }}</span>
        </div>

        <div class="info-divider"></div>

        <!-- Stats Grid -->
        <div class="info-stats-grid">
            <div class="info-stat">
                <span class="info-stat-label">Duration</span>
                <span class="info-stat-value">{{ formatDuration(passage.duration) }}</span>
            </div>
            <div class="info-stat">
                <span class="info-stat-label">Distance</span>
                <span class="info-stat-value">{{ formatDistance(passage.distance) }}</span>
            </div>
            <div class="info-stat">
                <span class="info-stat-label">Avg Speed</span>
                <span class="info-stat-value">{{ passage.avgSpeed.toFixed(1) }} kts</span>
            </div>
            <div class="info-stat">
                <span class="info-stat-label">Max Speed</span>
                <span class="info-stat-value">{{ passage.maxSpeed.toFixed(1) }} kts</span>
            </div>
        </div>

        <div class="info-divider"></div>

        <!-- Start/End -->
        <div class="info-location">
            <div class="info-location-item">
                <span class="info-label">Start:</span>
                <span class="info-value">{{ formatDateTime(passage.startTime) }}</span>
                <span class="info-coords">{{ passage.startLocation.lat.toFixed(4) }}, {{ passage.startLocation.lon.toFixed(4) }}</span>
            </div>
            <div class="info-location-item">
                <span class="info-label">End:</span>
                <span class="info-value">{{ formatDateTime(passage.endTime) }}</span>
                <span class="info-coords">{{ passage.endLocation.lat.toFixed(4) }}, {{ passage.endLocation.lon.toFixed(4) }}</span>
            </div>
        </div>

        <!-- Optional fields -->
        <div v-if="passage.filename || passage.description">
            <div class="info-divider"></div>
            <div v-if="passage.filename" class="info-section">
                <span class="info-label">Filename:</span>
                <span class="info-value font-mono">{{ passage.filename }}</span>
            </div>
            <div v-if="passage.description" class="info-section">
                <span class="info-label">Description:</span>
                <span class="info-value">{{ passage.description }}</span>
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

const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    })
}
</script>

<style scoped>
.passage-info-compact {
    padding: 0.5rem 0;
}

.info-section {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    padding: 0.5rem 0;
}

.info-label {
    font-size: 0.75rem;
    font-weight: 500;
    color: #6b7280;
    line-height: 1.4;
}

.info-value {
    font-size: 0.8125rem;
    color: #111827;
    line-height: 1.4;
    word-break: break-word;
}

.info-divider {
    height: 1px;
    background: rgba(0, 0, 0, 0.08);
    margin: 0.5rem 0;
}

.info-stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 0.75rem;
    padding: 0.5rem 0;
}

.info-stat {
    display: flex;
    flex-direction: column;
    gap: 0.125rem;
}

.info-stat-label {
    font-size: 0.6875rem;
    color: #6b7280;
    line-height: 1.3;
}

.info-stat-value {
    font-size: 0.875rem;
    font-weight: 600;
    color: #111827;
    line-height: 1.3;
}

.info-location {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 0.5rem 0;
}

.info-location-item {
    display: flex;
    flex-direction: column;
    gap: 0.125rem;
}

.info-coords {
    font-size: 0.6875rem;
    color: #9ca3af;
    font-family: ui-monospace, monospace;
    line-height: 1.3;
}

@media (max-width: 768px) {
    .info-stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 640px) {
    .info-stats-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 0.5rem;
    }

    .info-stat-value {
        font-size: 0.8125rem;
    }
}
</style>

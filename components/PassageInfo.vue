<template>
    <UCard v-if="passage">
        <template #header>
            <div class="flex justify-between items-center gap-2">
                <h2 class="text-base sm:text-lg font-semibold flex-1 truncate">{{ passage.name }}</h2>
                <UBadge color="primary" variant="subtle" class="flex-shrink-0 text-xs">Details</UBadge>
            </div>
        </template>

        <div class="space-y-3 sm:space-y-4">
            <div>
                <h3 class="text-xs sm:text-sm font-medium text-gray-500 mb-1 sm:mb-2">Route</h3>
                <p class="text-xs sm:text-sm break-words">{{ passage.route }}</p>
            </div>

            <USeparator />

            <div class="grid grid-cols-2 gap-3 sm:gap-4">
                <div>
                    <p class="text-xs text-gray-500 mb-1">Duration</p>
                    <p class="text-sm sm:text-base font-semibold">{{ formatDuration(passage.duration) }}</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500 mb-1">Distance</p>
                    <p class="text-sm sm:text-base font-semibold">{{ formatDistance(passage.distance) }}</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500 mb-1">Avg Speed</p>
                    <p class="text-sm sm:text-base font-semibold">{{ passage.avgSpeed.toFixed(1) }} kts</p>
                </div>
                <div>
                    <p class="text-xs text-gray-500 mb-1">Max Speed</p>
                    <p class="text-sm sm:text-base font-semibold">{{ passage.maxSpeed.toFixed(1) }} kts</p>
                </div>
            </div>

            <USeparator />

            <div>
                <h3 class="text-xs sm:text-sm font-medium text-gray-500 mb-1 sm:mb-2">Start</h3>
                <p class="text-xs sm:text-sm text-gray-600 mb-1">
                    {{ formatDateTime(passage.startTime) }}
                </p>
                <p class="text-xs text-gray-500 break-all">
                    {{ passage.startLocation.lat.toFixed(4) }}, {{ passage.startLocation.lon.toFixed(4) }}
                </p>
            </div>

            <div>
                <h3 class="text-xs sm:text-sm font-medium text-gray-500 mb-1 sm:mb-2">End</h3>
                <p class="text-xs sm:text-sm text-gray-600 mb-1">
                    {{ formatDateTime(passage.endTime) }}
                </p>
                <p class="text-xs text-gray-500 break-all">
                    {{ passage.endLocation.lat.toFixed(4) }}, {{ passage.endLocation.lon.toFixed(4) }}
                </p>
            </div>

            <USeparator v-if="passage.description || passage.filename" />

            <div v-if="passage.filename">
                <h3 class="text-xs sm:text-sm font-medium text-gray-500 mb-1 sm:mb-2">Filename</h3>
                <p class="text-xs sm:text-sm text-gray-600 break-all font-mono">{{ passage.filename }}</p>
            </div>

            <div v-if="passage.description">
                <h3 class="text-xs sm:text-sm font-medium text-gray-500 mb-1 sm:mb-2">Description</h3>
                <p class="text-xs sm:text-sm text-gray-600 break-words">{{ passage.description }}</p>
            </div>
        </div>
    </UCard>

    <UCard v-else>
        <div class="text-center py-8">
            <UIcon name="i-lucide-map" class="text-4xl text-gray-300 mb-2" />
            <p class="text-sm text-gray-500">Select a passage to view details</p>
        </div>
    </UCard>
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

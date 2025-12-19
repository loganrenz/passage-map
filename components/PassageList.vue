<template>
    <div class="space-y-2">
        <UInput v-model="searchQuery" placeholder="Search passages..." icon="i-lucide-search" class="mb-4" size="sm" />

        <div v-if="isLoading" class="text-center py-8">
            <UIcon name="i-lucide-loader-2" class="animate-spin text-2xl" />
            <p class="mt-2 text-sm text-gray-500">Loading passages...</p>
        </div>

        <div v-else-if="error" class="text-center py-8">
            <UAlert color="error" :title="error" />
        </div>

        <div v-else-if="filteredPassages.length === 0" class="text-center py-8">
            <p class="text-sm text-gray-500">No passages found</p>
        </div>

        <div v-else class="space-y-2 overflow-y-auto -mx-1 px-1">
            <UCard v-for="passage in filteredPassages" :key="passage.id" :class="[
                'cursor-pointer transition-all touch-manipulation',
                'min-h-[60px] sm:min-h-[70px]',
                selectedPassage?.id === passage.id
                    ? 'ring-2 ring-primary-500 bg-primary-50'
                    : 'hover:bg-gray-50 active:bg-gray-100',
            ]" @click="selectPassage(passage)">
                <div class="p-3 sm:p-4">
                    <div class="flex justify-between items-start mb-2 gap-2">
                        <h3 class="font-semibold text-sm sm:text-base flex-1">{{ passage.name }}</h3>
                        <UBadge v-if="selectedPassage?.id === passage.id" color="primary" variant="subtle"
                            class="flex-shrink-0">
                            Selected
                        </UBadge>
                    </div>
                    <p class="text-xs sm:text-sm text-gray-500 mb-2">{{ formatDate(passage.startTime) }}</p>
                    <div class="flex flex-wrap gap-3 sm:gap-4 text-xs sm:text-sm text-gray-600">
                        <span class="flex items-center gap-1">
                            <UIcon name="i-lucide-clock" class="w-3 h-3" />
                            {{ formatDuration(passage.duration) }}
                        </span>
                        <span class="flex items-center gap-1">
                            <UIcon name="i-lucide-navigation" class="w-3 h-3" />
                            {{ formatDistance(passage.distance) }}
                        </span>
                        <span class="flex items-center gap-1">
                            <UIcon name="i-lucide-gauge" class="w-3 h-3" />
                            {{ passage.avgSpeed.toFixed(1) }} kts
                        </span>
                    </div>
                    <p class="text-xs sm:text-sm text-gray-400 mt-2 line-clamp-2">{{ passage.route }}</p>
                </div>
            </UCard>
        </div>
    </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { formatDuration, formatDistance } from '~/utils/mapHelpers'

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
}>()

const searchQuery = ref('')

const filteredPassages = computed(() => {
    if (!searchQuery.value) {
        return props.passages
    }

    const query = searchQuery.value.toLowerCase()
    return props.passages.filter(
        (passage) =>
            passage.name.toLowerCase().includes(query) ||
            passage.description.toLowerCase().includes(query) ||
            passage.route.toLowerCase().includes(query)
    )
})

const selectPassage = (passage: Passage) => {
    emit('select', passage)
}

const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    })
}
</script>

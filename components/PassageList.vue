<template>
    <div class="space-y-3">
        <UInput 
            v-model="searchQuery" 
            placeholder="Search passages..." 
            icon="i-lucide-search" 
            class="mb-3" 
            size="sm"
            :ui="{ 
                base: 'relative block w-full disabled:cursor-not-allowed disabled:opacity-75 focus:outline-none border-0',
                rounded: 'rounded-lg',
                placeholder: 'placeholder-gray-400 dark:placeholder-gray-500',
                size: { sm: 'text-sm' },
                gap: { sm: 'gap-1.5' },
                padding: { sm: 'px-3 py-2' },
                color: {
                    white: {
                        outline: 'shadow-sm bg-white dark:bg-gray-900 text-gray-900 dark:text-white ring-1 ring-inset ring-gray-300 dark:ring-gray-700 focus:ring-2 focus:ring-primary-500 dark:focus:ring-primary-400'
                    }
                }
            }"
        />

        <div v-if="isLoading" class="text-center py-12">
            <UIcon name="i-lucide-loader-2" class="animate-spin text-3xl text-primary-500 mx-auto" />
            <p class="mt-3 text-sm text-gray-500 dark:text-gray-400">Loading passages...</p>
        </div>

        <div v-else-if="error" class="text-center py-8">
            <UAlert color="error" :title="error" variant="soft" />
        </div>

        <div v-else-if="filteredPassages.length === 0" class="text-center py-12">
            <UIcon name="i-lucide-inbox" class="text-4xl text-gray-300 dark:text-gray-600 mx-auto mb-2" />
            <p class="text-sm text-gray-500 dark:text-gray-400">No passages found</p>
        </div>

        <div v-else class="space-y-3">
            <div
                v-for="passage in filteredPassages"
                :key="passage.id"
                :class="[
                    'cursor-pointer transition-all duration-200 touch-manipulation',
                    'rounded-lg border bg-white dark:bg-gray-900',
                    'hover:shadow-md hover:scale-[1.01]',
                    selectedPassage?.id === passage.id
                        ? 'ring-2 ring-primary-500 ring-offset-2 bg-gradient-to-br from-primary-50 to-primary-100/50 dark:from-primary-950/50 dark:to-primary-900/30 border-primary-300 dark:border-primary-700 shadow-lg'
                        : 'hover:bg-gray-50 dark:hover:bg-gray-800/50 border-gray-200 dark:border-gray-700 shadow-sm',
                ]"
                @click="selectPassage(passage)"
            >
                <div class="p-4">
                    <div class="flex justify-between items-start mb-3 gap-2">
                        <h3 class="font-semibold text-sm leading-snug flex-1 text-gray-900 dark:text-gray-100">
                            {{ passage.name }}
                        </h3>
                        <UBadge
                            v-if="selectedPassage?.id === passage.id"
                            color="primary"
                            variant="solid"
                            class="shrink-0 text-xs font-semibold px-2 py-0.5 shadow-sm"
                        >
                            Selected
                        </UBadge>
                    </div>
                    <div class="flex items-center gap-2 mb-3">
                        <UIcon name="i-lucide-calendar" class="w-3.5 h-3.5 text-gray-400 shrink-0" />
                        <p class="text-xs text-gray-600 dark:text-gray-400 font-medium">
                            {{ formatDate(passage.startTime) }}
                        </p>
                    </div>
                    <div class="grid grid-cols-3 gap-2 mb-3 p-2.5 bg-gray-50/50 dark:bg-gray-800/30 rounded-md">
                        <div class="flex flex-col gap-1">
                            <div class="flex items-center gap-1.5 text-xs text-gray-500 dark:text-gray-400">
                                <UIcon name="i-lucide-clock" class="w-3.5 h-3.5" />
                                <span class="font-medium">Duration</span>
                            </div>
                            <span class="text-xs font-semibold text-gray-900 dark:text-gray-100">
                                {{ formatDuration(passage.duration) }}
                            </span>
                        </div>
                        <div class="flex flex-col gap-1">
                            <div class="flex items-center gap-1.5 text-xs text-gray-500 dark:text-gray-400">
                                <UIcon name="i-lucide-navigation" class="w-3.5 h-3.5" />
                                <span class="font-medium">Distance</span>
                            </div>
                            <span class="text-xs font-semibold text-gray-900 dark:text-gray-100">
                                {{ formatDistance(passage.distance) }}
                            </span>
                        </div>
                        <div class="flex flex-col gap-1">
                            <div class="flex items-center gap-1.5 text-xs text-gray-500 dark:text-gray-400">
                                <UIcon name="i-lucide-gauge" class="w-3.5 h-3.5" />
                                <span class="font-medium">Speed</span>
                            </div>
                            <span class="text-xs font-semibold text-gray-900 dark:text-gray-100">
                                {{ passage.avgSpeed.toFixed(1) }} kts
                            </span>
                        </div>
                    </div>
                    <p v-if="passage.route" class="text-xs text-gray-500 dark:text-gray-400 mt-3 pt-3 border-t border-gray-200 dark:border-gray-700 line-clamp-2 leading-relaxed">
                        {{ passage.route }}
                    </p>
                </div>
            </div>
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

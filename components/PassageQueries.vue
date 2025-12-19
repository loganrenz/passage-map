<template>
    <div class="space-y-3">
        <div class="flex items-center justify-between gap-2">
            <UInput v-model="searchQuery" placeholder="Search queries..." icon="i-lucide-search" size="sm" class="flex-1" />
            <UButton v-if="!isLoading" icon="i-lucide-refresh-cw" variant="ghost" size="sm" @click="loadQueries" />
        </div>

        <div v-if="isLoading" class="text-center py-8">
            <UIcon name="i-lucide-loader-2" class="animate-spin text-2xl" />
            <p class="mt-2 text-sm text-gray-500">Loading queries...</p>
        </div>

        <div v-else-if="error" class="text-center py-8">
            <UAlert color="error" :title="error" />
        </div>

        <div v-else-if="filteredQueries.length === 0" class="text-center py-8">
            <p class="text-sm text-gray-500">No queries found</p>
        </div>

        <div v-else class="space-y-3 max-h-[500px] overflow-y-auto -mx-1 px-1">
            <UCard v-for="query in filteredQueries" :key="query.id" class="hover:bg-gray-50 transition-colors">
                <div class="p-4">
                    <div class="flex justify-between items-start mb-3 gap-2">
                        <div class="flex-1">
                            <h3 class="font-semibold text-sm mb-1">
                                {{ query.description || 'Unnamed Query' }}
                            </h3>
                            <p class="text-xs text-gray-500">
                                {{ formatDate(query.timestamp) }}
                            </p>
                        </div>
                        <div class="flex gap-2 flex-shrink-0">
                            <UButton icon="i-lucide-copy" variant="ghost" size="xs" @click="copyQuery(query.query)">
                                Copy
                            </UButton>
                            <UButton v-if="query.passageId" icon="i-lucide-external-link" variant="ghost" size="xs"
                                @click="viewPassage(query.passageId!)">
                                View Passage
                            </UButton>
                        </div>
                    </div>

                    <div v-if="query.passageId" class="mb-3">
                        <UBadge color="primary" variant="subtle" size="sm">
                            Passage: {{ query.passageId }}
                        </UBadge>
                        {{ query.passageFilename }}
                        <UBadge v-if="query.passageFilename" color="neutral" variant="subtle" size="sm" class="ml-2">
                        </UBadge>
                    </div>

                    <div class="bg-gray-50 rounded-md p-3 mb-3">
                        <div class="flex justify-between items-center mb-2">
                            <span class="text-xs font-mono text-gray-600">Flux Query</span>
                            <UButton icon="i-lucide-copy" variant="ghost" size="xs" @click="copyQuery(query.query)">
                                Copy Query
                            </UButton>
                        </div>
                        <pre
                            class="text-xs font-mono text-gray-800 overflow-x-auto whitespace-pre-wrap break-words">{{ query.query }}</pre>
                    </div>

                    <div v-if="query.parameters && Object.keys(query.parameters).length > 0" class="mt-3">
                        <details class="text-sm">
                            <summary class="cursor-pointer text-gray-600 hover:text-gray-800">
                                Parameters
                            </summary>
                            <div class="mt-2 pl-4 border-l-2 border-gray-200">
                                <pre
                                    class="text-xs font-mono text-gray-700 overflow-x-auto">{{ JSON.stringify(query.parameters, null, 2) }}</pre>
                            </div>
                        </details>
                    </div>
                </div>
            </UCard>
        </div>
    </div>
</template>

<script setup lang="ts">
interface QueryMetadata {
    id: string
    query: string
    parameters?: Record<string, unknown>
    passageId?: string
    timestamp: string
    description?: string
    passageFilename?: string
}

const queries = ref<QueryMetadata[]>([])
const isLoading = ref(false)
const error = ref<string | null>(null)
const searchQuery = ref('')

const loadQueries = async () => {
    isLoading.value = true
    error.value = null

    try {
        const response = await fetch('/api/passages/queries')
        if (!response.ok) {
            throw new Error(`Failed to load queries: ${response.statusText}`)
        }
        const data = await response.json()
        queries.value = Array.isArray(data) ? data : []
    } catch (err) {
        error.value = err instanceof Error ? err.message : 'Failed to load queries'
        console.error('Error loading queries:', err)
    } finally {
        isLoading.value = false
    }
}

const filteredQueries = computed(() => {
    if (!searchQuery.value) {
        return queries.value
    }

    const query = searchQuery.value.toLowerCase()
    return queries.value.filter(
        (q) =>
            q.query.toLowerCase().includes(query) ||
            (q.description && q.description.toLowerCase().includes(query)) ||
            (q.passageId && q.passageId.toLowerCase().includes(query)) ||
            (q.passageFilename &&
                q.passageFilename.toLowerCase().includes(query))
    )
})

const copyQuery = async (query: string) => {
    try {
        await navigator.clipboard.writeText(query)
        // Could add a toast notification here
    } catch (err) {
        console.error('Failed to copy query:', err)
    }
}

const viewPassage = (passageId: string) => {
    // Emit event to parent to select passage
    // This assumes the parent component can handle passage selection
    navigateTo(`/?passage=${passageId}`)
}

const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    })
}

// Load queries on mount
onMounted(() => {
    loadQueries()
})
</script>

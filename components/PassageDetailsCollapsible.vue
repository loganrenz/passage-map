<template>
    <div v-if="passage" class="details-collapsible">
        <div v-for="section in sections" :key="section.key" class="details-section"
            :class="{ 'is-expanded': expandedSections[section.key] }">
            <button class="section-header touch-manipulation" @click="toggleSection(section.key)"
                @touchstart.prevent="toggleSection(section.key)">
                <span class="section-title">{{ section.title }}</span>
                <span class="section-summary" v-if="!expandedSections[section.key] && section.getSummary">
                    {{ section.getSummary(passage) }}
                </span>
                <UIcon :name="expandedSections[section.key] ? 'i-lucide-chevron-up' : 'i-lucide-chevron-down'"
                    class="section-icon" />
            </button>

            <div v-if="expandedSections[section.key]" class="section-content">
                <slot :name="section.key" :passage="passage">
                    <component :is="section.component" v-if="section.component" :passage="passage" />
                </slot>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { formatDuration, formatDistance } from '~/utils/mapHelpers'

interface Props {
    passage?: Passage | null
    defaultExpanded?: string[]
}

const props = withDefaults(defineProps<Props>(), {
    defaultExpanded: () => ['stats'],
})

const expandedSections = ref<Record<string, boolean>>({})

const formatDateTime = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    })
}

const sections = computed(() => [
    {
        key: 'stats',
        title: 'Passage Stats',
        getSummary: (p: Passage) => `${formatDistance(p.distance)} • ${formatDuration(p.duration)}`,
    },
    {
        key: 'start-end',
        title: 'Start / End',
        getSummary: (p: Passage) => `${formatDateTime(p.startTime)} → ${formatDateTime(p.endTime)}`,
    },
    {
        key: 'performance',
        title: 'Performance Summary',
        getSummary: (p: Passage) => `Avg ${p.avgSpeed.toFixed(1)} kt • Max ${p.maxSpeed.toFixed(1)} kt`,
    },
    {
        key: 'notes',
        title: 'Notes',
        getSummary: () => 'Add notes about this passage',
    },
])

const toggleSection = (key: string) => {
    expandedSections.value[key] = !expandedSections.value[key]
}

// Initialize expanded sections
watch(
    () => props.passage,
    () => {
        expandedSections.value = {}
        props.defaultExpanded.forEach((key) => {
            expandedSections.value[key] = true
        })
    },
    { immediate: true }
)
</script>

<style scoped>
.details-collapsible {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.details-section {
    border: 1px solid rgba(0, 0, 0, 0.08);
    border-radius: 0.5rem;
    overflow: hidden;
    transition: all 0.2s ease;
}

.details-section.is-expanded {
    border-color: rgba(0, 0, 0, 0.12);
}

.section-header {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.75rem 1rem;
    background: rgba(0, 0, 0, 0.02);
    border: none;
    cursor: pointer;
    text-align: left;
    transition: background-color 0.2s ease;
    touch-action: manipulation;
    -webkit-tap-highlight-color: transparent;
    min-height: 44px;
}

.section-header:hover {
    background: rgba(0, 0, 0, 0.04);
}

.section-title {
    font-size: 0.875rem;
    font-weight: 600;
    color: #111827;
}

.section-summary {
    flex: 1;
    margin-left: 1rem;
    font-size: 0.8125rem;
    color: #6b7280;
    text-align: right;
}

.section-icon {
    width: 1rem;
    height: 1rem;
    color: #6b7280;
    margin-left: 0.5rem;
    transition: transform 0.2s ease;
}

.section-content {
    padding: 1rem;
    background: white;
}
</style>

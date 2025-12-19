<template>
    <div v-if="passage" class="passage-locations-compact">
        <!-- Header with action button -->
        <div class="locations-header">
            <h3 class="locations-title">Locations</h3>
            <UButton
                v-if="!passage.locations || passage.locations.length === 0"
                :loading="isGeocoding || isLoadingLocations"
                :disabled="isGeocoding || isLoadingLocations"
                size="xs"
                icon="i-lucide-map-pin"
                @click="handleGeocode"
            >
                {{ isGeocoding ? 'Geocoding...' : isLoadingLocations ? 'Loading...' : 'Get Locations' }}
            </UButton>
        </div>

        <!-- Loading state -->
        <div v-if="isGeocoding || isLoadingLocations" class="locations-loading">
            <UIcon name="i-lucide-loader-2" class="animate-spin" />
            <span>{{ isGeocoding ? 'Discovering locations...' : 'Loading locations from D1...' }}</span>
        </div>

        <!-- Narrative Summary -->
        <div v-else-if="passage.locations && passage.locations.length > 0">
            <div v-if="narrative" class="locations-narrative">
                <p>{{ narrative }}</p>
            </div>

            <!-- Location List -->
            <div class="locations-list">
                <div
                    v-for="(location, index) in passage.locations"
                    :key="index"
                    class="location-item"
                >
                    <UIcon name="i-lucide-map-pin" class="location-icon" />
                    <div class="location-content">
                        <div class="location-header">
                            <span v-if="location.locality" class="location-name">
                                {{ location.locality }}
                            </span>
                            <span v-else-if="location.name" class="location-name">
                                {{ location.name }}
                            </span>
                            <div class="location-badges">
                                <UBadge v-if="location.administrativeArea" size="xs" variant="subtle">
                                    {{ location.administrativeArea }}
                                </UBadge>
                                <UBadge v-if="location.country" size="xs" variant="subtle" color="gray">
                                    {{ location.country }}
                                </UBadge>
                            </div>
                        </div>
                        <p v-if="location.time" class="location-time">
                            {{ formatTime(location.time) }}
                        </p>
                        <p v-if="location.formattedAddress" class="location-address">
                            {{ location.formattedAddress }}
                        </p>
                        <div
                            v-if="location.pointsOfInterest && location.pointsOfInterest.length > 0"
                            class="location-pois"
                        >
                            <UBadge
                                v-for="(poi, poiIndex) in location.pointsOfInterest"
                                :key="poiIndex"
                                size="xs"
                                color="purple"
                                variant="subtle"
                            >
                                {{ poi }}
                            </UBadge>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Empty state -->
        <div v-else class="locations-empty">
            <UIcon name="i-lucide-map" class="locations-empty-icon" />
            <p class="locations-empty-text">No location information available</p>
            <UButton size="xs" icon="i-lucide-map-pin" @click="handleGeocode">
                Discover Locations
            </UButton>
        </div>
    </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'
import { usePassageGeocoding } from '~/composables/usePassageGeocoding'

interface Props {
    passage: Passage | null
}

const props = defineProps<Props>()

const { geocodePassage, getLocationNarrative, isGeocoding } = usePassageGeocoding()
const isLoadingLocations = ref(false)
const narrative = computed(() => {
    if (!props.passage?.locations || props.passage.locations.length === 0) {
        return null
    }
    return getLocationNarrative(props.passage.locations)
})

const emit = defineEmits<{
    'update:locations': [locations: Passage['locations']]
}>()

/**
 * Try to load locations from D1 if they're not already loaded
 */
const tryLoadLocationsFromD1 = async () => {
    if (!props.passage || !props.passage.id) return
    
    // If locations already exist, don't reload
    if (props.passage.locations && props.passage.locations.length > 0) {
        return
    }

    isLoadingLocations.value = true
    
    try {
        // Try to fetch locations from D1 via API
        const response = await $fetch<Passage>(`/api/passages/${props.passage.id}`)
        
        if (response.locations && response.locations.length > 0) {
            // Update the passage with locations from D1
            emit('update:locations', response.locations)
            console.log(`✓ Loaded ${response.locations.length} locations from D1`)
        }
    } catch (error) {
        // Silently fail - D1 might not be available or locations might not exist
        console.debug('Could not load locations from D1:', error)
    } finally {
        isLoadingLocations.value = false
    }
}

// Try to load locations when passage changes
watch(() => props.passage?.id, async (passageId) => {
    if (passageId) {
        await tryLoadLocationsFromD1()
    }
}, { immediate: true })

const handleGeocode = async () => {
    if (!props.passage) return

    try {
        // Create a mutable copy for geocoding
        const passageCopy: Passage = {
            ...props.passage,
            positions: props.passage.positions ? [...props.passage.positions] : undefined,
        }
        const locations = await geocodePassage(passageCopy)
        if (locations.length > 0) {
            // Save to D1 if available
            try {
                await $fetch(`/api/passages/${props.passage.id}/locations`, {
                    method: 'POST',
                    body: { locations },
                })
                console.log(`✓ Saved ${locations.length} locations to D1`)
            } catch (error) {
                console.warn('Could not save locations to D1 (they are still in memory):', error)
                // Continue anyway - locations are in memory
            }

            // Update the passage with location information
            emit('update:locations', locations)
        }
    } catch (error) {
        console.error('Error geocoding passage:', error)
    }
}

const formatTime = (timeString: string) => {
    return new Date(timeString).toLocaleString('en-US', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
    })
}
</script>

<style scoped>
.passage-locations-compact {
    padding: 0.5rem 0;
}

.locations-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.75rem;
}

.locations-title {
    font-size: 0.8125rem;
    font-weight: 600;
    color: #111827;
}

.locations-loading {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 0;
    font-size: 0.8125rem;
    color: #6b7280;
}

.locations-narrative {
    padding: 0.625rem;
    background: rgba(59, 130, 246, 0.1);
    border-radius: 0.375rem;
    margin-bottom: 0.75rem;
}

.locations-narrative p {
    font-size: 0.8125rem;
    color: #1e40af;
    line-height: 1.5;
    margin: 0;
}

.locations-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    max-height: 50vh;
    overflow-y: auto;
}

.location-item {
    display: flex;
    gap: 0.5rem;
    padding: 0.5rem;
    border: 1px solid rgba(0, 0, 0, 0.08);
    border-radius: 0.375rem;
    transition: background-color 0.15s;
}

.location-item:hover {
    background-color: rgba(0, 0, 0, 0.02);
}

.location-icon {
    color: #3b82f6;
    flex-shrink: 0;
    margin-top: 0.125rem;
    width: 16px;
    height: 16px;
}

.location-content {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
}

.location-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex-wrap: wrap;
}

.location-name {
    font-size: 0.8125rem;
    font-weight: 600;
    color: #111827;
    line-height: 1.4;
}

.location-badges {
    display: flex;
    gap: 0.25rem;
    flex-wrap: wrap;
}

.location-time {
    font-size: 0.6875rem;
    color: #6b7280;
    line-height: 1.3;
}

.location-address {
    font-size: 0.75rem;
    color: #4b5563;
    line-height: 1.4;
}

.location-pois {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
    margin-top: 0.25rem;
}

.locations-empty {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem 1rem;
    text-align: center;
}

.locations-empty-icon {
    width: 2rem;
    height: 2rem;
    color: #d1d5db;
    margin-bottom: 0.5rem;
}

.locations-empty-text {
    font-size: 0.8125rem;
    color: #6b7280;
    margin-bottom: 0.75rem;
}

@media (max-width: 640px) {
    .locations-list {
        max-height: 40vh;
    }

    .location-item {
        padding: 0.625rem;
    }
}
</style>


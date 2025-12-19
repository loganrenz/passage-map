<template>
  <div class="passage-right-panel">
    <UCard class="w-full h-full flex flex-col">
      <!-- Tabs: Passages and Queries -->
      <div class="flex gap-1 border-b p-2">
        <UButton
          :variant="activeTab === 'passages' ? 'solid' : 'ghost'"
          size="xs"
          @click="activeTab = 'passages'"
          class="flex-1"
        >
          Passages
        </UButton>
        <UButton
          :variant="activeTab === 'queries' ? 'solid' : 'ghost'"
          size="xs"
          @click="activeTab = 'queries'"
          class="flex-1"
        >
          Queries
        </UButton>
      </div>

      <!-- Tab Content -->
      <div class="flex-1 overflow-hidden flex flex-col min-h-0">
        <!-- Passages Tab -->
        <div v-show="activeTab === 'passages'" class="flex-1 overflow-y-auto min-h-0 p-2">
          <PassageList
            :passages="passages"
            :selected-passage="selectedPassage"
            :is-loading="isLoading"
            :error="error"
            @select="handleSelect"
          />
        </div>

        <!-- Queries Tab -->
        <div v-show="activeTab === 'queries'" class="flex-1 overflow-y-auto min-h-0 p-2">
          <PassageQueries />
        </div>
      </div>

      <!-- Vessels Section -->
      <div v-if="selectedPassage" class="border-t p-2">
        <UButton
          :variant="showVessels ? 'solid' : 'outline'"
          size="xs"
          icon="i-lucide-ship"
          class="w-full mb-2"
          @click="handleToggleVessels"
        >
          Vessels
        </UButton>
      </div>

      <!-- Map Controls: Fit and Center -->
      <div class="border-t p-2 flex flex-col gap-2">
        <UButton
          size="xs"
          variant="outline"
          icon="i-lucide-maximize"
          class="w-full"
          @click="handleFit"
        >
          Fit
        </UButton>
        <UButton
          v-if="selectedPassage && currentTime"
          size="xs"
          :variant="lockTideye === 'locked' ? 'solid' : lockTideye === 'center' ? 'soft' : 'outline'"
          :icon="lockTideye === 'locked' ? 'i-lucide-lock' : 'i-lucide-crosshair'"
          class="w-full"
          @click="handleCenter"
        >
          {{ lockTideye === 'locked' ? 'Locked' : lockTideye === 'center' ? 'Centered' : 'Center' }}
        </UButton>
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import type { Passage } from '~/types/passage'

interface Props {
  passages: Passage[]
  selectedPassage?: Passage | null
  isLoading?: boolean
  error?: string | null
  showVessels?: boolean
  lockTideye?: 'center' | 'locked' | null
  currentTime?: string | null
}

const props = withDefaults(defineProps<Props>(), {
  selectedPassage: null,
  isLoading: false,
  error: null,
  showVessels: true,
  lockTideye: null,
  currentTime: null,
})

const emit = defineEmits<{
  select: [passage: Passage]
  'update:showVessels': [show: boolean]
  'update:lockTideye': [lock: 'center' | 'locked' | null]
  fit: []
  center: []
}>()

const activeTab = ref<'passages' | 'queries'>('passages')

const handleSelect = (passage: Passage) => {
  emit('select', passage)
}

const handleToggleVessels = () => {
  emit('update:showVessels', !props.showVessels)
}

const handleFit = () => {
  emit('fit')
}

const handleCenter = () => {
  emit('center')
}
</script>

<style scoped>
.passage-right-panel {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 320px;
  max-width: calc(100vw - 2rem);
  max-height: calc(100vh - 8rem);
  z-index: 1001;
}

.passage-right-panel :deep(.card) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

@media (max-width: 640px) {
  .passage-right-panel {
    width: calc(100vw - 2rem);
    max-height: calc(100vh - 6rem);
  }
}
</style>


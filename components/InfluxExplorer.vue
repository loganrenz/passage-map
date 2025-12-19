<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <h2 class="text-xl font-semibold">InfluxDB Explorer</h2>
      <UButton
        icon="i-lucide-refresh-cw"
        variant="ghost"
        size="sm"
        :loading="isLoading"
        @click="exploreSchema"
      >
        Explore Schema
      </UButton>
    </div>

    <div v-if="isLoading" class="text-center py-8">
      <UIcon name="i-lucide-loader-2" class="animate-spin text-2xl" />
      <p class="mt-2 text-sm text-gray-500">Exploring InfluxDB schema...</p>
    </div>

    <div v-else-if="error" class="text-center py-8">
      <UAlert color="error" :title="error" />
    </div>

    <div v-else-if="measurements.length === 0" class="text-center py-8">
      <p class="text-sm text-gray-500">No measurements found</p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="measurement in measurements"
        :key="measurement.name"
        class="border rounded-lg p-4"
      >
        <div class="flex items-center justify-between mb-3">
          <h3 class="font-semibold text-lg">{{ measurement.name }}</h3>
          <UBadge color="primary" variant="subtle">
            {{ measurement.fields.length }} fields
          </UBadge>
        </div>

        <div v-if="measurement.fields.length > 0" class="mb-3">
          <h4 class="text-sm font-medium text-gray-700 mb-2">Fields:</h4>
          <div class="flex flex-wrap gap-2">
            <UBadge
              v-for="field in measurement.fields"
              :key="field"
              color="gray"
              variant="subtle"
              size="sm"
            >
              {{ field }}
            </UBadge>
          </div>
        </div>

        <div v-if="measurement.tagKeys.length > 0" class="mb-3">
          <h4 class="text-sm font-medium text-gray-700 mb-2">Tag Keys:</h4>
          <div class="flex flex-wrap gap-2">
            <UBadge
              v-for="tag in measurement.tagKeys"
              :key="tag"
              color="blue"
              variant="subtle"
              size="sm"
            >
              {{ tag }}
            </UBadge>
          </div>
        </div>

        <UButton
          variant="outline"
          size="sm"
          @click="buildQueryForMeasurement(measurement.name)"
        >
          Build Query
        </UButton>
      </div>
    </div>

    <UModal v-model="queryModalOpen">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">Query Builder</h3>
        </template>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Measurement
            </label>
            <UInput v-model="queryBuilder.measurement" disabled />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Start Time
            </label>
            <UInput
              v-model="queryBuilder.startTime"
              type="datetime-local"
              @update:model-value="updateResolution"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              End Time
            </label>
            <UInput
              v-model="queryBuilder.endTime"
              type="datetime-local"
              @update:model-value="updateResolution"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Aggregate Window (seconds)
              <span class="text-xs text-gray-500 font-normal ml-1">
                (auto-calculated based on time range)
              </span>
            </label>
            <UInput
              v-model.number="queryBuilder.resolution"
              type="number"
              :min="10"
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ resolutionDescription }}
            </p>
          </div>

          <div class="bg-gray-50 rounded-md p-3">
            <div class="flex justify-between items-center mb-2">
              <span class="text-xs font-mono text-gray-600">Generated Query</span>
              <UButton
                icon="i-lucide-copy"
                variant="ghost"
                size="xs"
                @click="copyQuery(generatedQuery)"
              >
                Copy
              </UButton>
            </div>
            <pre
              class="text-xs font-mono text-gray-800 overflow-x-auto whitespace-pre-wrap break-words max-h-48 overflow-y-auto"
            >{{ generatedQuery }}</pre>
          </div>

          <!-- Query Results -->
          <div v-if="queryResults !== null" class="bg-green-50 rounded-md p-3 border border-green-200">
            <div class="flex justify-between items-center mb-2">
              <span class="text-xs font-medium text-green-700">Query Results</span>
              <UBadge color="success" variant="subtle" size="sm">
                {{ queryResults.length }} result{{ queryResults.length !== 1 ? 's' : '' }}
              </UBadge>
            </div>
            <div class="text-xs text-green-700 max-h-32 overflow-y-auto">
              <pre class="whitespace-pre-wrap break-words">{{ JSON.stringify(queryResults.slice(0, 5), null, 2) }}{{ queryResults.length > 5 ? `\n... and ${queryResults.length - 5} more` : '' }}</pre>
            </div>
          </div>

          <!-- Query Error -->
          <div v-if="queryError" class="bg-red-50 rounded-md p-3 border border-red-200">
            <div class="text-xs font-medium text-red-700 mb-1">Query Error</div>
            <div class="text-xs text-red-600">{{ queryError }}</div>
          </div>
        </div>

        <template #footer>
          <div class="flex justify-end gap-2">
            <UButton variant="ghost" @click="queryModalOpen = false">
              Close
            </UButton>
            <UButton
              icon="i-lucide-copy"
              variant="outline"
              @click="copyQuery(generatedQuery)"
            >
              Copy Query
            </UButton>
            <UButton
              icon="i-lucide-play"
              :loading="isTestingQuery"
              @click="testQuery"
            >
              Test Query
            </UButton>
          </div>
        </template>
      </UCard>
    </UModal>
  </div>
</template>

<script setup lang="ts">
interface Measurement {
  name: string
  fields: string[]
  tagKeys: string[]
}

const measurements = ref<Measurement[]>([])
const isLoading = ref(false)
const error = ref<string | null>(null)
const queryModalOpen = ref(false)
const queryBuilder = ref({
  measurement: '',
  startTime: '',
  endTime: '',
  resolution: 60,
})

const exploreSchema = async () => {
  isLoading.value = true
  error.value = null

  try {
    const response = await fetch('/api/influxdb/schema')
    if (!response.ok) {
      throw new Error(`Failed to explore schema: ${response.statusText}`)
    }
    const data = await response.json()
    
    // Transform the response to match our Measurement interface
    if (data.measurements) {
      measurements.value = data.measurements.map((m: any) => ({
        name: m.name,
        fields: m.fields || [],
        tagKeys: m.tagKeys || [],
      }))
    } else {
      measurements.value = []
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to explore schema'
    console.error('Error exploring schema:', err)
  } finally {
    isLoading.value = false
  }
}

/**
 * Calculate appropriate aggregate window based on time range
 * Returns resolution in seconds
 */
const calculateResolution = (startTime: string, endTime: string): number => {
  if (!startTime || !endTime) {
    return 60 // Default 1 minute
  }

  try {
    const start = new Date(startTime)
    const end = new Date(endTime)
    const diffMs = end.getTime() - start.getTime()
    const diffHours = diffMs / (1000 * 60 * 60)
    const diffDays = diffHours / 24

    // Calculate resolution based on time range
    if (diffHours < 1) {
      // Less than 1 hour: 10 seconds
      return 10
    } else if (diffHours < 24) {
      // Less than 1 day: 60 seconds (1 minute)
      return 60
    } else if (diffDays < 7) {
      // Less than 7 days: 300 seconds (5 minutes)
      return 300
    } else if (diffDays < 30) {
      // Less than 30 days: 1800 seconds (30 minutes)
      return 1800
    } else {
      // More than 30 days: 3600 seconds (1 hour)
      return 3600
    }
  } catch (err) {
    console.error('Error calculating resolution:', err)
    return 60
  }
}

/**
 * Update resolution based on time range
 */
const updateResolution = () => {
  if (queryBuilder.value.startTime && queryBuilder.value.endTime) {
    const calculated = calculateResolution(
      queryBuilder.value.startTime,
      queryBuilder.value.endTime
    )
    queryBuilder.value.resolution = calculated
  }
}

/**
 * Get human-readable description of resolution
 */
const resolutionDescription = computed(() => {
  const resolution = queryBuilder.value.resolution || 60
  if (resolution < 60) {
    return `${resolution} seconds`
  } else if (resolution < 3600) {
    const minutes = resolution / 60
    return `${minutes} minute${minutes !== 1 ? 's' : ''}`
  } else {
    const hours = resolution / 3600
    return `${hours} hour${hours !== 1 ? 's' : ''}`
  }
})

const buildQueryForMeasurement = (measurementName: string) => {
  queryBuilder.value.measurement = measurementName
  // Set default times (last 7 days)
  const end = new Date()
  const start = new Date()
  start.setDate(start.getDate() - 7)
  
  queryBuilder.value.startTime = start.toISOString().slice(0, 16)
  queryBuilder.value.endTime = end.toISOString().slice(0, 16)
  // Calculate initial resolution
  updateResolution()
  // Reset query results
  queryResults.value = null
  queryError.value = null
  queryModalOpen.value = true
}

const generatedQuery = computed(() => {
  if (!queryBuilder.value.measurement || !queryBuilder.value.startTime || !queryBuilder.value.endTime) {
    return '// Fill in the form to generate a query'
  }

  const start = new Date(queryBuilder.value.startTime).toISOString()
  const end = new Date(queryBuilder.value.endTime).toISOString()
  const resolution = queryBuilder.value.resolution || 60

  return `from(bucket: "Tideye")
  |> range(start: ${start}, stop: ${end})
  |> filter(fn: (r) => r["_measurement"] == "${queryBuilder.value.measurement}")
  |> filter(fn: (r) => r["self"] == "t")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> aggregateWindow(every: ${resolution}s, fn: first, createEmpty: false)
  |> yield(name: "results")`
})

const toast = useToast()
const isTestingQuery = ref(false)
const queryResults = ref<any[] | null>(null)
const queryError = ref<string | null>(null)

const copyQuery = async (query: string) => {
  try {
    await navigator.clipboard.writeText(query)
    toast.add({
      title: 'Query Copied',
      description: 'Query has been copied to clipboard',
      color: 'success',
    })
  } catch (err) {
    console.error('Failed to copy query:', err)
    toast.add({
      title: 'Error',
      description: 'Failed to copy query to clipboard',
      color: 'error',
    })
  }
}

const testQuery = async () => {
  if (!queryBuilder.value.measurement || !queryBuilder.value.startTime || !queryBuilder.value.endTime) {
    toast.add({
      title: 'Validation Error',
      description: 'Please fill in all required fields',
      color: 'error',
    })
    return
  }

  isTestingQuery.value = true
  queryError.value = null
  queryResults.value = null

  try {
    const response = await fetch('/api/influxdb/explore', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query: generatedQuery.value,
      }),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ error: response.statusText }))
      throw new Error(errorData.error || `Failed to execute query: ${response.statusText}`)
    }

    const data = await response.json()
    queryResults.value = data.results || []
    
    toast.add({
      title: 'Query Executed',
      description: `Query returned ${queryResults.value.length} result${queryResults.value.length !== 1 ? 's' : ''}`,
      color: 'success',
    })
  } catch (err) {
    queryError.value = err instanceof Error ? err.message : 'Failed to execute query'
    toast.add({
      title: 'Query Error',
      description: queryError.value,
      color: 'error',
    })
    console.error('Error testing query:', err)
  } finally {
    isTestingQuery.value = false
  }
}

// Load schema on mount
onMounted(() => {
  exploreSchema()
})
</script>


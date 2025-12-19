<template>
  <div class="min-h-screen bg-gray-50">
    <UContainer class="py-2 sm:py-4 px-2 sm:px-4">
      <div class="mb-3 sm:mb-4">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Passage Queries</h1>
            <p class="text-sm sm:text-base text-gray-600 mt-1">
              View and reference queries used to generate passages
            </p>
          </div>
          <UButton
            variant="ghost"
            icon="i-lucide-arrow-left"
            to="/"
          >
            Back to Map
          </UButton>
        </div>
      </div>

      <!-- Common Queries Section -->
      <UCard class="mb-3 sm:mb-4">
        <template #header>
          <h2 class="text-base sm:text-lg font-semibold">Common Queries</h2>
        </template>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <UButton
            v-for="query in commonQueries"
            :key="query.id"
            variant="outline"
            class="justify-start h-auto p-3"
            @click="useCommonQuery(query)"
          >
            <div class="text-left w-full">
              <div class="font-medium text-sm mb-1">{{ query.name }}</div>
              <div class="text-xs text-gray-500">{{ query.description }}</div>
            </div>
          </UButton>
        </div>
      </UCard>

      <!-- Query Runner Section -->
      <UCard class="mb-3 sm:mb-4">
        <template #header>
          <div class="flex items-center justify-between">
            <h2 class="text-base sm:text-lg font-semibold">Query Runner</h2>
            <div class="flex gap-2">
              <UButton
                icon="i-lucide-copy"
                variant="ghost"
                size="sm"
                :disabled="!queryInput.trim()"
                @click="copyQueryInput"
              >
                Copy Query
              </UButton>
              <UButton
                icon="i-lucide-trash-2"
                variant="ghost"
                size="sm"
                :disabled="!queryInput.trim()"
                @click="clearQuery"
              >
                Clear
              </UButton>
            </div>
          </div>
        </template>
        <div class="mb-4">
          <div class="flex items-center gap-2 mb-2">
            <span class="text-sm font-medium text-gray-700">Diagnostic Queries:</span>
            <UButton
              size="xs"
              variant="outline"
              @click="loadDiagnosticQuery('check-data')"
            >
              Check Data Exists
            </UButton>
            <UButton
              size="xs"
              variant="outline"
              @click="loadDiagnosticQuery('check-measurements')"
            >
              List Measurements
            </UButton>
            <UButton
              size="xs"
              variant="outline"
              @click="loadDiagnosticQuery('check-fields')"
            >
              Check Fields
            </UButton>
            <UButton
              size="xs"
              variant="outline"
              @click="loadDiagnosticQuery('check-tags')"
            >
              Check Tags
            </UButton>
            <UButton
              size="xs"
              variant="outline"
              @click="loadDiagnosticQuery('no-self-filter')"
            >
              Without Self Filter
            </UButton>
            <UButton
              size="xs"
              variant="outline"
              @click="loadDiagnosticQuery('longer-range')"
            >
              Longer Time Range
            </UButton>
          </div>
        </div>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Flux Query
            </label>
            <textarea
              v-model="queryInput"
              class="w-full font-mono text-sm border border-gray-300 rounded-md p-3 focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              rows="8"
              placeholder="Enter your Flux query here..."
            />
          </div>

          <div class="flex gap-2">
            <UButton
              icon="i-lucide-play"
              :loading="isRunningQuery"
              :disabled="!queryInput.trim()"
              @click="runQuery"
            >
              Run Query
            </UButton>
            <UButton
              v-if="queryResults !== null"
              icon="i-lucide-download"
              variant="outline"
              @click="downloadResults"
            >
              Download Results
            </UButton>
          </div>

          <!-- Query Results -->
          <div v-if="queryError" class="bg-red-50 border border-red-200 rounded-md p-4">
            <div class="flex items-start gap-2">
              <UIcon name="i-lucide-alert-circle" class="text-red-600 mt-0.5" />
              <div class="flex-1">
                <div class="text-sm font-medium text-red-800 mb-1">Query Error</div>
                <div class="text-sm text-red-700 font-mono whitespace-pre-wrap">{{ queryError }}</div>
              </div>
            </div>
          </div>

          <div v-if="queryResults !== null && !queryError" class="space-y-2">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <UIcon name="i-lucide-check-circle" class="text-green-600" />
                <span class="text-sm font-medium text-gray-700">
                  Query executed successfully
                </span>
                <UBadge color="success" variant="subtle" size="sm">
                  {{ queryResults.length }} result{{ queryResults.length !== 1 ? 's' : '' }}
                </UBadge>
              </div>
              <UButton
                icon="i-lucide-x"
                variant="ghost"
                size="xs"
                @click="clearResults"
              >
                Clear Results
              </UButton>
            </div>
            <div class="bg-gray-50 border border-gray-200 rounded-md p-4 max-h-96 overflow-auto">
              <pre class="text-xs font-mono text-gray-800 whitespace-pre-wrap break-words">{{ formattedResults }}</pre>
            </div>
          </div>
        </div>
      </UCard>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-3 sm:gap-4">
        <!-- Main Content -->
        <div class="lg:col-span-2">
          <UCard>
            <template #header>
              <h2 class="text-base sm:text-lg font-semibold">Query Registry</h2>
            </template>
            <PassageQueries />
          </UCard>
        </div>

        <!-- Sidebar -->
        <div class="lg:col-span-1">
          <UCard>
            <template #header>
              <h2 class="text-base sm:text-lg font-semibold">InfluxDB Explorer</h2>
            </template>
            <InfluxExplorer />
          </UCard>
        </div>
      </div>
    </UContainer>
  </div>
</template>

<script setup lang="ts">
// Page metadata
useHead({
  title: 'Passage Queries - Passage Map',
})

interface CommonQuery {
  id: string
  name: string
  description: string
  query: string
  parameters?: Record<string, unknown>
}

const toast = useToast()

const commonQueries: CommonQuery[] = [
  {
    id: 'position-last-hour',
    name: 'Last Hour Positions',
    description: 'Position data from the last hour',
    query: `from(bucket: "Tideye")
  |> range(start: -1h, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> filter(fn: (r) => r["self"] == "t")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => exists r.lat and exists r.lon)
  |> aggregateWindow(every: 10s, fn: first, createEmpty: false)
  |> yield(name: "positions")`,
    parameters: {
      timeRange: '-1h',
      resolution: 10,
    },
  },
  {
    id: 'position-last-day',
    name: 'Last 24 Hours',
    description: 'Position data from the last day',
    query: `from(bucket: "Tideye")
  |> range(start: -24h, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> filter(fn: (r) => r["self"] == "t")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => exists r.lat and exists r.lon)
  |> aggregateWindow(every: 60s, fn: first, createEmpty: false)
  |> yield(name: "positions")`,
    parameters: {
      timeRange: '-24h',
      resolution: 60,
    },
  },
  {
    id: 'position-last-week',
    name: 'Last 7 Days',
    description: 'Position data from the last week',
    query: `from(bucket: "Tideye")
  |> range(start: -7d, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> filter(fn: (r) => r["self"] == "t")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => exists r.lat and exists r.lon)
  |> aggregateWindow(every: 5m, fn: first, createEmpty: false)
  |> yield(name: "positions")`,
    parameters: {
      timeRange: '-7d',
      resolution: 300,
    },
  },
  {
    id: 'speed-last-day',
    name: 'Speed Data (24h)',
    description: 'Speed over ground from last day',
    query: `from(bucket: "Tideye")
  |> range(start: -24h, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.speedOverGround")
  |> filter(fn: (r) => r["self"] == "t")
  |> aggregateWindow(every: 60s, fn: mean, createEmpty: false)
  |> yield(name: "speed")`,
    parameters: {
      timeRange: '-24h',
      resolution: 60,
    },
  },
]

const queryInput = ref('')
const isRunningQuery = ref(false)
const queryResults = ref<any[] | null>(null)
const queryError = ref<string | null>(null)

const useCommonQuery = async (query: CommonQuery) => {
  queryInput.value = query.query
  toast.add({
    title: 'Query Loaded',
    description: `${query.name} query has been loaded into the query runner`,
    color: 'success',
  })
}

const copyQueryInput = async () => {
  try {
    await navigator.clipboard.writeText(queryInput.value)
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

const clearQuery = () => {
  queryInput.value = ''
  queryResults.value = null
  queryError.value = null
}

const clearResults = () => {
  queryResults.value = null
  queryError.value = null
}

const runQuery = async () => {
  if (!queryInput.value.trim()) {
    toast.add({
      title: 'Validation Error',
      description: 'Please enter a query',
      color: 'error',
    })
    return
  }

  isRunningQuery.value = true
  queryError.value = null
  queryResults.value = null

  try {
    const response = await fetch('/api/influxdb/explore', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query: queryInput.value,
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
    console.error('Error executing query:', err)
  } finally {
    isRunningQuery.value = false
  }
}

const formattedResults = computed(() => {
  if (!queryResults.value || queryResults.value.length === 0) {
    return 'No results'
  }
  
  // Format results as JSON, but limit to first 100 for display
  const displayResults = queryResults.value.slice(0, 100)
  const json = JSON.stringify(displayResults, null, 2)
  
  if (queryResults.value.length > 100) {
    return `${json}\n\n... and ${queryResults.value.length - 100} more results (use download to see all)`
  }
  
  return json
})

const downloadResults = () => {
  if (!queryResults.value || queryResults.value.length === 0) {
    return
  }

  const dataStr = JSON.stringify(queryResults.value, null, 2)
  const dataBlob = new Blob([dataStr], { type: 'application/json' })
  const url = URL.createObjectURL(dataBlob)
  const link = document.createElement('a')
  link.href = url
  link.download = `query-results-${Date.now()}.json`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)

  toast.add({
    title: 'Download Started',
    description: 'Query results are being downloaded',
    color: 'success',
  })
}

const diagnosticQueries: Record<string, string> = {
  'check-data': `from(bucket: "Tideye")
  |> range(start: -1h, stop: now())
  |> limit(n: 10)
  |> yield(name: "sample")`,
  
  'check-measurements': `import "influxdata/influxdb/schema"
schema.measurements(bucket: "Tideye")`,
  
  'check-fields': `from(bucket: "Tideye")
  |> range(start: -24h, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> group()
  |> distinct(column: "_field")
  |> yield(name: "fields")`,
  
  'check-tags': `from(bucket: "Tideye")
  |> range(start: -24h, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> group()
  |> distinct(column: "self")
  |> yield(name: "self_tag_values")`,
  
  'no-self-filter': `from(bucket: "Tideye")
  |> range(start: -1h, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => exists r.lat and exists r.lon)
  |> limit(n: 10)
  |> yield(name: "positions")`,
  
  'longer-range': `from(bucket: "Tideye")
  |> range(start: -7d, stop: now())
  |> filter(fn: (r) => r["_measurement"] == "navigation.position")
  |> filter(fn: (r) => r["self"] == "t")
  |> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => exists r.lat and exists r.lon)
  |> aggregateWindow(every: 5m, fn: first, createEmpty: false)
  |> limit(n: 10)
  |> yield(name: "positions")`,
}

const loadDiagnosticQuery = (key: string) => {
  const query = diagnosticQueries[key]
  if (query) {
    queryInput.value = query
    toast.add({
      title: 'Diagnostic Query Loaded',
      description: 'Query has been loaded. Click "Run Query" to execute.',
      color: 'info',
    })
  }
}
</script>


<template>
  <div class="space-y-6">
    <!-- API Type -->
    <div>
      <label class="block text-sm font-medium mb-1">API Type</label>
      <select
        v-model="form.type"
        class="w-full rounded-lg border bg-background px-3 py-2"
        disabled
      >
        <option value="rest">REST API</option>
        <option value="graphql" disabled>GraphQL (Coming Soon)</option>
        <option value="soap" disabled>SOAP (Coming Soon)</option>
      </select>
    </div>

    <!-- HTTP Method -->
    <div>
      <label class="block text-sm font-medium mb-1">HTTP Method</label>
      <select
        v-model="form.method"
        class="w-full rounded-lg border bg-background px-3 py-2"
        required
      >
        <option value="GET">GET</option>
        <option value="POST">POST</option>
        <option value="PUT">PUT</option>
        <option value="DELETE">DELETE</option>
      </select>
    </div>

    <!-- Endpoint Path -->
    <div>
      <label class="block text-sm font-medium mb-1">Endpoint Path</label>
      <div class="flex items-center rounded-lg border bg-background">
        <span class="bg-muted px-3 py-2 text-muted-foreground">
          /{{ project?.base_path }}/
        </span>
        <input
          v-model="form.path"
          type="text"
          placeholder="users"
          class="flex-1 bg-transparent px-3 py-2 focus:outline-none"
          required
        />
      </div>
      <p class="mt-1 text-sm text-muted-foreground">
        Example: users, posts/{id}, comments
      </p>
    </div>

    <!-- Description -->
    <div>
      <label class="block text-sm font-medium mb-1">Description</label>
      <textarea
        v-model="form.description"
        rows="2"
        class="w-full rounded-lg border bg-background px-3 py-2"
        placeholder="Describe what this endpoint does"
      ></textarea>
    </div>

    <!-- Headers -->
    <div>
      <label class="block text-sm font-medium mb-1">Headers</label>
      <div class="space-y-2">
        <div
          v-for="(header, index) in form.headers"
          :key="index"
          class="flex items-center gap-2"
        >
          <input
            v-model="header.key"
            type="text"
            placeholder="Header Name"
            class="flex-1 rounded-lg border bg-background px-3 py-2"
          />
          <input
            v-model="header.value"
            type="text"
            placeholder="Value"
            class="flex-1 rounded-lg border bg-background px-3 py-2"
          />
          <button
            @click="removeHeader(index)"
            class="rounded-lg p-2 text-destructive hover:bg-destructive/10"
          >
            <Icon name="heroicons:trash" class="h-5 w-5" />
          </button>
        </div>
        <button
          @click="addHeader"
          class="text-sm text-primary hover:underline"
        >
          + Add Header
        </button>
      </div>
    </div>

    <!-- Response Type -->
    <div>
      <label class="block text-sm font-medium mb-1">Response Type</label>
      <select
        v-model="form.response_type"
        class="w-full rounded-lg border bg-background px-3 py-2"
        required
      >
        <option value="json">JSON</option>
        <option value="xml">XML</option>
        <option value="text">Plain Text</option>
      </select>
    </div>

    <!-- Status Code -->
    <div>
      <label class="block text-sm font-medium mb-1">Status Code</label>
      <select
        v-model="form.status_code"
        class="w-full rounded-lg border bg-background px-3 py-2"
        required
      >
        <optgroup label="Success">
          <option value="200">200 OK</option>
          <option value="201">201 Created</option>
          <option value="202">202 Accepted</option>
          <option value="204">204 No Content</option>
        </optgroup>
        <optgroup label="Client Error">
          <option value="400">400 Bad Request</option>
          <option value="401">401 Unauthorized</option>
          <option value="403">403 Forbidden</option>
          <option value="404">404 Not Found</option>
          <option value="422">422 Unprocessable Entity</option>
          <option value="429">429 Too Many Requests</option>
        </optgroup>
        <optgroup label="Server Error">
          <option value="500">500 Internal Server Error</option>
          <option value="502">502 Bad Gateway</option>
          <option value="503">503 Service Unavailable</option>
        </optgroup>
      </select>
    </div>

    <!-- Response Body -->
    <div>
      <label class="block text-sm font-medium mb-1">Response Body</label>
      <div class="rounded-lg border bg-background">
        <div class="border-b px-4 py-2">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-2">
              <button
                v-for="tab in ['Raw', 'Preview']"
                :key="tab"
                @click="activeTab = tab"
                :class="[
                  'px-2 py-1 text-sm rounded-md',
                  activeTab === tab
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                ]"
              >
                {{ tab }}
              </button>
            </div>
            <button
              @click="formatResponse"
              class="text-sm text-primary hover:underline"
            >
              Format
            </button>
          </div>
        </div>
        <div class="p-4">
          <textarea
            v-if="activeTab === 'Raw'"
            v-model="form.response_body"
            rows="8"
            class="w-full bg-transparent font-mono text-sm focus:outline-none"
            :class="{
              'text-red-500': !isValidResponse
            }"
          ></textarea>
          <pre v-else class="font-mono text-sm">{{ prettyResponse }}</pre>
        </div>
      </div>
      <p v-if="!isValidResponse" class="mt-1 text-sm text-red-500">
        Invalid {{ form.response_type.toUpperCase() }} format
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const props = defineProps<{
  project: any
  endpoint?: any
}>()

const form = reactive({
  type: 'rest',
  method: 'GET',
  path: '',
  description: '',
  headers: [] as { key: string; value: string }[],
  response_type: 'json',
  status_code: 200,
  response_body: '{\n  "message": "Hello World"\n}'
})

// Make form data accessible to parent
defineExpose({
  form
})

const activeTab = ref('Raw')
const isValidResponse = computed(() => {
  try {
    if (form.response_type === 'json') {
      JSON.parse(form.response_body)
    }
    // Add validation for XML and other formats
    return true
  } catch {
    return false
  }
})

const prettyResponse = computed(() => {
  try {
    if (form.response_type === 'json') {
      return JSON.stringify(JSON.parse(form.response_body), null, 2)
    }
    return form.response_body
  } catch {
    return form.response_body
  }
})

const addHeader = () => {
  form.headers.push({ key: '', value: '' })
}

const removeHeader = (index: number) => {
  form.headers.splice(index, 1)
}

const formatResponse = () => {
  try {
    if (form.response_type === 'json') {
      form.response_body = JSON.stringify(JSON.parse(form.response_body), null, 2)
    }
    // Add formatting for XML and other formats
  } catch {
    // Invalid format, keep as is
  }
}

// Initialize form with endpoint data if editing
onMounted(() => {
  if (props.endpoint) {
    form.method = props.endpoint.method
    form.path = props.endpoint.path
    form.description = props.endpoint.description || ''
    form.response_type = props.endpoint.response_type
    form.status_code = props.endpoint.status_code
    form.response_body = JSON.stringify(props.endpoint.response_body, null, 2)
    
    if (props.endpoint.headers) {
      form.headers = Object.entries(props.endpoint.headers).map(([key, value]) => ({
        key,
        value: value as string
      }))
    }
  }
})
</script>
<template>
  <div class="container py-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-semibold">Endpoints</h1>
        <p class="text-muted-foreground">Manage your API endpoints and responses</p>
      </div>
      <div class="flex items-center space-x-2">
        <select
          v-model="selectedProjectForNew"
          class="rounded-lg border bg-background px-4 py-2"
        >
          <option value="" disabled>Select Project</option>
          <option v-for="project in projects" :key="project.id" :value="project.id">
            {{ project.name }}
          </option>
        </select>
        <button
          @click="createNewEndpoint"
          :disabled="!selectedProjectForNew"
          class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50 flex items-center space-x-2"
        >
          <Icon name="heroicons:plus" class="h-5 w-5" />
          <span>New Endpoint</span>
        </button>
      </div>
    </div>

    <!-- Search and Filters -->
    <div class="mb-6 flex items-center space-x-4">
      <div class="flex-1">
        <div class="relative">
          <Icon 
            name="heroicons:magnifying-glass" 
            class="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground"
          />
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search endpoints..."
            class="w-full rounded-lg border bg-background pl-10 pr-4 py-2"
          />
        </div>
      </div>
      <select
        v-model="selectedProject"
        class="rounded-lg border bg-background px-4 py-2"
        :class="{ 'border-primary': selectedProject }"
      >
        <option value="">All Projects</option>
        <option v-for="project in projects" :key="project.id" :value="project.id">
          {{ project.name }}
          {{ project.tags?.length ? `(${project.tags.join(', ')})` : '' }}
        </option>
      </select>
      <select
        v-model="selectedMethod"
        class="rounded-lg border bg-background px-4 py-2"
      >
        <option value="">All Methods</option>
        <option value="GET">GET</option>
        <option value="POST">POST</option>
        <option value="PUT">PUT</option>
        <option value="DELETE">DELETE</option>
      </select>
    </div>

    <!-- Endpoints List -->
    <div v-if="filteredEndpoints.length > 0" class="rounded-lg border bg-card divide-y">
      <div
        v-for="endpoint in filteredEndpoints"
        :key="endpoint.id"
        class="p-4 hover:bg-muted/50 transition-all"
      >
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4 flex-1 min-w-0">
            <div
              class="px-3 py-1 rounded-lg text-sm font-medium"
              :class="{
                'bg-blue-100 text-blue-700': endpoint.method === 'GET',
                'bg-green-100 text-green-700': endpoint.method === 'POST',
                'bg-yellow-100 text-yellow-700': endpoint.method === 'PUT',
                'bg-red-100 text-red-700': endpoint.method === 'DELETE'
              }"
            >
              {{ endpoint.method }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center space-x-2">
                <span class="rounded-lg bg-muted px-2 py-1 text-xs font-medium">
                  {{ endpoint.project?.name }}
                </span>
                <code class="text-sm font-mono truncate">
                  /{{ getProjectBasePath(endpoint.project_id) }}/{{ endpoint.path }}
                </code>
                <span
                  class="rounded-full px-2 py-0.5 text-xs"
                  :class="{
                    'bg-green-100 text-green-700': endpoint.status_code < 400,
                    'bg-red-100 text-red-700': endpoint.status_code >= 400
                  }"
                >
                  {{ endpoint.status_code }}
                </span>
              </div>
              <p v-if="endpoint.description" class="text-sm text-muted-foreground truncate mt-1">
                {{ endpoint.description }}
              </p>
            </div>
          </div>
          <div class="flex items-center space-x-2 ml-4">
            <button
              @click="toggleEndpoint(endpoint)"
              :class="[
                'rounded-full p-2',
                endpoint.active ? 'text-green-600' : 'text-muted-foreground'
              ]"
            >
              <Icon
                :name="endpoint.active ? 'heroicons:check-circle' : 'heroicons:x-circle'"
                class="h-5 w-5"
              />
            </button>
            <button
              @click="editEndpoint(endpoint)"
              class="rounded-md p-2 hover:bg-muted"
            >
              <Icon name="heroicons:pencil" class="h-5 w-5" />
            </button>
            <button
              @click="deleteEndpoint(endpoint.id)"
              class="rounded-md p-2 text-destructive hover:bg-destructive/10"
            >
              <Icon name="heroicons:trash" class="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="!searchQuery && endpoints.length === 0"
      class="text-center py-12"
    >
      <div class="rounded-full bg-primary/10 p-3 w-12 h-12 mx-auto mb-4">
        <Icon name="heroicons:code-bracket" class="h-6 w-6 text-primary" />
      </div>
      <h3 class="text-lg font-medium mb-2">No endpoints yet</h3>
      <p class="text-muted-foreground mb-4">
        Create your first endpoint to start mocking API responses
      </p>
      <button
        @click="showProjectModal = true"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Create your first endpoint
      </button>
    </div>

    <!-- No Results -->
    <div
      v-else
      class="text-center py-12"
    >
      <p class="text-muted-foreground">No endpoints found matching your search</p>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const router = useRouter()
const supabase = useSupabaseClient()
const user = useState('user')
const organization = ref(null)
const endpoints = ref<any[]>([])
const projects = ref<any[]>([])
const searchQuery = ref('')
const selectedProject = ref('')
const selectedMethod = ref('')
const selectedProjectForNew = ref('')

const filteredEndpoints = computed(() => {
  let result = [...endpoints.value]
  
  // Apply search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(e => 
      e.path.toLowerCase().includes(query) ||
      e.description?.toLowerCase().includes(query)
    )
  }

  // Filter by project
  if (selectedProject.value) {
    result = result.filter(e => e.project_id === selectedProject.value)
  }

  // Filter by method
  if (selectedMethod.value) {
    result = result.filter(e => e.method === selectedMethod.value)
  }
  
  return result
})

const initializeOrganization = async () => {
  if (!user.value?.id) return null
  
  const { data: memberData } = await supabase
    .from('organization_members')
    .select('organization_id')
    .eq('user_id', user.value.id)
    .single()

  if (memberData) {
    const { data: orgData } = await supabase
      .from('organizations')
      .select('*')
      .eq('id', memberData.organization_id)
      .single()
    
    if (orgData) {
      organization.value = orgData
      return orgData
    }
  }
  return null
}

const loadProjects = async () => {
  const org = organization.value
  if (!org?.id) return
  
  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .eq('organization_id', org.id)

  if (error) {
    console.error('Error loading projects:', error)
    return
  }

  if (data) {
    projects.value = data
  }
}

const loadEndpoints = async () => {
  const org = organization.value
  if (!org?.id) return
  
  const { data, error } = await supabase
    .from('endpoints')
    .select('*, project:projects(*)')
    .eq('projects.organization_id', org.id)

  if (error) {
    console.error('Error loading endpoints:', error)
    return
  }

  if (data) {
    endpoints.value = data
  }
}

const getProjectBasePath = (projectId: string) => {
  const project = projects.value.find(p => p.id === projectId)
  return project?.base_path || ''
}

const createNewEndpoint = () => {
  if (!selectedProjectForNew.value) return
  router.push(`/${organization.value.subdomain}/dashboard/endpoints/new?project=${selectedProjectForNew.value}`)
}

const toggleEndpoint = async (endpoint: any) => {
  try {
    const { error } = await supabase
      .from('endpoints')
      .update({ active: !endpoint.active })
      .eq('id', endpoint.id)

    if (error) throw error
    endpoint.active = !endpoint.active
  } catch (error) {
    console.error('Error toggling endpoint:', error)
  }
}

const editEndpoint = (endpoint: any) => {
  router.push(`/${organization.value.subdomain}/dashboard/endpoints/${endpoint.id}/edit`)
}

const deleteEndpoint = async (id: string) => {
  if (!confirm('Are you sure you want to delete this endpoint?')) return

  try {
    const { error } = await supabase
      .from('endpoints')
      .delete()
      .eq('id', id)

    if (error) throw error
    await loadEndpoints()
  } catch (error) {
    console.error('Error deleting endpoint:', error)
  }
}

onMounted(async () => {
  await initializeOrganization()
  await loadProjects()
  await loadEndpoints()
})
</script>
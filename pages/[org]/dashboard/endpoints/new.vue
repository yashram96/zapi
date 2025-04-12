<template>
  <div class="container py-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center space-x-2 text-sm text-muted-foreground mb-4">
        <NuxtLink to="/dashboard/endpoints" class="hover:text-foreground">
          Endpoints
        </NuxtLink>
        <Icon name="heroicons:chevron-right" class="h-4 w-4" />
        <span>New Endpoint</span>
      </div>
      <h1 class="text-2xl font-semibold">Create New Endpoint</h1>
      <p class="text-muted-foreground">Configure your API endpoint and response</p>
    </div>

    <!-- Endpoint Form -->
    <div v-if="selectedProject" class="space-y-6">
      <div class="flex items-center space-x-4 p-4 rounded-lg bg-muted/50">
        <div class="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
          <Icon name="heroicons:code-bracket-square" class="h-6 w-6 text-primary" />
        </div>
        <div>
          <h3 class="font-medium">{{ selectedProject.name }}</h3>
          <p class="text-sm text-muted-foreground">
            /{{ selectedProject.base_path }}
          </p>
        </div>
        <button
          @click="selectedProject = null"
          class="ml-auto rounded-md p-2 hover:bg-muted"
        >
          <Icon name="heroicons:x-mark" class="h-5 w-5" />
        </button>
      </div>

      <!-- Endpoint Form -->
      <div class="rounded-lg border bg-card">
        <div class="p-6">
          <EndpointForm
            :project="selectedProject"
            ref="endpointForm"
            @submit="handleSubmit"
          />
        </div>
        <div class="border-t p-6 flex justify-end space-x-4">
          <NuxtLink
            :to="`/${organization?.subdomain}/dashboard/endpoints`"
            class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
          >
            Cancel
          </NuxtLink>
          <button
            @click="handleSubmit"
            :disabled="isSubmitting"
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {{ isSubmitting ? 'Creating...' : 'Create Endpoint' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-else-if="isLoading" class="text-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
      <p class="mt-2 text-sm text-muted-foreground">Loading project...</p>
    </div>

    <!-- Error State -->
    <div v-else class="text-center py-12">
      <div class="rounded-full bg-destructive/10 p-3 w-12 h-12 mx-auto mb-4">
        <Icon name="heroicons:exclamation-triangle" class="h-6 w-6 text-destructive" />
      </div>
      <h3 class="text-lg font-medium mb-2">Project not found</h3>
      <p class="text-muted-foreground mb-4">
        Please select a project to create an endpoint.
      </p>
      <NuxtLink :to="`/${organization?.subdomain}/dashboard/endpoints`" class="text-primary hover:underline">
        Back to endpoints
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import EndpointForm from '~/components/endpoints/EndpointForm.vue'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const user = useState('user')
const supabase = useSupabaseClient()
const router = useRouter()
const organization = ref(null)
const projects = ref<any[]>([])
const route = useRoute()
const selectedProject = ref(null)
const isSubmitting = ref(false)
const isLoading = ref(true)

const endpointForm = ref(null)

const handleSubmit = async () => {
  try {
    if (!endpointForm.value) {
      console.error('Form is not available')
      return
    }
    
    isSubmitting.value = true
    const formData = endpointForm.value.form
    
    if (!formData) {
      throw new Error('Form data is not available')
    }

    // Convert headers array to object
    const headers = formData.headers?.reduce((acc: any, header: any) => {
      if (header.key && header.value) {
        acc[header.key] = header.value
      }
      return acc
    }, {}) || {}

    const endpoint = {
      project_id: selectedProject.value.id,
      method: formData.method,
      path: formData.path,
      description: formData.description,
      response_type: formData.response_type,
      status_code: formData.status_code,
      response_body: JSON.parse(formData.response_body),
      headers
    }

    const { error } = await supabase
      .from('endpoints')
      .insert([endpoint])

    if (error) throw error

    // Redirect to endpoints list
    router.push(`/${organization.value.subdomain}/dashboard/endpoints`)
  } catch (error) {
    console.error('Error creating endpoint:', error)
    alert('Failed to create endpoint')
  } finally {
    isSubmitting.value = false
  }
}

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
    .order('updated_at', { ascending: false })

  if (error) {
    console.error('Error loading projects:', error)
    return
  }

  if (data) {
    projects.value = data
    isLoading.value = false
  }
}

onMounted(async () => {
  await initializeOrganization()
  await loadProjects()
  
  // If project ID is provided in query params, select it automatically
  const projectId = route.query.project as string
  if (projectId) {
    const project = projects.value.find(p => p.id === projectId)
    if (project) {
      isLoading.value = false
      selectedProject.value = project
    }
  }
})
</script>
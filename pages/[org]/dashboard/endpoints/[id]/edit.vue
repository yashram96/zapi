<template>
  <div class="container py-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center space-x-2 text-sm text-muted-foreground mb-4">
        <NuxtLink 
          :to="`/${organization?.subdomain}/dashboard/endpoints`" 
          class="hover:text-foreground"
        >
          Endpoints
        </NuxtLink>
        <Icon name="heroicons:chevron-right" class="h-4 w-4" />
        <span>Edit Endpoint</span>
      </div>
      <h1 class="text-2xl font-semibold">Edit Endpoint</h1>
      <p class="text-muted-foreground">Modify your API endpoint configuration</p>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="text-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
      <p class="mt-2 text-sm text-muted-foreground">Loading endpoint...</p>
    </div>

    <!-- Endpoint Form -->
    <div v-else-if="endpoint && project" class="space-y-6">
      <div class="flex items-center space-x-4 p-4 rounded-lg bg-muted/50">
        <div class="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center">
          <Icon name="heroicons:code-bracket-square" class="h-6 w-6 text-primary" />
        </div>
        <div>
          <h3 class="font-medium">{{ project.name }}</h3>
          <p class="text-sm text-muted-foreground">
            /{{ project.base_path }}
          </p>
        </div>
      </div>

      <div class="rounded-lg border bg-card">
        <div class="p-6">
          <EndpointForm
            :project="project"
            :endpoint="endpoint"
            ref="endpointForm"
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
            {{ isSubmitting ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else class="text-center py-12">
      <div class="rounded-full bg-destructive/10 p-3 w-12 h-12 mx-auto mb-4">
        <Icon name="heroicons:exclamation-triangle" class="h-6 w-6 text-destructive" />
      </div>
      <h3 class="text-lg font-medium mb-2">Endpoint not found</h3>
      <p class="text-muted-foreground mb-4">
        The endpoint you're looking for doesn't exist or you don't have permission to view it.
      </p>
      <NuxtLink
        :to="`/${organization?.subdomain}/dashboard/endpoints`"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Back to Endpoints
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

const route = useRoute()
const router = useRouter()
const supabase = useSupabaseClient()
const organization = useState('organization')

const endpoint = ref(null)
const project = ref(null)
const isLoading = ref(true)
const isSubmitting = ref(false)

const endpointForm = ref(null)

const handleSubmit = async () => {
  try {
    if (!endpointForm.value) return
    
    isSubmitting.value = true
    const form = endpointForm.value.$data.form

    // Convert headers array to object
    const headers = form.headers.reduce((acc: any, header: any) => {
      if (header.key && header.value) {
        acc[header.key] = header.value
      }
      return acc
    }, {})

    const updates = {
      method: form.method,
      path: form.path,
      description: form.description,
      response_type: form.response_type,
      status_code: form.status_code,
      response_body: JSON.parse(form.response_body),
      headers
    }

    const { error } = await supabase
      .from('endpoints')
      .update(updates)
      .eq('id', endpoint.value.id)

    if (error) throw error

    // Redirect to endpoints list
    router.push(`/${organization.value.subdomain}/dashboard/endpoints`)
  } catch (error) {
    console.error('Error updating endpoint:', error)
    alert('Failed to update endpoint')
  } finally {
    isSubmitting.value = false
  }
}

const loadEndpoint = async () => {
  try {
    const { data, error } = await supabase
      .from('endpoints')
      .select('*, project:projects(*)')
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    if (data) {
      endpoint.value = data
      project.value = data.project
    }
  } catch (error) {
    console.error('Error loading endpoint:', error)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  loadEndpoint()
})
</script>
<template>
  <div class="p-6">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-medium">API Keys</h2>
      <button
        @click="showNewKeyModal = true"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Create New Key
      </button>
    </div>

    <!-- API Keys List -->
    <div class="mt-6 space-y-4">
      <div v-for="key in apiKeys" :key="key.id" class="rounded-lg border p-4">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-medium">{{ key.name }}</h3>
            <p class="text-sm text-muted-foreground">Created {{ new Date(key.created_at).toLocaleDateString() }}</p>
          </div>
          <button
            @click="$emit('delete', key.id)"
            class="rounded-md p-2 text-destructive hover:bg-destructive/10"
          >
            <Icon name="heroicons:trash" class="h-5 w-5" />
          </button>
        </div>
        <div class="mt-2">
          <div class="flex items-center space-x-2">
            <span class="text-sm font-mono">{{ maskApiKey(key.key) }}</span>
            <button
              @click="copyToClipboard(key.key)"
              class="rounded-md p-1 hover:bg-muted"
            >
              <Icon name="heroicons:clipboard" class="h-4 w-4" />
            </button>
            <span class="text-xs text-muted-foreground">(Click to copy)</span>
          </div>
        </div>
        <div class="mt-2 flex items-center space-x-2">
          <span
            :class="[
              'rounded-full px-2 py-1 text-xs font-medium',
              key.access_type === 'read' ? 'bg-blue-100 text-blue-700' : 'bg-orange-100 text-orange-700'
            ]"
          >
            {{ key.access_type }}
          </span>
          <div v-if="key.api_key_projects?.length" class="flex items-center space-x-1">
            <span class="text-sm text-muted-foreground">Projects:</span>
            <div class="flex space-x-1">
              <span 
                v-for="project in key.api_key_projects" 
                :key="project.project.id"
                class="rounded-full bg-muted px-2 py-1 text-xs"
              >
                {{ project.project.name }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- New API Key Modal -->
    <div v-if="showNewKeyModal" class="fixed inset-0 z-50 flex items-center justify-center bg-background/80">
      <div class="w-full max-w-md rounded-lg border bg-card p-6">
        <h3 class="text-lg font-medium">Create New API Key</h3>
        <form @submit.prevent="handleSubmit" class="mt-4 space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Key Name</label>
            <input
              v-model="form.name"
              type="text"
              class="w-full rounded-lg border bg-background px-3 py-2"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Access Type</label>
            <select
              v-model="form.access_type"
              class="w-full rounded-lg border bg-background px-3 py-2"
            >
              <option value="read">Read Only</option>
              <option value="write">Read & Write</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Projects</label>
            <div class="space-y-2">
              <p class="text-sm text-muted-foreground mb-2">Select projects for this API key</p>
              <div v-if="projects.length === 0" class="text-center py-4">
                <p class="text-sm text-muted-foreground">No projects available</p>
                <button
                  @click="showNewProjectModal = true"
                  class="mt-2 text-sm text-primary hover:underline"
                >
                  Create your first project
                </button>
              </div>
              <div v-else>
                <div v-for="project in projects" :key="project.id" class="flex items-center">
                  <input
                    type="checkbox"
                    :id="project.id"
                    v-model="form.project_ids"
                    :value="project.id"
                    class="rounded border-input mr-2"
                  />
                  <label :for="project.id">{{ project.name }}</label>
                </div>
                <button
                  @click="showNewProjectModal = true"
                  class="mt-2 text-sm text-primary hover:underline"
                >
                  + Add new project
                </button>
              </div>
            </div>
          </div>

          <div class="flex justify-end space-x-2">
            <button
              type="button"
              :disabled="isSubmitting"
              @click="showNewKeyModal = false"
              class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="isSubmitting || form.project_ids.length === 0"
              class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
            >
              {{ isSubmitting ? 'Creating...' : 'Create Key' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- New Project Modal -->
    <div v-if="showNewProjectModal" class="fixed inset-0 z-50 flex items-center justify-center bg-background/80">
      <div class="w-full max-w-md rounded-lg border bg-card p-6">
        <h3 class="text-lg font-medium">Create New Project</h3>
        <form @submit.prevent="handleCreateProject" class="mt-4 space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Project Name</label>
            <input
              v-model="projectForm.name"
              type="text"
              class="w-full rounded-lg border bg-background px-3 py-2"
              required
            />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Description</label>
            <textarea
              v-model="projectForm.description"
              class="w-full rounded-lg border bg-background px-3 py-2"
              rows="3"
            ></textarea>
          </div>
          <div class="flex justify-end space-x-2">
            <button
              type="button"
              @click="showNewProjectModal = false"
              class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="isCreatingProject"
              class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
            >
              {{ isCreatingProject ? 'Creating...' : 'Create Project' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const showNewKeyModal = ref(false)
const showNewProjectModal = ref(false)
const isSubmitting = ref(false)
const isCreatingProject = ref(false)

const form = reactive({
  name: '',
  access_type: 'read',
  project_ids: [] as string[]
})

const projectForm = reactive({
  name: '',
  description: ''
})

const props = defineProps<{
  apiKeys: any[]
  projects: any[]
}>()

const emit = defineEmits<{
  create: [form: typeof form]
  delete: [id: string]
  'create-project': [form: { name: string, description: string }]
}>()

const handleSubmit = async () => {
  if (form.project_ids.length === 0) {
    alert('Please select at least one project')
    return
  }

  try {
    isSubmitting.value = true
    await emit('create', { ...form })
    showNewKeyModal.value = false
    form.name = ''
    form.access_type = 'read'
    form.project_ids = []
  } finally {
    isSubmitting.value = false
  }
}

const handleCreateProject = async () => {
  try {
    isCreatingProject.value = true
    await emit('create-project', { ...projectForm })
    showNewProjectModal.value = false
    projectForm.name = ''
    projectForm.description = ''
  } catch (error) {
    console.error('Error creating project:', error)
  } finally {
    isCreatingProject.value = false
  }
}

const copyToClipboard = async (text: string) => {
  try {
    await navigator.clipboard.writeText(text)
    alert('API key copied to clipboard')
  } catch (error) {
    console.error('Error copying to clipboard:', error)
  }
}

const maskApiKey = (key: string) => {
  if (!key) return ''
  const prefix = key.slice(0, 8)
  const suffix = key.slice(-4)
  return `${prefix}...${suffix}`
}
</script>
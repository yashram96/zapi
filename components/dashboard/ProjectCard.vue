<template>
  <div class="rounded-lg border bg-card">
    <div class="border-b p-6">
      <h2 class="text-lg font-medium">Projects</h2>
      <p class="mt-1 text-sm text-muted-foreground">Manage your API projects</p>
    </div>
    <div v-if="projects.length === 0" class="p-6 text-center">
      <div class="mb-4 text-muted-foreground">No projects yet</div>
      <button
        @click="showNewProjectModal = true"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Create Your First Project
      </button>
    </div>
    <div v-else class="divide-y">
      <div v-for="project in projects" :key="project.id" class="p-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <div class="h-8 w-8 rounded bg-primary/10 flex items-center justify-center">
              <Icon name="heroicons:folder" class="h-5 w-5 text-primary" />
            </div>
            <div>
              <h3 class="font-medium">{{ project.name }}</h3>
              <p v-if="project.description" class="text-sm text-muted-foreground">{{ project.description }}</p>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <button
              @click="editProject(project)"
              class="rounded-md p-2 hover:bg-muted"
            >
              <Icon name="heroicons:pencil" class="h-5 w-5" />
            </button>
            <button
              @click="deleteProject(project.id)"
              class="rounded-md p-2 text-destructive hover:bg-destructive/10"
            >
              <Icon name="heroicons:trash" class="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="border-t p-4">
      <button
        @click="showNewProjectModal = true"
        class="w-full rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Create New Project
      </button>
    </div>

    <!-- New Project Modal -->
    <div v-if="showNewProjectModal" class="fixed inset-0 z-50 flex items-center justify-center bg-background/80">
      <div class="w-full max-w-md rounded-lg border bg-card p-6">
        <h3 class="text-lg font-medium">{{ editingProject ? 'Edit Project' : 'Create New Project' }}</h3>
        <form @submit.prevent="handleSubmit" class="mt-4 space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Project Name</label>
            <input
              v-model="form.name"
              type="text"
              class="w-full rounded-lg border bg-background px-3 py-2"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Description</label>
            <textarea
              v-model="form.description"
              class="w-full rounded-lg border bg-background px-3 py-2"
              rows="3"
            ></textarea>
          </div>

          <div class="flex justify-end space-x-2">
            <button
              type="button"
              @click="closeModal"
              class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="isSubmitting"
              class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
            >
              {{ isSubmitting ? 'Saving...' : (editingProject ? 'Save Changes' : 'Create Project') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const organization = useState('organization')
const projects = ref<any[]>([])
const showNewProjectModal = ref(false)
const isSubmitting = ref(false)
const editingProject = ref(null)

const form = reactive({
  name: '',
  description: ''
})

const loadProjects = async () => {
  if (!organization.value?.id) return
  
  const { data, error } = await supabase
    .from('projects')
    .select('*')
    .eq('organization_id', organization.value.id)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error loading projects:', error)
    return
  }

  if (data) {
    projects.value = data
  }
}

const handleSubmit = async () => {
  try {
    isSubmitting.value = true

    if (!organization.value?.id) {
      alert('Organization not found. Please refresh the page.')
      return
    }

    if (!form.name.trim()) {
      alert('Project name is required')
      return
    }

    if (editingProject.value) {
      const { error } = await supabase
        .from('projects')
        .update({
          name: form.name,
          description: form.description
        })
        .eq('id', editingProject.value.id)

      if (error) throw error
    } else {
      const { data, error } = await supabase
        .from('projects')
        .insert([{
          organization_id: organization.value.id,
          name: form.name,
          description: form.description
        }])
        .select()

      if (error) throw error 
      if (data) {
        projects.value = [data[0], ...projects.value]
      }
    }

    closeModal()
  } catch (error) {
    console.error('Error saving project:', error) 
    alert(error instanceof Error ? error.message : 'Failed to save project. Please try again.')
  } finally {
    isSubmitting.value = false
  }
}

const editProject = (project: any) => {
  editingProject.value = project
  form.name = project.name
  form.description = project.description || ''
  showNewProjectModal.value = true
}

const deleteProject = async (id: string) => {
  if (!confirm('Are you sure you want to delete this project?')) return

  try {
    const { error } = await supabase
      .from('projects')
      .delete()
      .eq('id', id)

    if (error) throw error
    await loadProjects()
  } catch (error) {
    console.error('Error deleting project:', error)
  }
}

const closeModal = () => {
  showNewProjectModal.value = false
  editingProject.value = null
  form.name = '' 
  form.description = '' 
}

onMounted(async () => {
  await loadProjects()
})
</script>
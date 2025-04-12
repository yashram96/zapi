<template>
  <div class="container py-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-2xl font-semibold">Projects</h1>
        <p class="text-muted-foreground">Organize and manage your mock API endpoints</p>
      </div>
      <button
        @click="showNewProjectModal = true"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        <div class="flex items-center space-x-2">
          <Icon name="heroicons:plus" class="h-5 w-5" />
          <span>New Project</span>
        </div>
      </button>
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
            placeholder="Search projects..."
            class="w-full rounded-lg border bg-background pl-10 pr-4 py-2"
          />
        </div>
      </div>
      <select
        v-model="sortBy"
        class="rounded-lg border bg-background px-4 py-2"
      >
        <option value="name">Name (A-Z)</option>
        <option value="updated">Last Updated</option>
      </select>
    </div>

    <!-- Projects Grid -->
    <div v-if="filteredProjects.length > 0" class="rounded-lg border bg-card divide-y">
      <div
        v-for="project in filteredProjects"
        :key="project.id"
        class="group relative p-4 hover:bg-muted/50 transition-all"
      >
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4 flex-1 min-w-0">
            <div class="h-10 w-10 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
              <Icon name="heroicons:code-bracket-square" class="h-6 w-6 text-primary" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center space-x-2">
                <h3 class="font-medium truncate">{{ project.name }}</h3>
                <Icon 
                  v-if="project.is_favorite"
                  name="heroicons:star-solid"
                  class="h-4 w-4 text-yellow-500 flex-shrink-0"
                />
              </div>
              <p v-if="project.description" class="text-sm text-muted-foreground truncate">
                {{ project.description }}
              </p>
              <div class="flex items-center space-x-4 mt-1">
                <span class="text-xs text-muted-foreground">
                  Updated {{ formatDate(project.updated_at) }}
                </span>
                <div v-if="project.tags?.length" class="flex gap-2">
                  <span
                    v-for="tag in project.tags"
                    :key="tag"
                    class="rounded-full bg-primary/10 px-2 py-0.5 text-xs text-primary"
                  >
                    {{ tag }}
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="flex items-center space-x-2 ml-4">
            <button
              @click="toggleFavorite(project)"
              class="rounded-md p-2 hover:bg-muted"
              :class="{ 'text-yellow-500': project.is_favorite }"
            >
              <Icon :name="project.is_favorite ? 'heroicons:star-solid' : 'heroicons:star'" class="h-5 w-5" />
            </button>
            <button
              @click="duplicateProject(project)"
              class="rounded-md p-2 hover:bg-muted"
            >
              <Icon name="heroicons:document-duplicate" class="h-5 w-5" />
            </button>
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

    <!-- Empty State -->
    <div
      v-else-if="!searchQuery && projects.length === 0"
      class="text-center py-12"
    >
      <div class="rounded-full bg-primary/10 p-3 w-12 h-12 mx-auto mb-4">
        <Icon name="heroicons:folder-plus" class="h-6 w-6 text-primary" />
      </div>
      <h3 class="text-lg font-medium mb-2">No projects yet</h3>
      <p class="text-muted-foreground mb-4">
        Projects let you organize your mock APIs. Start by creating one.
      </p>
      <button
        @click="showNewProjectModal = true"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Create your first project
      </button>
    </div>

    <!-- No Results -->
    <div
      v-else
      class="text-center py-12"
    >
      <p class="text-muted-foreground">No projects found matching your search</p>
    </div>

    <!-- New/Edit Project Modal -->
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

          <div>
            <label class="block text-sm font-medium mb-1">Base Path</label>
            <div class="flex rounded-lg border bg-background overflow-hidden">
              <span class="bg-muted px-3 py-2 text-muted-foreground">/api</span>
              <input
                v-model="form.base_path"
                type="text"
                placeholder="v1"
                class="flex-1 px-3 py-2 bg-transparent border-0 focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Tags</label>
            <input
              v-model="form.tags"
              type="text"
              placeholder="Add tags separated by commas"
              class="w-full rounded-lg border bg-background px-3 py-2"
            />
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
import { ref, computed } from 'vue'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const supabase = useSupabaseClient()
const user = useState('user')
const organization = ref(null)
const projects = ref<any[]>([])
const showNewProjectModal = ref(false)
const isSubmitting = ref(false)
const editingProject = ref(null)
const searchQuery = ref('')
const sortBy = ref('updated')

const form = reactive({
  name: '',
  description: '',
  base_path: '',
  tags: ''
})

const filteredProjects = computed(() => {
  let result = [...projects.value]
  
  // Apply search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(p => 
      p.name.toLowerCase().includes(query) ||
      p.description?.toLowerCase().includes(query) ||
      p.tags?.some((t: string) => t.toLowerCase().includes(query))
    )
  }
  
  // Apply sorting
  result.sort((a, b) => {
    switch (sortBy.value) {
      case 'name':
        return a.name.localeCompare(b.name)
      default: // 'updated'
        return new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
    }
  })
  
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
    .order('updated_at', { ascending: false })

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
    const org = organization.value

    if (!org?.id) {
      alert('Organization not found. Please refresh the page.')
      return
    }

    const projectData = {
      name: form.name.trim(),
      description: form.description.trim(),
      base_path: form.base_path.trim(),
      tags: form.tags.split(',').map(t => t.trim()).filter(Boolean)
    }

    if (!projectData.name) {
      alert('Project name is required')
      return
    }

    if (editingProject.value) {
      const { error } = await supabase
        .from('projects')
        .update(projectData)
        .eq('id', editingProject.value.id)

      if (error) throw error
    } else {
      const { error } = await supabase
        .from('projects')
        .insert([{
          ...projectData,
          organization_id: org.id
        }])

      if (error) throw error
    }

    await loadProjects()
    closeModal()
  } catch (error) {
    console.error('Error saving project:', error)
    alert(error instanceof Error ? error.message : 'Failed to save project')
  } finally {
    isSubmitting.value = false
  }
}

const editProject = (project: any) => {
  editingProject.value = project
  form.name = project.name
  form.description = project.description || ''
  form.base_path = project.base_path || ''
  form.tags = (project.tags || []).join(', ')
  showNewProjectModal.value = true
}

const duplicateProject = async (project: any) => {
  const org = organization.value
  if (!org?.id) {
    alert('Organization not found. Please refresh the page.')
    return
  }

  const newName = `${project.name} (Copy)`
  try {
    const { error } = await supabase
      .from('projects')
      .insert([{
        name: newName,
        description: project.description,
        base_path: project.base_path,
        tags: project.tags,
        organization_id: org.id,
        is_favorite: project.is_favorite
      }])

    if (error) throw error
    await loadProjects()
  } catch (error) {
    console.error('Error duplicating project:', error)
    alert('Failed to duplicate project')
  }
}

const toggleFavorite = async (project: any) => {
  try {
    const { error } = await supabase
      .from('projects')
      .update({ is_favorite: !project.is_favorite })
      .eq('id', project.id)

    if (error) throw error
    project.is_favorite = !project.is_favorite
  } catch (error) {
    console.error('Error toggling favorite:', error)
  }
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
    alert('Failed to delete project')
  }
}

const closeModal = () => {
  showNewProjectModal.value = false
  editingProject.value = null
  form.name = ''
  form.description = ''
  form.base_path = ''
  form.tags = ''
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

onMounted(async () => {
  await initializeOrganization()
  await loadProjects()
})
</script>
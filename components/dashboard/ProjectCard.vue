<!-- Project Card Component -->
<template>
  <div class="rounded-lg border bg-card">
    <div class="border-b p-6">
      <h2 class="text-lg font-medium">Projects</h2>
      <p class="mt-1 text-sm text-muted-foreground">Your active API projects</p>
    </div>
    <div class="divide-y">
      <div v-for="project in projects" :key="project.id" class="p-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-3">
            <div class="h-8 w-8 rounded bg-primary/10 flex items-center justify-center">
              <Icon name="heroicons:folder" class="h-5 w-5 text-primary" />
            </div>
            <div>
              <h3 class="font-medium">{{ project.name }}</h3>
              <p class="text-sm text-muted-foreground">{{ project.endpoints }} endpoints</p>
            </div>
          </div>
          <button class="rounded-md p-2 hover:bg-muted">
            <Icon name="heroicons:ellipsis-vertical" class="h-5 w-5" />
          </button>
        </div>
      </div>
    </div>
    <div class="border-t p-4">
      <button class="w-full rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90">
        Create New Project
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
// TODO: Replace with actual project data from Supabase
const projects = ref([
  { id: 1, name: 'E-commerce API', endpoints: 12 },
  { id: 2, name: 'Blog API', endpoints: 8 },
  { id: 3, name: 'Auth Service', endpoints: 5 },
])
</script>
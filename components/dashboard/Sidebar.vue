<template>
  <aside v-if="organization" class="fixed top-0 bottom-0 w-64 flex flex-col border-r bg-muted/10">
    <!-- Logo -->
    <div class="flex h-16 items-center border-b px-6">
      <div class="flex items-center space-x-2">
        <span class="text-lg font-bold tracking-tight">ZAPI</span>
        <div class="h-5 w-[1px] bg-foreground/20"></div>
        <span class="text-sm text-muted-foreground">API Mocking</span>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 min-h-0 space-y-1 px-3 py-4 overflow-y-auto">
      <NuxtLink
        v-for="item in navigation"
        :key="item.name"
        :to="getNavigationUrl[item.href.split('/')[2] || 'dashboard']"
        :class="[
          'group flex items-center rounded-md px-3 py-2 text-sm font-medium',
          $route.path.endsWith(item.href.split('/')[2] || 'dashboard')
            ? 'bg-primary text-primary-foreground'
            : 'text-foreground/60 hover:bg-muted hover:text-foreground'
        ]"
      >
        <Icon :name="item.icon" class="mr-3 h-5 w-5" />
        {{ item.name }}
      </NuxtLink>
    </nav>

    <!-- Organization Info -->
    <div class="flex-shrink-0 border-t p-4">
      <div class="flex items-center space-x-3">
        <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
          <span class="text-sm font-medium text-primary">{{ orgInitials }}</span>
        </div>
        <div class="min-w-0 flex-1">
          <p class="truncate text-sm font-medium text-foreground">{{ organization.name }}</p>
          <p class="truncate text-xs text-muted-foreground">{{ organization.subdomain }}.getzapi.com</p>
        </div>
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
const config = useRuntimeConfig()

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: 'heroicons:home' },
  { name: 'Endpoints', href: '/dashboard/endpoints', icon: 'heroicons:code-bracket' },
  { name: 'Request Logs', href: '/dashboard/logs', icon: 'heroicons:document-text' },
  { name: 'Projects', href: '/dashboard/projects', icon: 'heroicons:folder' },
  { name: 'Team', href: '/dashboard/team', icon: 'heroicons:users' },
  { name: 'Settings', href: '/dashboard/settings', icon: 'heroicons:cog-6-tooth' },
]

const route = useRoute()
const organization = useState('organization')

const orgInitials = computed(() => {
  if (!organization.value?.name) return ''
  return organization.value.name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
})

const getNavigationUrl = computed(() => {
  if (!organization.value?.subdomain) return {}
  
  const basePath = `/${organization.value.subdomain}/dashboard`
    
  return {
    dashboard: basePath,
    endpoints: `${basePath}/endpoints`,
    logs: `${basePath}/logs`,
    projects: `${basePath}/projects`,
    team: `${basePath}/team`,
    settings: `${basePath}/settings`
  }
})
</script>
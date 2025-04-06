<template>
  <header class="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
    <div class="container flex h-16 items-center">
      <div class="mr-8 flex-shrink-0">
        <a href="/" class="flex items-center space-x-2">
          <div class="flex items-center space-x-1">
            <span class="text-lg font-bold tracking-tight">ZAPI</span>
            <div class="h-5 w-[1px] bg-foreground/20"></div>
            <span class="text-sm text-muted-foreground">API Mocking</span>
          </div>
        </a>
      </div>
      <nav class="flex flex-1 items-center justify-between">
        <div class="flex items-center space-x-6 text-sm">
          <a href="#features" class="text-foreground/60 transition-colors hover:text-foreground">Features</a>
          <a href="#pricing" class="text-foreground/60 transition-colors hover:text-foreground">Pricing</a>
          <a href="/docs" class="text-foreground/60 transition-colors hover:text-foreground">Docs</a>
        </div>
        <div v-if="mounted" class="flex items-center space-x-4">
          <template v-if="!user">
            <button @click="toggleTheme" class="rounded-md p-2 hover:bg-muted">
              <Icon v-if="isDark" name="heroicons:sun" class="h-5 w-5" />
              <Icon v-else name="heroicons:moon" class="h-5 w-5" />
            </button>
            <a href="/login" class="text-sm text-foreground/60 transition-colors hover:text-foreground">Sign in</a>
            <a href="/signup" class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90">
              Get Started
            </a>
          </template>
          <template v-else-if="organization">
            <button @click="toggleTheme" class="rounded-md p-2 hover:bg-muted">
              <Icon v-if="isDark" name="heroicons:sun" class="h-5 w-5" />
              <Icon v-else name="heroicons:moon" class="h-5 w-5" />
            </button>
            <a :href="getDashboardUrl(organization.subdomain)" class="text-foreground/60 transition-colors hover:text-foreground">Dashboard</a>
            <ProfileMenu />
          </template>
        </div>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts">
import { useDark, useStorage } from '@vueuse/core'
import { ref, onMounted } from 'vue'
const config = useRuntimeConfig()

const user = useState('user')
const organization = useState('organization')
const mounted = ref(false)
const isDark = useDark()
const colorScheme = useStorage('color-scheme', 'light')

const getDashboardUrl = (subdomain: string) => {
  if (config.public.useSubdomains) {
    return `https://${subdomain}.getzapi.com/dashboard`
  }
  return `/${subdomain}/dashboard`
}

const toggleTheme = () => {
  isDark.value = !isDark.value
  colorScheme.value = isDark.value ? 'dark' : 'light'
  document.documentElement.classList.toggle('dark')
}

onMounted(() => {
  mounted.value = true
  // Sync with stored preference
  isDark.value = colorScheme.value === 'dark'
  document.documentElement.classList.toggle('dark', isDark.value)
})
</script>
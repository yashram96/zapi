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
        <div class="flex items-center space-x-4" v-if="!user">
          <button v-if="mounted" @click="toggleTheme" class="rounded-md p-2 hover:bg-muted">
            <Icon v-if="isDark" name="heroicons:sun" class="h-5 w-5" />
            <Icon v-else name="heroicons:moon" class="h-5 w-5" />
          </button>
          <a href="/login" class="text-sm text-foreground/60 transition-colors hover:text-foreground">Sign in</a>
          <a href="/signup" class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90">
            Get Started
          </a>
        </div>
        <div class="flex items-center space-x-4" v-else>
          <button @click="toggleTheme" class="rounded-md p-2 hover:bg-muted">
            <Icon v-if="isDark" name="heroicons:sun" class="h-5 w-5" />
            <Icon v-else name="heroicons:moon" class="h-5 w-5" />
          </button>
          <a :href="dashboardUrl" class="text-foreground/60 transition-colors hover:text-foreground">Dashboard</a>
          <ProfileMenu />
        </div>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts">
import { useDark, useStorage } from '@vueuse/core'
import { ref, onMounted } from 'vue'

const { supabase } = useSupabase()
const user = ref(null)
const mounted = ref(false)
const isDark = useDark()
const colorScheme = useStorage('color-scheme', 'light')
const dashboardUrl = ref('')

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
  
  // Check auth state
  supabase.auth.getUser().then(({ data: { user: authUser } }) => {
    user.value = authUser
    if (user.value) {
      // Get user's organization
      supabase
        .from('organization_members')
        .select('organization_id')
        .eq('user_id', user.value.id)
        .single()
        .then(({ data: memberData }) => {
          if (memberData) {
            // Get organization details
            supabase
              .from('organizations')
              .select('subdomain')
              .eq('id', memberData.organization_id)
              .single()
              .then(({ data: orgData }) => {
                if (orgData) {
                  dashboardUrl.value = `https://${orgData.subdomain}.getzapi.com/dashboard`
                }
              })
          }
        })
    }
  })

  // Listen for auth changes
  supabase.auth.onAuthStateChange((event, session) => {
    user.value = session?.user || null
  })
})
</script>
<template>
  <div class="relative">
    <button
      @click="isOpen = !isOpen"
      class="flex items-center space-x-2 rounded-full bg-muted/50 p-2 hover:bg-muted"
    >
      <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
        <span class="text-sm font-medium text-primary">{{ userInitials }}</span>
      </div>
    </button>

    <div
      v-if="isOpen"
      class="absolute right-0 mt-2 w-48 rounded-md bg-background py-1 shadow-lg ring-1 ring-black ring-opacity-5"
    >
      <div class="px-4 py-2 text-sm">
        <div class="font-medium">{{ profile?.name }}</div>
        <div class="text-muted-foreground">{{ profile?.subdomain }}.zapi.dev</div>
      </div>
      <div class="border-t"></div>
      <NuxtLink
        to="/dashboard"
        class="block px-4 py-2 text-sm hover:bg-muted"
      >
        Dashboard
      </NuxtLink>
      <NuxtLink
        to="/dashboard/settings"
        class="block px-4 py-2 text-sm hover:bg-muted"
      >
        Settings
      </NuxtLink>
      <div class="border-t"></div>
      <button
        @click="handleSignOut"
        class="block w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-muted"
      >
        Sign out
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

const { supabase, signOut } = useSupabase()
const router = useRouter()

const isOpen = ref(false)
const profile = ref<any>(null)

const userInitials = computed(() => {
  if (!profile.value?.name) return ''
  return profile.value.name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
})

const handleSignOut = async () => {
  await signOut()
  router.push('/')
}

// Close menu when clicking outside
const closeMenu = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.relative')) {
    isOpen.value = false
  }
}

onMounted(async () => {
  document.addEventListener('click', closeMenu)
  
  // Get user profile
  const { data: { user } } = await supabase.auth.getUser()
  if (user) {
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()
    
    if (data) {
      profile.value = data
    }
  }
})

onUnmounted(() => {
  document.removeEventListener('click', closeMenu)
})
</script>
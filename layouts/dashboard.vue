<template>
  <div v-if="mounted && user" class="flex min-h-screen">
    <Sidebar />
    <div class="flex-1 flex flex-col ml-64 relative">
      <div class="sticky top-0 z-40 flex justify-between items-center border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div class="flex-1"></div>
        <div class="flex h-16 items-center justify-end px-6">
          <button @click="toggleTheme" class="rounded-md p-2 hover:bg-muted mr-4">
            <Icon v-if="isDark" name="heroicons:sun" class="h-5 w-5" />
            <Icon v-else name="heroicons:moon" class="h-5 w-5" />
          </button>
          <ProfileMenu />
        </div>
      </div>
      <main class="flex-1 relative">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Sidebar from '~/components/dashboard/Sidebar.vue'
import ProfileMenu from '~/components/ProfileMenu.vue'
import { useDark } from '@vueuse/core'

const { supabase } = useSupabase()
const isDark = useDark()
const mounted = ref(false)
const user = useState('user')

const toggleTheme = async () => {
  isDark.value = !isDark.value
  
  // Save preference to database
  if (user.value) {
    await supabase
      .from('profiles')
      .update({ theme_preference: isDark.value ? 'dark' : 'light' })
      .eq('id', user.value.id)
  }
}

onMounted(async () => {
  // Load user's theme preference
  if (user.value) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('theme_preference')
      .eq('id', user.value.id)
      .single()
    
    if (profile) {
      isDark.value = profile.theme_preference === 'dark'
    }
  }
  mounted.value = true
})
</script>
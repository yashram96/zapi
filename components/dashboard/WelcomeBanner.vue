<template>
  <div class="mb-8 bg-card rounded-lg border p-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-semibold">👋 Welcome back, {{ profile?.display_name || 'User' }}!</h1>
        <p class="mt-1 text-muted-foreground">Your workspace: {{ organization?.subdomain }}.getzapi.com</p>
      </div>
      <div class="flex items-center space-x-4">
        <div class="text-sm text-muted-foreground">
          <span class="inline-flex items-center rounded-full bg-primary/10 px-2 py-1 text-xs font-medium text-primary">
            Free Plan
          </span>
        </div>
        <button class="rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90">
          Upgrade Plan
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const { supabase } = useSupabase()
const profile = ref(null)
const organization = ref(null)

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  if (user) {
    // Get user profile
    const { data: profileData } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()
    
    if (profileData) {
      profile.value = profileData
    }

    // Get user's organization
    const { data: memberData } = await supabase
      .from('organization_members')
      .select('organization_id')
      .eq('user_id', user.id)
      .single()

    if (memberData) {
      const { data: orgData } = await supabase
        .from('organizations')
        .select('*')
        .eq('id', memberData.organization_id)
        .single()

      if (orgData) {
        organization.value = orgData
      }
    }
  }
})
</script>
<template>
  <div v-if="isLoading" class="flex items-center justify-center min-h-screen">
    <div class="text-center">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
      <p class="mt-2 text-sm text-muted-foreground">Loading settings...</p>
    </div>
  </div>
  <div v-else class="flex flex-col min-h-screen">
    <div class="max-w-5xl mx-auto w-full space-y-8 p-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-2xl font-semibold">Settings</h1>
          <p class="text-muted-foreground">Manage your organization settings and preferences</p>
        </div>
        <div v-if="userRole" class="rounded-full bg-primary/10 px-3 py-1">
          <span class="text-sm font-medium capitalize text-primary">{{ userRole }} Role</span>
        </div>
      </div>

      <!-- Settings Navigation -->
      <div class="flex space-x-1 rounded-lg bg-muted p-1">
        <button
          v-for="tab in accessibleTabs"
          :key="tab.id"
          @click="activeTab = tab.id"
          :class="[
            'flex items-center space-x-2 rounded-md px-3 py-2 text-sm font-medium',
            activeTab === tab.id
              ? 'bg-background text-foreground shadow-sm'
              : 'text-muted-foreground hover:bg-background/50 hover:text-foreground'
          ]"
        >
          <Icon :name="tab.icon" class="h-4 w-4" />
          <span>{{ tab.title }}</span>
        </button>
      </div>

      <!-- Settings Content -->
      <div class="rounded-lg border bg-card">
        <div v-if="isTabReadOnly(activeTab)" class="border-b bg-muted/50 px-6 py-4">
          <div class="flex items-center space-x-2 text-sm text-muted-foreground">
            <Icon name="heroicons:eye" class="h-4 w-4" />
            <span>You have read-only access to these settings</span>
          </div>
        </div>

        <!-- Organization Info -->
        <div v-if="activeTab === 'organization'" class="p-6">
          <h2 class="text-lg font-medium">Organization Information</h2>
          <div class="mt-4 space-y-4">
            <div>
              <label class="block text-sm font-medium">Organization Name</label>
              <input
                type="text"
                :value="organization?.name"
                :disabled="isTabReadOnly('organization')"
                class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
              />
            </div>
            <div>
              <label class="block text-sm font-medium">Subdomain</label>
              <div class="mt-1 flex rounded-md">
                <input
                  type="text"
                  :value="organization?.subdomain"
                  :disabled="isTabReadOnly('organization')"
                  class="block w-full rounded-l-md border bg-background px-3 py-2"
                />
                <span class="inline-flex items-center rounded-r-md border border-l-0 bg-muted px-3 text-muted-foreground">
                  .getzapi.com
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Other tabs can be implemented similarly -->
        <div v-else class="p-6">
          <p class="text-muted-foreground">Content for {{ activeTab }} settings</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRolePermissions } from '~/composables/useRolePermissions'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const { supabase } = useSupabase()
const userRole = useState('userRole')
const organization = ref(null)
const activeTab = ref('organization')
const isLoading = ref(true)

const {
  accessibleTabs,
  canAccessTab,
  isTabReadOnly
} = useRolePermissions()

onMounted(async () => {
  try {
    // Load organization data
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
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

    // Set initial active tab to first accessible tab
    if (accessibleTabs.value.length > 0) {
      activeTab.value = accessibleTabs.value[0].id
    }
  } catch (error) {
    console.error('Error loading settings:', error)
  } finally {
    isLoading.value = false
  }
})

// Watch for tab changes and redirect if user can't access the tab
watch(activeTab, (newTab) => {
  if (!canAccessTab(newTab)) {
    activeTab.value = accessibleTabs.value[0]?.id || 'profile'
  }
})
</script>
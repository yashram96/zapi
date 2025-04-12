<template>
  <div class="flex flex-col min-h-screen relative">
    <div v-if="isLoading" class="flex items-center justify-center min-h-screen">
      <div class="text-center">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
        <p class="mt-2 text-sm text-muted-foreground">Loading settings...</p>
      </div>
    </div>
    <div v-else>
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

        <div class="rounded-lg border bg-card">
          <div v-if="isTabReadOnly(activeTab)" class="border-b bg-muted/50 px-6 py-4">
            <div class="flex items-center space-x-2 text-sm text-muted-foreground">
              <Icon name="heroicons:eye" class="h-4 w-4" />
              <span>You have read-only access to these settings</span>
            </div>
          </div>

          <div v-if="activeTab === 'organization'" class="p-6">
            <OrganizationSettings
              :organization="organization"
              :is-read-only="isTabReadOnly('organization')"
              @save="saveOrganization"
            />
          </div>

          <div v-if="activeTab === 'profile'" class="p-6">
            <ProfileSettings
              :profile="profile"
              @save="saveProfile"
            />
          </div>

          <div v-if="activeTab === 'billing'" class="p-6">
            <BillingSettings
              :plan="currentPlan"
              :billing-email="organization?.billing_email"
              @upgrade="upgradePlan"
            />
          </div>

          <div v-if="activeTab === 'security'" class="p-6">
            <SecuritySettings
              :two-factor-enabled="twoFactorEnabled"
              :login-history="loginHistory"
              @enable-2fa="enable2FA"
              @disable-2fa="disable2FA"
            />
          </div>

          <div v-if="activeTab === 'auth'" class="p-6">
            <ApiKeySettings
              :api-keys="apiKeys"
              :projects="projects"
              @create="createApiKey"
              @delete="deleteApiKey"
            />
          </div>

          <div v-if="activeTab === 'integrations'" class="p-6">
            <IntegrationSettings
              :integrations="availableIntegrations"
              @connect="connectIntegration"
            />
          </div>

          <div v-if="activeTab === 'webhooks'" class="p-6">
            <WebhookSettings
              :webhooks="webhooks"
              :available-events="availableEvents"
              @create="createWebhook"
              @toggle="toggleWebhook"
              @delete="deleteWebhook"
            />
          </div>

          <div v-if="activeTab === 'danger'" class="p-6">
            <DangerZoneSettings
              :organization="organization"
              @delete-organization="deleteOrganization"
              @transfer-ownership="transferOwnership"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRolePermissions } from '~/composables/useRolePermissions'
import OrganizationSettings from '~/components/settings/OrganizationSettings.vue'
import ApiKeySettings from '~/components/settings/ApiKeySettings.vue'
import IntegrationSettings from '~/components/settings/IntegrationSettings.vue'
import WebhookSettings from '~/components/settings/WebhookSettings.vue'
import ProfileSettings from '~/components/settings/ProfileSettings.vue'
import BillingSettings from '~/components/settings/BillingSettings.vue'
import SecuritySettings from '~/components/settings/SecuritySettings.vue'
import DangerZoneSettings from '~/components/settings/DangerZoneSettings.vue'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})

const { supabase } = useSupabase()
const userRole = useState('userRole')
const organization = ref(null)
const activeTab = ref('organization')
const isLoading = ref(true)
const profile = ref(null)
const currentPlan = ref('free')
const twoFactorEnabled = ref(false)
const loginHistory = ref([])
const apiKeys = ref([])
const projects = ref([])
const webhooks = ref([])

const availableIntegrations = [
  {
    type: 'github',
    name: 'GitHub',
    description: 'Connect your GitHub repositories to sync API documentation'
  },
  {
    type: 'postman',
    name: 'Postman',
    description: 'Import collections from Postman'
  },
  {
    type: 'swagger',
    name: 'Swagger',
    description: 'Import OpenAPI/Swagger specifications'
  }
]

const availableEvents = [
  { value: 'endpoint.created', label: 'Endpoint Created' },
  { value: 'endpoint.updated', label: 'Endpoint Updated' },
  { value: 'endpoint.deleted', label: 'Endpoint Deleted' },
  { value: 'request.received', label: 'Request Received' }
]

const {
  accessibleTabs,
  canAccessTab,
  isTabReadOnly
} = useRolePermissions()

// Save organization changes
const saveOrganization = async (form: any) => {
  try {
    const { error } = await supabase
      .from('organizations')
      .update(form)
      .eq('id', organization.value.id)

    if (error) throw error
    organization.value = { ...organization.value, ...form }
  } catch (error) {
    console.error('Error saving organization:', error)
  }
}

// API Key functions
const createApiKey = async (form: any) => {
  try {
    const { data, error } = await supabase
      .from('api_keys')
      .insert([{
        organization_id: organization.value.id,
        name: form.name,
        access_type: form.access_type
      }])
      .select()

    if (error) throw error
    if (data) {
      apiKeys.value.push(data[0])
    }
  } catch (error) {
    console.error('Error creating API key:', error)
  }
}

const deleteApiKey = async (id: string) => {
  try {
    const { error } = await supabase
      .from('api_keys')
      .delete()
      .eq('id', id)

    if (error) throw error
    apiKeys.value = apiKeys.value.filter(key => key.id !== id)
  } catch (error) {
    console.error('Error deleting API key:', error)
  }
}

// Integration functions
const connectIntegration = async (type: string) => {
  try {
    const { error } = await supabase
      .from('integrations')
      .insert([{
        organization_id: organization.value.id,
        type
      }])

    if (error) throw error
  } catch (error) {
    console.error('Error connecting integration:', error)
  }
}

// Webhook functions
const createWebhook = async (form: any) => {
  try {
    const { data, error } = await supabase
      .from('webhooks')
      .insert([{
        organization_id: organization.value.id,
        url: form.url,
        events: form.events,
        secret: crypto.randomUUID()
      }])
      .select()

    if (error) throw error
    if (data) {
      webhooks.value.push(data[0])
    }
  } catch (error) {
    console.error('Error creating webhook:', error)
  }
}

const toggleWebhook = async (webhook: any) => {
  try {
    const { error } = await supabase
      .from('webhooks')
      .update({ active: !webhook.active })
      .eq('id', webhook.id)

    if (error) throw error
    webhook.active = !webhook.active
  } catch (error) {
    console.error('Error toggling webhook:', error)
  }
}

const deleteWebhook = async (id: string) => {
  try {
    const { error } = await supabase
      .from('webhooks')
      .delete()
      .eq('id', id)

    if (error) throw error
    webhooks.value = webhooks.value.filter(webhook => webhook.id !== id)
  } catch (error) {
    console.error('Error deleting webhook:', error)
  }
}

// Profile functions
const saveProfile = async (form: any) => {
  try {
    const { error } = await supabase
      .from('profiles')
      .update(form)
      .eq('id', profile.value.id)

    if (error) throw error
    profile.value = { ...profile.value, ...form }
  } catch (error) {
    console.error('Error saving profile:', error)
  }
}

// Security functions
const enable2FA = async () => {
  // Implement 2FA enablement
}

const disable2FA = async () => {
  // Implement 2FA disablement
}

// Danger zone functions
const deleteOrganization = async () => {
  try {
    const { error } = await supabase
      .from('organizations')
      .delete()
      .eq('id', organization.value.id)

    if (error) throw error
    // Redirect to home after deletion
    navigateTo('/')
  } catch (error) {
    console.error('Error deleting organization:', error)
  }
}

const transferOwnership = async (newOwnerId: string) => {
  // Implement ownership transfer
}

// Load initial data
onMounted(async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      // Load profile
      const { data: profileData } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single()

      if (profileData) {
        profile.value = profileData
      }

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

        // Load API keys
        const { data: apiKeysData } = await supabase
          .from('api_keys')
          .select('*, api_key_projects(project:projects(*))')
          .eq('organization_id', memberData.organization_id)

        if (apiKeysData) {
          apiKeys.value = apiKeysData
        }

        // Load projects
        const { data: projectsData } = await supabase
          .from('projects')
          .select('*')
          .eq('organization_id', memberData.organization_id)

        if (projectsData) {
          projects.value = projectsData
        }

        // Load webhooks
        const { data: webhooksData } = await supabase
          .from('webhooks')
          .select('*')
          .eq('organization_id', memberData.organization_id)

        if (webhooksData) {
          webhooks.value = webhooksData
        }
      }
    }
  } catch (error) {
    console.error('Error loading settings:', error)
  } finally {
    isLoading.value = false
  }
})

// Set initial active tab to first accessible tab
watch(accessibleTabs, (tabs) => {
  if (tabs.length > 0 && !canAccessTab(activeTab.value)) {
    activeTab.value = tabs[0].id
  }
}, { immediate: true })
</script>
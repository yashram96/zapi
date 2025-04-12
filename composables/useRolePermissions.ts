import { ref, computed } from 'vue'

export interface TabPermission {
  canView: boolean
  canEdit: boolean
  isReadOnly?: boolean
}

export interface SettingsTab {
  id: string
  title: string
  icon: string
  permissions: Record<string, TabPermission>
}

export const useRolePermissions = () => {
  const supabase  = useSupabaseClient()
  const userRole = useState('userRole')

  const settingsTabs = computed<SettingsTab[]>(() => [
    {
      id: 'organization',
      title: 'Organization Info',
      icon: 'heroicons:building-office',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: true },
        editor: { canView: true, canEdit: false },
        viewer: { canView: true, canEdit: false, isReadOnly: true }
      }
    },
    {
      id: 'profile',
      title: 'Profile',
      icon: 'heroicons:user',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: true },
        editor: { canView: true, canEdit: true },
        viewer: { canView: true, canEdit: true }
      }
    },
    {
      id: 'billing',
      title: 'Billing & Plan',
      icon: 'heroicons:credit-card',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: false },
        editor: { canView: false, canEdit: false },
        viewer: { canView: false, canEdit: false }
      }
    },
    {
      id: 'security',
      title: 'Security',
      icon: 'heroicons:shield-check',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: true },
        editor: { canView: false, canEdit: false },
        viewer: { canView: false, canEdit: false }
      }
    },
    {
      id: 'auth',
      title: 'API Keys',
      icon: 'heroicons:key',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: false },
        editor: { canView: false, canEdit: false },
        viewer: { canView: false, canEdit: false }
      }
    },
    {
      id: 'webhooks',
      title: 'Webhooks',
      icon: 'heroicons:bell',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: false },
        editor: { canView: false, canEdit: false },
        viewer: { canView: false, canEdit: false }
      }
    },
    {
      id: 'integrations',
      title: 'Integrations',
      icon: 'heroicons:puzzle-piece',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: true, canEdit: false },
        editor: { canView: false, canEdit: false },
        viewer: { canView: false, canEdit: false }
      }
    },
    {
      id: 'danger',
      title: 'Danger Zone',
      icon: 'heroicons:exclamation-triangle',
      permissions: {
        admin: { canView: true, canEdit: true },
        manager: { canView: false, canEdit: false },
        editor: { canView: false, canEdit: false },
        viewer: { canView: false, canEdit: false }
      }
    }
  ])

  const accessibleTabs = computed(() => {
    if (!userRole.value) return []
    return settingsTabs.value.filter(tab => {
      const permission = tab.permissions[userRole.value!]
      return permission?.canView
    })
  })

  const canAccessTab = (tabId: string) => {
    if (!userRole.value) return false
    const tab = settingsTabs.value.find(t => t.id === tabId)
    return tab?.permissions[userRole.value]?.canView || false
  }

  const isTabReadOnly = (tabId: string) => {
    if (!userRole.value) return true
    const tab = settingsTabs.value.find(t => t.id === tabId)
    return tab?.permissions[userRole.value]?.isReadOnly || false
  }

  return {
    userRole,
    settingsTabs,
    accessibleTabs,
    canAccessTab,
    isTabReadOnly
  }
}
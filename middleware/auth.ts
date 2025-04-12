export default defineNuxtRouteMiddleware(async (to, from) => {
  const supabase = useSupabaseClient()
  const config = useRuntimeConfig()
  const useSubdomains = config.public.useSubdomains
  const userState = useState('user')
  const userRole = useState('userRole')
  const organizationState = useState('organization')
  const isAuthChecking = useState('isAuthChecking', () => false) 
  const onboardingChecked = useState('onboardingChecked', () => false)

  // Prevent multiple simultaneous auth checks
  if (isAuthChecking.value) {
    return
  }

  // Skip auth check if we already have user data
  if (!userState.value) {
    isAuthChecking.value = true
    try {
      const { data: { session }, error } = await supabase.auth.getSession()
      
      if (!session) {
        isAuthChecking.value = false
        return navigateTo('/login')
      }

      userState.value = session.user
    } finally {
      isAuthChecking.value = false
    }
  }

  // Fetch role if not already set
  if (!userRole.value && userState.value) {
    const { data } = await supabase
      .from('organization_members')
      .select('role')
      .eq('user_id', userState.value.id)
      .single()
    
    if (data) {
      userRole.value = data.role
    }
  }

  // Extract subdomain from path
  const pathMatch = to.path.match(/^\/([^\/]+)\/dashboard/)
  const potentialSubdomain = pathMatch ? pathMatch[1] : null

  // Get user's organization if not already set
  if (!organizationState.value && userState.value) {
    const { data: memberData } = await supabase
      .from('organization_members')
      .select('organization_id')
      .eq('user_id', userState.value.id)
      .single()

    if (memberData) {
      const { data: orgData } = await supabase
        .from('organizations')
        .select('subdomain')
        .eq('id', memberData.organization_id)
        .single()

      if (orgData) {
        organizationState.value = orgData
      }
    }
  }

  // Handle routing based on organization
  if (organizationState.value) {
    const subdomain = organizationState.value.subdomain

    // Handle path-based routing
    if (to.path.startsWith('/dashboard')) {
      return navigateTo(`/${subdomain}/dashboard`)
    } else if (potentialSubdomain && potentialSubdomain !== subdomain) {
      const newPath = to.path.replace(`/${potentialSubdomain}/`, `/${subdomain}/`)
      return navigateTo(newPath)
    }

    // Ensure settings page uses the correct org path
    if (to.path.includes('/settings') && !to.path.includes(`/${subdomain}/`)) {
      return navigateTo(`/${subdomain}/dashboard/settings`)
    }
  }

  // Only check onboarding status once and only if not already on onboarding page
  if (!onboardingChecked.value && to.path !== '/onboarding' && userState.value) {
    onboardingChecked.value = true
    const { data: profile } = await supabase
      .from('profiles')
      .select('onboarding_completed')
      .eq('id', userState.value.id)
      .single()

    if (profile && !profile.onboarding_completed) {
      return navigateTo('/onboarding')
    }
  }
})
export default defineNuxtRouteMiddleware(async (to, from) => {
  const { supabase } = useSupabase()
  const config = useRuntimeConfig()
  const useSubdomains = config.public.useSubdomains
  const userState = useState('user', () => null)
  const userRole = useState('userRole')
  const organizationState = useState('organization', () => null)

  // Get current session
  const { data: { session }, error } = await supabase.auth.getSession()

  if (!session) {
    return navigateTo('/login')
  }

  userState.value = session.user
  
  // Fetch role if not already set
  if (!userRole.value) {
    const { data } = await supabase
      .from('organization_members')
      .select('role')
      .eq('user_id', session.user.id)
      .single()
    
    if (data) {
      userRole.value = data.role
    }
  }

  // Extract subdomain from path
  const pathMatch = to.path.match(/^\/([^\/]+)\/dashboard/)
  const potentialSubdomain = pathMatch ? pathMatch[1] : null

  // Get user's organization
  const { data: memberData } = await supabase
    .from('organization_members')
    .select('organization_id')
    .eq('user_id', session.user.id)
    .single()

  if (memberData) {
    const { data: orgData } = await supabase
      .from('organizations')
      .select('subdomain')
      .eq('id', memberData.organization_id)
      .single()

    if (orgData) {
      organizationState.value = orgData
      const subdomain = orgData.subdomain

      // Handle path-based routing
      if (to.path.startsWith('/dashboard')) {
        // Redirect to org-specific dashboard
        return navigateTo(`/${subdomain}/dashboard`)
      } else if (potentialSubdomain && potentialSubdomain !== subdomain) {
        // Wrong org in URL, redirect to correct one
        const newPath = to.path.replace(`/${potentialSubdomain}/`, `/${subdomain}/`)
        return navigateTo(newPath)
      }

      // Ensure settings page uses the correct org path
      if (to.path.includes('/settings') && !to.path.includes(`/${subdomain}/`)) {
        return navigateTo(`/${subdomain}/dashboard/settings`)
      }
    }
  }

  // Check if user needs to complete onboarding
  if (to.path !== '/onboarding') {
    const { data: profile } = await supabase
      .from('profiles')
      .select('onboarding_completed')
      .eq('id', session.user.id)
      .single()

    if (!profile?.onboarding_completed) {
      return navigateTo('/onboarding')
    }
  }
})
export default defineNuxtRouteMiddleware(async (to, from) => {
  const { supabase } = useSupabase()
  const { data: { session }, error } = await supabase.auth.getSession()

  if (!session) {
    return navigateTo('/login')
  }

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

    if (orgData && to.path.startsWith('/dashboard')) {
      const currentHost = window.location.host
      const subdomain = orgData.subdomain

      // Check if we're not already on the correct subdomain
      if (!currentHost.startsWith(`${subdomain}.`)) {
        // Redirect to the subdomain
        const protocol = window.location.protocol
        const newUrl = `${protocol}//${subdomain}.getzapi.com${to.fullPath}`
        window.location.href = newUrl
        return
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
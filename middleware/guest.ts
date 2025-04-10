export default defineNuxtRouteMiddleware(async (to) => {
  const supabase = useSupabaseClient()
  const userState = useState('user')
  const organizationState = useState('organization')

  // Skip check if we already have user data
  if (!userState.value) {
    const { data: { session } } = await supabase.auth.getSession()
    if (session) {
      userState.value = session.user
    } else {
      return
    }
  }

  // If user is authenticated, redirect to dashboard
  if (userState.value) {
    if (!organizationState.value) {
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

    if (organizationState.value) {
      const config = useRuntimeConfig()
      if (config.public.useSubdomains) {
        // Redirect to subdomain
        const protocol = window.location.protocol
        const newUrl = `${protocol}//${organizationState.value.subdomain}.getzapi.com/dashboard`
        window.location.href = newUrl
        return
      } else {
        // Redirect to path-based URL
        return navigateTo(`/${organizationState.value.subdomain}/dashboard`)
      }
    }
  }
})
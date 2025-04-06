export default defineNuxtRouteMiddleware(async (to) => {
  const { supabase } = useSupabase()
  const { data: { session } } = await supabase.auth.getSession()

  // If user is authenticated, redirect to dashboard
  if (session) {
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
        const config = useRuntimeConfig()
        if (config.public.useSubdomains) {
          // Redirect to subdomain
          const protocol = window.location.protocol
          const newUrl = `${protocol}//${orgData.subdomain}.getzapi.com/dashboard`
          window.location.href = newUrl
          return
        } else {
          // Redirect to path-based URL
          return navigateTo(`/${orgData.subdomain}/dashboard`)
        }
      }
    }
  }
})
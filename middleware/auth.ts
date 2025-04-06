export default defineNuxtRouteMiddleware(async (to, from) => {
  const { supabase } = useSupabase()
  const { data: { session }, error } = await supabase.auth.getSession()

  if (!session) {
    return navigateTo('/login')
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
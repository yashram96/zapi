import { createClient } from '@supabase/supabase-js'
import { ref } from 'vue'
import { useRuntimeConfig } from '#app'

export const useSupabase = () => {
  const config = useRuntimeConfig()
  const supabase = createClient(
    config.public.supabaseUrl,
    config.public.supabaseKey
  )

  const user = ref(null)
  const userRole = useState('userRole', () => null)
  const loading = ref(true)

  const fetchUserRole = async (userId: string) => {
    const { data } = await supabase
      .from('organization_members')
      .select('role')
      .eq('user_id', userId)
      .single()
    
    if (data) {
      userRole.value = data.role
    }
    return data?.role
  }

  const signUp = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password
    })
    return { data, error }
  }

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    
    if (data?.user) {
      await fetchUserRole(data.user.id)
    }
    
    return { data, error }
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    userRole.value = null
    return { error }
  }

  const createOrganization = async (subdomain: string, name: string, username: string) => {
    const { data, error } = await supabase
      .from('organizations')
      .insert([{ subdomain, name }])
      .select()
      .single()

    if (data) {
      const { data: userData } = await supabase.auth.getUser()
      if (!userData?.user?.id) throw new Error('User not found')

      // Create organization membership
      await supabase
        .from('organization_members')
        .insert([{ 
          organization_id: data.id,
          user_id: userData.user.id,
          role: 'owner',
          username
        }])
    }

    return { data, error }
  }

  const checkSubdomainAvailability = async (subdomain: string) => {
    const { data, error } = await supabase
      .from('organizations')
      .select('subdomain')
      .eq('subdomain', subdomain)
      .maybeSingle()

    return { 
      available: !data && !error,
      error: error ? error.message : null
    }
  }

  return {
    user,
    loading,
    userRole,
    supabase,
    signUp,
    signIn,
    signOut,
    fetchUserRole,
    createOrganization,
    checkSubdomainAvailability
  }
}
<template>
  <div>
    <h1 class="text-xl font-semibold">Create an account</h1>
    <p class="mt-1 text-base text-muted-foreground">
      Fill in your details to get started.
    </p>

    <div v-if="error" class="mt-4 rounded-lg border border-red-200 bg-red-50 p-4 text-red-600">
      {{ error }}
    </div>

    <form @submit.prevent="handleSubmit" class="mt-6 space-y-4">
      <div>
        <label for="organizationName" class="mb-1 block text-base font-medium">Organization Name</label>
        <input
          id="organizationName"
          v-model="formData.organizationName"
          type="text"
          placeholder="My Company"
          class="w-full rounded-lg border bg-background px-4 py-2 text-foreground"
          required
        />
      </div>

      <div>
        <label for="username" class="mb-1 block text-base font-medium">Username</label>
        <input
          id="username"
          v-model="formData.username"
          type="text"
          placeholder="johndoe"
          class="w-full rounded-lg border bg-background px-4 py-2 text-foreground"
          required
        />
      </div>

      <div>
        <label for="email" class="mb-1 block text-base font-medium">Email</label>
        <input
          id="email"
          v-model="formData.email"
          type="email"
          placeholder="name@example.com"
          class="w-full rounded-lg border bg-background px-4 py-2 text-foreground"
          required
        />
      </div>

      <div>
        <label for="subdomain" class="mb-1 block text-base font-medium">Site Subdomain</label>
        <div class="flex rounded-lg border bg-background">
          <input
            id="subdomain"
            v-model="formData.subdomain"
            type="text"
            placeholder="myorg"
            class="flex-1 rounded-l-lg border-0 bg-transparent px-4 py-2 text-foreground disabled:opacity-50"
            :class="{ 
              'border-green-500 focus:border-green-500': subdomainStatus === 'available',
              'border-red-500 focus:border-red-500': subdomainStatus === 'unavailable'
            }"
            required
          />
          <span class="flex items-center gap-2 border-l px-4">
            <span v-if="subdomainStatus === 'checking'" class="text-muted-foreground">Checking...</span>
            <span v-else-if="subdomainStatus === 'available'" class="text-green-500">Available</span>
            <span v-else-if="subdomainStatus === 'unavailable'" class="text-red-500">Unavailable</span>
            <span class="text-muted-foreground">.zapi.dev</span>
          </span>
        </div>
      </div>

      <div>
        <label for="password" class="mb-1 block text-base font-medium">Password</label>
        <input
          id="password"
          v-model="formData.password"
          type="password"
          class="w-full rounded-lg border bg-background px-4 py-2 text-foreground"
          required
        />
        <div class="mt-1">
          <div class="h-1 rounded-full bg-muted">
            <div
              class="h-1 rounded-full transition-all"
              :class="{
                'bg-red-500': passwordScore === 0 || passwordScore === 1,
                'bg-yellow-500': passwordScore === 2,
                'bg-green-500': passwordScore === 3,
                'bg-emerald-500': passwordScore === 4
              }"
              :style="{ width: `${(passwordScore + 1) * 20}%` }"
            ></div>
          </div>
          <p class="mt-1 text-base text-muted-foreground">
            {{ passwordFeedback }}
          </p>
        </div>
      </div>

      <div class="flex items-center space-x-2">
        <input type="checkbox" id="terms" class="rounded border-input" required />
        <label for="terms" class="text-base text-muted-foreground">
          I agree to the
          <NuxtLink to="/terms" class="text-primary hover:underline">Terms of Service</NuxtLink>
          and
          <NuxtLink to="/privacy" class="text-primary hover:underline">Privacy Policy</NuxtLink>
        </label>
      </div>

      <button
        type="submit"
        class="mt-2 w-full rounded-lg bg-primary px-4 py-2 text-base font-medium text-primary-foreground hover:bg-primary/90"
        :disabled="isSubmitting"
      >
        {{ isSubmitting ? 'Creating Account...' : 'Create Account' }}
      </button>
    </form>

    <p class="mt-4 text-center text-base text-muted-foreground">
      Already have an account?
      <NuxtLink to="/login" class="font-medium text-primary hover:underline">
        Sign in
      </NuxtLink>
    </p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import zxcvbn from 'zxcvbn'
import { useDebounceFn, useAsyncState } from '@vueuse/core'

definePageMeta({
  layout: 'auth'
})

const { signUp, createOrganization, checkSubdomainAvailability } = useSupabase()
const { supabase } = useSupabase()
const router = useRouter()

const formData = ref({
  organizationName: '',
  username: '',
  email: '',
  subdomain: '',
  password: ''
})

const error = ref<string | null>(null)
const isSubmitting = ref(false)
const subdomainStatus = ref<'available' | 'unavailable' | 'checking' | null>(null)

const passwordScore = computed(() => {
  if (!formData.value.password) return 0
  return zxcvbn(formData.value.password).score
})

const passwordFeedback = computed(() => {
  if (!formData.value.password) return ''
  const score = passwordScore.value
  switch (score) {
    case 0:
    case 1:
      return 'Weak password'
    case 2:
      return 'Fair password'
    case 3:
      return 'Good password'
    case 4:
      return 'Strong password'
  }
})

const checkSubdomain = useDebounceFn(async () => {
  const subdomain = formData.value.subdomain?.trim().toLowerCase()
  if (!subdomain) {
    subdomainStatus.value = null
    return
  }
  
  // Validate length
  if (subdomain.length < 3 || subdomain.length > 63) {
    subdomainStatus.value = 'unavailable'
    error.value = 'Subdomain must be between 3 and 63 characters'
    return
  }

  // Validate format
  const subdomainRegex = /^[a-z0-9][a-z0-9-]*[a-z0-9]$/
  if (!subdomainRegex.test(subdomain) || subdomain.includes('--')) {
    subdomainStatus.value = 'unavailable'
    error.value = 'Subdomain can only contain lowercase letters, numbers, and hyphens. Must start and end with a letter or number.'
    return
  }
  
  subdomainStatus.value = 'checking'
  error.value = null
  const { available } = await checkSubdomainAvailability(subdomain)
  subdomainStatus.value = available ? 'available' : 'unavailable'
  if (!available) {
    error.value = 'This subdomain is already taken'
  }
}, 300)

watch(() => formData.value.subdomain, checkSubdomain)

const handleSubmit = async () => {
  try {
    error.value = null
    isSubmitting.value = true

    // Sign up user
    const { data: authData, error: authError } = await signUp(
      formData.value.email,
      formData.value.password
    )

    if (authError) {
      // Check for specific error codes
      if (authError.message === 'User already registered') {
        error.value = 'This email is already registered. Please sign in instead or use a different email address.'
        return
      }
      throw authError
    }

    if (!authData.user) throw new Error('No user data returned')

    // Create organization
    const { data: orgData, error: orgError } = await createOrganization(
      formData.value.subdomain,
      formData.value.organizationName,
      formData.value.username
    )

    if (orgError) throw orgError

    // Create initial profile
    const { error: profileError } = await supabase
      .from('profiles')
      .insert([{
        id: authData.user.id,
        name: formData.value.username,
        subdomain: formData.value.subdomain,
        onboarding_completed: false
      }])

    if (profileError) throw profileError

    // Redirect to onboarding
    router.push('/onboarding')
  } catch (err: any) {
    console.error('Error:', err)
    error.value = 'An unexpected error occurred. Please try again.'
  } finally {
    isSubmitting.value = false
  }
}
</script>
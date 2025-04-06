<template>
  <div>
    <h1 class="text-xl font-semibold">Sign in</h1>

    <form @submit.prevent="handleSubmit" class="mt-6 space-y-4">
      <div v-if="error" class="p-4 mb-4 text-sm text-red-700 bg-red-100 rounded-lg" role="alert">
        {{ error }}
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
        <label for="password" class="mb-1 block text-base font-medium">Password</label>
        <input
          id="password"
          v-model="formData.password"
          type="password"
          class="w-full rounded-lg border bg-background px-4 py-2 text-foreground"
          required
        />
      </div>

      <div class="flex items-center space-x-2">
        <input type="checkbox" id="remember" class="rounded border-input" />
        <label for="remember" class="text-base text-muted-foreground">Remember me for 30 days</label>
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full rounded-lg bg-primary px-4 py-2 text-base font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
      >
        {{ isLoading ? 'Signing in...' : 'Sign in' }}
      </button>

      <p class="mt-4 text-center text-sm text-muted-foreground">
        Need an account?
        <NuxtLink to="/signup" class="font-medium text-primary hover:underline">
          Sign up here
        </NuxtLink>
      </p>
    </form>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth',
  middleware: ['guest']
})

const { signIn } = useSupabase()
const router = useRouter()

const formData = ref({
  email: '',
  password: ''
})

const error = ref('')
const isLoading = ref(false)

const handleSubmit = async () => {
  try {
    error.value = ''
    isLoading.value = true
    
    const { data, error: authError } = await signIn(formData.value.email, formData.value.password)
    
    if (authError) {
      if (authError.message === 'Invalid login credentials') {
        error.value = 'The email or password you entered is incorrect. Please try again.'
      } else {
        error.value = 'An error occurred while signing in. Please try again.'
      }
      return
    }

    if (data) {
      await router.push('/dashboard')
    }
  } catch (err) {
    error.value = 'An unexpected error occurred. Please try again later.'
    console.error('Error:', err)
  } finally {
    isLoading.value = false
  }
}
</script>
<template>
  <div>
    <h2 class="text-lg font-medium">Security Settings</h2>
    <div class="mt-4 space-y-6">
      <!-- Change Password -->
      <div class="rounded-lg border p-4">
        <div>
          <h3 class="font-medium">Change Password</h3>
          <p class="text-sm text-muted-foreground">Update your account password</p>
        </div>
        
        <form @submit.prevent="handleChangePassword" class="mt-4 space-y-4">
          <div>
            <label class="block text-sm font-medium">Current Password</label>
            <input
              v-model="passwordForm.currentPassword"
              type="password"
              class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
              required
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium">New Password</label>
            <input
              v-model="passwordForm.newPassword"
              type="password"
              class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
              required
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium">Confirm New Password</label>
            <input
              v-model="passwordForm.confirmPassword"
              type="password"
              class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
              required
            />
          </div>

          <div v-if="passwordError" class="text-sm text-destructive">
            {{ passwordError }}
          </div>

          <button
            type="submit"
            :disabled="isChangingPassword"
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
          >
            {{ isChangingPassword ? 'Changing Password...' : 'Change Password' }}
          </button>
        </form>
      </div>

      <!-- Two-Factor Authentication -->
      <div class="rounded-lg border p-4">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-medium">Two-Factor Authentication</h3>
            <p class="text-sm text-muted-foreground">Add an extra layer of security to your account</p>
          </div>
          <button
            @click="twoFactorEnabled ? $emit('disable-2fa') : $emit('enable-2fa')"
            :class="[
              'rounded-lg px-4 py-2 text-sm font-medium',
              twoFactorEnabled
                ? 'bg-destructive text-destructive-foreground hover:bg-destructive/90'
                : 'bg-primary text-primary-foreground hover:bg-primary/90'
            ]"
          >
            {{ twoFactorEnabled ? 'Disable 2FA' : 'Enable 2FA' }}
          </button>
        </div>
      </div>

      <!-- Login History -->
      <div>
        <h3 class="font-medium mb-4">Recent Login Activity</h3>
        <div class="space-y-2">
          <div v-for="login in loginHistory" :key="login.id" class="rounded-lg border p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium">{{ login.location }}</p>
                <p class="text-xs text-muted-foreground">{{ login.device }}</p>
              </div>
              <p class="text-sm text-muted-foreground">
                {{ new Date(login.timestamp).toLocaleDateString() }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const passwordError = ref('')
const isChangingPassword = ref(false)

defineProps<{
  twoFactorEnabled: boolean
  loginHistory: Array<{
    id: string
    location: string
    device: string
    timestamp: string
  }>
}>()

defineEmits<{
  'enable-2fa': []
  'disable-2fa': []
}>()

const handleChangePassword = async () => {
  try {
    passwordError.value = ''
    isChangingPassword.value = true

    // Validate passwords match
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      passwordError.value = 'New passwords do not match'
      return
    }

    // Validate password length
    if (passwordForm.newPassword.length < 8) {
      passwordError.value = 'Password must be at least 8 characters long'
      return
    }

    const { error } = await supabase.auth.updateUser({
      password: passwordForm.newPassword
    })

    if (error) throw error

    // Clear form
    passwordForm.currentPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''

    // Show success message
    alert('Password updated successfully')
  } catch (error: any) {
    passwordError.value = error.message || 'Failed to update password'
  } finally {
    isChangingPassword.value = false
  }
}
</script>
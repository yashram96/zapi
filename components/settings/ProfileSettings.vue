<template>
  <div>
    <h2 class="text-lg font-medium">Profile Settings</h2>
    <div class="mt-4 space-y-4">
      <div>
        <label class="block text-sm font-medium">Display Name</label>
        <input
          v-model="form.display_name"
          type="text"
          class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
        />
      </div>

      <div>
        <label class="block text-sm font-medium">Avatar URL</label>
        <input
          v-model="form.avatar_url"
          type="url"
          class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
          placeholder="https://example.com/avatar.png"
        />
      </div>

      <div>
        <label class="block text-sm font-medium">Role</label>
        <select
          v-model="form.role"
          class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
        >
          <option value="frontend_developer">Frontend Developer</option>
          <option value="full_stack_developer">Full Stack Developer</option>
          <option value="qa_tester">QA Tester</option>
          <option value="designer">Designer</option>
          <option value="product_manager">Product Manager</option>
          <option value="other">Other</option>
        </select>
      </div>

      <div>
        <h3 class="text-sm font-medium mb-2">Notification Preferences</h3>
        <div class="space-y-2">
          <label class="flex items-center">
            <input
              type="checkbox"
              v-model="form.notification_preferences.email_updates"
              class="rounded border-input mr-2"
            />
            <span>Email Updates</span>
          </label>
          <label class="flex items-center">
            <input
              type="checkbox"
              v-model="form.notification_preferences.security_alerts"
              class="rounded border-input mr-2"
            />
            <span>Security Alerts</span>
          </label>
        </div>
      </div>

      <div class="pt-4">
        <button
          @click="$emit('save', form)"
          class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          Save Changes
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  profile: any
}>()

const form = reactive({
  display_name: props.profile?.display_name || '',
  avatar_url: props.profile?.avatar_url || '',
  role: props.profile?.role || '',
  notification_preferences: {
    email_updates: props.profile?.notification_preferences?.email_updates ?? true,
    security_alerts: props.profile?.notification_preferences?.security_alerts ?? true
  }
})

defineEmits<{
  save: [form: typeof form]
}>()

watch(() => props.profile, (newProfile) => {
  if (newProfile) {
    form.display_name = newProfile.display_name
    form.avatar_url = newProfile.avatar_url
    form.role = newProfile.role
    form.notification_preferences = {
      ...form.notification_preferences,
      ...newProfile.notification_preferences
    }
  }
}, { immediate: true })
</script>
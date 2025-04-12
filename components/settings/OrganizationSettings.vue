<template>
  <div class="p-6">
    <h2 class="text-lg font-medium">Organization Information</h2>
    <div class="mt-4 space-y-4">
      <div>
        <label class="block text-sm font-medium">Organization Name</label>
        <input
          type="text"
          v-model="form.name"
          :disabled="isReadOnly"
          class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
        />
      </div>
      <div>
        <label class="block text-sm font-medium">Subdomain</label>
        <div class="mt-1 flex rounded-md">
          <input
            type="text"
            v-model="form.subdomain"
            :disabled="isReadOnly"
            class="block w-full rounded-l-md border bg-background px-3 py-2"
          />
          <span class="inline-flex items-center rounded-r-md border border-l-0 bg-muted px-3 text-muted-foreground">
            .getzapi.com
          </span>
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium">Logo URL</label>
        <input
          type="url"
          v-model="form.logo_url"
          :disabled="isReadOnly"
          class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
          placeholder="https://example.com/logo.png"
        />
      </div>
      <div>
        <label class="block text-sm font-medium">Billing Email</label>
        <input
          type="email"
          v-model="form.billing_email"
          :disabled="isReadOnly"
          class="mt-1 block w-full rounded-md border bg-background px-3 py-2"
        />
      </div>
      <div class="pt-4">
        <button
          @click="$emit('save', form)"
          :disabled="isReadOnly"
          class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
        >
          Save Changes
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  organization: any
  isReadOnly: boolean
}>()

const form = reactive({
  name: props.organization?.name || '',
  subdomain: props.organization?.subdomain || '',
  logo_url: props.organization?.logo_url || '',
  billing_email: props.organization?.billing_email || ''
})

defineEmits<{
  save: [form: typeof form]
}>()

// Update form when organization changes
watch(() => props.organization, (newOrg) => {
  if (newOrg) {
    form.name = newOrg.name
    form.subdomain = newOrg.subdomain
    form.logo_url = newOrg.logo_url
    form.billing_email = newOrg.billing_email
  }
}, { immediate: true })
</script>
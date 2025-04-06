<template>
  <div class="rounded-lg border bg-card p-6">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-medium">Current Project</h2>
      <button class="text-sm text-primary hover:underline">Switch Project</button>
    </div>
    
    <div class="mt-4 space-y-4">
      <div>
        <label class="text-sm text-muted-foreground">Base URL</label>
        <div class="mt-1 flex items-center space-x-2">
          <code class="flex-1 rounded bg-muted px-2 py-1 text-sm">
            https://{{ organization?.subdomain }}.zapi.dev
          </code>
          <button class="rounded-md p-2 hover:bg-muted" @click="copyUrl">
            <Icon name="heroicons:clipboard" class="h-4 w-4" />
          </button>
        </div>
      </div>

      <div class="flex space-x-4">
        <button class="flex-1 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90">
          Create Endpoint
        </button>
        <button class="flex-1 rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted">
          View Logs
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// TODO: Replace with actual organization data from Supabase
const organization = ref({
  subdomain: 'myorg'
})

const copyUrl = () => {
  navigator.clipboard.writeText(`https://${organization.value.subdomain}.zapi.dev`)
}
</script>
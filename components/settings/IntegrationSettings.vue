<template>
  <div class="p-6">
    <h2 class="text-lg font-medium">Integrations</h2>
    <div class="mt-4 space-y-4">
      <div v-for="integration in integrations" :key="integration.type" class="rounded-lg border p-4">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-medium">{{ integration.name }}</h3>
            <p class="text-sm text-muted-foreground">{{ integration.description }}</p>
          </div>
          <button
            @click="$emit('connect', integration.type)"
            class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Connect
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  integrations: Array<{
    type: string
    name: string
    description: string
  }>
}>()

defineEmits<{
  connect: [type: string]
}>()
</script>
<template>
  <div class="rounded-lg border bg-card">
    <div class="border-b p-6">
      <h2 class="text-lg font-medium">📊 Usage Summary</h2>
      <p class="mt-1 text-sm text-muted-foreground">Your API usage this month</p>
    </div>
    <div class="grid grid-cols-1 divide-y">
      <div class="flex items-center justify-between p-6">
        <div>
          <p class="text-sm font-medium">Total Endpoints</p>
          <p class="mt-1 text-2xl font-semibold">{{ stats.endpoints }}</p>
        </div>
        <div class="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center">
          <Icon name="heroicons:code-bracket" class="h-6 w-6 text-primary" />
        </div>
      </div>

      <div class="flex items-center justify-between p-6">
        <div>
          <p class="text-sm font-medium">API Requests</p>
          <p class="mt-1 text-2xl font-semibold">{{ stats.requests }}</p>
        </div>
        <div class="h-12 w-12 rounded-full bg-secondary/10 flex items-center justify-center">
          <Icon name="heroicons:arrow-path" class="h-6 w-6 text-secondary" />
        </div>
      </div>

      <div class="flex items-center justify-between p-6">
        <div>
          <p class="text-sm font-medium">Active Auth Tokens</p>
          <p class="mt-1 text-2xl font-semibold">{{ stats.tokens }}</p>
        </div>
        <div class="h-12 w-12 rounded-full bg-accent/10 flex items-center justify-center">
          <Icon name="heroicons:key" class="h-6 w-6 text-accent" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// TODO: Replace with actual stats from Supabase
const stats = ref({
  endpoints: 4,
  requests: '1,304',
  tokens: 2
})
</script>
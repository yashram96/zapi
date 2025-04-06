<!-- Quick Start Component -->
<template>
  <div class="rounded-lg border bg-card">
    <div class="border-b p-6">
      <h2 class="text-lg font-medium">🚀 Quick Start</h2>
      <p class="mt-1 text-sm text-muted-foreground">Create your first API endpoint in seconds</p>
    </div>
    <div class="p-6">
      <div class="space-y-4">
        <button
          class="w-full flex items-center justify-between rounded-lg border p-4 hover:bg-muted/50 transition-colors"
          @click="createEndpoint('get-hello')"
        >
          <div class="flex items-center space-x-4">
            <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
              <Icon name="heroicons:code-bracket" class="h-5 w-5 text-primary" />
            </div>
            <div class="text-left">
              <h3 class="font-medium">GET /hello</h3>
              <p class="text-sm text-muted-foreground">Simple "Hello, World!" endpoint</p>
            </div>
          </div>
          <Icon name="heroicons:arrow-right" class="h-5 w-5 text-muted-foreground" />
        </button>

        <button
          class="w-full flex items-center justify-between rounded-lg border p-4 hover:bg-muted/50 transition-colors"
          @click="createEndpoint('post-auth')"
        >
          <div class="flex items-center space-x-4">
            <div class="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
              <Icon name="heroicons:key" class="h-5 w-5 text-primary" />
            </div>
            <div class="text-left">
              <h3 class="font-medium">POST /auth/login</h3>
              <p class="text-sm text-muted-foreground">Authentication endpoint template</p>
            </div>
          </div>
          <Icon name="heroicons:arrow-right" class="h-5 w-5 text-muted-foreground" />
        </button>

        <NuxtLink
          to="/dashboard/endpoints/new"
          class="block w-full text-center rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
        >
          Create Custom Endpoint
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const router = useRouter()

const createEndpoint = (template: string) => {
  // TODO: Implement endpoint creation
  router.push('/dashboard/endpoints/new?template=' + template)
}
</script>
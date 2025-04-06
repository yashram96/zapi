<template>
  <div class="rounded-lg border bg-card">
    <div class="border-b p-6">
      <h2 class="text-lg font-medium">💡 Tip of the Day</h2>
      <p class="mt-1 text-sm text-muted-foreground">Quick tips to help you get the most out of Zapi</p>
    </div>
    <div class="p-6">
      <div class="rounded-lg bg-muted/50 p-4">
        <h3 class="font-medium">{{ currentTip.title }}</h3>
        <p class="mt-2 text-sm text-muted-foreground">{{ currentTip.description }}</p>
        <NuxtLink 
          :to="currentTip.link" 
          class="mt-4 inline-flex items-center text-sm font-medium text-primary hover:underline"
        >
          Learn more
          <Icon name="heroicons:arrow-right" class="ml-1 h-4 w-4" />
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const tips = [
  {
    title: 'Use Auth Headers for Protected Routes',
    description: 'Add authentication headers to your endpoints to simulate protected API routes. Perfect for testing auth flows.',
    link: '/docs/auth-headers'
  },
  {
    title: 'Dynamic Response Templates',
    description: 'Use template variables in your responses to generate dynamic data like timestamps and UUIDs.',
    link: '/docs/templates'
  },
  {
    title: 'Conditional Responses',
    description: 'Return different responses based on request parameters, headers, or body content.',
    link: '/docs/conditional-responses'
  }
]

// Randomly select a tip each day
const currentTip = computed(() => {
  const dayOfYear = Math.floor(Date.now() / (1000 * 60 * 60 * 24))
  return tips[dayOfYear % tips.length]
})
</script>
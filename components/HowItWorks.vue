<template>
  <section class="py-24 sm:py-32 bg-muted/50">
    <div class="container">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-3xl font-bold tracking-tight sm:text-4xl">How Zapi Works</h2>
        <p class="mt-6 text-lg leading-8 text-muted-foreground">
          Get started in three simple steps
        </p>
      </div>
      <div class="mx-auto mt-16 max-w-7xl">
        <div class="grid grid-cols-1 gap-8 md:grid-cols-3">
          <div v-for="(step, index) in steps" :key="step.title" 
               class="relative flex flex-col items-center p-6 bg-background rounded-lg shadow-sm">
            <div class="flex h-12 w-12 items-center justify-center rounded-full bg-primary text-primary-foreground text-lg font-semibold mb-4">
              {{ index + 1 }}
            </div>
            <h3 class="text-xl font-semibold mb-2">{{ step.title }}</h3>
            <p class="text-center text-muted-foreground">{{ step.description }}</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const steps = [
  {
    title: 'Sign Up',
    description: 'Create an account and choose your subdomain (e.g., yourorg.zapi.dev)',
  },
  {
    title: 'Define Endpoint',
    description: 'Specify your endpoint path, response payload, and authentication requirements',
  },
  {
    title: 'Start Using',
    description: 'Use your mock API endpoint in your frontend application immediately',
  },
]
</script>
<template>
  <section class="py-24 sm:py-32">
    <div class="container">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-3xl font-bold tracking-tight sm:text-4xl">Everything you need to mock APIs</h2>
        <p class="mt-6 text-lg leading-8 text-muted-foreground">
          Focus on building great frontends while Zapi handles your mock API needs.
        </p>
      </div>
      <div class="mx-auto mt-16 max-w-7xl sm:mt-20 lg:mt-24">
        <dl class="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-3 lg:gap-y-16">
          <div v-for="feature in features" :key="feature.name" class="relative pl-16">
            <dt class="text-base font-semibold leading-7">
              <div class="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-primary">
                <component :is="feature.icon" class="h-6 w-6 text-primary-foreground" aria-hidden="true" />
              </div>
              {{ feature.name }}
            </dt>
            <dd class="mt-2 text-base leading-7 text-muted-foreground">{{ feature.description }}</dd>
          </div>
        </dl>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const features = [
  {
    name: 'Mock endpoints in seconds',
    description: 'Create custom API endpoints with JSON responses in just a few clicks. No coding required.',
    icon: 'i-heroicons-bolt',
  },
  {
    name: 'Custom responses & status codes',
    description: 'Define different response scenarios, status codes, and headers for realistic API behavior.',
    icon: 'i-heroicons-code-bracket',
  },
  {
    name: 'Authentication ready',
    description: 'Secure your endpoints with API keys or JWT tokens. Test auth flows with ease.',
    icon: 'i-heroicons-key',
  },
]
</script>
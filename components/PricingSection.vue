<template>
  <section class="py-24 sm:py-32">
    <div class="container">
      <div class="mx-auto max-w-2xl text-center">
        <h2 class="text-3xl font-bold tracking-tight sm:text-4xl">Simple, transparent pricing</h2>
        <p class="mt-6 text-lg leading-8 text-muted-foreground">
          Start for free, upgrade when you need more
        </p>
      </div>
      <div class="mx-auto mt-16 max-w-lg">
        <div class="rounded-2xl bg-muted p-8 ring-1 ring-muted-foreground/10">
          <h3 class="text-sm font-semibold leading-6">Free Forever</h3>
          <p class="mt-8 flex items-baseline justify-start gap-x-2">
            <span class="text-4xl font-bold tracking-tight">$0</span>
            <span class="text-sm font-semibold leading-6 text-muted-foreground">/month</span>
          </p>
          <ul role="list" class="mt-10 space-y-4 text-sm leading-6">
            <li v-for="feature in features" :key="feature" class="flex gap-x-3">
              <div class="h-6 w-6 flex-none text-primary">
                <div class="i-heroicons-check h-6 w-6" aria-hidden="true" />
              </div>
              {{ feature }}
            </li>
          </ul>
          <a href="/signup" class="mt-8 block rounded-md bg-primary px-3.5 py-2 text-center text-sm font-semibold leading-6 text-primary-foreground shadow-sm hover:bg-primary/90">
            Get Started
          </a>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const features = [
  'Up to 50 endpoints',
  'Basic authentication',
  'Custom response payloads',
  'Status code simulation',
  'Real-time request logs',
]
</script>
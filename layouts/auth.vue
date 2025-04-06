<template>
  <div class="flex min-h-screen">
    <!-- Auth Form Section -->
    <div class="w-full max-w-md p-8 sm:p-12">
      <div class="mb-8 flex items-center">
        <NuxtLink to="/" class="mr-4 flex h-8 w-8 items-center justify-center rounded-lg hover:bg-muted">
          <Icon name="heroicons:arrow-left" class="h-5 w-5" />
        </NuxtLink>
        <NuxtLink to="/" class="flex items-center space-x-2">
          <div class="flex items-center space-x-1">
            <span class="text-lg font-bold tracking-tight">ZAPI</span>
            <div class="h-5 w-[1px] bg-foreground/20"></div>
            <span class="text-sm text-muted-foreground">API Mocking</span>
          </div>
        </NuxtLink>
      </div>
      <slot />
    </div>

    <!-- Image Section -->
    <div class="hidden w-full bg-gradient-to-r from-purple-600 via-blue-500 to-orange-500 lg:block">
      <div class="relative h-full w-full">
        <div class="absolute inset-0 bg-background/10 backdrop-blur-sm"></div>
        <div class="relative z-10 flex h-full flex-col items-center justify-center p-12 text-white">
          <div class="rounded-lg bg-white/10 px-4 py-1 text-sm backdrop-blur">WHAT'S NEW?</div>
          <h2 class="mt-8 text-4xl font-bold">15 new integrations added</h2>
          <p class="mt-4 text-center text-lg text-white/90">
            You asked and we listened! We've added a bunch of new integrations to speed up your workflow.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
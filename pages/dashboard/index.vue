<template>
  <div>
    <WelcomeBanner />
    
    <div class="grid gap-8 lg:grid-cols-2">
      <ProjectCard />
      <div class="space-y-8">
        <div class="grid grid-cols-2 gap-4">
          <div class="rounded-lg border bg-card p-6">
            <h3 class="text-lg font-medium">Total Endpoints</h3>
            <p class="mt-2 text-3xl font-semibold">12</p>
          </div>
          <div class="rounded-lg border bg-card p-6">
            <h3 class="text-lg font-medium">Today's Requests</h3>
            <p class="mt-2 text-3xl font-semibold">1,234</p>
          </div>
        </div>
      </div>
    </div>

    <div class="mt-8">
      <RecentRequests />
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})
</script>
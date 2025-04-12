<template>
  <div class="max-w-[1920px] mx-auto space-y-8">
    <WelcomeBanner />
    <div class="grid gap-8 lg:grid-cols-2">
      <UsageSummary />
    </div>
    <div class="grid gap-8 lg:grid-cols-2">
      <RecentRequests />
      <ProjectCard />
    </div>
  </div>
</template>

<script setup lang="ts">
import WelcomeBanner from '~/components/dashboard/WelcomeBanner.vue'
import UsageSummary from '~/components/dashboard/UsageSummary.vue'
import RecentRequests from '~/components/dashboard/RecentRequests.vue'
import ProjectCard from '~/components/dashboard/ProjectCard.vue'

definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})
</script>
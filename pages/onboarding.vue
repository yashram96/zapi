<template>
  <div class="flex min-h-screen items-center justify-center bg-muted/10 py-12">
    <OnboardingFlow />
  </div>
</template>

<script setup lang="ts">
import OnboardingFlow from '~/components/onboarding/OnboardingFlow.vue'

definePageMeta({
  middleware: ['auth']
})
</script>
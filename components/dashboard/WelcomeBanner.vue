<template>
  <div class="mb-8">
    <h1 class="text-2xl font-semibold">👋 Welcome back, {{ username }}!</h1>
    <p class="mt-1 text-muted-foreground">Here's what's happening with your API mocks.</p>
  </div>
</template>

<script setup lang="ts">
// TODO: Replace with actual user data from Supabase
const username = ref('User')
</script>
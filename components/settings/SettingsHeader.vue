<template>
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-2xl font-semibold">Settings</h1>
      <p class="text-muted-foreground">Manage your organization settings and preferences</p>
    </div>
    <div v-if="userRole" class="rounded-full bg-primary/10 px-3 py-1">
      <span class="text-sm font-medium capitalize text-primary">{{ userRole }} Role</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  userRole: string | null
}>()
</script>
<template>
  <div 
    class="fixed top-4 right-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg shadow-lg z-50 flex items-center"
    role="alert"
  >
    <Icon name="heroicons:check-circle" class="h-5 w-5 mr-2" />
    <span>{{ message }}</span>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  message: string
}>()
</script>
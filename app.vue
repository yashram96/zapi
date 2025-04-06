<script setup lang="ts">
import { useDark, useStorage } from '@vueuse/core'
import { onMounted } from 'vue'

const isDark = useDark()
const colorScheme = useStorage('color-scheme', 'light')

onMounted(() => {
  // Sync with stored preference
  isDark.value = colorScheme.value === 'dark'
  // Update class immediately
  document.documentElement.classList.toggle('dark', isDark.value)
})

// Watch for changes and persist
watch(isDark, (val) => {
  colorScheme.value = val ? 'dark' : 'light'
})
</script>

<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<style>
@import '@/assets/css/tailwind.css';
</style>
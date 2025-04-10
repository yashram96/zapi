<script setup lang="ts">
import { useDark, useStorage } from '@vueuse/core'
import { onMounted, ref } from 'vue'

const isDark = useDark()
const colorScheme = useStorage('color-scheme', 'light')
const mounted = ref(false)

onMounted(() => {
  // Sync with stored preference
  isDark.value = colorScheme.value === 'dark'
  // Update class immediately
  document.documentElement.classList.toggle('dark', isDark.value)
  mounted.value = true
})

// Watch for changes and persist
watch(isDark, (val) => {
  colorScheme.value = val ? 'dark' : 'light'
  document.documentElement.classList.toggle('dark', val)
})
</script>

<template>
  <div v-if="mounted">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<style>
@import '@/assets/css/tailwind.css';
</style>
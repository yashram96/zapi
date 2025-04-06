<!-- Dynamic organization projects route -->
<template>
  <div>
    <h1>Projects</h1>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})
</script>
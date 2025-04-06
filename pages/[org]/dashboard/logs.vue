<!-- Dynamic organization logs route -->
<template>
  <div>
    <h1>Request Logs</h1>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})
</script>
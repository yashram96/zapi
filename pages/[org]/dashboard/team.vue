<!-- Dynamic organization team route -->
<template>
  <div>
    <h1>Team</h1>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'dashboard',
  middleware: ['auth']
})
</script>
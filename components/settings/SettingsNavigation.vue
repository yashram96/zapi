<template>
  <div class="flex space-x-1 rounded-lg bg-muted p-1">
    <button
      v-for="tab in tabs"
      :key="tab.id"
      @click="$emit('update:tab', tab.id)"
      :class="[
        'flex items-center space-x-2 rounded-md px-3 py-2 text-sm font-medium',
        activeTab === tab.id
          ? 'bg-background text-foreground shadow-sm'
          : 'text-muted-foreground hover:bg-background/50 hover:text-foreground'
      ]"
    >
      <Icon :name="tab.icon" class="h-4 w-4" />
      <span>{{ tab.title }}</span>
    </button>
  </div>
</template>

<script setup lang="ts">
import type { SettingsTab } from '~/composables/useRolePermissions'

defineProps<{
  tabs: SettingsTab[]
  activeTab: string
}>()

defineEmits<{
  'update:tab': [value: string]
}>()
</script>
<template>
  <div class="flex min-h-screen">
    <Sidebar />
    <div class="flex-1 flex flex-col">
      <div class="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div class="flex h-16 items-center justify-end px-6">
          <ProfileMenu />
        </div>
      </div>
      <main class="flex-1 overflow-y-auto">
      <div class="container py-8">
        <slot />
      </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import Sidebar from '~/components/dashboard/Sidebar.vue'
import ProfileMenu from '~/components/ProfileMenu.vue'
</script>
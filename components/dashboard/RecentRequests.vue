<template>
  <div class="rounded-lg border bg-card">
    <div class="border-b p-6">
      <h2 class="text-lg font-medium">Recent Requests</h2>
    </div>
    
    <div class="divide-y">
      <div v-for="request in recentRequests" :key="request.id" class="flex items-center space-x-4 p-4">
        <span :class="[
          'rounded px-2 py-1 text-xs font-medium',
          request.method === 'GET' ? 'bg-blue-100 text-blue-700' : '',
          request.method === 'POST' ? 'bg-green-100 text-green-700' : '',
          request.method === 'PUT' ? 'bg-yellow-100 text-yellow-700' : '',
          request.method === 'DELETE' ? 'bg-red-100 text-red-700' : '',
        ]">
          {{ request.method }}
        </span>
        <span class="flex-1 font-mono text-sm">{{ request.path }}</span>
        <span :class="[
          'rounded-full px-2 py-1 text-xs',
          request.status < 400 ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
        ]">
          {{ request.status }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// TODO: Replace with actual request data from Supabase
const recentRequests = ref([
  { id: 1, method: 'GET', path: '/api/users', status: 200 },
  { id: 2, method: 'POST', path: '/api/orders', status: 201 },
  { id: 3, method: 'PUT', path: '/api/users/123', status: 200 },
  { id: 4, method: 'DELETE', path: '/api/posts/456', status: 404 },
])
</script>
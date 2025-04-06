<template>
  <footer class="bg-muted">
    <div class="container py-12 md:py-16">
      <div class="xl:grid xl:grid-cols-3 xl:gap-8">
        <div class="space-y-8">
          <div class="flex items-center space-x-1">
            <span class="text-2xl font-bold tracking-tight">ZAPI</span>
            <div class="h-6 w-[1px] bg-foreground/20"></div>
            <span class="text-base text-muted-foreground">API Mocking</span>
          </div>
          <p class="text-sm leading-6 text-muted-foreground">
            Mock API endpoints for frontend developers.
          </p>
          <div class="flex space-x-6">
            <a v-for="item in social" :key="item.name" :href="item.href" class="text-muted-foreground hover:text-foreground">
              <span class="sr-only">{{ item.name }}</span>
              <component :is="item.icon" class="h-6 w-6" aria-hidden="true" />
            </a>
          </div>
        </div>
        <div class="mt-16 grid grid-cols-2 gap-8 xl:col-span-2 xl:mt-0">
          <div class="md:grid md:grid-cols-2 md:gap-8">
            <div v-for="section in navigation" :key="section.name">
              <h3 class="text-sm font-semibold leading-6">{{ section.name }}</h3>
              <ul role="list" class="mt-6 space-y-4">
                <li v-for="item in section.items" :key="item.name">
                  <a :href="item.href" class="text-sm leading-6 text-muted-foreground hover:text-foreground">
                    {{ item.name }}
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <div class="mt-16 border-t border-muted-foreground/10 pt-8 sm:mt-20 lg:mt-24">
        <p class="text-xs leading-5 text-muted-foreground">&copy; {{ new Date().getFullYear() }} Zapi. All rights reserved.</p>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const navigation = [
  {
    name: 'Product',
    items: [
      { name: 'Features', href: '#features' },
      { name: 'Pricing', href: '#pricing' },
      { name: 'Documentation', href: '/docs' },
      { name: 'API Reference', href: '/api' },
    ],
  },
  {
    name: 'Company',
    items: [
      { name: 'About', href: '/about' },
      { name: 'Blog', href: '/blog' },
      { name: 'Terms', href: '/terms' },
      { name: 'Privacy', href: '/privacy' },
    ],
  },
]

const social = [
  {
    name: 'Twitter',
    href: '#',
    icon: 'i-heroicons-x-mark',
  },
  {
    name: 'GitHub',
    href: '#',
    icon: 'i-heroicons-code-bracket-square',
  },
]
</script>
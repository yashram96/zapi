// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/tailwindcss', '@vueuse/nuxt', 'nuxt-icon', '@nuxtjs/supabase'],
  supabase: {
    url: process.env.NUXT_PUBLIC_SUPABASE_URL,
    key: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY,
    redirect: false,
  },
  // serverMiddleware: [
  //   { path: '/', handler: '~/server/middleware/api.ts' },
  // ],
  runtimeConfig: {
    public: {
      NUXT_PUBLIC_SUPABASE_URL: process.env.NUXT_PUBLIC_SUPABASE_URL,
      NUXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY,
      useSubdomains: process.env.NUXT_PUBLIC_USE_SUBDOMAINS === 'true'
    }
  },
  vite: {
    server: {
      watch: {
        usePolling: true, // Enables polling mode
        interval: 10,    // Check every 100ms
      },
      hmr: {
        port: 24678, // Default Vite HMR port
      },
    },
  },
  app: {
    head: {
      title: 'ZAPI - Create Mock API Endpoints Without a Backend',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        {
          name: 'description',
          content: 'Create mock API endpoints with custom payloads, authentication, and status codes for frontend development.'
        },
        // Open Graph / Facebook
        { property: 'og:type', content: 'website' },
        { property: 'og:url', content: 'https://getzapi.com/' },
        { property: 'og:title', content: 'Zapi - Create Mock API Endpoints Without a Backend' },
        { property: 'og:description', content: 'Create mock API endpoints with custom payloads, authentication, and status codes for frontend development.' },
        { property: 'og:image', content: 'https://getzapi.com/og-image.png' },
        // Twitter
        { property: 'twitter:card', content: 'summary_large_image' },
        { property: 'twitter:url', content: 'https://getzapi.com/' },
        { property: 'twitter:title', content: 'Zapi - Create Mock API Endpoints Without a Backend' },
        { property: 'twitter:description', content: 'Create mock API endpoints with custom payloads, authentication, and status codes for frontend development.' },
        { property: 'twitter:image', content: 'https://getzapi.com/og-image.png' },
        // Additional SEO
        { name: 'theme-color', content: '#7c3aed' },
        { name: 'apple-mobile-web-app-capable', content: 'yes' },
        { name: 'apple-mobile-web-app-status-bar-style', content: 'black-translucent' }
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        { rel: 'icon', type: 'image/png', href: '/favicon.png' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' },
        {
          rel: 'stylesheet',
          href: 'https://fonts.cdnfonts.com/css/sf-pro-display'
        }
      ]
    }
  }
})
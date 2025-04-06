// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/tailwindcss', '@vueuse/nuxt', 'nuxt-icon'],
  runtimeConfig: {
    public: {
      supabaseUrl: process.env.NUXT_PUBLIC_SUPABASE_URL,
      supabaseKey: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY
    }
  },
  app: {
    head: {
      title: 'Zapi - Create Mock API Endpoints Without a Backend',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { 
          name: 'description', 
          content: 'Create mock API endpoints with custom payloads, authentication, and status codes for frontend development.' 
        }
      ],
      link: [
        { 
          rel: 'stylesheet',
          href: 'https://fonts.cdnfonts.com/css/sf-pro-display'
        }
      ]
    }
  }
})
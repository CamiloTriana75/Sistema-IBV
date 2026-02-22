export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt'
  ],
  
  app: {
    head: {
      title: 'Sistema IBV - Inventario y Despacho de Vehículos',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Sistema de gestión de inventario y despacho de vehículos en bodegas' }
      ]
    }
  },

  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:8000/api'
    }
  },

  typescript: {
    strict: true,
    shim: false
  },

  nitro: {
    prerender: {
      crawlLinks: false,
      routes: ['/sitemap.xml', '/rss.xml']
    }
  }
})

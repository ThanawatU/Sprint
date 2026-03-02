import tailwindcssVite from "@tailwindcss/vite";

export default defineNuxtConfig({
  compatibilityDate: "2025-05-15",
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiBase: "https://deploy-production-88fa.up.railway.app/api/",
      // apiBase:"https://painamnae-backend.onrender.com/api/",
      googleMapsApiKey: process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY || ""
    },
  },
  devServer: {
    port: 3001,
  },
  plugins: ["~/plugins/api.client.js"],
  vite: {
    plugins: [tailwindcssVite()],
  },
  app: {
    head: {
      link: [
        {
          rel: 'stylesheet',
          href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css'
        }
      ]
    }
  },
  css: [
    'leaflet/dist/leaflet.css',
    '~/assets/css/input.css',
  ],
  build: {
    transpile: ['leaflet']
  },
});

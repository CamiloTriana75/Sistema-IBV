<template>
  <div class="min-h-screen bg-white">
    <!-- Navbar -->
    <header class="sticky top-0 z-50 bg-white/90 backdrop-blur-md border-b border-gray-100 shadow-sm">
      <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 bg-primary-600 rounded-xl flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
          </div>
          <span class="text-lg font-black text-gray-900">Sistema IBV</span>
        </div>
        <NuxtLink to="/login"
          class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 hover:bg-primary-700 text-white text-sm font-bold rounded-xl transition shadow-lg shadow-primary-500/25">
          Iniciar sesión →
        </NuxtLink>
      </div>
    </header>

    <!-- Hero -->
    <section class="bg-gradient-to-br from-gray-50 to-primary-50/30 py-20 px-6">
      <div class="max-w-4xl mx-auto text-center">
        <span class="inline-block mb-4 px-4 py-1.5 bg-primary-100 text-primary-700 text-xs font-bold rounded-full uppercase tracking-widest">
          Sistema de Gestión Vehicular
        </span>
        <h1 class="text-5xl sm:text-6xl font-black text-gray-900 leading-tight mb-6">
          Bienvenido a<br/>
          <span class="text-primary-600">Sistema IBV</span>
        </h1>
        <p class="text-xl text-gray-600 max-w-2xl mx-auto mb-10">
          Plataforma centralizada para la Inspección, Bodega y Verificación de vehículos. Gestiona todo el ciclo desde la recepción hasta el despacho.
        </p>
        <div class="flex flex-col sm:flex-row gap-4 justify-center">
          <NuxtLink to="/login"
            class="inline-flex items-center justify-center gap-2 px-8 py-4 bg-primary-600 hover:bg-primary-700 text-white text-base font-bold rounded-2xl transition shadow-xl shadow-primary-500/30">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
            </svg>
            Acceder al sistema
          </NuxtLink>
        </div>
      </div>
    </section>

    <!-- Módulos -->
    <section class="py-16 px-6">
      <div class="max-w-6xl mx-auto">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-black text-gray-900 mb-3">Módulos Principales</h2>
          <p class="text-gray-500">Cada rol del sistema tiene su propio flujo de trabajo especializado</p>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <div v-for="modulo in modulos" :key="modulo.title"
            class="group bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-xl hover:shadow-gray-200/60 p-6 transition-all duration-300 hover:-translate-y-1">
            <div class="w-12 h-12 rounded-2xl flex items-center justify-center mb-4" :class="modulo.colorFondo">
              <svg class="w-6 h-6" :class="modulo.colorIcono" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="modulo.icono" />
              </svg>
            </div>
            <h3 class="font-black text-gray-900 text-lg mb-2">{{ modulo.title }}</h3>
            <p class="text-gray-500 text-sm leading-relaxed">{{ modulo.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-900 text-gray-400 py-8 px-6 mt-8">
      <div class="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-3">
          <div class="w-7 h-7 bg-primary-600 rounded-lg flex items-center justify-center">
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
          </div>
          <span class="text-white font-bold">Sistema IBV</span>
        </div>
        <p class="text-sm">© 2026 Sistema IBV. Todos los derechos reservados.</p>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'blank' })

const modulos = [
  {
    title: 'Recepción',
    desc: 'Registra vehículos al llegar del buque y genera la impronta inicial.',
    icono: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
    colorFondo: 'bg-blue-100',
    colorIcono: 'text-blue-600'
  },
  {
    title: 'Impronta',
    desc: 'Registra fotos y el estado de cada vehículo al ingresar a la bodega.',
    icono: 'M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z',
    colorFondo: 'bg-purple-100',
    colorIcono: 'text-purple-600'
  },
  {
    title: 'Inventario',
    desc: 'Verifica equipamiento y estado mecánico mediante checklist detallado.',
    icono: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
    colorFondo: 'bg-green-100',
    colorIcono: 'text-green-600'
  },
  {
    title: 'Despacho',
    desc: 'Gestiona el despacho de vehículos mediante escaneo QR secuencial.',
    icono: 'M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4',
    colorFondo: 'bg-orange-100',
    colorIcono: 'text-orange-600'
  }
]
</script>

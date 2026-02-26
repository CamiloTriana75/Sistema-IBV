<script setup lang="ts">
definePageMeta({
  layout: 'blank',
})

const currentYear = new Date().getFullYear()

useHead({
  title: 'Sistema IBV | Gestión Integral de Vehículos',
  meta: [
    {
      name: 'description',
      content:
        'Plataforma para gestionar recepción, impronta, inventario y despacho de vehículos con trazabilidad y operación en tiempo real.',
    },
    { property: 'og:title', content: 'Sistema IBV | Gestión Integral de Vehículos' },
    {
      property: 'og:description',
      content:
        'Gestiona el flujo completo: recepción, impronta, inventario y despacho con trazabilidad completa.',
    },
  ],
})
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50 overflow-x-hidden pc-zoom-110">
    <!-- Navbar -->
    <nav class="sticky top-0 z-40 bg-white/80 backdrop-blur-lg border-b border-gray-100 shadow-sm">
      <div class="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 2xl:px-12">
        <div class="flex justify-between items-center h-14 sm:h-16">
          <!-- Logo -->
          <div class="flex items-center gap-2 sm:gap-3">
            <div
              class="w-9 h-9 sm:w-10 sm:h-10 bg-gradient-to-br from-primary-600 to-primary-700 rounded-lg sm:rounded-xl flex items-center justify-center shadow-lg shadow-primary-500/25 shrink-0"
            >
              <svg
                class="w-5 h-5 sm:w-6 sm:h-6 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
                />
              </svg>
            </div>
            <span
              class="text-lg sm:text-xl font-bold bg-gradient-to-r from-primary-600 to-primary-700 bg-clip-text text-transparent"
            >
              IBV
            </span>
          </div>
          <!-- Nav Links -->
          <div class="flex items-center gap-4">
            <NuxtLink
              to="/login"
              class="px-4 sm:px-6 py-2 bg-primary-600 hover:bg-primary-700 text-white font-semibold text-sm sm:text-base rounded-2xl transition-all shadow-lg shadow-primary-500/25 hover:shadow-primary-500/40 hover:scale-[1.02] active:scale-[0.99] focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-white motion-reduce:transform-none motion-reduce:transition-none"
            >
              Iniciar Sesión
            </NuxtLink>
          </div>
        </div>
      </div>
    </nav>

    <!-- Hero Section -->
    <section class="relative overflow-hidden pt-10 pb-12 sm:pt-12 sm:pb-16 lg:py-0">
      <!-- Decorative Elements -->
      <div class="absolute inset-0 -z-10">
        <div
          class="absolute top-1/4 right-0 w-80 h-80 sm:w-96 sm:h-96 bg-primary-500/5 rounded-full blur-3xl"
        />
        <div
          class="absolute bottom-0 left-0 w-80 h-80 sm:w-96 sm:h-96 bg-success-500/5 rounded-full blur-3xl"
        />
      </div>

      <div
        class="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 2xl:px-12 lg:min-h-[calc(100vh-4rem)] lg:flex lg:items-center"
      >
        <div
          class="grid md:grid-cols-2 lg:grid-cols-[1.15fr_0.85fr] gap-10 sm:gap-12 lg:gap-14 xl:gap-16 items-center w-full"
        >
          <!-- Content -->
          <div class="space-y-6 sm:space-y-8 lg:py-10 text-center md:text-left">
            <div
              class="inline-flex items-center gap-2 px-3 sm:px-4 py-2 bg-primary-50 border border-primary-100 rounded-full mx-auto md:mx-0"
            >
              <span class="w-2 h-2 bg-primary-500 rounded-full animate-pulse" />
              <span class="text-xs sm:text-sm font-semibold text-primary-700">
                Sistema en línea • Operativo 24/7
              </span>
            </div>

            <h1
              class="text-3xl sm:text-5xl lg:text-6xl xl:text-7xl 2xl:text-[4.5rem] font-extrabold leading-tight tracking-tight"
            >
              <span class="text-gray-900">Gestión Integral</span>
              <span
                class="block bg-gradient-to-r from-primary-600 via-primary-500 to-primary-700 bg-clip-text text-transparent"
              >
                de Vehículos
              </span>
            </h1>

            <p class="text-base sm:text-lg lg:text-xl text-gray-600 leading-relaxed max-w-2xl mx-auto md:mx-0">
              Optimiza cada etapa del flujo logístico: desde la recepción hasta el despacho. Control
              total, trazabilidad completa y eficiencia operativa en tiempo real.
            </p>

            <div class="flex flex-col sm:flex-row flex-wrap gap-4 sm:gap-5 justify-center md:justify-start">
              <NuxtLink
                to="/login"
                class="inline-flex items-center justify-center sm:justify-start gap-2 px-6 sm:px-8 py-3 sm:py-4 bg-primary-600 hover:bg-primary-700 text-white font-bold text-base sm:text-lg rounded-2xl transition-all shadow-xl shadow-primary-500/30 hover:shadow-primary-500/50 hover:scale-[1.02] active:scale-[0.99] group focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-50 motion-reduce:transform-none motion-reduce:transition-none"
              >
                Acceder al Sistema
                <svg
                  class="w-5 h-5 hidden sm:block group-hover:translate-x-1 transition-transform"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 7l5 5m0 0l-5 5m5-5H6"
                  />
                </svg>
              </NuxtLink>
            </div>

            <!-- Stats -->
            <div
              class="grid grid-cols-3 gap-4 sm:gap-6 pt-6 sm:pt-8 border-t border-gray-200 max-w-xl mx-auto md:mx-0"
            >
              <div>
                <div class="text-2xl sm:text-3xl font-bold text-gray-900">100%</div>
                <div class="text-xs sm:text-sm text-gray-500 mt-1">Trazabilidad</div>
              </div>
              <div>
                <div class="text-2xl sm:text-3xl font-bold text-gray-900">24/7</div>
                <div class="text-xs sm:text-sm text-gray-500 mt-1">Disponibilidad</div>
              </div>
              <div>
                <div class="text-2xl sm:text-3xl font-bold text-gray-900">5</div>
                <div class="text-xs sm:text-sm text-gray-500 mt-1">Módulos</div>
              </div>
            </div>
          </div>

          <!-- Visual Hero -->
          <div class="relative hidden md:block md:h-[420px] lg:h-[520px] xl:h-[600px] 2xl:h-[640px]">
            <div
              class="absolute inset-0 bg-gradient-to-br from-primary-500/10 via-primary-400/5 to-transparent rounded-3xl"
            />
            <!-- Floating Cards -->
            <div
              class="absolute top-6 right-6 lg:top-8 lg:right-8 w-60 lg:w-64 xl:w-72 bg-white rounded-2xl shadow-xl p-5 lg:p-6 animate-float"
            >
              <div class="flex items-center gap-3 mb-4">
                <div
                  class="w-12 h-12 bg-success-100 rounded-xl flex items-center justify-center shrink-0"
                >
                  <svg
                    class="w-6 h-6 text-success-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <div class="min-w-0">
                  <div class="text-sm font-semibold text-gray-900 truncate">Vehículo Recibido</div>
                  <div class="text-xs text-gray-500 truncate">Toyota Corolla 2024</div>
                </div>
              </div>
              <div class="flex items-center justify-between text-xs gap-2">
                <span class="text-gray-500 truncate">VIN: 1HGBH41JXMN109186</span>
                <span
                  class="px-2 py-1 bg-success-100 text-success-700 rounded-full font-semibold shrink-0"
                >
                  ✓ OK
                </span>
              </div>
            </div>

            <div
              class="absolute bottom-10 left-6 lg:bottom-16 lg:left-8 w-52 lg:w-56 xl:w-64 bg-white rounded-2xl shadow-xl p-4 lg:p-5 animate-float-delayed"
            >
              <div class="flex items-center gap-3 mb-3">
                <div
                  class="w-10 h-10 bg-primary-100 rounded-xl flex items-center justify-center shrink-0"
                >
                  <svg
                    class="w-5 h-5 text-primary-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
                    />
                  </svg>
                </div>
                <div class="min-w-0">
                  <div class="text-sm font-semibold text-gray-900">Eficiencia</div>
                  <div class="text-xs text-gray-500">Últimas 24 horas</div>
                </div>
              </div>
              <div class="text-2xl font-bold text-primary-600">+47%</div>
            </div>

            <div
              class="absolute top-1/3 left-1/4 w-48 lg:w-52 xl:w-56 bg-gradient-to-br from-primary-600 to-primary-700 rounded-2xl shadow-2xl p-4 lg:p-5 text-white"
            >
              <div class="text-sm font-semibold opacity-90 mb-2">Vehículos en Bodega</div>
              <div class="text-4xl font-bold mb-3">142</div>
              <div class="flex gap-2 text-xs flex-wrap">
                <span class="px-2 py-1 bg-white/20 rounded-lg">+12 hoy</span>
                <span class="px-2 py-1 bg-white/20 rounded-lg">8 listos</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-14 sm:py-20 lg:py-24 2xl:py-28 bg-white">
      <div class="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 2xl:px-12">
        <div class="text-center max-w-3xl mx-auto mb-12 sm:mb-16">
          <h2 class="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900 mb-4 sm:mb-6">
            Todo lo que necesitas en una plataforma
          </h2>
          <p class="text-lg sm:text-xl text-gray-600 leading-relaxed">
            Flujo completo de operaciones, desde recepción hasta despacho final
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8 2xl:gap-10 mb-12 sm:mb-16">
          <!-- Recepción -->
          <div
            class="group relative bg-gradient-to-br from-blue-50 to-white rounded-2xl sm:rounded-3xl p-6 sm:p-8 border border-blue-100 hover:border-blue-300 hover:shadow-xl transition-all duration-300"
          >
            <div
              class="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform shadow-lg shadow-blue-500/25"
            >
              <svg
                class="w-7 h-7 sm:w-8 sm:h-8 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                />
              </svg>
            </div>
            <h3 class="text-lg sm:text-xl font-bold text-gray-900 mb-3">Recepción</h3>
            <p class="text-base text-gray-600 leading-relaxed">
              Registro rápido de vehículos al arribo. Captura de datos esenciales y generación de
              documentos.
            </p>
          </div>

          <!-- Impronta -->
          <div
            class="group relative bg-gradient-to-br from-purple-50 to-white rounded-2xl sm:rounded-3xl p-6 sm:p-8 border border-purple-100 hover:border-purple-300 hover:shadow-xl transition-all duration-300"
          >
            <div
              class="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-purple-500 to-purple-600 rounded-2xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform shadow-lg shadow-purple-500/25"
            >
              <svg
                class="w-7 h-7 sm:w-8 sm:h-8 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
            </div>
            <h3 class="text-lg sm:text-xl font-bold text-gray-900 mb-3">Impronta</h3>
            <p class="text-base text-gray-600 leading-relaxed">
              Registro fotográfico completo del estado del vehículo. Documentación visual detallada.
            </p>
          </div>

          <!-- Inventario -->
          <div
            class="group relative bg-gradient-to-br from-success-50 to-white rounded-2xl sm:rounded-3xl p-6 sm:p-8 border border-success-100 hover:border-success-300 hover:shadow-xl transition-all duration-300"
          >
            <div
              class="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-success-500 to-success-600 rounded-2xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform shadow-lg shadow-success-500/25"
            >
              <svg
                class="w-7 h-7 sm:w-8 sm:h-8 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
                />
              </svg>
            </div>
            <h3 class="text-lg sm:text-xl font-bold text-gray-900 mb-3">Inventario</h3>
            <p class="text-base text-gray-600 leading-relaxed">
              Verificación exhaustiva de equipamiento. Checklist digital y validación de
              componentes.
            </p>
          </div>

          <!-- Despacho -->
          <div
            class="group relative bg-gradient-to-br from-warning-50 to-white rounded-2xl sm:rounded-3xl p-6 sm:p-8 border border-warning-100 hover:border-warning-300 hover:shadow-xl transition-all duration-300"
          >
            <div
              class="w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-br from-warning-500 to-warning-600 rounded-2xl flex items-center justify-center mb-5 group-hover:scale-110 transition-transform shadow-lg shadow-warning-500/25"
            >
              <svg
                class="w-7 h-7 sm:w-8 sm:h-8 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 7l5 5m0 0l-5 5m5-5H6"
                />
              </svg>
            </div>
            <h3 class="text-lg sm:text-xl font-bold text-gray-900 mb-3">Despacho</h3>
            <p class="text-base text-gray-600 leading-relaxed">
              Gestión inteligente de salidas. Creación de lotes y coordinación de transportistas.
            </p>
          </div>
        </div>

        <!-- Additional Features -->
        <div class="mt-12 sm:mt-16 grid md:grid-cols-3 gap-6 sm:gap-8">
          <div class="flex gap-4 sm:gap-5">
            <div
              class="flex-shrink-0 w-12 h-12 sm:w-14 sm:h-14 bg-primary-100 rounded-xl sm:rounded-2xl flex items-center justify-center"
            >
              <svg
                class="w-6 h-6 sm:w-7 sm:h-7 text-primary-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            </div>
            <div class="min-w-0">
              <h4 class="font-bold text-gray-900 mb-1 text-base sm:text-lg">Seguridad Total</h4>
              <p class="text-sm text-gray-600 leading-relaxed">
                Roles y permisos granulares. Control de acceso por nivel.
              </p>
            </div>
          </div>

          <div class="flex gap-4 sm:gap-5">
            <div
              class="flex-shrink-0 w-12 h-12 sm:w-14 sm:h-14 bg-primary-100 rounded-xl sm:rounded-2xl flex items-center justify-center"
            >
              <svg
                class="w-6 h-6 sm:w-7 sm:h-7 text-primary-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                />
              </svg>
            </div>
            <div class="min-w-0">
              <h4 class="font-bold text-gray-900 mb-1 text-base sm:text-lg">
                Reportes en Tiempo Real
              </h4>
              <p class="text-sm text-gray-600 leading-relaxed">
                Dashboards actualizados. Métricas y KPIs operativos.
              </p>
            </div>
          </div>

          <div class="flex gap-4 sm:gap-5">
            <div
              class="flex-shrink-0 w-12 h-12 sm:w-14 sm:h-14 bg-primary-100 rounded-xl sm:rounded-2xl flex items-center justify-center"
            >
              <svg
                class="w-6 h-6 sm:w-7 sm:h-7 text-primary-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"
                />
              </svg>
            </div>
            <div class="min-w-0">
              <h4 class="font-bold text-gray-900 mb-1 text-base sm:text-lg">Acceso Móvil</h4>
              <p class="text-sm text-gray-600 leading-relaxed">
                Diseño responsive. Escaneo QR desde cualquier dispositivo.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-950 text-gray-300">
      <div class="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8 2xl:px-12">
        <div class="py-12 sm:py-14 border-b border-white/10">
          <div class="grid gap-10 lg:gap-12 md:grid-cols-2 lg:grid-cols-4">
            <div class="space-y-4">
              <div class="flex items-center gap-3">
                <div
                  class="w-10 h-10 bg-primary-600 rounded-xl flex items-center justify-center shrink-0"
                >
                  <svg
                    class="w-6 h-6 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
                    />
                  </svg>
                </div>
                <div class="min-w-0">
                  <div class="text-white font-bold text-base">Sistema IBV</div>
                  <div class="text-sm text-gray-400">Gestión integral de vehículos</div>
                </div>
              </div>

              <p class="text-sm text-gray-400 leading-relaxed max-w-sm">
                Controla recepción, impronta, inventario y despacho con trazabilidad completa y
                operación en tiempo real.
              </p>

              <div class="flex items-center gap-3">
                <NuxtLink
                  to="/login"
                  class="inline-flex items-center gap-2 text-sm font-semibold text-white hover:text-primary-200 transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
                >
                  Acceder al sistema
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M13 7l5 5m0 0l-5 5m5-5H6"
                    />
                  </svg>
                </NuxtLink>
              </div>
            </div>

            <div>
              <h3 class="text-sm font-bold text-white tracking-wide uppercase">Producto</h3>
              <ul class="mt-4 space-y-3 text-sm">
                <li class="text-gray-400">Recepción</li>
                <li class="text-gray-400">Impronta</li>
                <li class="text-gray-400">Inventario</li>
                <li class="text-gray-400">Despacho</li>
              </ul>
            </div>

            <div>
              <h3 class="text-sm font-bold text-white tracking-wide uppercase">Soporte</h3>
              <ul class="mt-4 space-y-3 text-sm">
                <li>
                  <a
                    href="#"
                    class="text-gray-400 hover:text-white transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
                    @click.prevent
                  >
                    Centro de ayuda
                  </a>
                </li>
                <li>
                  <a
                    href="mailto:soporte@sistemaibv.com"
                    class="text-gray-400 hover:text-white transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
                  >
                    soporte@sistemaibv.com
                  </a>
                </li>
                <li class="text-gray-400">Operativo 24/7</li>
              </ul>
            </div>

            <div>
              <h3 class="text-sm font-bold text-white tracking-wide uppercase">Legal</h3>
              <ul class="mt-4 space-y-3 text-sm">
                <li>
                  <a
                    href="#"
                    class="text-gray-400 hover:text-white transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
                    @click.prevent
                  >
                    Términos de uso
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-400 hover:text-white transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
                    @click.prevent
                  >
                    Política de privacidad
                  </a>
                </li>
                <li>
                  <a
                    href="#"
                    class="text-gray-400 hover:text-white transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
                    @click.prevent
                  >
                    Seguridad
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>

        <div class="py-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <p class="text-xs sm:text-sm text-gray-500">
            © {{ currentYear }} Sistema IBV. Todos los derechos reservados.
          </p>
          <div class="flex items-center gap-4 text-xs sm:text-sm">
            <NuxtLink
              to="/"
              class="text-gray-500 hover:text-gray-200 transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
            >
              Inicio
            </NuxtLink>
            <NuxtLink
              to="/login"
              class="text-gray-500 hover:text-gray-200 transition focus:outline-none focus-visible:ring-4 focus-visible:ring-primary-500/30 focus-visible:ring-offset-2 focus-visible:ring-offset-gray-950 rounded-lg px-1 -mx-1"
            >
              Iniciar sesión
            </NuxtLink>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
@media (min-width: 1024px) {
  .pc-zoom-110 {
    zoom: 1.1;
  }
}

@supports not (zoom: 1) {
  @media (min-width: 1024px) {
    .pc-zoom-110 {
      font-size: 110%;
    }
  }
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}

@keyframes float-delayed {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-15px);
  }
}

.animate-float {
  animation: float 6s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 6s ease-in-out infinite 1s;
}
</style>

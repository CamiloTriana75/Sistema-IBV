<script setup lang="ts">
definePageMeta({ layout: 'admin' })

const movements = [
  {
    id: 1,
    vehicle: 'Toyota Corolla',
    bin: 'VH-2024-0156',
    type: 'entrada',
    driver: 'Juan Martínez',
    time: 'Hace 10 min',
  },
  {
    id: 2,
    vehicle: 'Nissan Versa',
    bin: 'VH-2024-0140',
    type: 'salida',
    driver: 'Pedro López',
    time: 'Hace 25 min',
  },
  {
    id: 3,
    vehicle: 'Chevrolet Onix',
    bin: 'VH-2024-0142',
    type: 'salida',
    driver: 'María García',
    time: 'Hace 45 min',
  },
  {
    id: 4,
    vehicle: 'Kia Rio',
    bin: 'VH-2024-0160',
    type: 'entrada',
    driver: 'Carlos Díaz',
    time: 'Hace 1h',
  },
  {
    id: 5,
    vehicle: 'Hyundai Accent',
    bin: 'VH-2024-0161',
    type: 'entrada',
    driver: 'Ana Torres',
    time: 'Hace 2h',
  },
]
</script>

<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Portería</h1>
      <p class="text-gray-500 mt-1">Control de entrada y salida de vehículos</p>
    </div>

    <!-- Acción principal: Escanear QR -->
    <div
      class="bg-gradient-to-br from-primary-600 to-primary-700 rounded-2xl p-8 text-white mb-8 shadow-lg"
    >
      <div class="flex flex-col sm:flex-row items-center gap-6">
        <div
          class="w-20 h-20 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center"
        >
          <svg class="w-10 h-10" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
            />
          </svg>
        </div>
        <div class="text-center sm:text-left flex-1">
          <h2 class="text-2xl font-bold">Escanear Código QR</h2>
          <p class="text-primary-100 mt-1">
            Verifica la autorización de salida/entrada de vehículos
          </p>
        </div>
        <button
          class="px-6 py-3 bg-white text-primary-600 font-semibold rounded-xl hover:bg-primary-50 transition shadow-lg"
        >
          Abrir Escáner
        </button>
      </div>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Entradas Hoy</p>
        <p class="text-3xl font-bold text-success-600 mt-1">18</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Salidas Hoy</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">12</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">En Bodega</p>
        <p class="text-3xl font-bold text-gray-900 mt-1">156</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Alertas</p>
        <p class="text-3xl font-bold text-danger-600 mt-1">1</p>
      </div>
    </div>

    <!-- Registro de movimientos -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100">
        <h3 class="font-semibold text-gray-900">Últimos Movimientos</h3>
      </div>
      <div class="divide-y divide-gray-50">
        <div
          v-for="mov in movements"
          :key="mov.id"
          class="px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition"
        >
          <div class="flex items-center gap-4">
            <div
              :class="[
                'w-10 h-10 rounded-full flex items-center justify-center',
                mov.type === 'entrada'
                  ? 'bg-success-500/10 text-success-600'
                  : 'bg-primary-100 text-primary-600',
              ]"
            >
              <svg
                v-if="mov.type === 'entrada'"
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"
                />
              </svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-900">{{ mov.vehicle }} — {{ mov.bin }}</p>
              <p class="text-xs text-gray-500">
                {{ mov.type === 'entrada' ? 'Entrada' : 'Salida' }} · {{ mov.driver }}
              </p>
            </div>
          </div>
          <span class="text-xs text-gray-400">{{ mov.time }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

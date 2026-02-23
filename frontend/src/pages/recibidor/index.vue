<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Recibidor</h1>
      <p class="text-gray-500 mt-1">Gestión de recepción de vehículos en bodega</p>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Recibidos Hoy</p>
        <p class="text-3xl font-bold text-success-600 mt-1">12</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Pendientes</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">5</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Esta Semana</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">47</p>
      </div>
    </div>

    <!-- Vehículos pendientes de recepción -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <h3 class="font-semibold text-gray-900">Vehículos Pendientes de Recepción</h3>
        <NuxtLink to="/recibidor/impronta" class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/20">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nueva Impronta
        </NuxtLink>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">BIN</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Modelo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Color</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Fecha</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Acción</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="v in pendingVehicles" :key="v.bin" class="hover:bg-gray-50 transition">
              <td class="px-6 py-4 text-sm font-mono font-medium text-gray-900">{{ v.bin }}</td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ v.model }}</td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ v.color }}</td>
              <td class="px-6 py-4 text-sm text-gray-500">{{ v.date }}</td>
              <td class="px-6 py-4">
                <NuxtLink to="/recibidor/impronta" class="px-3 py-1.5 text-xs font-semibold text-white bg-success-500 rounded-lg hover:bg-success-600 transition">
                  Registrar Impronta
                </NuxtLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'admin' })

const pendingVehicles = [
  { bin: 'VH-2024-0157', model: 'Toyota Corolla', color: 'Blanco', date: '23/02/2026' },
  { bin: 'VH-2024-0158', model: 'Chevrolet Spark', color: 'Rojo', date: '23/02/2026' },
  { bin: 'VH-2024-0159', model: 'Nissan Versa', color: 'Plata', date: '23/02/2026' },
  { bin: 'VH-2024-0160', model: 'Kia Rio', color: 'Negro', date: '23/02/2026' },
  { bin: 'VH-2024-0161', model: 'Hyundai Accent', color: 'Azul', date: '23/02/2026' },
]
</script>

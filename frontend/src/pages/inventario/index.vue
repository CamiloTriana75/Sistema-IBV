<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Inventario</h1>
      <p class="text-gray-500 mt-1">Inspección y control de inventario de vehículos</p>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Inspecciones Hoy</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">8</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Pendientes</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">3</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Completadas</p>
        <p class="text-3xl font-bold text-success-600 mt-1">142</p>
      </div>
    </div>

    <!-- Lista de inspecciones pendientes -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100">
        <h3 class="font-semibold text-gray-900">Vehículos Pendientes de Inspección</h3>
      </div>
      <div class="divide-y divide-gray-50">
        <div v-for="v in pendingInspections" :key="v.bin" class="px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 bg-warning-500/10 text-warning-600 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
              </svg>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-900">{{ v.model }} - <span class="font-mono">{{ v.bin }}</span></p>
              <p class="text-xs text-gray-500">{{ v.color }} · Recibido {{ v.receivedDate }}</p>
            </div>
          </div>
          <NuxtLink to="/inventario/checklist" class="px-4 py-2 text-sm font-semibold text-white bg-primary-600 rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/20">
            Iniciar Checklist
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'admin' })

const pendingInspections = [
  { bin: 'VH-2024-0150', model: 'Toyota Hilux', color: 'Blanco', receivedDate: 'Hace 2h' },
  { bin: 'VH-2024-0151', model: 'Mazda 3', color: 'Rojo', receivedDate: 'Hace 4h' },
  { bin: 'VH-2024-0152', model: 'Renault Duster', color: 'Gris', receivedDate: 'Ayer' },
]
</script>

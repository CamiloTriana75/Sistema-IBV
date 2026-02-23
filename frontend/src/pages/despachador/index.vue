<script setup lang="ts">
definePageMeta({ layout: 'admin' })

const readyVehicles = [
  {
    bin: 'VH-2024-0140',
    model: 'Nissan Versa',
    destination: 'Concesionario Norte',
    status: 'Listo',
  },
  { bin: 'VH-2024-0141', model: 'Toyota Yaris', destination: 'Concesionario Sur', status: 'Listo' },
  {
    bin: 'VH-2024-0142',
    model: 'Chevrolet Onix',
    destination: 'Concesionario Centro',
    status: 'Listo',
  },
  {
    bin: 'VH-2024-0143',
    model: 'Kia Sportage',
    destination: 'Concesionario Norte',
    status: 'Listo',
  },
  {
    bin: 'VH-2024-0144',
    model: 'Hyundai Tucson',
    destination: 'Concesionario Este',
    status: 'Listo',
  },
]
</script>

<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Despachador</h1>
      <p class="text-gray-500 mt-1">Gestión de despacho y salida de vehículos</p>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Despachados Hoy</p>
        <p class="text-3xl font-bold text-success-600 mt-1">8</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Listos para Despacho</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">15</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Programados</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">6</p>
      </div>
    </div>

    <!-- Vehículos listos para despacho -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <h3 class="font-semibold text-gray-900">Vehículos Listos para Despacho</h3>
        <button
          class="px-4 py-2 bg-success-500 text-white text-sm font-medium rounded-lg hover:bg-success-600 transition"
        >
          Crear Lote de Despacho
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                <input type="checkbox" class="rounded border-gray-300" />
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                BIN
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Modelo
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Destino
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Estado
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Acción
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr v-for="v in readyVehicles" :key="v.bin" class="hover:bg-gray-50 transition">
              <td class="px-6 py-4">
                <input type="checkbox" class="rounded border-gray-300" />
              </td>
              <td class="px-6 py-4 text-sm font-mono font-medium text-gray-900">{{ v.bin }}</td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ v.model }}</td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ v.destination }}</td>
              <td class="px-6 py-4">
                <span
                  class="px-2.5 py-1 text-xs font-medium bg-success-500/10 text-success-600 rounded-full"
                >
                  {{ v.status }}
                </span>
              </td>
              <td class="px-6 py-4">
                <button
                  class="px-3 py-1.5 text-xs font-medium text-white bg-primary-600 rounded-lg hover:bg-primary-700 transition"
                >
                  Despachar
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

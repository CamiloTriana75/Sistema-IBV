<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'
import ForceStatusChangeModal from '~/components/admin/ForceStatusChangeModal.vue'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const vehiculoStore = useVehiculoStore()
const searchTerm = ref('')
const showForceModal = ref(false)
const selectedVehiculo = ref<any>(null)
const loading = ref(false)

const recibidosVehiculos = computed(() => {
  const recibidos = vehiculoStore.vehiculos.filter((v) => !v.despachado)
  if (!searchTerm.value) return recibidos
  
  const q = searchTerm.value.toLowerCase()
  return recibidos.filter(
    (v) =>
      v.vin.toLowerCase().includes(q) ||
      v.placa.toLowerCase().includes(q) ||
      v.marca.toLowerCase().includes(q) ||
      v.modelo.toLowerCase().includes(q) ||
      v.cliente.toLowerCase().includes(q)
  )
})

const estadoVehLabel = (e: string) =>
  ({
    recibido: 'Recibido',
    impronta_pendiente: 'Impronta Pend.',
    impronta_completada: 'Impronta OK',
    inventario_pendiente: 'Inventario Pend.',
    inventario_aprobado: 'Inventario OK',
    listo_despacho: 'Listo Despacho',
    despachado: 'Despachado',
  })[e] || e

const estadoVehBadge = (e: string) =>
  ({
    recibido: 'bg-blue-50 text-blue-700',
    impronta_pendiente: 'bg-amber-50 text-amber-700',
    impronta_completada: 'bg-green-50 text-green-700',
    inventario_pendiente: 'bg-orange-50 text-orange-700',
    inventario_aprobado: 'bg-teal-50 text-teal-700',
    listo_despacho: 'bg-purple-50 text-purple-700',
    despachado: 'bg-gray-100 text-gray-500',
  })[e] || 'bg-gray-100 text-gray-500'

const estadisticas = computed(() => ({
  recibidos: vehiculoStore.vehiculos.filter((v) => v.estado === 'recibido').length,
  improntaPend: vehiculoStore.vehiculos.filter((v) => v.estado === 'impronta_pendiente').length,
  improntaOk: vehiculoStore.vehiculos.filter((v) => v.estado === 'impronta_completada').length,
  inventarioPend: vehiculoStore.vehiculos.filter((v) => v.estado === 'inventario_pendiente').length,
  inventarioOk: vehiculoStore.vehiculos.filter((v) => v.estado === 'inventario_aprobado').length,
  listoDespacho: vehiculoStore.listosDespacho,
}))

const recargar = async () => {
  loading.value = true
  try {
    await vehiculoStore.loadFromSupabase()
  } finally {
    loading.value = false
  }
}

const openForceModal = (vehiculo: any) => {
  console.log('Vehículo seleccionado:', vehiculo)
  selectedVehiculo.value = vehiculo
  showForceModal.value = true
}

const closeForceModal = () => {
  showForceModal.value = false
  selectedVehiculo.value = null
}

const selectedVehiculoDbId = computed(() => {
  if (!selectedVehiculo.value) return null
  if (selectedVehiculo.value.dbId) return selectedVehiculo.value.dbId
  if (selectedVehiculo.value.id) {
    const match = selectedVehiculo.value.id.match(/vp-(\d+)/)
    if (match) return parseInt(match[1], 10)
  }
  return null
})

const handleForceSuccess = () => {
  vehiculoStore.loadFromSupabase()
  closeForceModal()
}

onMounted(async () => {
  if (vehiculoStore.vehiculos.length === 0) {
    loading.value = true
    try {
      await vehiculoStore.loadFromSupabase()
    } finally {
      loading.value = false
    }
  }
})
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Monitoreo Recepción</h1>
        <p class="text-sm text-gray-500 mt-1">Control sobre el proceso de recepción e impronta de vehículos</p>
      </div>
      <button
        class="inline-flex items-center gap-2 px-4 py-2.5 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
        type="button"
        @click="recargar"
        :disabled="loading"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 4v5h.582m15.356 2A8 8 0 104.582 9"
          />
        </svg>
        Recargar
      </button>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-6 gap-3 mb-8">
      <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 font-medium">Recibidos</p>
        <p class="text-2xl font-bold text-blue-600 mt-1">{{ estadisticas.recibidos }}</p>
      </div>
      <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 font-medium">Impronta Pend.</p>
        <p class="text-2xl font-bold text-amber-600 mt-1">{{ estadisticas.improntaPend }}</p>
      </div>
      <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 font-medium">Impronta OK</p>
        <p class="text-2xl font-bold text-green-600 mt-1">{{ estadisticas.improntaOk }}</p>
      </div>
      <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 font-medium">Inventario Pend.</p>
        <p class="text-2xl font-bold text-orange-600 mt-1">{{ estadisticas.inventarioPend }}</p>
      </div>
      <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 font-medium">Inventario OK</p>
        <p class="text-2xl font-bold text-teal-600 mt-1">{{ estadisticas.inventarioOk }}</p>
      </div>
      <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100">
        <p class="text-xs text-gray-500 font-medium">Listo Despacho</p>
        <p class="text-2xl font-bold text-purple-600 mt-1">{{ estadisticas.listoDespacho }}</p>
      </div>
    </div>

    <!-- Búsqueda -->
    <div class="mb-6">
      <input
        v-model="searchTerm"
        type="text"
        placeholder="Buscar por VIN, placa, marca, modelo o cliente..."
        class="w-full px-4 py-2.5 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
      />
    </div>

    <!-- Tabla de vehículos -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">VIN / Placa</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Vehículo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Cliente</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Impronta</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Inventario</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="vehiculo in recibidosVehiculos" :key="vehiculo.id" class="hover:bg-gray-50 transition">
              <td class="px-6 py-4 text-sm font-mono text-gray-900">
                <span class="block font-semibold">{{ vehiculo.vin }}</span>
                <span class="text-gray-500">{{ vehiculo.placa }}</span>
              </td>
              <td class="px-6 py-4 text-sm">
                <span class="block font-semibold text-gray-900">{{ vehiculo.marca }} {{ vehiculo.modelo }}</span>
                <span class="text-gray-500">{{ vehiculo.anio }}</span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-900">{{ vehiculo.cliente }}</td>
              <td class="px-6 py-4">
                <span :class="`px-3 py-1 rounded-full text-xs font-semibold ${estadoVehBadge(vehiculo.estado)}`">
                  {{ estadoVehLabel(vehiculo.estado) }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm">
                <span
                  v-if="vehiculo.improntaCompletada"
                  class="px-3 py-1 rounded-full text-xs font-semibold bg-green-50 text-green-700"
                >
                  ✓ Completada
                </span>
                <span v-else class="px-3 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700">
                  Pendiente
                </span>
              </td>
              <td class="px-6 py-4 text-sm">
                <span
                  v-if="vehiculo.inventarioAprobado"
                  class="px-3 py-1 rounded-full text-xs font-semibold bg-green-50 text-green-700"
                >
                  ✓ Aprobado
                </span>
                <span v-else class="px-3 py-1 rounded-full text-xs font-semibold bg-orange-50 text-orange-700">
                  Pendiente
                </span>
              </td>
              <td class="px-6 py-4">
                <button
                  @click="openForceModal(vehiculo)"
                  class="px-3 py-1 bg-red-50 text-red-700 text-xs font-semibold rounded-lg hover:bg-red-100"
                >
                  Forzar Estado
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="recibidosVehiculos.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-500">No hay vehículos para mostrar</p>
      </div>
    </div>

    <!-- Force Status Modal -->
    <ForceStatusChangeModal
      v-if="selectedVehiculo"
      :is-open="showForceModal"
      :vehiculo-id="selectedVehiculoDbId"
      :current-status="selectedVehiculo.estado"
      @close="closeForceModal"
      @success="handleForceSuccess"
    />
  </div>
</template>

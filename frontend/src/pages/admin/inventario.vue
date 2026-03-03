<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'
import ForceStatusChangeModal from '~/components/admin/ForceStatusChangeModal.vue'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const vehiculoStore = useVehiculoStore()
const tab = ref<'pendientes' | 'completados'>('pendientes')
const searchTerm = ref('')
const showForceModal = ref(false)
const selectedVehiculo = ref<any>(null)
const loading = ref(false)

const pendientesInventario = computed(() => {
  const pendientes = vehiculoStore.getPendientesInventario
  if (!searchTerm.value) return pendientes

  const q = searchTerm.value.toLowerCase()
  return pendientes.filter(
    (v) =>
      v.vin.toLowerCase().includes(q) ||
      v.placa.toLowerCase().includes(q) ||
      v.marca.toLowerCase().includes(q) ||
      v.modelo.toLowerCase().includes(q) ||
      v.cliente.toLowerCase().includes(q)
  )
})

const completadosInventario = computed(() => {
  const completados = vehiculoStore.getListosParaDespacho
  if (!searchTerm.value) return completados

  const q = searchTerm.value.toLowerCase()
  return completados.filter(
    (v) =>
      v.vin.toLowerCase().includes(q) ||
      v.placa.toLowerCase().includes(q) ||
      v.marca.toLowerCase().includes(q) ||
      v.modelo.toLowerCase().includes(q) ||
      v.cliente.toLowerCase().includes(q)
  )
})

const estadisticas = computed(() => ({
  pendientes: vehiculoStore.pendientesInventario,
  completados: vehiculoStore.getListosParaDespacho.length,
  conImpronta: vehiculoStore.conImpronta,
  despachados: vehiculoStore.despachados,
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
        <h1 class="text-2xl font-bold text-gray-900">Monitoreo Inventario</h1>
        <p class="text-sm text-gray-500 mt-1">Control sobre inspección y auditoría de inventario</p>
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
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Pendientes Inventario</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">{{ estadisticas.pendientes }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Listos para Despacho</p>
        <p class="text-3xl font-bold text-success-600 mt-1">{{ estadisticas.completados }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Con Impronta</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">{{ estadisticas.conImpronta }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Despachados</p>
        <p class="text-3xl font-bold text-gray-600 mt-1">{{ estadisticas.despachados }}</p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="flex gap-2 mb-4">
      <button
        class="px-4 py-2 text-sm font-semibold rounded-xl transition"
        :class="
          tab === 'pendientes'
            ? 'bg-warning-100 text-warning-700'
            : 'text-gray-500 hover:bg-gray-100'
        "
        @click="tab = 'pendientes'"
      >
        Pendientes ({{ pendientesInventario.length }})
      </button>
      <button
        class="px-4 py-2 text-sm font-semibold rounded-xl transition"
        :class="
          tab === 'completados'
            ? 'bg-success-100 text-success-700'
            : 'text-gray-500 hover:bg-gray-100'
        "
        @click="tab = 'completados'"
      >
        Completados ({{ completadosInventario.length }})
      </button>
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

    <!-- Tabla Pendientes -->
    <div v-if="tab === 'pendientes'" class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">VIN / Placa</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Vehículo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Cliente</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Impronta</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="vehiculo in pendientesInventario" :key="vehiculo.id" class="hover:bg-gray-50 transition">
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
                <span
                  v-if="vehiculo.improntaCompletada"
                  class="px-3 py-1 rounded-full text-xs font-semibold bg-green-50 text-green-700"
                >
                  ✓ Completada
                </span>
                <span v-else class="px-3 py-1 rounded-full text-xs font-semibold bg-red-50 text-red-700">
                  ✗ Sin Impronta
                </span>
              </td>
              <td class="px-6 py-4">
                <span class="px-3 py-1 rounded-full text-xs font-semibold bg-warning-50 text-warning-700">
                  Pendiente Revisión
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
      <div v-if="pendientesInventario.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-500">No hay vehículos pendientes de inventario</p>
      </div>
    </div>

    <!-- Tabla Completados -->
    <div v-if="tab === 'completados'" class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">VIN / Placa</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Vehículo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Cliente</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Inventario</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="vehiculo in completadosInventario" :key="vehiculo.id" class="hover:bg-gray-50 transition">
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
                <span
                  v-if="vehiculo.inventarioAprobado"
                  class="px-3 py-1 rounded-full text-xs font-semibold bg-green-50 text-green-700"
                >
                  ✓ Aprobado
                </span>
              </td>
              <td class="px-6 py-4">
                <span class="px-3 py-1 rounded-full text-xs font-semibold bg-success-50 text-success-700">
                  Listo Despacho
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
      <div v-if="completadosInventario.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-500">No hay vehículos listos para despacho</p>
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

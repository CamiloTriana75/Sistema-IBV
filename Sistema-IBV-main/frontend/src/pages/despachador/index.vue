<script setup lang="ts">
import { computed } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'

definePageMeta({ layout: 'admin' })

const vehiculoStore = useVehiculoStore()

// Vehicles that are in the system but NOT ready to dispatch (missing impronta or inventory)
const vehiculosBloqueados = computed(() =>
  vehiculoStore.vehiculos.filter(
    (v) => !v.despachado && !(v.improntaCompletada && v.inventarioAprobado)
  )
)
</script>

<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Despachador</h1>
      <p class="text-gray-500 mt-1">Gestión de despacho y salida de vehículos</p>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Listos para Despacho</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">{{ vehiculoStore.listosDespacho }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Despachados</p>
        <p class="text-3xl font-bold text-success-600 mt-1">{{ vehiculoStore.despachados }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Pendiente Inventario</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">
          {{ vehiculoStore.pendientesInventario }}
        </p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Total en Sistema</p>
        <p class="text-3xl font-bold text-gray-600 mt-1">{{ vehiculoStore.total }}</p>
      </div>
    </div>

    <!-- Alerta si hay vehículos listos -->
    <div
      v-if="vehiculoStore.listosDespacho > 0"
      class="bg-success-50 border border-success-200 rounded-xl p-4 mb-6 flex items-center gap-4"
    >
      <div class="w-10 h-10 bg-success-500 rounded-xl flex items-center justify-center shrink-0">
        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5 13l4 4L19 7"
          />
        </svg>
      </div>
      <div class="flex-1">
        <p class="text-sm font-bold text-success-800">
          {{ vehiculoStore.listosDespacho }} vehículo(s) listo(s) para despacho
        </p>
        <p class="text-xs text-success-600 mt-0.5">Impronta completada + Inventario aprobado</p>
      </div>
      <NuxtLink
        to="/despachador/escaneo"
        class="inline-flex items-center gap-2 px-5 py-2.5 bg-success-600 text-white text-sm font-semibold rounded-xl hover:bg-success-700 transition shadow-lg shadow-success-500/20"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12v.01M12 4h.01M4 4h4v4H4V4zm12 0h4v4h-4V4zM4 16h4v4H4v-4z"
          />
        </svg>
        Iniciar Escaneo de Lote
      </NuxtLink>
    </div>

    <!-- Vehículos listos para despacho -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <h3 class="font-semibold text-gray-900">Vehículos Listos para Despacho</h3>
        <span class="text-xs text-gray-400">Solo con impronta ✓ e inventario ✓</span>
      </div>
      <div v-if="vehiculoStore.getListosParaDespacho.length === 0" class="px-6 py-12 text-center">
        <svg
          class="w-12 h-12 text-gray-300 mx-auto mb-3"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
          />
        </svg>
        <p class="text-gray-400 font-medium">No hay vehículos listos para despacho</p>
        <p class="text-gray-300 text-sm mt-1">
          Los vehículos necesitan impronta completada e inventario aprobado
        </p>
      </div>
      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                VIN
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Vehículo
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Cliente
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Impronta
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Inventario
              </th>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Estado
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr
              v-for="v in vehiculoStore.getListosParaDespacho"
              :key="v.id"
              class="hover:bg-gray-50 transition"
            >
              <td class="px-6 py-4 text-sm font-mono font-medium text-gray-900">
                {{ v.vin.slice(-8) }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-700">
                {{ v.marca }} {{ v.modelo }} {{ v.anio }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ v.cliente || '—' }}</td>
              <td class="px-6 py-4">
                <span
                  class="px-2 py-1 text-xs font-semibold bg-blue-100 text-blue-700 rounded-full"
                >
                  {{ v.improntaFolio || '✓' }}
                </span>
              </td>
              <td class="px-6 py-4">
                <span
                  class="px-2 py-1 text-xs font-semibold bg-success-100 text-success-700 rounded-full"
                >
                  {{
                    v.inventarioResultado
                      ? `${v.inventarioResultado.aprobados}/${v.inventarioResultado.totalItems}`
                      : '✓'
                  }}
                </span>
              </td>
              <td class="px-6 py-4">
                <span
                  class="px-2.5 py-1 text-xs font-semibold bg-success-500/10 text-success-600 rounded-full"
                >
                  Listo
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Vehículos bloqueados (sin completar pipeline) -->
    <div
      v-if="vehiculosBloqueados.length > 0"
      class="mt-6 bg-white rounded-xl shadow-sm border border-gray-100"
    >
      <div class="px-6 py-4 border-b border-gray-100">
        <h3 class="font-semibold text-gray-900">Vehículos Bloqueados para Despacho</h3>
        <p class="text-xs text-gray-400 mt-0.5">Requieren completar impronta y/o inventario</p>
      </div>
      <div class="divide-y divide-gray-50">
        <div
          v-for="v in vehiculosBloqueados"
          :key="v.id"
          class="px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition"
        >
          <div class="flex items-center gap-4">
            <div
              class="w-10 h-10 bg-danger-500/10 text-danger-600 rounded-lg flex items-center justify-center"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-bold text-gray-900">
                {{ v.marca }} {{ v.modelo }} {{ v.anio }}
              </p>
              <p class="text-xs text-gray-500 font-mono">{{ v.vin }}</p>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <span
              class="px-2 py-1 text-[10px] font-bold rounded-full"
              :class="
                v.improntaCompletada
                  ? 'bg-success-100 text-success-700'
                  : 'bg-danger-100 text-danger-700'
              "
            >
              Impronta {{ v.improntaCompletada ? '✓' : '✗' }}
            </span>
            <span
              class="px-2 py-1 text-[10px] font-bold rounded-full"
              :class="
                v.inventarioAprobado
                  ? 'bg-success-100 text-success-700'
                  : 'bg-danger-100 text-danger-700'
              "
            >
              Inventario {{ v.inventarioAprobado ? '✓' : '✗' }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

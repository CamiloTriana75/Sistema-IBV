<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useInventarioStore } from '~/stores/inventarioStore'

definePageMeta({ layout: 'admin', middleware: ['auth', 'inventario'] })

const vehiculoStore = useInventarioStore()
const tab = ref<'pendientes' | 'completados'>('pendientes')

onMounted(async () => {
  await vehiculoStore.load()
})
</script>

<template>
  <div>
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Inventario</h1>
      <p class="text-gray-500 mt-1">Inspección y control de inventario de vehículos</p>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Pendientes</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">
          {{ vehiculoStore.pendientesInventario }}
        </p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Listos para Despacho</p>
        <p class="text-3xl font-bold text-success-600 mt-1">{{ vehiculoStore.listosDespacho }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Con Impronta</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">{{ vehiculoStore.conImpronta }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Despachados</p>
        <p class="text-3xl font-bold text-gray-600 mt-1">{{ vehiculoStore.despachados }}</p>
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
        Pendientes ({{ vehiculoStore.getPendientesInventario.length }})
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
        Inventario Completo ({{ vehiculoStore.getListosParaDespacho.length }})
      </button>
    </div>

    <!-- Lista de vehículos pendientes de inspección -->
    <div v-if="tab === 'pendientes'" class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <h3 class="font-semibold text-gray-900">Vehículos Pendientes de Inventario</h3>
        <p class="text-xs text-gray-400">Solo vehículos con impronta completada</p>
      </div>
      <div v-if="vehiculoStore.getPendientesInventario.length === 0" class="px-6 py-12 text-center">
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
            d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
        <p class="text-gray-400 font-medium">Sin vehículos pendientes</p>
        <p class="text-gray-300 text-sm mt-1">
          Todos los vehículos con impronta ya tienen inventario aprobado
        </p>
      </div>
      <div v-else class="divide-y divide-gray-50">
        <div
          v-for="v in vehiculoStore.getPendientesInventario"
          :key="v.id"
          class="px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition"
        >
          <div class="flex items-center gap-4">
            <div
              class="w-10 h-10 bg-warning-500/10 text-warning-600 rounded-lg flex items-center justify-center"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-bold text-gray-900">
                {{ v.marca }} {{ v.modelo }} {{ v.anio }}
              </p>
              <p class="text-xs text-gray-500">
                <span class="font-mono">{{ v.vin }}</span>
                · {{ v.color }}
                <span
                  v-if="v.improntaFolio"
                  class="ml-2 px-1.5 py-0.5 bg-blue-50 text-blue-600 rounded text-[10px] font-bold"
                >
                  {{ v.improntaFolio }}
                </span>
              </p>
              <p class="text-xs text-gray-400 mt-0.5">
                Cliente: {{ v.cliente || '—' }} · Recibido {{ v.fechaRecepcion }}
              </p>
            </div>
          </div>
          <NuxtLink
            :to="`/inventario/checklist?vin=${v.vin}`"
            class="px-4 py-2 text-sm font-semibold text-white bg-primary-600 rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/20"
          >
            Iniciar Checklist
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- Lista de vehículos con inventario completo -->
    <div v-if="tab === 'completados'" class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100">
        <h3 class="font-semibold text-gray-900">Vehículos con Inventario Aprobado</h3>
      </div>
      <div v-if="vehiculoStore.getListosParaDespacho.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-400 font-medium">No hay vehículos con inventario aprobado aún</p>
      </div>
      <div v-else class="divide-y divide-gray-50">
        <div
          v-for="v in vehiculoStore.getListosParaDespacho"
          :key="v.id"
          class="px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition"
        >
          <div class="flex items-center gap-4">
            <div
              class="w-10 h-10 bg-success-500/10 text-success-600 rounded-lg flex items-center justify-center"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-bold text-gray-900">
                {{ v.marca }} {{ v.modelo }} {{ v.anio }}
              </p>
              <p class="text-xs text-gray-500">
                <span class="font-mono">{{ v.vin }}</span>
                · {{ v.color }}
              </p>
              <p class="text-xs text-gray-400 mt-0.5">
                Inspector: {{ v.inventarioInspector || '—' }} · Fecha: {{ v.inventarioFecha }}
                <span v-if="v.inventarioResultado" class="ml-1">
                  · {{ v.inventarioResultado.aprobados }}/{{ v.inventarioResultado.totalItems }} OK
                </span>
              </p>
            </div>
          </div>
          <span class="px-3 py-1.5 text-xs font-bold bg-success-100 text-success-700 rounded-full">
            Listo para Despacho
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

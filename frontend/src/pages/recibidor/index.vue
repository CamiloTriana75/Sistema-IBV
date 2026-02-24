<script setup lang="ts">
import { ref, computed } from 'vue'
import { useImprontaStore, type Impronta } from '~/stores/improntaStore'
import { useContenedorStore } from '~/stores/contenedorStore'

definePageMeta({ layout: 'admin' })

const store = useImprontaStore()
const contStore = useContenedorStore()
const search = ref('')
const filterEstado = ref('')
const filterCondicion = ref('')
const deleteTarget = ref<Impronta | null>(null)
const toast = ref('')

const filteredImprontas = computed(() => {
  let result = [...store.improntas]
  if (search.value) {
    const q = search.value.toLowerCase()
    result = result.filter(
      (i) =>
        i.folio.toLowerCase().includes(q) ||
        i.vin.toLowerCase().includes(q) ||
        i.placa.toLowerCase().includes(q) ||
        i.marca.toLowerCase().includes(q) ||
        i.modelo.toLowerCase().includes(q) ||
        i.cliente.toLowerCase().includes(q)
    )
  }
  if (filterEstado.value) result = result.filter((i) => i.estado === filterEstado.value)
  if (filterCondicion.value) result = result.filter((i) => i.condicion === filterCondicion.value)
  return result
})

const condicionLabel = (c: string) =>
  ({ excelente: 'Excelente', bueno: 'Bueno', regular: 'Regular', dañado: 'Con daños' })[c] || '—'
const condicionBadge = (c: string) =>
  ({
    excelente: 'bg-green-50 text-green-700',
    bueno: 'bg-blue-50 text-blue-700',
    regular: 'bg-amber-50 text-amber-700',
    dañado: 'bg-red-50 text-red-700',
  })[c] || 'bg-gray-50 text-gray-500'
const condicionDot = (c: string) =>
  ({
    excelente: 'bg-green-500',
    bueno: 'bg-blue-500',
    regular: 'bg-amber-500',
    dañado: 'bg-red-500',
  })[c] || 'bg-gray-400'

const estadoLabel = (e: string) =>
  ({ borrador: 'Borrador', completada: 'Completada', revisada: 'Revisada' })[e] || e
const estadoBadge = (e: string) =>
  ({
    borrador: 'bg-amber-50 text-amber-700',
    completada: 'bg-green-50 text-green-700',
    revisada: 'bg-purple-50 text-purple-700',
  })[e] || 'bg-gray-50 text-gray-500'
const estadoDot = (e: string) =>
  ({
    borrador: 'bg-amber-500',
    completada: 'bg-green-500',
    revisada: 'bg-purple-500',
  })[e] || 'bg-gray-400'

const formatDate = (d: string) => {
  if (!d) return '—'
  const [y, m, day] = d.split('-')
  const months = [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ]
  return `${day} ${months[parseInt(m)]} ${y}`
}

const confirmarEliminar = (imp: Impronta) => {
  deleteTarget.value = imp
}

const handleDelete = async () => {
  if (!deleteTarget.value) return
  const folio = deleteTarget.value.folio
  await store.eliminar(deleteTarget.value.id)
  deleteTarget.value = null
  toast.value = `Impronta ${folio} eliminada`
  setTimeout(() => {
    toast.value = ''
  }, 3000)
}
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Panel Recibidor</h1>
        <p class="text-gray-500 mt-1">Gestión de recepción e impronta de vehículos</p>
      </div>
      <div class="flex gap-3">
        <NuxtLink
          to="/recibidor/escaneo"
          class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
            />
          </svg>
          Escanear Recepción
        </NuxtLink>
        <NuxtLink
          to="/recibidor/impronta"
          class="inline-flex items-center gap-2 px-5 py-2.5 border border-gray-200 bg-white text-gray-700 font-semibold rounded-xl hover:bg-gray-50 transition"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 4v16m8-8H4"
            />
          </svg>
          Nueva Impronta
        </NuxtLink>
      </div>
    </div>

    <!-- Estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-2">
          <div class="w-10 h-10 bg-primary-50 rounded-lg flex items-center justify-center">
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
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
          </div>
          <span
            class="text-xs font-semibold text-primary-600 bg-primary-50 px-2 py-0.5 rounded-full"
          >
            Total
          </span>
        </div>
        <p class="text-3xl font-bold text-gray-900">{{ store.totalImprontas }}</p>
        <p class="text-sm text-gray-500 mt-1">Improntas registradas</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-2">
          <div class="w-10 h-10 bg-green-50 rounded-lg flex items-center justify-center">
            <svg
              class="w-5 h-5 text-green-600"
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
          <span class="text-xs font-semibold text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
            Hoy
          </span>
        </div>
        <p class="text-3xl font-bold text-green-600">{{ store.hoy }}</p>
        <p class="text-sm text-gray-500 mt-1">Registradas hoy</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-2">
          <div class="w-10 h-10 bg-amber-50 rounded-lg flex items-center justify-center">
            <svg
              class="w-5 h-5 text-amber-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </div>
          <span class="text-xs font-semibold text-amber-600 bg-amber-50 px-2 py-0.5 rounded-full">
            Pendientes
          </span>
        </div>
        <p class="text-3xl font-bold text-amber-600">{{ store.borradores }}</p>
        <p class="text-sm text-gray-500 mt-1">Borradores</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="flex items-center justify-between mb-2">
          <div class="w-10 h-10 bg-purple-50 rounded-lg flex items-center justify-center">
            <svg
              class="w-5 h-5 text-purple-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
          </div>
          <span class="text-xs font-semibold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-full">
            Revisadas
          </span>
        </div>
        <p class="text-3xl font-bold text-purple-600">{{ store.revisadas }}</p>
        <p class="text-sm text-gray-500 mt-1">Revisadas</p>
      </div>
    </div>

    <!-- Contenedores pendientes (acceso rápido) -->
    <div
      v-if="contStore.pendientes + contStore.enRecepcion > 0"
      class="bg-gradient-to-r from-primary-50 to-blue-50 rounded-xl border border-primary-100 p-5 mb-6"
    >
      <div class="flex items-center justify-between mb-3">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
              />
            </svg>
          </div>
          <div>
            <h3 class="text-sm font-bold text-gray-900">Contenedores por Recibir</h3>
            <p class="text-xs text-gray-500">
              {{ contStore.pendientes }} pendientes · {{ contStore.enRecepcion }} en recepción
            </p>
          </div>
        </div>
        <NuxtLink
          to="/recibidor/escaneo"
          class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition shadow-md shadow-primary-500/25"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
            />
          </svg>
          Iniciar Escaneo
        </NuxtLink>
      </div>
      <div class="flex gap-2 flex-wrap">
        <span
          v-for="cont in contStore.contenedores.filter((c) => c.estado !== 'completado')"
          :key="cont.id"
          class="text-xs font-mono font-bold bg-white px-3 py-1.5 rounded-lg border border-primary-200 text-primary-700"
        >
          {{ cont.codigo }} ({{ cont.vehiculosEsperados }} veh.)
        </span>
      </div>
    </div>

    <!-- Filtros -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 mb-6">
      <div class="flex flex-col sm:flex-row gap-3">
        <div class="flex-1 relative">
          <svg
            class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          <input
            v-model="search"
            type="text"
            placeholder="Buscar por folio, VIN, placa, marca..."
            class="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          />
        </div>
        <select
          v-model="filterEstado"
          class="px-4 py-2.5 border border-gray-200 rounded-lg text-sm bg-white focus:ring-2 focus:ring-primary-500"
        >
          <option value="">Todos los estados</option>
          <option value="borrador">Borrador</option>
          <option value="completada">Completada</option>
          <option value="revisada">Revisada</option>
        </select>
        <select
          v-model="filterCondicion"
          class="px-4 py-2.5 border border-gray-200 rounded-lg text-sm bg-white focus:ring-2 focus:ring-primary-500"
        >
          <option value="">Todas las condiciones</option>
          <option value="excelente">Excelente</option>
          <option value="bueno">Bueno</option>
          <option value="regular">Regular</option>
          <option value="dañado">Con daños</option>
        </select>
      </div>
    </div>

    <!-- Lista de improntas -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div v-if="store.loading" class="p-12 text-center">
        <div
          class="animate-spin w-8 h-8 border-4 border-primary-200 border-t-primary-600 rounded-full mx-auto mb-3"
        />
        <p class="text-gray-500 text-sm">Cargando improntas...</p>
      </div>

      <div v-else-if="filteredImprontas.length === 0" class="p-12 text-center">
        <svg
          class="w-16 h-16 text-gray-300 mx-auto mb-4"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="1.5"
            d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
          />
        </svg>
        <p class="text-gray-500 font-medium">No se encontraron improntas</p>
        <p class="text-gray-400 text-sm mt-1">Ajusta los filtros o crea una nueva impronta</p>
      </div>

      <div v-else class="overflow-x-auto">
        <table class="w-full">
          <thead>
            <tr class="bg-gray-50 border-b border-gray-100">
              <th
                class="px-5 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Folio
              </th>
              <th
                class="px-5 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Vehículo
              </th>
              <th
                class="px-5 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Cliente
              </th>
              <th
                class="px-5 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Condición
              </th>
              <th
                class="px-5 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Estado
              </th>
              <th
                class="px-5 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Fecha
              </th>
              <th
                class="px-5 py-3.5 text-center text-xs font-semibold text-gray-500 uppercase tracking-wider"
              >
                Acciones
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-50">
            <tr
              v-for="imp in filteredImprontas"
              :key="imp.id"
              class="hover:bg-gray-50/50 transition"
            >
              <td class="px-5 py-4">
                <span class="text-sm font-bold text-primary-600 font-mono">{{ imp.folio }}</span>
              </td>
              <td class="px-5 py-4">
                <div>
                  <p class="text-sm font-semibold text-gray-900">
                    {{ imp.marca }} {{ imp.modelo }} {{ imp.anio }}
                  </p>
                  <p class="text-xs text-gray-500 font-mono">
                    {{ imp.placa || 'Sin placa' }} · {{ imp.vin ? imp.vin.slice(-8) : 'S/N' }}
                  </p>
                </div>
              </td>
              <td class="px-5 py-4">
                <p class="text-sm text-gray-700">{{ imp.cliente || '—' }}</p>
              </td>
              <td class="px-5 py-4">
                <span
                  :class="condicionBadge(imp.condicion)"
                  class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                >
                  <span :class="condicionDot(imp.condicion)" class="w-1.5 h-1.5 rounded-full" />
                  {{ condicionLabel(imp.condicion) }}
                </span>
              </td>
              <td class="px-5 py-4">
                <span
                  :class="estadoBadge(imp.estado)"
                  class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                >
                  <span :class="estadoDot(imp.estado)" class="w-1.5 h-1.5 rounded-full" />
                  {{ estadoLabel(imp.estado) }}
                </span>
              </td>
              <td class="px-5 py-4">
                <p class="text-sm text-gray-700">{{ formatDate(imp.fechaCreacion) }}</p>
                <p class="text-xs text-gray-400">{{ imp.horaCreacion }}</p>
              </td>
              <td class="px-5 py-4">
                <div class="flex items-center justify-center gap-2">
                  <NuxtLink
                    :to="`/recibidor/impronta?id=${imp.id}`"
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-lg transition"
                  >
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                      />
                    </svg>
                    Editar
                  </NuxtLink>
                  <NuxtLink
                    :to="`/recibidor/impronta-print?id=${imp.id}`"
                    target="_blank"
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-gray-700 bg-gray-50 hover:bg-gray-100 rounded-lg transition"
                  >
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"
                      />
                    </svg>
                    Imprimir
                  </NuxtLink>
                  <button
                    class="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-red-700 bg-red-50 hover:bg-red-100 rounded-lg transition"
                    @click="confirmarEliminar(imp)"
                  >
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                      />
                    </svg>
                    Eliminar
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div
        v-if="filteredImprontas.length > 0"
        class="px-5 py-3 bg-gray-50 border-t border-gray-100 text-xs text-gray-500"
      >
        Mostrando {{ filteredImprontas.length }} de {{ store.totalImprontas }} improntas
      </div>
    </div>

    <!-- Modal eliminar -->
    <Teleport to="body">
      <Transition
        enter-active-class="transition duration-200"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition duration-150"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="deleteTarget" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="deleteTarget = null" />
          <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6 text-center">
            <div
              class="w-14 h-14 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-4"
            >
              <svg
                class="w-7 h-7 text-red-600"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                />
              </svg>
            </div>
            <h3 class="text-lg font-bold text-gray-900 mb-1">Eliminar Impronta</h3>
            <p class="text-sm text-gray-500 mb-6">
              ¿Eliminar
              <span class="font-semibold text-gray-700">{{ deleteTarget.folio }}</span>
              ({{ deleteTarget.marca }} {{ deleteTarget.modelo }})? Esta acción no se puede
              deshacer.
            </p>
            <div class="flex gap-3">
              <button
                class="flex-1 px-4 py-2.5 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition text-sm"
                @click="deleteTarget = null"
              >
                Cancelar
              </button>
              <button
                class="flex-1 px-4 py-2.5 bg-red-600 text-white font-semibold rounded-xl hover:bg-red-700 transition text-sm"
                @click="handleDelete"
              >
                Eliminar
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Toast -->
    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="translate-y-2 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="translate-y-0 opacity-100"
      leave-to-class="translate-y-2 opacity-0"
    >
      <div
        v-if="toast"
        class="fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-3 rounded-xl shadow-lg text-white font-medium bg-green-600"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5 13l4 4L19 7"
          />
        </svg>
        {{ toast }}
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'
import {
  getOpenExceptions,
  getVehicleExceptions,
  createException,
  updateExceptionStatus,
  assignException,
} from '~/services/supabaseAuditService'
import { supabaseUserService } from '~/services/supabaseUserService'
import type { VehicleException, ExceptionSeverity, ExceptionType } from '~/services/supabaseAuditService'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const vehiculoStore = useVehiculoStore()
const exceptions = ref<VehicleException[]>([])
const users = ref<any[]>([])
const loading = ref(false)
const statusFilter = ref<'all' | 'abierta' | 'en_progreso' | 'resuelta' | 'escalada'>('all')
const severityFilter = ref<'all' | 'baja' | 'media' | 'alta' | 'critica'>('all')

// Modal de crear excepción
const showCreateModal = ref(false)
const formData = ref({
  vehiculoId: '',
  exceptionType: 'bloqueada_en_estado' as ExceptionType,
  severity: 'alta' as ExceptionSeverity,
  description: '',
})

const filteredExceptions = computed(() => {
  let exc = exceptions.value

  if (statusFilter.value !== 'all') {
    exc = exc.filter((e) => e.estado === statusFilter.value)
  }

  if (severityFilter.value !== 'all') {
    exc = exc.filter((e) => e.severidad === severityFilter.value)
  }

  return exc.sort((a, b) => {
    const severityOrder = { critica: 0, alta: 1, media: 2, baja: 3 }
    const aOrder = severityOrder[a.severidad as keyof typeof severityOrder] || 99
    const bOrder = severityOrder[b.severidad as keyof typeof severityOrder] || 99
    return aOrder - bOrder || new Date(b.creada_en).getTime() - new Date(a.creada_en).getTime()
  })
})

const severityBadge = (severity: string) =>
  ({
    critica: 'bg-red-50 text-red-700',
    alta: 'bg-orange-50 text-orange-700',
    media: 'bg-yellow-50 text-yellow-700',
    baja: 'bg-blue-50 text-blue-700',
  })[severity] || 'bg-gray-50 text-gray-700'

const statusBadge = (status: string) =>
  ({
    abierta: 'bg-red-50 text-red-700',
    en_progreso: 'bg-blue-50 text-blue-700',
    resuelta: 'bg-green-50 text-green-700',
    escalada: 'bg-purple-50 text-purple-700',
  })[status] || 'bg-gray-50 text-gray-700'

const formatDate = (date: string) => {
  return new Date(date).toLocaleString('es-ES', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}

const exceptionTypeLabel = (type: string) =>
  ({
    bloqueada_en_estado: 'Atrapado en Estado',
    retrasada_mas_de_3_dias: 'Retraso > 3 días',
    documento_faltante: 'Documento Faltante',
    problema_calidad: 'Problema de Calidad',
    otra: 'Otro',
  })[type] || type

const severityLabel = (severity: string) =>
  ({
    critica: 'CRÍTICA',
    alta: 'ALTA',
    media: 'MEDIA',
    baja: 'BAJA',
  })[severity] || severity.toUpperCase()

const statusLabel = (status: string) =>
  ({
    abierta: 'ABIERTA',
    en_progreso: 'EN PROGRESO',
    resuelta: 'RESUELTA',
    escalada: 'ESCALADA',
  })[status] || status.toUpperCase()

const loadData = async () => {
  loading.value = true
  try {
    // Cargar vehículos si no están cargados
    if (vehiculoStore.vehiculos.length === 0) {
      await vehiculoStore.loadFromSupabase()
    }
    
    // Cargar TODAS las excepciones (no solo las abiertas)
    exceptions.value = await getVehicleExceptions()
    users.value = await supabaseUserService.getAllUsers()
  } finally {
    loading.value = false
  }
}

onMounted(loadData)

const openCreateModal = () => {
  showCreateModal.value = true
}

const closeCreateModal = () => {
  showCreateModal.value = false
  formData.value = {
    vehiculoId: '',
    exceptionType: 'bloqueada_en_estado',
    severity: 'alta',
    description: '',
  }
}

const submitCreateException = async () => {
  if (!formData.value.vehiculoId || !formData.value.description) {
    alert('Por favor completa todos los campos')
    return
  }

  try {
    await createException({
      vehiculoId: parseInt(formData.value.vehiculoId),
      exceptionType: formData.value.exceptionType,
      severity: formData.value.severity,
      description: formData.value.description,
    })

    closeCreateModal()
    await loadData()
  } catch (err) {
    console.error('Error creating exception:', err)
    alert('Error al crear la excepción')
  }
}

const updateStatus = async (exceptionId: number, newStatus: string) => {
  try {
    await updateExceptionStatus(exceptionId, newStatus as any)
    await loadData()
  } catch (err) {
    console.error('Error updating status:', err)
    alert('Error al actualizar estado')
  }
}

const assignToUser = async (exceptionId: number, userId: number) => {
  try {
    await assignException(exceptionId, userId)
    await loadData()
  } catch (err) {
    console.error('Error assigning:', err)
    alert('Error al asignar')
  }
}

const getVehicleInfo = (vehiculoId: number) => {
  return vehiculoStore.vehiculos.find((v) => Number(v.id) === vehiculoId)
}

const recargar = () => {
  loadData()
}
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Gestión de Excepciones</h1>
        <p class="text-sm text-gray-500 mt-1">Crear y resolver excepciones en el flujo de vehículos</p>
      </div>
      <div class="flex items-center gap-2">
        <button
          class="inline-flex items-center gap-2 px-4 py-2.5 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
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
        <button
          class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white rounded-xl font-medium text-sm hover:bg-primary-700 transition"
          @click="openCreateModal"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nueva Excepción
        </button>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Total</p>
        <p class="text-3xl font-bold text-gray-600 mt-1">{{ exceptions.length }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Abiertas</p>
        <p class="text-3xl font-bold text-red-600 mt-1">
          {{ exceptions.filter((e) => e.estado === 'abierta').length }}
        </p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">En Progreso</p>
        <p class="text-3xl font-bold text-blue-600 mt-1">
          {{ exceptions.filter((e) => e.estado === 'en_progreso').length }}
        </p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Resueltas</p>
        <p class="text-3xl font-bold text-green-600 mt-1">
          {{ exceptions.filter((e) => e.estado === 'resuelta').length }}
        </p>
      </div>
    </div>

    <!-- Filters -->
    <div class="flex gap-3 mb-6 flex-wrap">
      <select
        v-model="statusFilter"
        class="px-4 py-2.5 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
      >
        <option value="all">Todos los estados</option>
        <option value="abierta">Abiertas</option>
        <option value="en_progreso">En Progreso</option>
        <option value="resuelta">Resueltas</option>
        <option value="escalada">Escaladas</option>
      </select>
      <select
        v-model="severityFilter"
        class="px-4 py-2.5 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
      >
        <option value="all">Todas las severidades</option>
        <option value="critica">Crítica</option>
        <option value="alta">Alta</option>
        <option value="media">Media</option>
        <option value="baja">Baja</option>
      </select>
    </div>

    <!-- Exceptions Table -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">ID Vehículo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Tipo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Severidad</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Descripción</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Asignado a</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Creada</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="exc in filteredExceptions" :key="exc.id" class="hover:bg-gray-50">
              <td class="px-6 py-4">
                <div class="font-mono font-semibold text-gray-900">{{ exc.vehiculo_id }}</div>
                <div v-if="getVehicleInfo(exc.vehiculo_id)" class="text-xs text-gray-500 mt-0.5">
                  {{ getVehicleInfo(exc.vehiculo_id)?.bin }}
                </div>
              </td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ exceptionTypeLabel(exc.tipo_excepcion) }}</td>
              <td class="px-6 py-4">
                <span :class="`px-3 py-1 rounded-full text-xs font-semibold ${severityBadge(exc.severidad)}`">
                  {{ severityLabel(exc.severidad) }}
                </span>
              </td>
              <td class="px-6 py-4">
                <span :class="`px-3 py-1 rounded-full text-xs font-semibold ${statusBadge(exc.estado)}`">
                  {{ statusLabel(exc.estado) }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 max-w-xs">{{ exc.descripcion }}</td>
              <td class="px-6 py-4">
                <select
                  :value="exc.asignado_a_usuario_id || ''"
                  @change="(e) => assignToUser(exc.id, parseInt((e.target as HTMLSelectElement).value))"
                  class="px-3 py-1 border border-gray-200 rounded text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="">Sin asignar</option>
                  <option v-for="user in users" :key="user.id" :value="user.id">
                    {{ user.name }} ({{ user.role }})
                  </option>
                </select>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 whitespace-nowrap">
                {{ formatDate(exc.creada_en) }}
              </td>
              <td class="px-6 py-4">
                <select
                  :value="exc.estado"
                  @change="(e) => updateStatus(exc.id, (e.target as HTMLSelectElement).value)"
                  class="px-3 py-1 border border-gray-200 rounded text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                >
                  <option value="abierta">Abierta</option>
                  <option value="en_progreso">En Progreso</option>
                  <option value="resuelta">Resuelta</option>
                  <option value="escalada">Escalada</option>
                </select>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="filteredExceptions.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-500">No hay excepciones que mostrar</p>
      </div>
    </div>

    <!-- Create Exception Modal -->
    <Teleport to="body">
      <div
        v-if="showCreateModal"
        class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
        @click.self="closeCreateModal"
      >
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
          <div class="px-6 py-4 border-b border-gray-100">
            <h2 class="text-lg font-bold text-gray-900">Nueva Excepción</h2>
          </div>

          <div class="px-6 py-4 space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ID del Vehículo *</label>
              <select
                v-model="formData.vehiculoId"
                class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Selecciona un vehículo</option>
                <option v-for="vehiculo in vehiculoStore.vehiculos" :key="vehiculo.id" :value="vehiculo.id">
                  {{ vehiculo.id }} - {{ vehiculo.vin }} ({{ vehiculo.placa }})
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tipo de Excepción *</label>
              <select
                v-model="formData.exceptionType"
                class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="bloqueada_en_estado">Atrapado en Estado</option>
                <option value="retrasada_mas_de_3_dias">Retardo > 3 días</option>
                <option value="documento_faltante">Documento Faltante</option>
                <option value="problema_calidad">Problema de Calidad</option>
                <option value="otra">Otro</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Severidad *</label>
              <select
                v-model="formData.severity"
                class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="baja">Baja</option>
                <option value="media">Media</option>
                <option value="alta">Alta</option>
                <option value="critica">Crítica</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Descripción *</label>
              <textarea
                v-model="formData.description"
                rows="4"
                class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Describe el problema..."
              />
            </div>
          </div>

          <div class="px-6 py-4 border-t border-gray-100 flex gap-3 justify-end">
            <button
              class="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200"
              @click="closeCreateModal"
            >
              Cancelar
            </button>
            <button
              class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
              @click="submitCreateException"
            >
              Crear
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

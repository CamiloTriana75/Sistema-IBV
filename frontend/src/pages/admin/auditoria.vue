<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'
import { getAuditLogs, getActiveLocks, getVehicleExceptions, unlockVehicle, lockVehicle } from '~/services/supabaseAuditService'
import type { AuditLog, VehicleLock, VehicleException } from '~/services/supabaseAuditService'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const vehiculoStore = useVehiculoStore()
const auditLogs = ref<AuditLog[]>([])
const activeLocks = ref<VehicleLock[]>([])
const vehicleExceptions = ref<VehicleException[]>([])
const loading = ref(false)
const searchTerm = ref('')
const filterType = ref<'all' | 'cambio_estado' | 'anulacion_admin' | 'desbloqueo_manual' | 'escalacion'>('all')
const tab = ref<'logs' | 'locks' | 'exceptions'>('logs')

// Modal de bloqueo
const showLockModal = ref(false)
const lockFormData = ref({
  vehiculoId: '',
  reason: 'otra' as 'bloqueada_en_estado' | 'esperando_revision_manual' | 'escalacion_pendiente' | 'mantenimiento' | 'otra',
  description: '',
})
const lockingVehicleId = ref<number | null>(null)

const filteredLogs = computed(() => {
  let logs = auditLogs.value
  
  if (filterType.value !== 'all') {
    logs = logs.filter((log) => log.tipo_accion === filterType.value)
  }
  
  if (searchTerm.value) {
    const q = searchTerm.value.toLowerCase()
    logs = logs.filter((log) =>
      log.vehiculo_id.toString().includes(q) ||
      log.cambiado_por_rol.toLowerCase().includes(q) ||
      (log.razon && log.razon.toLowerCase().includes(q))
    )
  }
  
  return logs
})

const actionTypeLabel = (type: string) =>
  ({
    cambio_estado: 'Cambio de Estado',
    anulacion_admin: 'Anulación Admin',
    desbloqueo_manual: 'Desbloqueo Manual',
    escalacion: 'Escalada',
    nota_agregada: 'Nota Agregada',
  })[type] || type

const actionTypeBadge = (type: string) =>
  ({
    cambio_estado: 'bg-blue-50 text-blue-700',
    anulacion_admin: 'bg-red-50 text-red-700',
    desbloqueo_manual: 'bg-yellow-50 text-yellow-700',
    escalacion: 'bg-purple-50 text-purple-700',
    nota_agregada: 'bg-green-50 text-green-700',
  })[type] || 'bg-gray-50 text-gray-700'

const lockReasonLabel = (reason: string) =>
  ({
    bloqueada_en_estado: 'Atrapado en Estado',
    esperando_revision_manual: 'Esperando Revisión',
    escalacion_pendiente: 'Escalada Pendiente',
    mantenimiento: 'Mantenimiento',
    otra: 'Otro',
  })[reason] || reason

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

const formatDate = (date: string) => {
  return new Date(date).toLocaleString('es-ES', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })
}

const loadData = async () => {
  loading.value = true
  try {
    // Load vehicles if not loaded
    if (vehiculoStore.vehiculos.length === 0) {
      await vehiculoStore.loadFromSupabase()
    }

    // Get all audit logs (without filtering by vehicle - more efficient)
    auditLogs.value = await getAuditLogs()

    // Get active locks
    activeLocks.value = await getActiveLocks()

    // Get all exceptions (without filtering by vehicle - more efficient)
    vehicleExceptions.value = await getVehicleExceptions()
  } finally {
    loading.value = false
  }
}

onMounted(loadData)

const recargar = () => {
  loadData()
}

const getVehicleInfo = (vehiculoId: number) => {
  return vehiculoStore.vehiculos.find((v) => Number(v.id) === vehiculoId)
}

const openLockModal = (vehiculoId: number) => {
  lockingVehicleId.value = vehiculoId
  lockFormData.value = {
    vehiculoId: vehiculoId.toString(),
    reason: 'otra',
    description: '',
  }
  showLockModal.value = true
}

const closeLockModal = () => {
  showLockModal.value = false
  lockingVehicleId.value = null
}

const handleUnlock = async (lockId: number) => {
  try {
    const success = await unlockVehicle(lockId)
    if (success) {
      console.log('[Auditoria] Vehículo desbloqueado exitosamente')
      await loadData() // Recargar datos
    } else {
      console.error('[Auditoria] Error desbloqueando vehículo')
    }
  } catch (error) {
    console.error('[Auditoria] Exception desbloqueando:', error)
  }
}

const handleLock = async () => {
  if (!lockFormData.value.vehiculoId || !lockFormData.value.description) {
    console.warn('[Auditoria] ID vehículo y descripción son requeridos')
    return
  }

  try {
    const result = await lockVehicle({
      vehiculoId: parseInt(lockFormData.value.vehiculoId, 10),
      reason: lockFormData.value.reason,
      description: lockFormData.value.description,
    })

    if (result) {
      console.log('[Auditoria] Vehículo bloqueado exitosamente')
      await loadData() // Recargar datos
      closeLockModal()
    } else {
      console.error('[Auditoria] Error bloqueando vehículo')
    }
  } catch (error) {
    console.error('[Auditoria] Exception bloqueando:', error)
  }
}
</script>

<template>
  <div>
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Auditoría y Control</h1>
        <p class="text-sm text-gray-500 mt-1">Registro completo de cambios, bloqueos y excepciones</p>
      </div>
      <div class="flex gap-2">
        <button
          class="inline-flex items-center gap-2 px-4 py-2.5 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed"
          type="button"
          @click="showLockModal = true"
          :disabled="loading"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
          </svg>
          Bloquear Vehículo
        </button>
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
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Total de Cambios</p>
        <p class="text-3xl font-bold text-primary-600 mt-1">{{ auditLogs.length }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Bloqueos Activos</p>
        <p class="text-3xl font-bold text-warning-600 mt-1">{{ activeLocks.length }}</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-sm text-gray-500 font-medium">Excepciones Abiertas</p>
        <p class="text-3xl font-bold text-danger-600 mt-1">
          {{ vehicleExceptions.filter((e) => e.estado === 'abierta').length }}
        </p>
      </div>
    </div>

    <!-- Tabs -->
    <div class="flex gap-2 mb-6 flex-wrap">
      <button
        class="px-4 py-2 text-sm font-semibold rounded-xl transition"
        :class="tab === 'logs' ? 'bg-primary-100 text-primary-700' : 'text-gray-500 hover:bg-gray-100'"
        @click="tab = 'logs'"
      >
        Registro de Cambios ({{ auditLogs.length }})
      </button>
      <button
        class="px-4 py-2 text-sm font-semibold rounded-xl transition"
        :class="tab === 'locks' ? 'bg-warning-100 text-warning-700' : 'text-gray-500 hover:bg-gray-100'"
        @click="tab = 'locks'"
      >
        Bloqueos Activos ({{ activeLocks.length }})
      </button>
      <button
        class="px-4 py-2 text-sm font-semibold rounded-xl transition"
        :class="tab === 'exceptions' ? 'bg-danger-100 text-danger-700' : 'text-gray-500 hover:bg-gray-100'"
        @click="tab = 'exceptions'"
      >
        Excepciones ({{ vehicleExceptions.length }})
      </button>
    </div>

    <!-- Audit Logs Tab -->
    <div v-if="tab === 'logs'" class="space-y-4">
      <div class="flex gap-3">
        <input
          v-model="searchTerm"
          type="text"
          placeholder="Buscar por ID vehículo, rol, razón..."
          class="flex-1 px-4 py-2.5 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
        />
        <select
          v-model="filterType"
          class="px-4 py-2.5 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="all">Todos los tipos</option>
          <option value="cambio_estado">Cambios de Estado</option>
          <option value="anulacion_admin">Anulación Admin</option>
          <option value="desbloqueo_manual">Desbloqueos</option>
          <option value="escalacion">Escaladas</option>
        </select>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-100">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">ID Vehículo</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Tipo de Acción</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Realizado por</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Cambio</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Razón</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Fecha</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
              <tr v-for="log in filteredLogs" :key="log.id" class="hover:bg-gray-50">
                <td class="px-6 py-4">
                  <div class="font-mono font-semibold text-gray-900">{{ log.vehiculo_id }}</div>
                </td>
                <td class="px-6 py-4">
                  <span :class="`px-3 py-1 rounded-full text-xs font-semibold ${actionTypeBadge(log.tipo_accion)}`">
                    {{ actionTypeLabel(log.tipo_accion) }}
                  </span>
                </td>
                <td class="px-6 py-4">
                  <div class="text-sm">
                    <div class="font-semibold text-gray-900">{{ log.cambiado_por_rol }}</div>
                    <div class="text-gray-500 text-xs">ID: {{ log.cambiado_por_usuario_id }}</div>
                  </div>
                </td>
                <td class="px-6 py-4">
                  <div class="text-sm max-w-xs">
                    <div class="text-red-600 font-mono text-xs">{{ log.estado_anterior.estado }}</div>
                    <div class="text-green-600 font-mono text-xs">→ {{ log.estado_nuevo.estado }}</div>
                  </div>
                </td>
                <td class="px-6 py-4 text-sm text-gray-600">{{ log.razon || '-' }}</td>
                <td class="px-6 py-4">
                  <div class="text-sm text-gray-600 whitespace-nowrap">{{ formatDate(log.creada_en) }}</div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="filteredLogs.length === 0" class="px-6 py-12 text-center">
          <p class="text-gray-500">No hay registros de auditoría</p>
        </div>
      </div>
    </div>

    <!-- Active Locks Tab -->
    <div v-if="tab === 'locks'" class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">ID Vehículo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Razón</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Descripción</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Bloqueado por</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Desde</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Acciones</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="lock in activeLocks" :key="lock.id" class="hover:bg-gray-50">
              <td class="px-6 py-4">
                <div class="font-mono font-semibold text-gray-900">{{ lock.vehiculo_id }}</div>
              </td>
              <td class="px-6 py-4">
                <span class="px-3 py-1 rounded-full text-xs font-semibold bg-warning-50 text-warning-700">
                  {{ lockReasonLabel(lock.razon) }}
                </span>
              </td>
              <td class="px-6 py-4">
                <p class="text-sm text-gray-600 max-w-xs">{{ lock.descripcion }}</p>
              </td>
              <td class="px-6 py-4">
                <div class="text-sm">
                  <div class="font-semibold text-gray-900">{{ lock.bloqueado_por_rol }}</div>
                </div>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 whitespace-nowrap">
                {{ formatDate(lock.bloqueado_en) }}
              </td>
              <td class="px-6 py-4">
                <button
                  class="px-3 py-1 bg-red-50 text-red-700 text-xs font-semibold rounded-lg hover:bg-red-100"
                  @click="handleUnlock(lock.id)"
                >
                  Desbloquear
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="activeLocks.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-500">No hay bloqueos activos</p>
      </div>
    </div>

    <!-- Exceptions Tab -->
    <div v-if="tab === 'exceptions'" class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">ID Vehículo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Tipo</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Severidad</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Descripción</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Estado</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-700">Créado</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr v-for="exc in vehicleExceptions" :key="exc.id" class="hover:bg-gray-50">
              <td class="px-6 py-4">
                <div class="font-mono font-semibold text-gray-900">{{ exc.vehiculo_id }}</div>
                <div v-if="getVehicleInfo(exc.vehiculo_id)" class="text-xs text-gray-500 mt-0.5">
                  {{ getVehicleInfo(exc.vehiculo_id)?.bin }}
                </div>
              </td>
              <td class="px-6 py-4 text-sm text-gray-700">{{ exceptionTypeLabel(exc.tipo_excepcion) }}</td>
              <td class="px-6 py-4">
                <span
                  :class="{
                    'bg-red-50 text-red-700': exc.severidad === 'critica',
                    'bg-orange-50 text-orange-700': exc.severidad === 'alta',
                    'bg-yellow-50 text-yellow-700': exc.severidad === 'media',
                    'bg-blue-50 text-blue-700': exc.severidad === 'baja',
                  }"
                  class="px-3 py-1 rounded-full text-xs font-semibold"
                >
                  {{ severityLabel(exc.severidad) }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 max-w-xs">{{ exc.descripcion }}</td>
              <td class="px-6 py-4">
                <span
                  :class="{
                    'bg-red-50 text-red-700': exc.estado === 'abierta',
                    'bg-blue-50 text-blue-700': exc.estado === 'en_progreso',
                    'bg-green-50 text-green-700': exc.estado === 'resuelta',
                    'bg-purple-50 text-purple-700': exc.estado === 'escalada',
                  }"
                  class="px-3 py-1 rounded-full text-xs font-semibold"
                >
                  {{ statusLabel(exc.estado) }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600 whitespace-nowrap">
                {{ formatDate(exc.creada_en) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="vehicleExceptions.length === 0" class="px-6 py-12 text-center">
        <p class="text-gray-500">No hay excepciones registradas</p>
      </div>
    </div>

    <!-- Lock Modal -->
    <div v-if="showLockModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">Bloquear Vehículo</h3>
          <button
            @click="closeLockModal"
            class="text-gray-500 hover:text-gray-700 transition"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div class="px-6 py-4 space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Seleccionar Vehículo</label>
            <select
              v-model="lockFormData.vehiculoId"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">-- Selecciona un vehículo --</option>
              <option v-for="v in vehiculoStore.vehiculos" :key="v.id" :value="v.dbId.toString()">
                {{ v.vin || v.placa }} (ID: {{ v.dbId }})
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Razón del Bloqueo</label>
            <select
              v-model="lockFormData.reason"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="bloqueada_en_estado">Atrapado en Estado</option>
              <option value="esperando_revision_manual">Esperando Revisión Manual</option>
              <option value="escalacion_pendiente">Escalada Pendiente</option>
              <option value="mantenimiento">Mantenimiento</option>
              <option value="otra">Otro</option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
            <textarea
              v-model="lockFormData.description"
              rows="3"
              placeholder="Explica la razón del bloqueo..."
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
        </div>

        <div class="px-6 py-4 border-t border-gray-100 flex gap-2 justify-end">
          <button
            @click="closeLockModal"
            class="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition"
          >
            Cancelar
          </button>
          <button
            @click="handleLock"
            :disabled="!lockFormData.vehiculoId || !lockFormData.description"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition font-medium disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Bloquear
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'
import { useContenedorStore, type Contenedor } from '~/stores/contenedorStore'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ layout: 'admin' })

const contStore = useContenedorStore()
const authStore = useAuthStore()

const paso = ref(1)
const contenedorActual = ref<Contenedor | null>(null)
const observaciones = ref('')
const resumenFinal = reactive({ codigo: '', escaneados: 0, total: 0 })

const scannerContenedor = ref<any>(null)
const scannerVehiculo = ref<any>(null)

const toast = reactive({ show: false, msg: '', type: 'ok' as 'ok' | 'warn' | 'error' })
const mostrarToast = (type: 'ok' | 'warn' | 'error', msg: string) => {
  toast.type = type
  toast.msg = msg
  toast.show = true
  setTimeout(() => { toast.show = false }, 3500)
}

// Contenedores pendientes/en recepcion
const contenedoresPendientes = computed(() =>
  contStore.contenedores.filter(c => c.estado === 'pendiente' || c.estado === 'en_recepcion')
)

// Stats para paso 2
const vehiculosEscaneados = computed(() =>
  contenedorActual.value?.vehiculos.filter(v => v.escaneado).length || 0
)
const progresoVehiculos = computed(() => {
  if (!contenedorActual.value) return 0
  const total = contenedorActual.value.vehiculosEsperados
  if (total === 0) return 0
  return Math.round((vehiculosEscaneados.value / total) * 100)
})

// ===== Paso 1: Escanear contenedor =====
const onScanContenedor = (codigo: string) => {
  const cont = contStore.getByCodigo(codigo)
  if (!cont) {
    scannerContenedor.value?.setError(`Contenedor "${codigo}" no encontrado en el sistema`)
    mostrarToast('error', 'Contenedor no encontrado')
    return
  }
  if (cont.estado === 'completado') {
    scannerContenedor.value?.setError(`El contenedor "${codigo}" ya fue recibido`)
    mostrarToast('warn', 'Este contenedor ya fue recibido')
    return
  }
  seleccionarContenedor(cont)
}

const seleccionarContenedor = (cont: Contenedor) => {
  contenedorActual.value = cont
  const user = authStore.user?.name || 'Recibidor'
  contStore.iniciarRecepcion(cont.id, user)
  paso.value = 2
  mostrarToast('ok', `Contenedor ${cont.codigo} cargado`)
}

// ===== Paso 2: Escanear vehículos =====
const onScanVehiculo = (codigoImpronta: string) => {
  if (!contenedorActual.value) return

  // Buscar en el contenedor actual
  const veh = contenedorActual.value.vehiculos.find(
    v => v.codigoImpronta.toLowerCase() === codigoImpronta.toLowerCase() ||
         v.vin.toLowerCase() === codigoImpronta.toLowerCase()
  )

  if (!veh) {
    scannerVehiculo.value?.setError(`Vehículo con código "${codigoImpronta}" no pertenece a este contenedor`)
    mostrarToast('error', 'Vehículo no encontrado en este contenedor')
    return
  }

  if (veh.escaneado) {
    scannerVehiculo.value?.setError(`El vehículo ${veh.marca} ${veh.modelo} ya fue escaneado`)
    mostrarToast('warn', 'Este vehículo ya fue escaneado')
    return
  }

  // Marcar escaneado
  contStore.marcarVehiculoEscaneado(contenedorActual.value.id, veh.codigoImpronta)
  veh.escaneado = true
  mostrarToast('ok', `${veh.marca} ${veh.modelo} — escaneado correctamente`)

  // Si todos escaneados
  if (contenedorActual.value.vehiculos.every(v => v.escaneado)) {
    mostrarToast('ok', '¡Todos los vehículos escaneados!')
  }
}

// ===== Paso 3: Finalizar =====
const finalizarRecepcion = () => {
  if (!contenedorActual.value) return
  contStore.completarRecepcion(contenedorActual.value.id, observaciones.value)
  resumenFinal.codigo = contenedorActual.value.codigo
  resumenFinal.escaneados = vehiculosEscaneados.value
  resumenFinal.total = contenedorActual.value.vehiculosEsperados
  paso.value = 3
}

const nuevaRecepcion = () => {
  contenedorActual.value = null
  observaciones.value = ''
  paso.value = 1
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
      <div class="flex items-center gap-3">
        <NuxtLink to="/recibidor" class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </NuxtLink>
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Recepción de Vehículos</h1>
          <p class="text-gray-500 mt-1">Escanea el contenedor y luego cada vehículo</p>
        </div>
      </div>
    </div>

    <!-- Progress Steps -->
    <div class="flex items-center gap-3 mb-8">
      <div class="flex items-center gap-2">
        <div
:class="[
          'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all',
          paso >= 1 ? 'bg-primary-600 text-white shadow-lg shadow-primary-500/30' : 'bg-gray-200 text-gray-500'
        ]">1</div>
        <span class="text-sm font-semibold" :class="paso >= 1 ? 'text-primary-700' : 'text-gray-400'">Contenedor</span>
      </div>
      <div class="flex-1 h-1 rounded-full" :class="paso >= 2 ? 'bg-primary-500' : 'bg-gray-200'" />
      <div class="flex items-center gap-2">
        <div
:class="[
          'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all',
          paso >= 2 ? 'bg-primary-600 text-white shadow-lg shadow-primary-500/30' : 'bg-gray-200 text-gray-500'
        ]">2</div>
        <span class="text-sm font-semibold" :class="paso >= 2 ? 'text-primary-700' : 'text-gray-400'">Vehículos</span>
      </div>
      <div class="flex-1 h-1 rounded-full" :class="paso >= 3 ? 'bg-success-500' : 'bg-gray-200'" />
      <div class="flex items-center gap-2">
        <div
:class="[
          'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all',
          paso >= 3 ? 'bg-success-600 text-white shadow-lg shadow-success-500/30' : 'bg-gray-200 text-gray-500'
        ]">
          <svg v-if="paso >= 3" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <span v-else>3</span>
        </div>
        <span class="text-sm font-semibold" :class="paso >= 3 ? 'text-success-700' : 'text-gray-400'">Completado</span>
      </div>
    </div>

    <!-- ========== PASO 1: Escanear Contenedor ========== -->
    <div v-if="paso === 1" class="max-w-2xl mx-auto">
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 sm:p-8">
        <div class="text-center mb-6">
          <div class="w-16 h-16 bg-primary-50 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
            </svg>
          </div>
          <h2 class="text-xl font-bold text-gray-900 mb-1">Escanear Código de Contenedor</h2>
          <p class="text-sm text-gray-500">Escanea el código QR o de barras del contenedor que trae los vehículos</p>
        </div>

        <QrScanner
          ref="scannerContenedor"
          placeholder="Código del contenedor (ej: CONT-2026-0001)"
          hide-result
          @scan="onScanContenedor"
        />

        <!-- Contenedores pendientes de hoy -->
        <div class="mt-8 pt-6 border-t border-gray-100">
          <h3 class="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Contenedores pendientes
          </h3>
          <div v-if="contenedoresPendientes.length === 0" class="text-sm text-gray-400 py-4 text-center bg-gray-50 rounded-xl">
            No hay contenedores pendientes
          </div>
          <div class="space-y-2">
            <button
v-for="cont in contenedoresPendientes" :key="cont.id" class="w-full flex items-center gap-4 p-4 rounded-xl text-left hover:bg-primary-50 border-2 border-transparent hover:border-primary-200 transition bg-gray-50"
              @click="seleccionarContenedor(cont)">
              <div class="w-11 h-11 bg-primary-100 rounded-xl flex items-center justify-center shrink-0">
                <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                </svg>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-gray-900 font-mono">{{ cont.codigo }}</p>
                <p class="text-xs text-gray-500">{{ cont.origen }} · {{ cont.transportista }}</p>
              </div>
              <div class="text-right shrink-0">
                <p class="text-sm font-bold text-primary-600">{{ cont.vehiculosEsperados }} veh.</p>
                <p class="text-xs text-gray-400">{{ cont.horaLlegada }}</p>
              </div>
              <span
:class="[
                'text-xs font-semibold px-2.5 py-1 rounded-full shrink-0',
                cont.estado === 'en_recepcion' ? 'bg-amber-50 text-amber-700' : 'bg-blue-50 text-blue-700'
              ]">
                {{ cont.estado === 'en_recepcion' ? 'En recepción' : 'Pendiente' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ========== PASO 2: Escanear Vehículos ========== -->
    <div v-if="paso === 2 && contenedorActual" class="space-y-6">
      <!-- Info del contenedor -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
        <div class="flex flex-wrap items-center gap-5">
          <div class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center shrink-0">
            <svg class="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
            </svg>
          </div>
          <div class="flex-1 grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Contenedor</p>
              <p class="text-sm font-bold text-gray-900 font-mono">{{ contenedorActual.codigo }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Origen</p>
              <p class="text-sm font-bold text-gray-900">{{ contenedorActual.origen }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Transportista</p>
              <p class="text-sm font-bold text-gray-900">{{ contenedorActual.transportista }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Placa Camión</p>
              <p class="text-sm font-bold text-gray-900 font-mono">{{ contenedorActual.placaCamion }}</p>
            </div>
          </div>
          <button
class="px-3 py-1.5 text-xs text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition font-semibold"
            @click="paso = 1; contenedorActual = null">
            Cambiar
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Scanner de vehículos -->
        <div class="xl:col-span-2 space-y-6">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center gap-3 mb-5">
              <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
                </svg>
              </div>
              <div>
                <h2 class="text-lg font-bold text-gray-900">Escanear Código de Impronta</h2>
                <p class="text-sm text-gray-500">Escanea el código QR de cada vehículo del contenedor</p>
              </div>
            </div>

            <QrScanner
              ref="scannerVehiculo"
              placeholder="Código de impronta del vehículo (ej: IMP-VH-001)"
              hide-result
              @scan="onScanVehiculo"
            />
          </div>

          <!-- Lista de vehículos del contenedor -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 class="text-sm font-bold text-gray-900">Vehículos del Contenedor</h3>
              <span class="text-sm font-bold" :class="vehiculosEscaneados === contenedorActual.vehiculosEsperados ? 'text-success-600' : 'text-primary-600'">
                {{ vehiculosEscaneados }} / {{ contenedorActual.vehiculosEsperados }}
              </span>
            </div>

            <!-- Progress bar -->
            <div class="px-5 pt-3">
              <div class="w-full bg-gray-100 rounded-full h-2.5">
                <div
class="h-2.5 rounded-full transition-all duration-500"
                  :class="progresoVehiculos === 100 ? 'bg-success-500' : 'bg-primary-500'"
                  :style="{ width: progresoVehiculos + '%' }" />
              </div>
            </div>

            <div class="divide-y divide-gray-50">
              <div
v-for="(veh, idx) in contenedorActual.vehiculos" :key="veh.vin"
                class="px-5 py-4 flex items-center gap-4 transition"
                :class="veh.escaneado ? 'bg-success-50/30' : ''">
                <!-- Numero / Check -->
                <div
:class="[
                  'w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold shrink-0 transition-all',
                  veh.escaneado ? 'bg-success-500 text-white' : 'bg-gray-100 text-gray-500'
                ]">
                  <svg v-if="veh.escaneado" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                  <span v-else>{{ idx + 1 }}</span>
                </div>

                <!-- Info -->
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-semibold text-gray-900">{{ veh.marca }} {{ veh.modelo }} {{ veh.anio }}</p>
                  <p class="text-xs text-gray-500 font-mono">VIN: {{ veh.vin.slice(-8) }} · {{ veh.color }}</p>
                </div>

                <!-- Código -->
                <div class="text-right shrink-0">
                  <p class="text-xs text-gray-400 font-mono">{{ veh.codigoImpronta }}</p>
                </div>

                <!-- Estado -->
                <span
:class="[
                  'text-xs font-semibold px-2.5 py-1 rounded-full shrink-0',
                  veh.escaneado ? 'bg-success-50 text-success-700' : 'bg-gray-100 text-gray-500'
                ]">
                  {{ veh.escaneado ? 'Escaneado' : 'Pendiente' }}
                </span>

                <!-- Acción -->
                <NuxtLink
v-if="veh.escaneado && !veh.improntaId"
                  :to="`/recibidor/impronta?vin=${veh.vin}&marca=${veh.marca}&modelo=${veh.modelo}&anio=${veh.anio}&color=${veh.color}`"
                  class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-semibold text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-lg transition shrink-0">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                  </svg>
                  Impronta
                </NuxtLink>
                <span v-if="veh.improntaId" class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-semibold text-success-700 bg-success-50 rounded-lg shrink-0">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  Impronta OK
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Panel lateral: Resumen -->
        <div class="space-y-6">
          <!-- Progreso -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h3 class="text-sm font-bold text-gray-900 mb-4">Progreso de Recepción</h3>
            <div class="flex items-center justify-center mb-4">
              <div class="relative w-28 h-28">
                <svg class="w-28 h-28 transform -rotate-90">
                  <circle cx="56" cy="56" r="48" stroke="#e5e7eb" stroke-width="8" fill="none" />
                  <circle
cx="56" cy="56" r="48" :stroke="progresoVehiculos === 100 ? '#22c55e' : '#3b82f6'"
                    stroke-width="8" fill="none" stroke-linecap="round"
                    :stroke-dasharray="`${progresoVehiculos * 3.01} 301`" class="transition-all duration-700" />
                </svg>
                <div class="absolute inset-0 flex items-center justify-center">
                  <span class="text-2xl font-bold" :class="progresoVehiculos === 100 ? 'text-success-600' : 'text-primary-600'">
                    {{ progresoVehiculos }}%
                  </span>
                </div>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-3 text-center">
              <div class="bg-success-50 rounded-xl p-3">
                <p class="text-2xl font-bold text-success-600">{{ vehiculosEscaneados }}</p>
                <p class="text-xs text-success-600 font-semibold">Escaneados</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-3">
                <p class="text-2xl font-bold text-gray-500">{{ contenedorActual.vehiculosEsperados - vehiculosEscaneados }}</p>
                <p class="text-xs text-gray-500 font-semibold">Pendientes</p>
              </div>
            </div>
          </div>

          <!-- Observaciones -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h3 class="text-sm font-bold text-gray-900 mb-3">Observaciones</h3>
            <textarea
v-model="observaciones" rows="4" placeholder="Notas sobre la recepción..."
              class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 resize-none transition" />
          </div>

          <!-- Botones -->
          <div class="space-y-3">
            <button
:disabled="vehiculosEscaneados === 0" class="w-full px-5 py-3 text-sm font-bold rounded-xl transition shadow-lg disabled:opacity-40 disabled:cursor-not-allowed disabled:shadow-none"
              :class="progresoVehiculos === 100
                ? 'bg-success-600 text-white hover:bg-success-700 shadow-success-500/25'
                : 'bg-primary-600 text-white hover:bg-primary-700 shadow-primary-500/25'"
              @click="finalizarRecepcion">
              <span class="flex items-center justify-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                {{ progresoVehiculos === 100 ? 'Completar Recepción' : 'Finalizar Parcialmente' }}
              </span>
            </button>
            <button
class="w-full px-5 py-2.5 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition"
              @click="paso = 1; contenedorActual = null">
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ========== PASO 3: Completado ========== -->
    <div v-if="paso === 3" class="max-w-md mx-auto text-center">
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
        <div class="w-20 h-20 bg-success-100 rounded-full flex items-center justify-center mx-auto mb-5">
          <svg class="w-10 h-10 text-success-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-gray-900 mb-2">Recepción Completada</h2>
        <p class="text-gray-500 mb-2">
          Contenedor <span class="font-bold text-gray-700 font-mono">{{ resumenFinal.codigo }}</span>
        </p>
        <p class="text-sm text-gray-500 mb-6">
          Se escanearon <span class="font-bold text-success-600">{{ resumenFinal.escaneados }}</span> de {{ resumenFinal.total }} vehículos
        </p>
        <div class="flex gap-3">
          <button
class="flex-1 px-5 py-2.5 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25"
            @click="nuevaRecepcion">
            Nueva Recepción
          </button>
          <NuxtLink
to="/recibidor"
            class="flex-1 px-5 py-2.5 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition text-center">
            Ir al Panel
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <Transition
enter-active-class="transition duration-300 ease-out" enter-from-class="translate-y-2 opacity-0"
      enter-to-class="translate-y-0 opacity-100" leave-active-class="transition duration-200 ease-in"
      leave-from-class="translate-y-0 opacity-100" leave-to-class="translate-y-2 opacity-0">
      <div
v-if="toast.show" class="fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-3 rounded-xl shadow-lg text-white font-medium"
        :class="toast.type === 'ok' ? 'bg-success-600' : toast.type === 'warn' ? 'bg-amber-500' : 'bg-danger-600'">
        <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path v-if="toast.type === 'ok'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          <path v-else-if="toast.type === 'warn'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
        {{ toast.msg }}
      </div>
    </Transition>
  </div>
</template>

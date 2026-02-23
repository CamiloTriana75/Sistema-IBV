<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div class="flex items-center gap-3">
        <NuxtLink to="/despachador" class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </NuxtLink>
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Escaneo de Despacho</h1>
          <p class="text-gray-500 mt-1">Lote #{{ loteActual }} — Escanea cada vehículo para despachar</p>
        </div>
      </div>
      <div class="flex gap-3">
        <button @click="finalizarLote"
          :disabled="vehiculosEscaneados.length === 0"
          class="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-xl transition shadow-lg"
          :class="vehiculosEscaneados.length > 0
            ? 'bg-success-600 text-white hover:bg-success-700 shadow-success-500/25'
            : 'bg-gray-100 text-gray-400 cursor-not-allowed shadow-none'">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Finalizar Lote ({{ vehiculosEscaneados.length }})
        </button>
      </div>
    </div>

    <!-- Barra de progreso del lote -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 mb-6">
      <div class="flex items-center justify-between mb-3">
        <span class="text-sm font-bold text-gray-700">Progreso de escaneo</span>
        <span class="text-sm font-bold" :class="todosEscaneados ? 'text-success-600' : 'text-primary-600'">
          {{ vehiculosEscaneados.length }} / {{ vehiculosLote.length }} vehículos
        </span>
      </div>
      <div class="w-full bg-gray-100 rounded-full h-3">
        <div class="h-3 rounded-full transition-all duration-700"
          :class="todosEscaneados ? 'bg-success-500' : 'bg-primary-500'"
          :style="`width: ${progressPorcentaje}%`" />
      </div>
      <div class="flex items-center gap-6 mt-3 text-xs text-gray-500">
        <span class="flex items-center gap-1.5">
          <span class="w-2 h-2 bg-success-400 rounded-full" />
          Escaneados: {{ vehiculosEscaneados.length }}
        </span>
        <span class="flex items-center gap-1.5">
          <span class="w-2 h-2 bg-gray-300 rounded-full" />
          Pendientes: {{ vehiculosPendientes.length }}
        </span>
      </div>
    </div>

    <!-- Sin vehículos disponibles -->
    <div v-if="vehiculosLote.length === 0" class="bg-white rounded-xl shadow-sm border border-gray-100 p-12 text-center">
      <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
      </svg>
      <p class="text-gray-500 font-bold text-lg">No hay vehículos listos para despacho</p>
      <p class="text-gray-400 text-sm mt-2">Los vehículos requieren impronta completada e inventario aprobado</p>
      <NuxtLink to="/despachador" class="inline-flex items-center gap-2 mt-4 px-4 py-2 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition">
        Volver al panel
      </NuxtLink>
    </div>

    <div v-else class="grid grid-cols-1 xl:grid-cols-5 gap-6">
      <!-- Zona de escaneo QR -->
      <div class="xl:col-span-2 space-y-4">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <!-- Zona del scanner -->
          <div class="relative bg-gray-900 aspect-square flex flex-col items-center justify-center">
            <div v-if="!vehiculoActual" class="text-center">
              <div class="relative w-48 h-48 mx-auto mb-6">
                <div class="absolute inset-0 border-2 border-white/20 rounded-xl"></div>
                <div class="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-primary-400 rounded-tl-xl"></div>
                <div class="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-primary-400 rounded-tr-xl"></div>
                <div class="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-primary-400 rounded-bl-xl"></div>
                <div class="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-primary-400 rounded-br-xl"></div>
                <div class="absolute inset-x-4 h-0.5 bg-primary-400/80 rounded-full shadow-lg shadow-primary-400/60 animate-scan-line" />
                <div class="absolute inset-0 flex items-center justify-center">
                  <svg class="w-16 h-16 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12v.01M12 4h.01M4 4h4v4H4V4zm12 0h4v4h-4V4zM4 16h4v4H4v-4z" />
                  </svg>
                </div>
              </div>
              <p class="text-white/60 text-sm font-medium">Escanea el QR/VIN del vehículo</p>
              <p class="text-white/40 text-xs mt-1">Solo vehículos con impronta e inventario</p>
            </div>

            <!-- Vehículo reconocido -->
            <div v-else class="text-center px-6 py-4">
              <div class="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4 shadow-xl"
                :class="vehiculoActual.ok ? 'bg-success-500 shadow-success-500/50' : 'bg-danger-500 shadow-danger-500/50'">
                <svg v-if="vehiculoActual.ok" class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
                <svg v-else class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </div>
              <p class="text-sm font-bold uppercase tracking-widest mb-1"
                :class="vehiculoActual.ok ? 'text-success-400' : 'text-danger-400'">
                {{ vehiculoActual.ok ? '¡Verificado!' : '¡Bloqueado!' }}
              </p>
              <p class="text-white font-black text-xl">{{ vehiculoActual.vin }}</p>
              <p v-if="vehiculoActual.vehiculo" class="text-white/70 text-sm mt-1">
                {{ vehiculoActual.vehiculo.marca }} {{ vehiculoActual.vehiculo.modelo }}
              </p>
              <p v-if="!vehiculoActual.ok" class="text-danger-300 text-xs mt-2">{{ vehiculoActual.razon }}</p>
            </div>
          </div>

          <!-- Controles de escaneo -->
          <div class="p-5 space-y-3">
            <button @click="simularEscaneo"
              :disabled="todosEscaneados"
              class="w-full py-3 font-bold text-sm rounded-xl transition"
              :class="todosEscaneados
                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                : 'bg-primary-600 text-white hover:bg-primary-700 shadow-lg shadow-primary-500/25 active:scale-95'">
              {{ todosEscaneados ? 'Todos escaneados ✓' : '⚡ Simular Escaneo QR' }}
            </button>

            <div class="flex gap-2">
              <input v-model="vinManual" type="text" placeholder="Ingresar VIN manualmente..."
                class="flex-1 px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition"
                @keydown.enter="escanearManual" />
              <button @click="escanearManual"
                class="px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm font-semibold rounded-xl transition">
                OK
              </button>
            </div>

            <!-- Error message -->
            <div v-if="errorMsg" class="flex items-center gap-2 p-3 bg-danger-50 border border-danger-200 rounded-xl">
              <svg class="w-4 h-4 text-danger-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              <p class="text-xs text-danger-700 font-medium">{{ errorMsg }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Lista de vehículos del lote -->
      <div class="xl:col-span-3">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-bold text-gray-900">Vehículos del Lote</h3>
            <div class="flex gap-2">
              <span @click="filtroEstado = 'todos'"
                class="px-3 py-1 text-xs font-semibold rounded-lg cursor-pointer transition"
                :class="filtroEstado === 'todos' ? 'bg-primary-100 text-primary-700' : 'text-gray-500 hover:text-gray-700'">
                Todos ({{ vehiculosLote.length }})
              </span>
              <span @click="filtroEstado = 'pendiente'"
                class="px-3 py-1 text-xs font-semibold rounded-lg cursor-pointer transition"
                :class="filtroEstado === 'pendiente' ? 'bg-warning-100 text-warning-700' : 'text-gray-500 hover:text-gray-700'">
                Pendientes ({{ vehiculosPendientes.length }})
              </span>
            </div>
          </div>

          <div class="divide-y divide-gray-50 max-h-[520px] overflow-y-auto">
            <div v-for="(v, idx) in vehiculosFiltrados" :key="v.vin"
              class="flex items-center gap-4 px-5 py-3.5 transition-colors"
              :class="v.escaneado ? 'bg-success-50/50' : 'hover:bg-gray-50'">
              <div class="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0"
                :class="v.escaneado ? 'bg-success-500 text-white' : 'bg-gray-100 text-gray-500'">
                {{ v.escaneado ? '✓' : (idx + 1) }}
              </div>

              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <p class="text-sm font-bold text-gray-900 font-mono">{{ v.vin }}</p>
                  <span v-if="v.escaneado" class="text-xs px-2 py-0.5 bg-success-100 text-success-700 font-semibold rounded-full">
                    Escaneado
                  </span>
                </div>
                <p class="text-xs text-gray-400 mt-0.5">{{ v.marca }} {{ v.modelo }} {{ v.anio }} — {{ v.color }}</p>
              </div>

              <div class="flex items-center gap-1 shrink-0">
                <span class="px-1.5 py-0.5 text-[10px] font-bold bg-blue-50 text-blue-600 rounded">IMP ✓</span>
                <span class="px-1.5 py-0.5 text-[10px] font-bold bg-green-50 text-green-600 rounded">INV ✓</span>
              </div>

              <div v-if="v.horaEscaneo" class="text-right shrink-0">
                <p class="text-xs font-semibold text-success-600">{{ v.horaEscaneo }}</p>
              </div>
              <div v-else class="w-2 h-2 bg-warning-400 rounded-full animate-pulse shrink-0" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ layout: 'admin' })

const vehiculoStore = useVehiculoStore()
const authStore = useAuthStore()
const router = useRouter()
const vinManual = ref('')
const filtroEstado = ref<'todos' | 'pendiente'>('todos')
const errorMsg = ref('')
const vehiculoActual = ref<{ vin: string; ok: boolean; razon?: string; vehiculo?: any } | null>(null)

// Lot number auto-generated
const loteActual = `LT-${new Date().getFullYear()}-${String(Date.now()).slice(-4)}`

interface VehiculoLote {
  vin: string
  marca: string
  modelo: string
  anio: string
  color: string
  cliente: string
  escaneado: boolean
  horaEscaneo?: string
}

// Build lot from vehicles ready in the store
const vehiculosLote = ref<VehiculoLote[]>(
  vehiculoStore.getListosParaDespacho.map(v => ({
    vin: v.vin,
    marca: v.marca,
    modelo: v.modelo,
    anio: v.anio,
    color: v.color,
    cliente: v.cliente,
    escaneado: false,
  }))
)

const vehiculosEscaneados = computed(() => vehiculosLote.value.filter(v => v.escaneado))
const vehiculosPendientes = computed(() => vehiculosLote.value.filter(v => !v.escaneado))
const todosEscaneados = computed(() => vehiculosLote.value.length > 0 && vehiculosEscaneados.value.length === vehiculosLote.value.length)
const progressPorcentaje = computed(() => vehiculosLote.value.length === 0 ? 0 : Math.round((vehiculosEscaneados.value.length / vehiculosLote.value.length) * 100))

const vehiculosFiltrados = computed(() => {
  if (filtroEstado.value === 'pendiente') return vehiculosPendientes.value
  return vehiculosLote.value
})

const procesarEscaneo = (vin: string) => {
  errorMsg.value = ''

  // 1. Check dispatch eligibility via vehiculoStore
  const check = vehiculoStore.puedeDespachar(vin)
  if (!check.ok) {
    vehiculoActual.value = { vin, ok: false, razon: check.razon }
    errorMsg.value = check.razon || 'No se puede despachar'
    setTimeout(() => { vehiculoActual.value = null }, 3000)
    return
  }

  // 2. Find in lot
  const v = vehiculosLote.value.find(x => x.vin.toLowerCase() === vin.toLowerCase())
  if (!v) {
    vehiculoActual.value = { vin, ok: false, razon: 'Vehículo no está en este lote' }
    errorMsg.value = 'Este VIN no está en el lote actual'
    setTimeout(() => { vehiculoActual.value = null }, 3000)
    return
  }
  if (v.escaneado) {
    vehiculoActual.value = { vin, ok: false, razon: 'Ya fue escaneado' }
    errorMsg.value = 'Este vehículo ya fue escaneado en este lote'
    setTimeout(() => { vehiculoActual.value = null }, 3000)
    return
  }

  // 3. Success
  vehiculoActual.value = { vin, ok: true, vehiculo: v }
  setTimeout(() => {
    v.horaEscaneo = new Date().toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
    v.escaneado = true
    setTimeout(() => { vehiculoActual.value = null }, 1500)
  }, 800)
}

const simularEscaneo = () => {
  const pendientes = vehiculosPendientes.value
  if (pendientes.length === 0) return
  procesarEscaneo(pendientes[0].vin)
}

const escanearManual = () => {
  if (!vinManual.value.trim()) return
  procesarEscaneo(vinManual.value.trim())
  vinManual.value = ''
}

const finalizarLote = () => {
  // Mark all scanned vehicles as dispatched in the store
  const despachador = authStore.user?.name || 'Despachador'
  for (const v of vehiculosEscaneados.value) {
    vehiculoStore.despachar(v.vin, loteActual, despachador)
  }
  // Navigate to planilla with lot info
  router.push(`/despachador/planilla?lote=${loteActual}`)
}
</script>

<style scoped>
@keyframes scan-line {
  0%, 100% { top: 10%; }
  50% { top: 85%; }
}
.animate-scan-line {
  animation: scan-line 2s ease-in-out infinite;
  position: absolute;
}
</style>

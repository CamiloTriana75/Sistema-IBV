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
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Escaneo de Vehículos</h1>
          <p class="text-gray-500 mt-1">Lote #LT-2024-0089 — Escanea secuencialmente cada vehículo</p>
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
          Finalizar Lote
        </button>
      </div>
    </div>

    <!-- Barra de progreso del lote -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 mb-6">
      <div class="flex items-center justify-between mb-3">
        <span class="text-sm font-bold text-gray-700">Progreso del lote</span>
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

    <div class="grid grid-cols-1 xl:grid-cols-5 gap-6">
      <!-- Zona de escaneo QR -->
      <div class="xl:col-span-2 space-y-4">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <!-- Zona del scanner -->
          <div class="relative bg-gray-900 aspect-square flex flex-col items-center justify-center">
            <div v-if="!vehiculoActual" class="text-center">
              <!-- Marco de scanner animado -->
              <div class="relative w-48 h-48 mx-auto mb-6">
                <div class="absolute inset-0 border-2 border-white/20 rounded-xl"></div>
                <!-- Esquinas -->
                <div class="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-primary-400 rounded-tl-xl"></div>
                <div class="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-primary-400 rounded-tr-xl"></div>
                <div class="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-primary-400 rounded-bl-xl"></div>
                <div class="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-primary-400 rounded-br-xl"></div>
                <!-- Línea de escaneo -->
                <div class="absolute inset-x-4 h-0.5 bg-primary-400/80 rounded-full shadow-lg shadow-primary-400/60 animate-scan-line" />
                <!-- QR icon -->
                <div class="absolute inset-0 flex items-center justify-center">
                  <svg class="w-16 h-16 text-white/30" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12v.01M12 4h.01M4 4h4v4H4V4zm12 0h4v4h-4V4zM4 16h4v4H4v-4z" />
                  </svg>
                </div>
              </div>
              <p class="text-white/60 text-sm font-medium">Apunta la cámara al código QR</p>
              <p class="text-white/40 text-xs mt-1">del vehículo a escanear</p>
            </div>

            <!-- Vehículo reconocido -->
            <div v-else class="text-center px-6 py-4">
              <div class="w-16 h-16 bg-success-500 rounded-full flex items-center justify-center mx-auto mb-4 shadow-xl shadow-success-500/50">
                <svg class="w-9 h-9 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <p class="text-success-400 text-sm font-bold uppercase tracking-widest mb-1">¡Vehículo Reconocido!</p>
              <p class="text-white font-black text-xl">{{ vehiculoActual.vin }}</p>
              <p class="text-white/70 text-sm mt-1">{{ vehiculoActual.marca }} {{ vehiculoActual.modelo }}</p>
            </div>

            <!-- Botón de flash (UI) -->
            <button class="absolute top-3 right-3 p-2 bg-white/10 hover:bg-white/20 rounded-xl transition text-white">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </button>
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

            <!-- Entrada manual -->
            <div class="flex gap-2">
              <input v-model="vinManual" type="text" placeholder="Ingresar VIN manualmente..."
                class="flex-1 px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition"
                @keydown.enter="escanearManual" />
              <button @click="escanearManual"
                class="px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm font-semibold rounded-xl transition">
                OK
              </button>
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
            <div v-for="(v, idx) in vehiculosFiltrados" :key="v.id"
              class="flex items-center gap-4 px-5 py-3.5 transition-colors"
              :class="v.escaneado ? 'bg-success-50/50' : 'hover:bg-gray-50'">
              <!-- Número de orden -->
              <div class="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0"
                :class="v.escaneado ? 'bg-success-500 text-white' : 'bg-gray-100 text-gray-500'">
                {{ v.escaneado ? '✓' : (idx + 1) }}
              </div>

              <!-- Info del vehículo -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <p class="text-sm font-bold text-gray-900 font-mono">{{ v.vin }}</p>
                  <span v-if="v.escaneado" class="text-xs px-2 py-0.5 bg-success-100 text-success-700 font-semibold rounded-full">
                    Escaneado
                  </span>
                </div>
                <p class="text-xs text-gray-400 mt-0.5">{{ v.marca }} {{ v.modelo }} {{ v.anio }} — {{ v.color }}</p>
              </div>

              <!-- Hora de escaneo -->
              <div v-if="v.horaEscaneo" class="text-right shrink-0">
                <p class="text-xs font-semibold text-success-600">{{ v.horaEscaneo }}</p>
                <p class="text-xs text-gray-400">escaneado</p>
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

definePageMeta({ layout: 'admin' })

const router = useRouter()
const vinManual = ref('')
const filtroEstado = ref<'todos' | 'pendiente'>('todos')
const vehiculoActual = ref<any>(null)
let scanIdx = 0

interface Vehiculo {
  id: number
  vin: string
  marca: string
  modelo: string
  anio: number
  color: string
  escaneado: boolean
  horaEscaneo?: string
}

const vehiculosLote = ref<Vehiculo[]>([
  { id: 1, vin: '1HGBH41JMN109186', marca: 'Toyota', modelo: 'Corolla', anio: 2024, color: 'Blanco', escaneado: false },
  { id: 2, vin: '2T1BURHE0JC063671', marca: 'Toyota', modelo: 'Yaris', anio: 2024, color: 'Gris Plata', escaneado: false },
  { id: 3, vin: '3VWF17AT0FM516411', marca: 'Volkswagen', modelo: 'Gol', anio: 2023, color: 'Rojo', escaneado: false },
  { id: 4, vin: '4T1BF1FK5CU614935', marca: 'Toyota', modelo: 'Camry', anio: 2024, color: 'Negro', escaneado: false },
  { id: 5, vin: '5YJSA1DN1DFP14947', marca: 'Hyundai', modelo: 'Accent', anio: 2024, color: 'Azul', escaneado: false },
  { id: 6, vin: '6G2EC13T9EL174836', marca: 'Chevrolet', modelo: 'Spark', anio: 2023, color: 'Blanco Perla', escaneado: false },
  { id: 7, vin: '7FARW2H58JE044816', marca: 'Honda', modelo: 'Fit', anio: 2024, color: 'Verde', escaneado: false },
  { id: 8, vin: '8AR2E3D1XMK001234', marca: 'Nissan', modelo: 'March', anio: 2023, color: 'Plateado', escaneado: false }
])

const vehiculosEscaneados = computed(() => vehiculosLote.value.filter(v => v.escaneado))
const vehiculosPendientes = computed(() => vehiculosLote.value.filter(v => !v.escaneado))
const todosEscaneados = computed(() => vehiculosEscaneados.value.length === vehiculosLote.value.length)
const progressPorcentaje = computed(() => Math.round((vehiculosEscaneados.value.length / vehiculosLote.value.length) * 100))

const vehiculosFiltrados = computed(() => {
  if (filtroEstado.value === 'pendiente') return vehiculosPendientes.value
  return vehiculosLote.value
})

const simularEscaneo = () => {
  const pendientes = vehiculosPendientes.value
  if (pendientes.length === 0) return
  const v = pendientes[0]
  vehiculoActual.value = v
  setTimeout(() => {
    const hora = new Date().toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
    v.horaEscaneo = hora
    v.escaneado = true
    setTimeout(() => { vehiculoActual.value = null }, 1500)
  }, 1000)
}

const escanearManual = () => {
  if (!vinManual.value.trim()) return
  const v = vehiculosLote.value.find(x => x.vin.toLowerCase() === vinManual.value.trim().toLowerCase())
  if (v && !v.escaneado) {
    vehiculoActual.value = v
    setTimeout(() => {
      const hora = new Date().toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
      v.horaEscaneo = hora
      v.escaneado = true
      vinManual.value = ''
      setTimeout(() => { vehiculoActual.value = null }, 1500)
    }, 800)
  } else {
    vinManual.value = ''
  }
}

const finalizarLote = () => {
  router.push('/despachador/planilla')
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

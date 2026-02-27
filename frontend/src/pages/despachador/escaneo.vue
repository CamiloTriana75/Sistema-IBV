<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useDespachadorStore } from '~/stores/despachadorStore'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ layout: 'admin' })

const despachadorStore = useDespachadorStore()
const authStore = useAuthStore()
const router = useRouter()
const route = useRoute()
const scannerRef = ref<{
  setError: (msg: string) => void
  setSuccess: (msg?: string) => void
  reset: () => void
  focus: () => void
} | null>(null)

// Lot number auto-generated
const loteActual = `LT-${new Date().getFullYear()}-${String(Date.now()).slice(-4)}`

interface VehiculoLote {
  id: string | number
  bin: string
  marca: string
  modelo: string
  anio: number
  color: string
  escaneado: boolean
  horaEscaneo?: string
}

// Cargar vehículos al montar
onMounted(async () => {
  await despachadorStore.load()

  // Si viene bin en query, pre-seleccionar ese vehículo
  const binParam = route.query.bin as string
  if (binParam) {
    const v = despachadorStore.getByBin(binParam)
    if (v) {
      handleScan(binParam)
    }
  }
})

// Build lot from vehicles ready in the store
const vehiculosLote = ref<VehiculoLote[]>(
  despachadorStore.vehiculosListos.map((v) => ({
    id: v.id,
    bin: v.bin,
    marca: v.modelo?.marca || '',
    modelo: v.modelo?.modelo || '',
    anio: v.modelo?.anio || new Date().getFullYear(),
    color: v.color || '',
    escaneado: false,
  }))
)

const vehiculosEscaneados = computed(() => vehiculosLote.value.filter((v) => v.escaneado))
const vehiculosPendientes = computed(() => vehiculosLote.value.filter((v) => !v.escaneado))
const todosEscaneados = computed(
  () =>
    vehiculosLote.value.length > 0 &&
    vehiculosEscaneados.value.length === vehiculosLote.value.length
)
const progressPorcentaje = computed(() =>
  vehiculosLote.value.length === 0
    ? 0
    : Math.round((vehiculosEscaneados.value.length / vehiculosLote.value.length) * 100)
)

const vehiculosFiltrados = computed(() => {
  return vehiculosPendientes.value
})

/**
 * Procesa un BIN escaneado desde el QR scanner o entrada manual
 */
const handleScan = (bin: string) => {
  // 1. Check if vehicle exists in the list
  const vehiculoDb = despachadorStore.getByBin(bin)
  if (!vehiculoDb) {
    scannerRef.value?.setError('Este BIN no está en la lista de despacho')
    return
  }

  // 2. Find in lot
  const v = vehiculosLote.value.find((x) => x.bin.toLowerCase() === bin.toLowerCase())
  if (!v) {
    scannerRef.value?.setError('Este BIN no está en el lote actual')
    return
  }
  if (v.escaneado) {
    scannerRef.value?.setError('Este vehículo ya fue escaneado en este lote')
    return
  }

  // 3. Success — marcar como escaneado
  v.horaEscaneo = new Date().toLocaleTimeString('es-VE', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  })
  v.escaneado = true
  scannerRef.value?.setSuccess(`${v.marca} ${v.modelo} — BIN verificado`)
}

const onScan = (bin: string) => {
  handleScan(bin)
}

const simularEscaneo = () => {
  const pendientes = vehiculosPendientes.value
  if (pendientes.length === 0) return
  onScan(pendientes[0].bin)
}

const finalizarLote = async () => {
  // Despachar todos los vehículos escaneados
  const despachador = authStore.user?.name || 'Despachador'
  let despachosExitosos = 0
  let _despachosError = 0

  for (const v of vehiculosEscaneados.value) {
    const ok = await vehiculoStore.despachar(v.vin, loteActual, despachador)
    if (ok) {
      despachosExitosos++
    } else {
      _despachosError++
      console.error(`Error despachando ${v.vin}`)
    }
  }

  // Navegar si hubo al menos un despacho exitoso
  if (despachosExitosos > 0) {
    router.push(`/despachador/planilla?lote=${loteActual}`)
  } else {
    console.error(`No se pudo despachar ningún vehículo`)
  }
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div class="flex items-center gap-3">
        <NuxtLink
          to="/despachador"
          class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </NuxtLink>
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Escaneo de Despacho</h1>
          <p class="text-gray-500 mt-1">
            Lote #{{ loteActual }} — Escanea cada vehículo para despachar
          </p>
        </div>
      </div>
      <div class="flex gap-3">
        <button
          :disabled="vehiculosEscaneados.length === 0"
          class="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-xl transition shadow-lg"
          :class="
            vehiculosEscaneados.length > 0
              ? 'bg-success-600 text-white hover:bg-success-700 shadow-success-500/25'
              : 'bg-gray-100 text-gray-400 cursor-not-allowed shadow-none'
          "
          @click="finalizarLote"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          Finalizar Lote ({{ vehiculosEscaneados.length }})
        </button>
      </div>
    </div>

    <!-- Barra de progreso del lote -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 mb-6">
      <div class="flex items-center justify-between mb-3">
        <span class="text-sm font-bold text-gray-700">Progreso de escaneo</span>
        <span
          class="text-sm font-bold"
          :class="todosEscaneados ? 'text-success-600' : 'text-primary-600'"
        >
          {{ vehiculosEscaneados.length }} / {{ vehiculosLote.length }} vehículos
        </span>
      </div>
      <div class="w-full bg-gray-100 rounded-full h-3">
        <div
          class="h-3 rounded-full transition-all duration-700"
          :class="todosEscaneados ? 'bg-success-500' : 'bg-primary-500'"
          :style="`width: ${progressPorcentaje}%`"
        />
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
    <div
      v-if="vehiculosLote.length === 0"
      class="bg-white rounded-xl shadow-sm border border-gray-100 p-12 text-center"
    >
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
          d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
        />
      </svg>
      <p class="text-gray-500 font-bold text-lg">No hay vehículos listos para despacho</p>
      <p class="text-gray-400 text-sm mt-2">
        Los vehículos requieren impronta completada e inventario aprobado
      </p>
      <NuxtLink
        to="/despachador"
        class="inline-flex items-center gap-2 mt-4 px-4 py-2 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition"
      >
        Volver al panel
      </NuxtLink>
    </div>

    <div v-else class="grid grid-cols-1 xl:grid-cols-5 gap-6">
      <!-- Zona de escaneo QR (componente reutilizable) -->
      <div class="xl:col-span-2 space-y-4">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 bg-primary-100 rounded-xl flex items-center justify-center">
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
                  d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
                />
              </svg>
            </div>
            <div>
              <h2 class="text-lg font-bold text-gray-900">Escanear Vehículo</h2>
              <p class="text-sm text-gray-500">Escanea el QR o VIN de cada vehículo del lote</p>
            </div>
          </div>

          <QrScanner
            ref="scannerRef"
            placeholder="BIN del vehículo (escanea el código QR)"
            hide-result
            @scan="onScan"
          />

          <!-- Botón simular escaneo (solo desarrollo) -->
          <button
            :disabled="todosEscaneados"
            class="w-full mt-4 py-3 font-bold text-sm rounded-xl transition"
            :class="
              todosEscaneados
                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                : 'bg-primary-600 text-white hover:bg-primary-700 shadow-lg shadow-primary-500/25 active:scale-95'
            "
            @click="simularEscaneo"
          >
            {{ todosEscaneados ? 'Todos escaneados ✓' : '⚡ Simular Escaneo QR' }}
          </button>
        </div>
      </div>

      <!-- Lista de vehículos del lote -->
      <div class="xl:col-span-3">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-bold text-gray-900">Vehículos del Lote</h3>
            <div class="flex gap-2">
              <span
                class="px-3 py-1 text-xs font-semibold rounded-lg cursor-pointer transition"
                :class="
                  filtroEstado === 'todos'
                    ? 'bg-primary-100 text-primary-700'
                    : 'text-gray-500 hover:text-gray-700'
                "
                @click="filtroEstado = 'todos'"
              >
                Todos ({{ vehiculosLote.length }})
              </span>
              <span
                class="px-3 py-1 text-xs font-semibold rounded-lg cursor-pointer transition"
                :class="
                  filtroEstado === 'pendiente'
                    ? 'bg-warning-100 text-warning-700'
                    : 'text-gray-500 hover:text-gray-700'
                "
                @click="filtroEstado = 'pendiente'"
              >
                Pendientes ({{ vehiculosPendientes.length }})
              </span>
            </div>
          </div>

          <div class="divide-y divide-gray-50 max-h-[520px] overflow-y-auto">
            <div
              v-for="(v, idx) in vehiculosFiltrados"
              :key="v.bin"
              class="flex items-center gap-4 px-5 py-3.5 transition-colors"
              :class="v.escaneado ? 'bg-success-50/50' : 'hover:bg-gray-50'"
            >
              <div
                class="w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0"
                :class="v.escaneado ? 'bg-success-500 text-white' : 'bg-gray-100 text-gray-500'"
              >
                {{ v.escaneado ? '✓' : idx + 1 }}
              </div>

              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <p class="text-sm font-bold text-gray-900 font-mono">{{ v.bin }}</p>
                  <span
                    v-if="v.escaneado"
                    class="text-xs px-2 py-0.5 bg-success-100 text-success-700 font-semibold rounded-full"
                  >
                    Escaneado
                  </span>
                </div>
                <p class="text-xs text-gray-400 mt-0.5">
                  {{ v.marca }} {{ v.modelo }} {{ String(v.anio) }} — {{ v.color }}
                </p>
              </div>

              <div class="flex items-center gap-1 shrink-0">
                <span class="px-1.5 py-0.5 text-[10px] font-bold bg-blue-50 text-blue-600 rounded">
                  IMP ✓
                </span>
                <span
                  class="px-1.5 py-0.5 text-[10px] font-bold bg-green-50 text-green-600 rounded"
                >
                  INV ✓
                </span>
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

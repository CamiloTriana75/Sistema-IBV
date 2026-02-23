<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div class="flex items-center gap-3">
        <NuxtLink to="/inventario" class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </NuxtLink>
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Checklist de Inventario</h1>
          <p class="text-gray-500 mt-1">Verificación de artículos del vehículo</p>
        </div>
      </div>
      <div class="flex gap-3">
        <button @click="rechazar"
          class="inline-flex items-center gap-2 px-4 py-2.5 border border-danger-200 bg-danger-50 text-danger-700 text-sm font-semibold rounded-xl hover:bg-danger-100 transition">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
          Rechazar
        </button>
        <button @click="aprobar" :disabled="!puedeAprobar"
          class="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-xl transition shadow-lg"
          :class="puedeAprobar ? 'bg-success-600 text-white hover:bg-success-700 shadow-success-500/25' : 'bg-gray-100 text-gray-400 cursor-not-allowed shadow-none'">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          Aprobar Inventario
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-4 gap-6">
      <!-- Columna principal: Checklist -->
      <div class="xl:col-span-3 space-y-4">

        <!-- Info del vehículo -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5 flex flex-wrap items-center gap-6">
          <div class="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center shrink-0">
            <svg class="w-8 h-8 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
          </div>
          <div class="flex-1 grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">VIN</p>
              <p class="text-sm font-bold text-gray-900 font-mono">1HGBH41J</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Vehículo</p>
              <p class="text-sm font-bold text-gray-900">Toyota Corolla 2024</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Color</p>
              <p class="text-sm font-bold text-gray-900">Blanco Perla</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Cliente</p>
              <p class="text-sm font-bold text-gray-900">Distribuidora CCS</p>
            </div>
          </div>
          <div class="flex items-center gap-2 px-3 py-1.5 bg-warning-50 border border-warning-200 rounded-lg">
            <div class="w-2 h-2 bg-warning-500 rounded-full animate-pulse" />
            <span class="text-xs font-semibold text-warning-700">En verificación</span>
          </div>
        </div>

        <!-- Categorías del checklist -->
        <div v-for="categoria in categorias" :key="categoria.id" class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <!-- Header de categoría -->
          <button @click="categoria.abierta = !categoria.abierta"
            class="w-full flex items-center justify-between px-5 py-4 text-left hover:bg-gray-50 transition">
            <div class="flex items-center gap-3">
              <div class="w-8 h-8 rounded-xl flex items-center justify-center" :class="categoria.colorFondo">
                <svg class="w-4 h-4" :class="categoria.colorIcono" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="categoria.icono" />
                </svg>
              </div>
              <div>
                <h3 class="font-bold text-gray-900">{{ categoria.nombre }}</h3>
                <p class="text-xs text-gray-400">{{ categoria.descripcion }}</p>
              </div>
            </div>
            <div class="flex items-center gap-4">
              <!-- Mini progreso -->
              <div class="hidden sm:flex items-center gap-2">
                <div class="w-32 bg-gray-100 rounded-full h-1.5">
                  <div class="h-1.5 rounded-full transition-all duration-500"
                    :class="progresoCategoria(categoria) === 100 ? 'bg-success-500' : 'bg-primary-500'"
                    :style="`width: ${progresoCategoria(categoria)}%`" />
                </div>
                <span class="text-xs text-gray-500 font-semibold w-16 text-right">
                  {{ itemsResueltos(categoria) }}/{{ categoria.items.length }}
                </span>
              </div>
              <svg class="w-5 h-5 text-gray-400 transition-transform"
                :class="categoria.abierta ? 'rotate-180' : ''"
                fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </div>
          </button>

          <!-- Items de la categoría -->
          <div v-if="categoria.abierta" class="border-t border-gray-100">
            <div v-for="(item, idx) in categoria.items" :key="item.id"
              class="px-5 py-3 flex items-start gap-4 transition-colors"
              :class="[
                idx < categoria.items.length - 1 ? 'border-b border-gray-50' : '',
                item.estado === 'falla' ? 'bg-danger-50' : item.estado === 'ok' ? 'bg-success-50/40' : 'hover:bg-gray-50'
              ]">
              <!-- Nombre del ítem -->
              <div class="flex-1 min-w-0 pt-0.5">
                <p class="text-sm font-medium text-gray-800">{{ item.nombre }}</p>
                <p v-if="item.descripcion" class="text-xs text-gray-400 mt-0.5">{{ item.descripcion }}</p>
                <!-- Campo de notas para fallas -->
                <div v-if="item.estado === 'falla'" class="mt-2">
                  <input v-model="item.nota" type="text" placeholder="Describir la falla o faltante..."
                    class="w-full px-2.5 py-1.5 text-xs border border-danger-200 rounded-lg bg-white focus:ring-1 focus:ring-danger-400 focus:border-danger-400 transition" />
                </div>
              </div>

              <!-- Botones de estado -->
              <div class="flex items-center gap-2 shrink-0">
                <button @click="item.estado = 'ok'"
                  class="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg border-2 transition-all"
                  :class="item.estado === 'ok'
                    ? 'bg-success-500 border-success-500 text-white shadow-md shadow-success-500/30'
                    : 'bg-white border-gray-200 text-gray-500 hover:border-success-300 hover:text-success-600'">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                  </svg>
                  OK
                </button>
                <button @click="item.estado = 'falla'"
                  class="flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg border-2 transition-all"
                  :class="item.estado === 'falla'
                    ? 'bg-danger-500 border-danger-500 text-white shadow-md shadow-danger-500/30'
                    : 'bg-white border-gray-200 text-gray-500 hover:border-danger-300 hover:text-danger-600'">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                  Falla
                </button>
                <button @click="item.estado = 'na'"
                  class="px-3 py-1.5 text-xs font-semibold rounded-lg border-2 transition-all"
                  :class="item.estado === 'na'
                    ? 'bg-gray-400 border-gray-400 text-white'
                    : 'bg-white border-gray-200 text-gray-500 hover:border-gray-400 hover:text-gray-700'">
                  N/A
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Columna lateral: Resumen -->
      <div class="space-y-4">
        <!-- Progreso global -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
          <h3 class="text-sm font-bold text-gray-900 mb-4">Progreso General</h3>
          <div class="flex items-center justify-center mb-5">
            <div class="relative w-28 h-28">
              <svg class="w-full h-full -rotate-90" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="40" fill="none" stroke="#f1f5f9" stroke-width="10"/>
                <circle cx="50" cy="50" r="40" fill="none"
                  :stroke="progresoGlobal === 100 ? '#22c55e' : '#3b82f6'"
                  stroke-width="10"
                  stroke-linecap="round"
                  :stroke-dasharray="`${progresoGlobal * 2.51} 251`"
                  class="transition-all duration-700"/>
              </svg>
              <div class="absolute inset-0 flex flex-col items-center justify-center">
                <span class="text-3xl font-black" :class="progresoGlobal === 100 ? 'text-success-600' : 'text-primary-600'">
                  {{ progresoGlobal }}%
                </span>
                <span class="text-xs text-gray-400 font-semibold">completado</span>
              </div>
            </div>
          </div>
          <div class="space-y-2">
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-500 flex items-center gap-2">
                <span class="w-2.5 h-2.5 bg-success-500 rounded-full" />
                Aprobados
              </span>
              <span class="font-bold text-success-600">{{ totalOk }}</span>
            </div>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-500 flex items-center gap-2">
                <span class="w-2.5 h-2.5 bg-danger-500 rounded-full" />
                Con falla
              </span>
              <span class="font-bold text-danger-600">{{ totalFallas }}</span>
            </div>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-500 flex items-center gap-2">
                <span class="w-2.5 h-2.5 bg-gray-300 rounded-full" />
                No aplica
              </span>
              <span class="font-bold text-gray-500">{{ totalNa }}</span>
            </div>
            <div class="flex items-center justify-between text-sm border-t border-gray-100 pt-2 mt-1">
              <span class="text-gray-500 flex items-center gap-2">
                <span class="w-2.5 h-2.5 bg-gray-200 rounded-full" />
                Pendientes
              </span>
              <span class="font-bold text-gray-600">{{ totalPendientes }}</span>
            </div>
          </div>
        </div>

        <!-- Acciones rápidas por categoría -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
          <h3 class="text-sm font-bold text-gray-900 mb-4">Estado por Sección</h3>
          <div class="space-y-3">
            <div v-for="cat in categorias" :key="cat.id" class="flex items-center gap-3">
              <div class="w-6 h-6 rounded-lg flex items-center justify-center shrink-0" :class="cat.colorFondo">
                <svg class="w-3 h-3" :class="cat.colorIcono" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="cat.icono" />
                </svg>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex justify-between items-center mb-1">
                  <span class="text-xs font-semibold text-gray-600 truncate">{{ cat.nombre }}</span>
                  <span class="text-xs text-gray-400 ml-2 shrink-0">{{ progresoCategoria(cat) }}%</span>
                </div>
                <div class="w-full bg-gray-100 rounded-full h-1">
                  <div class="h-1 rounded-full transition-all duration-500"
                    :class="progresoCategoria(cat) === 100 ? 'bg-success-400' : 'bg-primary-400'"
                    :style="`width: ${progresoCategoria(cat)}%`" />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Nota de aprobación -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
          <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">
            Nota del inspector
          </label>
          <textarea v-model="notaInspector" rows="3" placeholder="Observaciones finales del inspector..."
            class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition resize-none" />
        </div>
      </div>
    </div>

    <!-- Modal de rechazo -->
    <div v-if="showModalRechazo" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
      <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-10 h-10 bg-danger-100 rounded-xl flex items-center justify-center">
            <svg class="w-5 h-5 text-danger-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          </div>
          <h2 class="text-lg font-bold text-gray-900">Rechazar Inventario</h2>
        </div>
        <p class="text-sm text-gray-600 mb-4">Indica el motivo del rechazo. El vehículo será devuelto para correcciones.</p>
        <textarea v-model="motivoRechazo" rows="3" placeholder="Motivo del rechazo..."
          class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-danger-500 focus:border-danger-500 transition resize-none mb-4" />
        <div class="flex gap-3 justify-end">
          <button @click="showModalRechazo = false"
            class="px-4 py-2.5 border border-gray-200 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-50 transition">
            Cancelar
          </button>
          <button @click="confirmarRechazo"
            class="px-5 py-2.5 bg-danger-600 text-white text-sm font-semibold rounded-xl hover:bg-danger-700 transition">
            Confirmar Rechazo
          </button>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="showToast" class="fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-4 rounded-2xl shadow-2xl text-white animate-bounce-in"
      :class="tipoToast === 'ok' ? 'bg-success-600' : 'bg-danger-600'">
      <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path v-if="tipoToast === 'ok'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>
      <span class="font-semibold">{{ mensajeToast }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'

definePageMeta({ layout: 'admin' })

const notaInspector = ref('')
const showModalRechazo = ref(false)
const motivoRechazo = ref('')
const showToast = ref(false)
const tipoToast = ref<'ok' | 'error'>('ok')
const mensajeToast = ref('')

interface Item {
  id: string
  nombre: string
  descripcion?: string
  estado: 'pendiente' | 'ok' | 'falla' | 'na'
  nota?: string
}

interface Categoria {
  id: string
  nombre: string
  descripcion: string
  icono: string
  colorFondo: string
  colorIcono: string
  abierta: boolean
  items: Item[]
}

const categorias = reactive<Categoria[]>([
  {
    id: 'documentacion',
    nombre: 'Documentación',
    descripcion: 'Documentos legales del vehículo',
    icono: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
    colorFondo: 'bg-blue-100',
    colorIcono: 'text-blue-600',
    abierta: true,
    items: [
      { id: 'doc1', nombre: 'Certificado de Origen', descripcion: 'Documento original del fabricante', estado: 'pendiente' },
      { id: 'doc2', nombre: 'Factura de Compra', descripcion: 'Factura del concesionario o importador', estado: 'pendiente' },
      { id: 'doc3', nombre: 'Autorización de Tránsito', descripcion: 'Permiso de circulación vigente', estado: 'pendiente' },
      { id: 'doc4', nombre: 'Manifiesto de Importación', descripcion: 'Solo vehículos importados', estado: 'pendiente' }
    ]
  },
  {
    id: 'mecanico',
    nombre: 'Mecánico',
    descripcion: 'Estado del motor y componentes mecánicos',
    icono: 'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z',
    colorFondo: 'bg-orange-100',
    colorIcono: 'text-orange-600',
    abierta: false,
    items: [
      { id: 'mec1', nombre: 'Nivel de aceite del motor', estado: 'pendiente' },
      { id: 'mec2', nombre: 'Nivel de refrigerante', estado: 'pendiente' },
      { id: 'mec3', nombre: 'Nivel de líquido de frenos', estado: 'pendiente' },
      { id: 'mec4', nombre: 'Batería', descripcion: 'Estado y carga', estado: 'pendiente' },
      { id: 'mec5', nombre: 'Neumáticos', descripcion: 'Presión y desgaste', estado: 'pendiente' },
      { id: 'mec6', nombre: 'Frenos', descripcion: 'Funcionamiento del sistema de frenos', estado: 'pendiente' }
    ]
  },
  {
    id: 'electrico',
    nombre: 'Eléctrico',
    descripcion: 'Luces, señales y sistemas electrónicos',
    icono: 'M13 10V3L4 14h7v7l9-11h-7z',
    colorFondo: 'bg-yellow-100',
    colorIcono: 'text-yellow-600',
    abierta: false,
    items: [
      { id: 'ele1', nombre: 'Luces delanteras', estado: 'pendiente' },
      { id: 'ele2', nombre: 'Luces traseras', estado: 'pendiente' },
      { id: 'ele3', nombre: 'Luces de emergencia', estado: 'pendiente' },
      { id: 'ele4', nombre: 'Bocina', estado: 'pendiente' },
      { id: 'ele5', nombre: 'Radio / Sistema de audio', estado: 'pendiente' },
      { id: 'ele6', nombre: 'Aire acondicionado', estado: 'pendiente' },
      { id: 'ele7', nombre: 'Elevalunas eléctrico', estado: 'pendiente' },
      { id: 'ele8', nombre: 'Sensores y cámara de retro', estado: 'pendiente' }
    ]
  },
  {
    id: 'cosmético',
    nombre: 'Cosmético / Carrocería',
    descripcion: 'Estado visual de la carrocería',
    icono: 'M7 21a4 4 0 01-4-4V5a2 2 0 012-2h14a2 2 0 012 2v12a4 4 0 01-4 4H7z',
    colorFondo: 'bg-pink-100',
    colorIcono: 'text-pink-600',
    abierta: false,
    items: [
      { id: 'cos1', nombre: 'Pintura', descripcion: 'Sin rayaduras ni burbujas', estado: 'pendiente' },
      { id: 'cos2', nombre: 'Parabrisas', descripcion: 'Sin grietas ni impactos', estado: 'pendiente' },
      { id: 'cos3', nombre: 'Ventanas laterales', estado: 'pendiente' },
      { id: 'cos4', nombre: 'Espejos', descripcion: 'Espejos laterales y retrovisor', estado: 'pendiente' },
      { id: 'cos5', nombre: 'Molduras y cromados', estado: 'pendiente' },
      { id: 'cos6', nombre: 'Rines y tapacubos', estado: 'pendiente' }
    ]
  },
  {
    id: 'accesorios',
    nombre: 'Accesorios',
    descripcion: 'Elementos incluidos con el vehículo',
    icono: 'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4',
    colorFondo: 'bg-purple-100',
    colorIcono: 'text-purple-600',
    abierta: false,
    items: [
      { id: 'acc1', nombre: 'Llanta de repuesto', estado: 'pendiente' },
      { id: 'acc2', nombre: 'Gato hidráulico', estado: 'pendiente' },
      { id: 'acc3', nombre: 'Llave de ruedas', estado: 'pendiente' },
      { id: 'acc4', nombre: 'Manual del propietario', estado: 'pendiente' },
      { id: 'acc5', nombre: 'Llaves del vehículo', descripcion: 'Principal + copia', estado: 'pendiente' },
      { id: 'acc6', nombre: 'Triángulos de emergencia', estado: 'pendiente' }
    ]
  }
])

const todosLosItems = computed(() => categorias.flatMap(c => c.items))
const totalOk = computed(() => todosLosItems.value.filter(i => i.estado === 'ok').length)
const totalFallas = computed(() => todosLosItems.value.filter(i => i.estado === 'falla').length)
const totalNa = computed(() => todosLosItems.value.filter(i => i.estado === 'na').length)
const totalPendientes = computed(() => todosLosItems.value.filter(i => i.estado === 'pendiente').length)
const progresoGlobal = computed(() => {
  const resueltos = todosLosItems.value.filter(i => i.estado !== 'pendiente').length
  return Math.round((resueltos / todosLosItems.value.length) * 100)
})

const progresoCategoria = (cat: Categoria) => {
  if (cat.items.length === 0) return 0
  const resueltos = cat.items.filter(i => i.estado !== 'pendiente').length
  return Math.round((resueltos / cat.items.length) * 100)
}

const itemsResueltos = (cat: Categoria) => cat.items.filter(i => i.estado !== 'pendiente').length

const puedeAprobar = computed(() => progresoGlobal.value === 100)

const mostrarToast = (tipo: 'ok' | 'error', mensaje: string) => {
  tipoToast.value = tipo
  mensajeToast.value = mensaje
  showToast.value = true
  setTimeout(() => { showToast.value = false }, 3000)
}

const aprobar = () => {
  if (!puedeAprobar.value) return
  mostrarToast('ok', 'Inventario aprobado — Listo para despacho')
}

const rechazar = () => { showModalRechazo.value = true }

const confirmarRechazo = () => {
  showModalRechazo.value = false
  mostrarToast('error', 'Inventario rechazado')
}
</script>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import * as XLSX from 'xlsx'
import { useContenedorStore, type Contenedor, type VehiculoContenedor } from '~/stores/contenedorStore'

definePageMeta({ layout: 'admin', middleware: ['auth', 'recibidor'] })

const contStore = useContenedorStore()

const selectedContenedor = ref<Contenedor | null>(null)
const showDetalleModal = ref(false)
const showNuevoModal = ref(false)
const modoImportacion = ref(false)
const searchQuery = ref('')
const filterEstado = ref<'todos' | 'pendiente' | 'en_recepcion'>('todos')
const archivoExcel = ref<File | null>(null)

// Form para nuevo contenedor
const nuevoContenedor = ref({
  codigo: '',
  fechaLlegada: '',
  agenteNaviero: '',
  motonave: '',
  viaje: '',
  operadorPortuario: '',
  tipoOperacion: 'TRANSITO' as 'TRANSITO' | 'REESTIBA',
  vehiculos: [] as VehiculoContenedor[],
})

const nuevoVehiculo = ref({
  cliente: '',
  modelo: '',
  bl: '',
  origen: '',
  vin: '',
  destino: '',
  agAduanas: '',
  peso: '',
  volumen: '',
})

const contenedoresFiltrados = computed(() => {
  let resultado = contStore.contenedores.filter((c) => c.estado === 'pendiente' || c.estado === 'en_recepcion')

  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    resultado = resultado.filter((c) => c.codigo.toLowerCase().includes(q) || c.origen.toLowerCase().includes(q))
  }

  if (filterEstado.value !== 'todos') {
    resultado = resultado.filter((c) => c.estado === filterEstado.value)
  }

  return resultado.sort((a, b) => new Date(a.fechaLlegada + ' ' + a.horaLlegada).getTime() - new Date(b.fechaLlegada + ' ' + b.horaLlegada).getTime())
})

const estadoColor = (estado: string) => {
  const map: Record<string, string> = { pendiente: 'bg-amber-50 text-amber-700', en_recepcion: 'bg-blue-50 text-blue-700', completado: 'bg-green-50 text-green-700' }
  return map[estado] || 'bg-gray-50 text-gray-700'
}

const estadoLabel = (estado: string) => {
  const map: Record<string, string> = { pendiente: 'Pendiente', en_recepcion: 'En Recepción', completado: 'Completado' }
  return map[estado] || estado
}

const abrirDetalle = (contenedor: Contenedor) => {
  selectedContenedor.value = contenedor
  showDetalleModal.value = true
}

const cerrarDetalle = () => {
  showDetalleModal.value = false
  selectedContenedor.value = null
}

const iniciarRecepcion = (contenedor: Contenedor) => {
  if (contenedor.estado === 'pendiente') {
    contenedor.estado = 'en_recepcion'
    contStore.updateContenedor(contenedor)
  }
}

const marcarVehiculoEscaneado = (vehiculo: VehiculoContenedor) => {
  vehiculo.escaneado = !vehiculo.escaneado
  if (selectedContenedor.value) {
    contStore.updateContenedor(selectedContenedor.value)
  }
}

const completarRecepcion = () => {
  if (selectedContenedor.value) {
    selectedContenedor.value.estado = 'completado'
    selectedContenedor.value.recibidoPor = 'Recibidor Actual'
    contStore.updateContenedor(selectedContenedor.value)
    cerrarDetalle()
  }
}

const abrirNuevoContenedor = () => {
  nuevoContenedor.value = {
    codigo: '',
    fechaLlegada: '',
    agenteNaviero: '',
    motonave: '',
    viaje: '',
    operadorPortuario: '',
    tipoOperacion: 'TRANSITO',
    vehiculos: []
  }
  nuevoVehiculo.value = {
    cliente: '',
    modelo: '',
    bl: '',
    origen: '',
    vin: '',
    destino: '',
    agAduanas: '',
    peso: '',
    volumen: ''
  }
  modoImportacion.value = false
  showNuevoModal.value = true
}

const cerrarNuevoContenedor = () => {
  showNuevoModal.value = false
  modoImportacion.value = false
  archivoExcel.value = null
}

const procesarExcel = (event: Event) => {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    try {
      const data = e.target?.result as ArrayBuffer
      const workbook = XLSX.read(data, { type: 'array' })
      const worksheet = workbook.Sheets[workbook.SheetNames[0]]
      const rows: any[] = XLSX.utils.sheet_to_json(worksheet)

      // Debug: ver qué columnas tiene el Excel
      console.log('Primera fila del Excel:', rows[0])
      console.log('Columnas disponibles:', Object.keys(rows[0] || {}))

      // Mapear columnas del Excel a campos del vehículo
      const vehiculosImportados: VehiculoContenedor[] = rows.map((row) => ({
        cliente: row['CLIENTE'] || '',
        modelo: row['MODELO'] || '',
        bl: row['BL'] || '',
        origen: row['ORIGEN'] || '',
        vin: row['VIN'] || '',
        destino: row['DESTINO'] || '',
        agAduanas: row['Ag. de Aduanas'] || '',
        peso: String(row['PESO'] || ''),
        volumen: String(row['VOLUMEN'] || ''),
        escaneado: false,
      }))

      console.log('Vehículos importados:', vehiculosImportados)
      nuevoContenedor.value.vehiculos = vehiculosImportados
      modoImportacion.value = false
      archivoExcel.value = null
    } catch (error) {
      alert('Error al procesar el archivo Excel')
      console.error(error)
    }
  }
  reader.readAsArrayBuffer(file)
}

const agregarVehiculoAlContenedor = () => {
  if (nuevoVehiculo.value.vin && nuevoVehiculo.value.modelo && nuevoVehiculo.value.cliente) {
    nuevoContenedor.value.vehiculos.push({
      ...nuevoVehiculo.value,
      escaneado: false,
    })
    nuevoVehiculo.value = {
      cliente: '',
      modelo: '',
      bl: '',
      origen: '',
      vin: '',
      destino: '',
      agAduanas: '',
      peso: '',
      volumen: ''
    }
  }
}

const eliminarVehiculo = (idx: number) => {
  nuevoContenedor.value.vehiculos.splice(idx, 1)
}

const guardarNuevoContenedor = () => {
  if (nuevoContenedor.value.codigo && nuevoContenedor.value.fechaLlegada && nuevoContenedor.value.vehiculos.length > 0) {
    const contenedor: Contenedor = {
      id: Date.now().toString(),
      codigo: nuevoContenedor.value.codigo,
      fechaLlegada: nuevoContenedor.value.fechaLlegada,
      agenteNaviero: nuevoContenedor.value.agenteNaviero,
      motonave: nuevoContenedor.value.motonave,
      viaje: nuevoContenedor.value.viaje,
      operadorPortuario: nuevoContenedor.value.operadorPortuario,
      tipoOperacion: nuevoContenedor.value.tipoOperacion,
      vehiculosEsperados: nuevoContenedor.value.vehiculos.length,
      vehiculos: nuevoContenedor.value.vehiculos,
      estado: 'pendiente',
      recibidoPor: '',
      observaciones: '',
    }
    contStore.agregarContenedor(contenedor)
    cerrarNuevoContenedor()
  }
}

onMounted(() => {
  contStore.init()
})
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-8">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">Contenedores por Recibir</h1>
        <p class="text-gray-500 mt-1">Gestión de contenedores próximos a llegar y registro de vehículos</p>
      </div>
      <button @click="abrirNuevoContenedor" class="px-5 py-2.5 bg-primary-600 text-white font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25 inline-flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        Nuevo Contenedor
      </button>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-3xl font-bold text-gray-900">{{ contStore.pendientes }}</p>
        <p class="text-sm text-gray-500 mt-1">Pendientes de llegar</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-3xl font-bold text-blue-600">{{ contStore.enRecepcion }}</p>
        <p class="text-sm text-gray-500 mt-1">En recepción</p>
      </div>
      <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <p class="text-3xl font-bold text-emerald-600">{{ contStore.totalVehiculosHoy }}</p>
        <p class="text-sm text-gray-500 mt-1">Vehículos hoy</p>
      </div>
    </div>

    <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100 mb-6">
      <div class="flex flex-col sm:flex-row gap-4">
        <div class="flex-1">
          <input v-model="searchQuery" type="text" placeholder="Buscar por código..." class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
        </div>
        <div class="w-full sm:w-48">
          <select v-model="filterEstado" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
            <option value="todos">Todos</option>
            <option value="pendiente">Pendientes</option>
            <option value="en_recepcion">En recepción</option>
          </select>
        </div>
      </div>
    </div>

    <div class="space-y-4">
      <template v-if="contenedoresFiltrados.length > 0">
        <div v-for="contenedor in contenedoresFiltrados" :key="contenedor.id" class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-4">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <h3 class="text-lg font-bold text-gray-900">{{ contenedor.codigo }}</h3>
                <span :class="['px-3 py-1 rounded-full text-sm font-semibold', estadoColor(contenedor.estado)]">{{ estadoLabel(contenedor.estado) }}</span>
              </div>
              <p class="text-sm text-gray-600">{{ contenedor.origen }}</p>
            </div>
            <div class="flex gap-2">
              <button v-if="contenedor.estado === 'pendiente'" @click="iniciarRecepcion(contenedor)" class="px-4 py-2 bg-blue-50 text-blue-700 font-semibold rounded-lg">Iniciar</button>
              <button @click="abrirDetalle(contenedor)" class="px-4 py-2 bg-primary-50 text-primary-700 font-semibold rounded-lg">Ver</button>
            </div>
          </div>

          <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 pt-4 border-t border-gray-100 text-sm">
            <div>
              <p class="text-xs font-semibold text-gray-500 uppercase">Transportista</p>
              <p class="text-gray-900 mt-1">{{ contenedor.transportista }}</p>
            </div>
            <div>
              <p class="text-xs font-semibold text-gray-500 uppercase">Placa</p>
              <p class="text-gray-900 mt-1">{{ contenedor.placaCamion }}</p>
            </div>
            <div>
              <p class="text-xs font-semibold text-gray-500 uppercase">Llegada</p>
              <p class="text-gray-900 mt-1">{{ contenedor.fechaLlegada }} {{ contenedor.horaLlegada }}</p>
            </div>
            <div>
              <p class="text-xs font-semibold text-gray-500 uppercase">Vehículos</p>
              <p class="text-gray-900 mt-1"><span class="font-bold">{{ contenedor.vehiculos.filter((v) => v.escaneado).length }}</span> / {{ contenedor.vehiculosEsperados }}</p>
            </div>
          </div>
        </div>
      </template>

      <div v-else class="text-center py-12">
        <p class="text-gray-500 text-lg">No hay contenedores para mostrar</p>
      </div>
    </div>

    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showDetalleModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click="cerrarDetalle">
          <div class="bg-white rounded-2xl shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto" @click.stop>
            <div class="sticky top-0 bg-white border-b border-gray-100 px-6 py-4 flex items-center justify-between">
              <div>
                <h2 class="text-2xl font-bold text-gray-900">{{ selectedContenedor?.codigo }}</h2>
                <p class="text-sm text-gray-500 mt-1">{{ selectedContenedor?.origen }}</p>
              </div>
              <button @click="cerrarDetalle" class="p-2 hover:bg-gray-100 rounded-lg">
                <svg class="w-6 h-6 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <div class="p-6">
              <div class="bg-gray-50 rounded-xl p-4 mb-6">
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase">Transportista</p>
                    <p class="text-sm font-semibold text-gray-900 mt-1">{{ selectedContenedor?.transportista }}</p>
                  </div>
                  <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase">Placa</p>
                    <p class="text-sm font-semibold text-gray-900 mt-1">{{ selectedContenedor?.placaCamion }}</p>
                  </div>
                  <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase">Llegada</p>
                    <p class="text-sm font-semibold text-gray-900 mt-1">{{ selectedContenedor?.fechaLlegada }} {{ selectedContenedor?.horaLlegada }}</p>
                  </div>
                  <div>
                    <p class="text-xs font-semibold text-gray-500 uppercase">Estado</p>
                    <p :class="['text-sm font-semibold mt-1 inline-block px-2 py-1 rounded', estadoColor(selectedContenedor?.estado || '')]">{{ estadoLabel(selectedContenedor?.estado || '') }}</p>
                  </div>
                </div>
              </div>

              <div class="mb-6">
                <h3 class="text-lg font-bold text-gray-900 mb-4">Vehículos Esperados</h3>
                <div class="space-y-3">
                  <div v-for="(vehiculo, idx) in selectedContenedor?.vehiculos || []" :key="idx" class="border border-gray-200 rounded-xl p-4">
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <div class="flex items-center gap-2">
                          <h4 class="font-bold text-gray-900">{{ vehiculo.cliente }} - {{ vehiculo.modelo }}</h4>
                          <span :class="['text-xs font-semibold px-2 py-1 rounded', vehiculo.escaneado ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700']">{{ vehiculo.escaneado ? '✓ Escaneado' : '○ Pendiente' }}</span>
                        </div>
                        <p class="text-sm text-gray-600 mt-2"><span class="font-semibold">VIN:</span> {{ vehiculo.vin }}</p>
                        <p class="text-sm text-gray-600"><span class="font-semibold">BL:</span> {{ vehiculo.bl }}</p>
                        <p class="text-sm text-gray-600"><span class="font-semibold">Ruta:</span> {{ vehiculo.origen }} → {{ vehiculo.destino }}</p>
                        <p class="text-sm text-gray-600"><span class="font-semibold">Ag. Aduanas:</span> {{ vehiculo.agAduanas }}</p>
                      </div>
                      <button v-if="selectedContenedor?.estado === 'en_recepcion'" @click="marcarVehiculoEscaneado(vehiculo)" :class="['ml-4 px-4 py-2 rounded-lg font-semibold', vehiculo.escaneado ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700']">
                        {{ vehiculo.escaneado ? 'Desmarcar' : 'Marcar' }}
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div v-if="selectedContenedor?.estado === 'en_recepcion'" class="mb-6">
                <label class="block text-sm font-semibold text-gray-700 mb-2">Observaciones</label>
                <textarea v-model="selectedContenedor.observaciones" placeholder="Observaciones..." class="w-full px-4 py-3 border border-gray-300 rounded-lg" rows="3" />
              </div>
            </div>

            <div class="sticky bottom-0 bg-white border-t border-gray-100 px-6 py-4 flex justify-end gap-3">
              <button @click="cerrarDetalle" class="px-4 py-2 border border-gray-300 text-gray-700 font-semibold rounded-lg">Cerrar</button>
              <button v-if="selectedContenedor?.estado === 'en_recepcion'" @click="completarRecepcion" class="px-4 py-2 bg-green-600 text-white font-semibold rounded-lg">Completar</button>
              <button v-else-if="selectedContenedor?.estado === 'pendiente'" @click="iniciarRecepcion(selectedContenedor!)" class="px-4 py-2 bg-primary-600 text-white font-semibold rounded-lg">Iniciar</button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>

    <!-- Modal Nuevo Contenedor -->
    <Teleport to="body">
      <Transition name="fade">
        <div v-if="showNuevoModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" @click="cerrarNuevoContenedor">
          <div class="bg-white rounded-2xl shadow-xl max-w-3xl w-full max-h-[90vh] overflow-y-auto" @click.stop>
            <div class="sticky top-0 bg-white border-b border-gray-100 px-6 py-4 flex items-center justify-between">
              <h2 class="text-2xl font-bold text-gray-900">Crear Nuevo Contenedor</h2>
              <button @click="cerrarNuevoContenedor" class="p-2 hover:bg-gray-100 rounded-lg">
                <svg class="w-6 h-6 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <!-- Botones de modo -->
            <div class="sticky top-14 bg-gray-50 border-b border-gray-200 px-6 py-3 flex gap-2">
              <button @click="modoImportacion = false" :class="['px-4 py-2 font-semibold rounded-lg transition', !modoImportacion ? 'bg-primary-600 text-white' : 'bg-white text-gray-700 border border-gray-300']">
                Ingreso Manual
              </button>
              <button @click="modoImportacion = true" :class="['px-4 py-2 font-semibold rounded-lg transition', modoImportacion ? 'bg-primary-600 text-white' : 'bg-white text-gray-700 border border-gray-300']">
                Importar Excel
              </button>
            </div>

            <div class="p-6 space-y-4">
              <!-- Info del contenedor -->
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Código (BL/Contenedor) *</label>
                  <input v-model="nuevoContenedor.codigo" type="text" placeholder="EUKOMUCE206788" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Fecha de Llegada *</label>
                  <input v-model="nuevoContenedor.fechaLlegada" type="date" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Agente Naviero</label>
                  <input v-model="nuevoContenedor.agenteNaviero" type="text" placeholder="NAVES COLOMBIA" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Motonave</label>
                  <input v-model="nuevoContenedor.motonave" type="text" placeholder="Mn. GRAND COSMO" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                </div>
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Viaje</label>
                    <input v-model="nuevoContenedor.viaje" type="text" placeholder="TBC" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                  </div>
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Tipo Operación</label>
                    <select v-model="nuevoContenedor.tipoOperacion" class="w-full px-4 py-2 border border-gray-300 rounded-lg">
                      <option value="TRANSITO">TRÁNSITO</option>
                      <option value="REESTIBA">REESTIBA</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Operador Portuario</label>
                  <input v-model="nuevoContenedor.operadorPortuario" type="text" placeholder="COMPAÑIA DEL LITORAL PACIFICO SAS" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                </div>
              </div>

              <!-- Modo ingreso manual -->
              <div v-if="!modoImportacion" class="border-t border-gray-200 pt-4">
                <h3 class="text-lg font-bold text-gray-900 mb-4">Vehículos Esperados</h3>
                <div class="space-y-4 mb-4">
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Cliente *</label>
                    <input v-model="nuevoVehiculo.cliente" type="text" placeholder="RENAULT SOFASA SAS" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                  </div>
                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">Modelo *</label>
                      <input v-model="nuevoVehiculo.modelo" type="text" placeholder="ARKANA" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                    </div>
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">BL (Bill of Lading)</label>
                      <input v-model="nuevoVehiculo.bl" type="text" placeholder="EUKOMUCE206788" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                    </div>
                  </div>
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Origen</label>
                    <input v-model="nuevoVehiculo.origen" type="text" placeholder="MASAN-KOREA DEL SUR" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                  </div>
                  <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">VIN *</label>
                    <input v-model="nuevoVehiculo.vin" type="text" placeholder="VFJR..." class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                  </div>
                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">Destino</label>
                      <input v-model="nuevoVehiculo.destino" type="text" placeholder="PTO) MAGNUM LOGISTICS" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                    </div>
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">Ag. de Aduanas</label>
                      <input v-model="nuevoVehiculo.agAduanas" type="text" placeholder="MAGNUM LOGISTICS" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                    </div>
                  </div>
                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">Peso (kg)</label>
                      <input v-model="nuevoVehiculo.peso" type="text" placeholder="1400" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                    </div>
                    <div>
                      <label class="block text-sm font-semibold text-gray-700 mb-2">Volumen (m³)</label>
                      <input v-model="nuevoVehiculo.volumen" type="text" placeholder="13,32" class="w-full px-4 py-2 border border-gray-300 rounded-lg" />
                    </div>
                  </div>
                </div>
                <button @click="agregarVehiculoAlContenedor" class="w-full px-4 py-2 bg-blue-50 text-blue-700 font-semibold rounded-lg hover:bg-blue-100">
                  + Agregar Vehículo
                </button>
              </div>

              <!-- Modo importación Excel -->
              <div v-else class="border-t border-gray-200 pt-4">
                <h3 class="text-lg font-bold text-gray-900 mb-4">Importar desde Excel</h3>
                <div class="bg-blue-50 p-4 rounded-lg mb-4 border border-blue-200">
                  <p class="text-sm text-blue-700"><strong>Nota:</strong> El Excel debe tener las columnas: CLIENTE, MODELO, BL, ORIGEN, VIN, DESTINO, Ag. de Aduanas, PESO, VOLUMEN</p>
                </div>
                <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  <input type="file" accept=".xlsx,.xls" @change="procesarExcel" class="hidden" id="excelInput" />
                  <label for="excelInput" class="cursor-pointer">
                    <svg class="w-12 h-12 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    <p class="text-gray-700 font-semibold">Clic para seleccionar archivo Excel</p>
                    <p class="text-xs text-gray-500 mt-1">o arrastra tu archivo aquí</p>
                  </label>
                </div>
              </div>

              <!-- Lista de vehículos agregados -->
              <div v-if="nuevoContenedor.vehiculos.length > 0" class="border-t border-gray-200 pt-4">
                <h4 class="font-bold text-gray-900 mb-3">Vehículos en este contenedor ({{ nuevoContenedor.vehiculos.length }})</h4>
                <div class="space-y-2 max-h-64 overflow-y-auto">
                  <div v-for="(vehiculo, idx) in nuevoContenedor.vehiculos" :key="idx" class="bg-gray-50 p-3 rounded-lg flex items-center justify-between">
                    <div class="flex-1">
                      <p class="font-semibold text-gray-900">{{ vehiculo.cliente }} - {{ vehiculo.modelo }}</p>
                      <p class="text-xs text-gray-600">VIN: {{ vehiculo.vin }}</p>
                      <p class="text-xs text-gray-500">{{ vehiculo.origen }} → {{ vehiculo.destino }}</p>
                    </div>
                    <button @click="eliminarVehiculo(idx)" class="px-3 py-1 bg-red-50 text-red-700 rounded font-semibold hover:bg-red-100">
                      Eliminar
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="sticky bottom-0 bg-white border-t border-gray-100 px-6 py-4 flex justify-end gap-3">
              <button @click="cerrarNuevoContenedor" class="px-4 py-2 border border-gray-300 text-gray-700 font-semibold rounded-lg">Cancelar</button>
              <button @click="guardarNuevoContenedor" :disabled="!nuevoContenedor.codigo || !nuevoContenedor.fechaLlegada || nuevoContenedor.vehiculos.length === 0" class="px-4 py-2 bg-primary-600 text-white font-semibold rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed">
                Crear Contenedor
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

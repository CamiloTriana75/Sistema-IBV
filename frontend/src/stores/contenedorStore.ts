import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface VehiculoContenedor {
  vin: string
  marca: string
  modelo: string
  anio: string
  color: string
  codigoImpronta: string // Código QR que trae cada vehículo
  escaneado: boolean
  improntaId?: string // Referencia a la impronta creada
}

export interface Contenedor {
  id: string
  codigo: string // Código QR del contenedor
  origen: string
  transportista: string
  placaCamion: string
  fechaLlegada: string
  horaLlegada: string
  vehiculosEsperados: number
  vehiculos: VehiculoContenedor[]
  estado: 'pendiente' | 'en_recepcion' | 'completado'
  recibidoPor: string
  observaciones: string
}

const STORAGE_KEY = 'ibv_contenedores'

const INITIAL_CONTENEDORES: Contenedor[] = [
  {
    id: '1',
    codigo: 'CONT-2026-0001',
    origen: 'Planta Toyota - La Victoria',
    transportista: 'Transportes Zulia C.A.',
    placaCamion: 'A12BC3D',
    fechaLlegada: '2026-02-23',
    horaLlegada: '08:30',
    vehiculosEsperados: 3,
    vehiculos: [
      {
        vin: '1HGBH41JXMN109186',
        marca: 'Toyota',
        modelo: 'Corolla',
        anio: '2024',
        color: 'Blanco Perla',
        codigoImpronta: 'IMP-VH-001',
        escaneado: false,
      },
      {
        vin: '3VWDX7AJ5BM123456',
        marca: 'Toyota',
        modelo: 'Hilux',
        anio: '2024',
        color: 'Gris Oscuro',
        codigoImpronta: 'IMP-VH-002',
        escaneado: false,
      },
      {
        vin: 'JTDKN3DU5A0123789',
        marca: 'Toyota',
        modelo: 'Yaris',
        anio: '2025',
        color: 'Rojo',
        codigoImpronta: 'IMP-VH-003',
        escaneado: false,
      },
    ],
    estado: 'pendiente',
    recibidoPor: '',
    observaciones: '',
  },
  {
    id: '2',
    codigo: 'CONT-2026-0002',
    origen: 'Puerto La Guaira - Importados',
    transportista: 'Logística Nacional S.A.',
    placaCamion: 'B45DE6F',
    fechaLlegada: '2026-02-23',
    horaLlegada: '10:15',
    vehiculosEsperados: 2,
    vehiculos: [
      {
        vin: 'WBA3A5G59DNP12345',
        marca: 'Chevrolet',
        modelo: 'Spark',
        anio: '2023',
        color: 'Azul Eléctrico',
        codigoImpronta: 'IMP-VH-004',
        escaneado: false,
      },
      {
        vin: '5YJSA1DNXDFP67890',
        marca: 'Chevrolet',
        modelo: 'Aveo',
        anio: '2024',
        color: 'Negro',
        codigoImpronta: 'IMP-VH-005',
        escaneado: false,
      },
    ],
    estado: 'pendiente',
    recibidoPor: '',
    observaciones: '',
  },
  {
    id: '3',
    codigo: 'CONT-2026-0003',
    origen: 'Planta Ford - Valencia',
    transportista: 'Transportes Rápido C.A.',
    placaCamion: 'C78GH9J',
    fechaLlegada: '2026-02-22',
    horaLlegada: '14:00',
    vehiculosEsperados: 2,
    vehiculos: [
      {
        vin: '1FADP3F29JL234567',
        marca: 'Ford',
        modelo: 'Explorer',
        anio: '2025',
        color: 'Blanco Oxford',
        codigoImpronta: 'IMP-VH-006',
        escaneado: true,
        improntaId: '1',
      },
      {
        vin: '3FA6P0HD7LR890123',
        marca: 'Ford',
        modelo: 'Escape',
        anio: '2024',
        color: 'Plata Estelar',
        codigoImpronta: 'IMP-VH-007',
        escaneado: true,
        improntaId: '2',
      },
    ],
    estado: 'completado',
    recibidoPor: 'María Recibidora',
    observaciones: 'Recepción sin novedades.',
  },
]

export const useContenedorStore = defineStore('contenedor', () => {
  // State
  const contenedores = ref<Contenedor[]>([])
  const loading = ref(false)

  // Initialize
  const init = () => {
    if (typeof window === 'undefined') return
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored) {
      try {
        contenedores.value = JSON.parse(stored)
      } catch {
        contenedores.value = [...INITIAL_CONTENEDORES]
        persist()
      }
    } else {
      contenedores.value = [...INITIAL_CONTENEDORES]
      persist()
    }
  }

  const persist = () => {
    if (typeof window === 'undefined') return
    localStorage.setItem(STORAGE_KEY, JSON.stringify(contenedores.value))
  }

  // Computed
  const totalContenedores = computed(() => contenedores.value.length)
  const pendientes = computed(
    () => contenedores.value.filter((c) => c.estado === 'pendiente').length
  )
  const enRecepcion = computed(
    () => contenedores.value.filter((c) => c.estado === 'en_recepcion').length
  )
  const completados = computed(
    () => contenedores.value.filter((c) => c.estado === 'completado').length
  )
  const totalVehiculosHoy = computed(() => {
    const hoy = new Date().toISOString().split('T')[0]
    return contenedores.value
      .filter((c) => c.fechaLlegada === hoy)
      .reduce((sum, c) => sum + c.vehiculosEsperados, 0)
  })

  // Actions
  const getById = (id: string) => contenedores.value.find((c) => c.id === id)

  const getByCodigo = (codigo: string): Contenedor | undefined => {
    return contenedores.value.find((c) => c.codigo.toLowerCase() === codigo.toLowerCase())
  }

  const buscarVehiculoPorCodigo = (
    codigoImpronta: string
  ): { contenedor: Contenedor; vehiculo: VehiculoContenedor } | undefined => {
    for (const cont of contenedores.value) {
      const veh = cont.vehiculos.find(
        (v) => v.codigoImpronta.toLowerCase() === codigoImpronta.toLowerCase()
      )
      if (veh) return { contenedor: cont, vehiculo: veh }
    }
    return undefined
  }

  const buscarVehiculoPorVin = (
    vin: string
  ): { contenedor: Contenedor; vehiculo: VehiculoContenedor } | undefined => {
    for (const cont of contenedores.value) {
      const veh = cont.vehiculos.find((v) => v.vin.toLowerCase() === vin.toLowerCase())
      if (veh) return { contenedor: cont, vehiculo: veh }
    }
    return undefined
  }

  const iniciarRecepcion = (id: string, recibidor: string) => {
    const cont = contenedores.value.find((c) => c.id === id)
    if (cont) {
      cont.estado = 'en_recepcion'
      cont.recibidoPor = recibidor
      persist()
    }
  }

  const marcarVehiculoEscaneado = (
    contenedorId: string,
    codigoImpronta: string,
    improntaId?: string
  ) => {
    const cont = contenedores.value.find((c) => c.id === contenedorId)
    if (cont) {
      const veh = cont.vehiculos.find(
        (v) => v.codigoImpronta.toLowerCase() === codigoImpronta.toLowerCase()
      )
      if (veh) {
        veh.escaneado = true
        if (improntaId) veh.improntaId = improntaId
        // Check if all vehicles are scanned
        if (cont.vehiculos.every((v) => v.escaneado)) {
          cont.estado = 'completado'
        }
        persist()
      }
    }
  }

  const completarRecepcion = (id: string, observaciones?: string) => {
    const cont = contenedores.value.find((c) => c.id === id)
    if (cont) {
      cont.estado = 'completado'
      if (observaciones) cont.observaciones = observaciones
      persist()
    }
  }

  // Init on creation
  init()

  return {
    contenedores,
    loading,
    totalContenedores,
    pendientes,
    enRecepcion,
    completados,
    totalVehiculosHoy,
    getById,
    getByCodigo,
    buscarVehiculoPorCodigo,
    buscarVehiculoPorVin,
    iniciarRecepcion,
    marcarVehiculoEscaneado,
    completarRecepcion,
    persist,
  }
})

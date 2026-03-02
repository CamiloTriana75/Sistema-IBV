import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface VehiculoContenedor {
  cliente: string
  modelo: string
  bl: string
  origen: string
  vin: string
  destino: string
  agAduanas: string
  peso: string
  volumen: string
  escaneado: boolean
  improntaId?: string
  codigoImpronta?: string
}

export interface Contenedor {
  id: string
  codigo: string
  fechaLlegada: string
  agenteNaviero: string
  motonave: string
  viaje: string
  operadorPortuario: string
  tipoOperacion: 'TRANSITO' | 'REESTIBA'
  vehiculosEsperados: number
  vehiculos: VehiculoContenedor[]
  estado: 'pendiente' | 'en_recepcion' | 'completado'
  recibidoPor: string
  observaciones: string
  // Campos opcionales para compatibilidad
  origen?: string
  transportista?: string
  placaCamion?: string
  horaLlegada?: string
}

const STORAGE_KEY = 'ibv_contenedores'

const INITIAL_CONTENEDORES: Contenedor[] = [
  {
    id: '1',
    codigo: 'CONT-2026-0001',
    fechaLlegada: '2026-02-23',
    agenteNaviero: 'MSC Mediterranean Shipping Company',
    motonave: 'MSC REEF',
    viaje: 'EP426A',
    operadorPortuario: 'Sociedad Portuaria Buenaventura',
    tipoOperacion: 'TRANSITO',
    vehiculosEsperados: 3,
    vehiculos: [
      {
        cliente: 'TOYOTA',
        modelo: 'COROLLA',
        bl: 'MEDUBB123456',
        origen: 'JAPON',
        vin: '1HGBH41JXMN109186',
        destino: 'VENEZUELA',
        agAduanas: 'AGENCIA MARITIMA VENEZOLANA',
        peso: '1200',
        volumen: '15',
        escaneado: false,
      },
      {
        cliente: 'TOYOTA',
        modelo: 'HILUX',
        bl: 'MEDUBB123457',
        origen: 'JAPON',
        vin: '3VWDX7AJ5BM123456',
        destino: 'VENEZUELA',
        agAduanas: 'AGENCIA MARITIMA VENEZOLANA',
        peso: '1800',
        volumen: '20',
        escaneado: false,
      },
      {
        cliente: 'TOYOTA',
        modelo: 'YARIS',
        bl: 'MEDUBB123458',
        origen: 'JAPON',
        vin: 'JTDKN3DU5A0123789',
        destino: 'VENEZUELA',
        agAduanas: 'AGENCIA MARITIMA VENEZOLANA',
        peso: '1000',
        volumen: '12',
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
    fechaLlegada: '2026-02-23',
    agenteNaviero: 'HAPAG-LLOYD',
    motonave: 'TOKYO EXPRESS',
    viaje: 'TE202W',
    operadorPortuario: 'Sociedad Portuaria Buenaventura',
    tipoOperacion: 'REESTIBA',
    vehiculosEsperados: 2,
    vehiculos: [
      {
        cliente: 'CHEVROLET',
        modelo: 'SPARK',
        bl: 'HLCUBB987654',
        origen: 'COREA',
        vin: 'WBA3A5G59DNP12345',
        destino: 'VENEZUELA',
        agAduanas: 'SERVIPORT',
        peso: '950',
        volumen: '10',
        escaneado: false,
      },
      {
        cliente: 'CHEVROLET',
        modelo: 'AVEO',
        bl: 'HLCUBB987655',
        origen: 'COREA',
        vin: '5YJSA1DNXDFP67890',
        destino: 'VENEZUELA',
        agAduanas: 'SERVIPORT',
        peso: '1050',
        volumen: '11',
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
    fechaLlegada: '2026-02-22',
    agenteNaviero: 'MAERSK LINE',
    motonave: 'MAERSK ATLANTA',
    viaje: 'MA305E',
    operadorPortuario: 'Sociedad Portuaria Buenaventura',
    tipoOperacion: 'TRANSITO',
    vehiculosEsperados: 2,
    vehiculos: [
      {
        cliente: 'FORD',
        modelo: 'EXPLORER',
        bl: 'MAEUBB456789',
        origen: 'USA',
        vin: '1FADP3F29JL234567',
        destino: 'VENEZUELA',
        agAduanas: 'AGENCIA MARITIMA DEL CARIBE',
        peso: '2200',
        volumen: '25',
        escaneado: true,
        improntaId: '1',
        codigoImpronta: 'IMP-VH-006',
      },
      {
        cliente: 'FORD',
        modelo: 'ESCAPE',
        bl: 'MAEUBB456790',
        origen: 'USA',
        vin: '3FA6P0HD7LR890123',
        destino: 'VENEZUELA',
        agAduanas: 'AGENCIA MARITIMA DEL CARIBE',
        peso: '1700',
        volumen: '18',
        escaneado: true,
        improntaId: '2',
        codigoImpronta: 'IMP-VH-007',
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
      contenedores.value = JSON.parse(JSON.stringify(INITIAL_CONTENEDORES))
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
        (v) => v.codigoImpronta && v.codigoImpronta.toLowerCase() === codigoImpronta.toLowerCase()
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
        (v) => v.codigoImpronta && v.codigoImpronta.toLowerCase() === codigoImpronta.toLowerCase()
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

  const updateContenedor = (contenedor: Contenedor) => {
    const idx = contenedores.value.findIndex((c) => c.id === contenedor.id)
    if (idx !== -1) {
      contenedores.value[idx] = contenedor
      persist()
    }
  }

  const agregarContenedor = (contenedor: Contenedor) => {
    contenedores.value.push(contenedor)
    persist()
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
    updateContenedor,
    agregarContenedor,
    init,
    persist,
  }
})

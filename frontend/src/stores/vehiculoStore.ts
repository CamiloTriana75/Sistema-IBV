import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/**
 * Store central del ciclo de vida de cada vehículo en el sistema IBV.
 *
 * Flujo: Recepción (VIN escaneado) → Impronta → Inventario → Despacho
 *
 * Un vehículo NO puede despacharse si:
 * - No tiene impronta completada
 * - No tiene inventario aprobado
 */

export type EstadoVehiculo =
  | 'recibido'
  | 'impronta_pendiente'
  | 'impronta_completada'
  | 'inventario_pendiente'
  | 'inventario_aprobado'
  | 'listo_despacho'
  | 'despachado'

export interface VehiculoPipeline {
  id: string
  vin: string
  placa: string
  marca: string
  modelo: string
  anio: string
  color: string
  cliente: string
  contenedorId?: string
  contenedorCodigo?: string
  // Etapas del pipeline
  fechaRecepcion: string
  horaRecepcion: string
  // Impronta
  improntaId?: string
  improntaFolio?: string
  improntaCompletada: boolean
  fechaImpronta?: string
  // Inventario
  inventarioCompletado: boolean
  inventarioAprobado: boolean
  inventarioFecha?: string
  inventarioInspector?: string
  inventarioResultado?: {
    totalItems: number
    aprobados: number
    fallas: number
    na: number
    nota?: string
  }
  // Despacho
  despachado: boolean
  fechaDespacho?: string
  horaDespacho?: string
  lotDespacho?: string
  despachador?: string
  // Estado calculado
  estado: EstadoVehiculo
}

const STORAGE_KEY = 'ibv_vehiculos_pipeline'

// Datos iniciales: vehículos que ya pasaron por distintas etapas
const INITIAL_VEHICULOS: VehiculoPipeline[] = [
  {
    id: 'vp-1',
    vin: '1HGBH41JXMN109186',
    placa: 'ABC-1234',
    marca: 'Toyota',
    modelo: 'Corolla',
    anio: '2024',
    color: 'Blanco Perla',
    cliente: 'Distribuidora Caracas',
    contenedorId: '3',
    contenedorCodigo: 'CONT-2026-0003',
    fechaRecepcion: '2026-02-22',
    horaRecepcion: '09:15',
    improntaId: '1',
    improntaFolio: 'IMP-0001',
    improntaCompletada: true,
    fechaImpronta: '2026-02-22',
    inventarioCompletado: true,
    inventarioAprobado: true,
    inventarioFecha: '2026-02-22',
    inventarioInspector: 'Carlos Inspector',
    inventarioResultado: { totalItems: 30, aprobados: 28, fallas: 0, na: 2 },
    despachado: false,
    estado: 'listo_despacho',
  },
  {
    id: 'vp-2',
    vin: '3VWDX7AJ5BM123456',
    placa: 'XYZ-5678',
    marca: 'Chevrolet',
    modelo: 'Spark',
    anio: '2023',
    color: 'Rojo',
    cliente: 'AutoVentas Norte',
    contenedorId: '3',
    contenedorCodigo: 'CONT-2026-0003',
    fechaRecepcion: '2026-02-22',
    horaRecepcion: '09:20',
    improntaId: '2',
    improntaFolio: 'IMP-0002',
    improntaCompletada: true,
    fechaImpronta: '2026-02-22',
    inventarioCompletado: true,
    inventarioAprobado: true,
    inventarioFecha: '2026-02-22',
    inventarioInspector: 'Carlos Inspector',
    inventarioResultado: {
      totalItems: 30,
      aprobados: 26,
      fallas: 2,
      na: 2,
      nota: 'Rayón en lateral derecho',
    },
    despachado: false,
    estado: 'listo_despacho',
  },
  {
    id: 'vp-3',
    vin: 'WVWZZZ3CZWE123789',
    placa: 'DEF-9012',
    marca: 'Nissan',
    modelo: 'Versa',
    anio: '2025',
    color: 'Plata',
    cliente: 'Distribuidora Valencia',
    fechaRecepcion: '2026-02-23',
    horaRecepcion: '08:00',
    improntaId: '3',
    improntaFolio: 'IMP-0003',
    improntaCompletada: false,
    inventarioCompletado: false,
    inventarioAprobado: false,
    despachado: false,
    estado: 'impronta_pendiente',
  },
  {
    id: 'vp-4',
    vin: 'KNDJP3A53H7654321',
    placa: 'GHI-3456',
    marca: 'Kia',
    modelo: 'Rio',
    anio: '2024',
    color: 'Negro',
    cliente: 'Importadora Maracaibo',
    fechaRecepcion: '2026-02-21',
    horaRecepcion: '16:45',
    improntaId: '4',
    improntaFolio: 'IMP-0004',
    improntaCompletada: true,
    fechaImpronta: '2026-02-21',
    inventarioCompletado: false,
    inventarioAprobado: false,
    despachado: false,
    estado: 'inventario_pendiente',
  },
  {
    id: 'vp-5',
    vin: 'KMHDN46D09U987654',
    placa: 'JKL-7890',
    marca: 'Hyundai',
    modelo: 'Accent',
    anio: '2023',
    color: 'Azul',
    cliente: 'AutoCenter Barquisimeto',
    fechaRecepcion: '2026-02-23',
    horaRecepcion: '10:20',
    improntaId: '5',
    improntaFolio: 'IMP-0005',
    improntaCompletada: true,
    fechaImpronta: '2026-02-23',
    inventarioCompletado: false,
    inventarioAprobado: false,
    despachado: false,
    estado: 'inventario_pendiente',
  },
  // Vehículo ya despachado
  {
    id: 'vp-6',
    vin: '1FADP3F29JL234567',
    placa: 'MNO-4567',
    marca: 'Ford',
    modelo: 'Explorer',
    anio: '2025',
    color: 'Blanco Oxford',
    cliente: 'Concesionaria Capital',
    contenedorId: '3',
    contenedorCodigo: 'CONT-2026-0003',
    fechaRecepcion: '2026-02-20',
    horaRecepcion: '14:00',
    improntaCompletada: true,
    fechaImpronta: '2026-02-20',
    inventarioCompletado: true,
    inventarioAprobado: true,
    inventarioFecha: '2026-02-21',
    inventarioInspector: 'Carlos Inspector',
    inventarioResultado: { totalItems: 30, aprobados: 30, fallas: 0, na: 0 },
    despachado: true,
    fechaDespacho: '2026-02-22',
    horaDespacho: '15:30',
    lotDespacho: 'LT-2026-0001',
    despachador: 'Luis Despachador',
    estado: 'despachado',
  },
]

function calcularEstado(v: Omit<VehiculoPipeline, 'estado'>): EstadoVehiculo {
  if (v.despachado) return 'despachado'
  if (v.inventarioAprobado && v.improntaCompletada) return 'listo_despacho'
  if (v.inventarioCompletado) return 'inventario_aprobado'
  if (v.improntaCompletada) return 'inventario_pendiente'
  if (v.improntaId) return 'impronta_pendiente'
  return 'recibido'
}

export const useVehiculoStore = defineStore('vehiculo', () => {
  const vehiculos = ref<VehiculoPipeline[]>([])

  const init = () => {
    if (typeof window === 'undefined') return
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored) {
      try {
        vehiculos.value = JSON.parse(stored)
      } catch {
        vehiculos.value = [...INITIAL_VEHICULOS]
        persist()
      }
    } else {
      vehiculos.value = JSON.parse(JSON.stringify(INITIAL_VEHICULOS))
      persist()
    }
  }

  const persist = () => {
    if (typeof window === 'undefined') return
    localStorage.setItem(STORAGE_KEY, JSON.stringify(vehiculos.value))
  }

  // === Computados ===
  const total = computed(() => vehiculos.value.length)
  const recibidos = computed(() => vehiculos.value.filter((v) => !v.despachado).length)
  const conImpronta = computed(() => vehiculos.value.filter((v) => v.improntaCompletada).length)
  const conInventario = computed(() => vehiculos.value.filter((v) => v.inventarioAprobado).length)
  const listosDespacho = computed(
    () => vehiculos.value.filter((v) => v.estado === 'listo_despacho').length
  )
  const despachados = computed(() => vehiculos.value.filter((v) => v.despachado).length)
  const pendientesImpronta = computed(
    () => vehiculos.value.filter((v) => !v.improntaCompletada && !v.despachado).length
  )
  const pendientesInventario = computed(
    () =>
      vehiculos.value.filter((v) => v.improntaCompletada && !v.inventarioAprobado && !v.despachado)
        .length
  )

  // === Getters ===
  const getByVin = (vin: string) =>
    vehiculos.value.find((v) => v.vin.toLowerCase() === vin.toLowerCase())
  const getById = (id: string) => vehiculos.value.find((v) => v.id === id)

  const getListosParaDespacho = computed(() =>
    vehiculos.value.filter((v) => v.improntaCompletada && v.inventarioAprobado && !v.despachado)
  )

  const getPendientesInventario = computed(() =>
    vehiculos.value.filter((v) => v.improntaCompletada && !v.inventarioAprobado && !v.despachado)
  )

  const getPendientesImpronta = computed(() =>
    vehiculos.value.filter((v) => !v.improntaCompletada && !v.despachado)
  )

  // === Validación de despacho ===
  const puedeDespachar = (vin: string): { ok: boolean; razon?: string } => {
    const v = getByVin(vin)
    if (!v) return { ok: false, razon: 'Vehículo no registrado en el sistema' }
    if (v.despachado) return { ok: false, razon: 'Este vehículo ya fue despachado' }
    if (!v.improntaCompletada) return { ok: false, razon: 'La impronta no ha sido completada' }
    if (!v.inventarioAprobado) return { ok: false, razon: 'El inventario no ha sido aprobado' }
    return { ok: true }
  }

  // === Actions ===
  const registrarRecepcion = (data: {
    vin: string
    placa?: string
    marca: string
    modelo: string
    anio: string
    color: string
    cliente?: string
    contenedorId?: string
    contenedorCodigo?: string
  }): VehiculoPipeline => {
    // Check if already registered
    const existing = getByVin(data.vin)
    if (existing) return existing

    const now = new Date()
    const v: VehiculoPipeline = {
      id: `vp-${Date.now()}`,
      vin: data.vin,
      placa: data.placa || '',
      marca: data.marca,
      modelo: data.modelo,
      anio: data.anio,
      color: data.color,
      cliente: data.cliente || '',
      contenedorId: data.contenedorId,
      contenedorCodigo: data.contenedorCodigo,
      fechaRecepcion: now.toISOString().split('T')[0],
      horaRecepcion: now.toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit' }),
      improntaCompletada: false,
      inventarioCompletado: false,
      inventarioAprobado: false,
      despachado: false,
      estado: 'recibido',
    }
    vehiculos.value.push(v)
    persist()
    return v
  }

  const vincularImpronta = (vin: string, improntaId: string, improntaFolio: string) => {
    const v = getByVin(vin)
    if (v) {
      v.improntaId = improntaId
      v.improntaFolio = improntaFolio
      v.estado = calcularEstado(v)
      persist()
    }
  }

  const completarImpronta = (vin: string) => {
    const v = getByVin(vin)
    if (v) {
      v.improntaCompletada = true
      v.fechaImpronta = new Date().toISOString().split('T')[0]
      v.estado = calcularEstado(v)
      persist()
    }
  }

  const aprobarInventario = (
    vin: string,
    resultado: VehiculoPipeline['inventarioResultado'],
    inspector: string
  ) => {
    const v = getByVin(vin)
    if (v) {
      v.inventarioCompletado = true
      v.inventarioAprobado = true
      v.inventarioFecha = new Date().toISOString().split('T')[0]
      v.inventarioInspector = inspector
      v.inventarioResultado = resultado
      v.estado = calcularEstado(v)
      persist()
    }
  }

  const rechazarInventario = (vin: string, motivo: string) => {
    const v = getByVin(vin)
    if (v) {
      v.inventarioCompletado = true
      v.inventarioAprobado = false
      v.inventarioFecha = new Date().toISOString().split('T')[0]
      v.inventarioResultado = { totalItems: 0, aprobados: 0, fallas: 0, na: 0, nota: motivo }
      v.estado = calcularEstado(v)
      persist()
    }
  }

  const despachar = (vin: string, lote: string, despachador: string): boolean => {
    const check = puedeDespachar(vin)
    if (!check.ok) return false
    const v = getByVin(vin)!
    const now = new Date()
    v.despachado = true
    v.fechaDespacho = now.toISOString().split('T')[0]
    v.horaDespacho = now.toLocaleTimeString('es-VE', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    })
    v.lotDespacho = lote
    v.despachador = despachador
    v.estado = 'despachado'
    persist()
    return true
  }

  init()

  return {
    vehiculos,
    total,
    recibidos,
    conImpronta,
    conInventario,
    listosDespacho,
    despachados,
    pendientesImpronta,
    pendientesInventario,
    getByVin,
    getById,
    getListosParaDespacho,
    getPendientesInventario,
    getPendientesImpronta,
    puedeDespachar,
    registrarRecepcion,
    vincularImpronta,
    completarImpronta,
    aprobarInventario,
    rechazarInventario,
    despachar,
    persist,
  }
})

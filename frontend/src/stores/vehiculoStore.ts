import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { SupabaseClient } from '@supabase/supabase-js'

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
  fechaRecepcion: string
  horaRecepcion: string
  improntaId?: string
  improntaFolio?: string
  improntaCompletada: boolean
  fechaImpronta?: string
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
  despachado: boolean
  fechaDespacho?: string
  horaDespacho?: string
  lotDespacho?: string
  despachador?: string
  estado: EstadoVehiculo
}

function mapEstadoVehiculos(estadoDB: string): EstadoVehiculo {
  const map: Record<string, EstadoVehiculo> = {
    recibido: 'recibido',
    en_impronta: 'impronta_pendiente',
    impronta_completada: 'impronta_completada',
    en_inventario: 'inventario_pendiente',
    inventario_aprobado: 'inventario_aprobado',
    listo_despacho: 'listo_despacho',
    despachado: 'despachado',
  }
  return map[estadoDB] || 'recibido'
}

interface VehiculoRow {
  id: number
  bin: string
  qr_codigo: string
  color: string | null
  estado: string
  fecha_registro: string | null
  created_at: string | null
  placa?: string
  cliente?: string
  modelo_vehiculo?: { marca: string; modelo: string; anio: number | null } | null
  modelo?: { marca: string; modelo: string; anio: number | null } | null
}

function mapRowToVehiculo(row: VehiculoRow): VehiculoPipeline {
  const modelo = row.modelo_vehiculo || row.modelo || null
  return {
    id: String(row.id),
    vin: row.bin,
    placa: row.placa || '',
    marca: modelo?.marca || '',
    modelo: modelo?.modelo || '',
    anio: modelo?.anio ? String(modelo.anio) : '',
    color: row.color || '',
    cliente: row.cliente || '',
    contenedorId: undefined,
    contenedorCodigo: undefined,
    fechaRecepcion: row.fecha_registro?.split('T')[0] || '',
    horaRecepcion: '',
    improntaId: undefined,
    improntaFolio: undefined,
    improntaCompletada:
      row.estado === 'impronta_completada' ||
      row.estado === 'listo_despacho' ||
      row.estado === 'despachado',
    fechaImpronta: undefined,
    inventarioCompletado:
      row.estado === 'inventario_aprobado' ||
      row.estado === 'listo_despacho' ||
      row.estado === 'despachado',
    inventarioAprobado: row.estado === 'listo_despacho' || row.estado === 'despachado',
    inventarioFecha: undefined,
    inventarioInspector: undefined,
    inventarioResultado: undefined,
    despachado: row.estado === 'despachado',
    fechaDespacho: undefined,
    horaDespacho: undefined,
    lotDespacho: undefined,
    despachador: undefined,
    estado: mapEstadoVehiculos(row.estado),
  }
}

export const useVehiculoStore = defineStore('vehiculo', () => {
  const { $supabase } = useNuxtApp()
  const supabase = $supabase as SupabaseClient

  const vehiculos = ref<VehiculoPipeline[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // ===== Fetch =====
  const fetchVehiculos = async () => {
    loading.value = true
    error.value = null
    try {
      const { data, error: err } = await supabase
        .from('vehiculos')
        .select('*, modelo_vehiculo:modelos_vehiculo(marca, modelo, anio)')
        .order('created_at', { ascending: false })

      if (err) throw err
      vehiculos.value = ((data || []) as VehiculoRow[]).map(mapRowToVehiculo)
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Error al cargar vehículos'
      error.value = message
      console.error('Error fetchVehiculos:', err)
    } finally {
      loading.value = false
    }
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
  const registrarRecepcion = async (data: {
    vin: string
    placa?: string
    marca: string
    modelo: string
    anio: string
    color: string
    cliente?: string
    contenedorId?: string
    contenedorCodigo?: string
  }): Promise<VehiculoPipeline> => {
    const existing = getByVin(data.vin)
    if (existing) return existing

    const insertData = {
      bin: data.vin,
      qr_codigo: data.vin,
      color: data.color || null,
      estado: 'recibido',
    }

    const { data: rows, error: err } = await supabase
      .from('vehiculos')
      .insert(insertData)
      .select('*, modelo_vehiculo:modelos_vehiculo(marca, modelo, anio)')

    if (err) throw err
    if (!rows || rows.length === 0) throw new Error('No se pudo registrar el vehículo')

    const v = mapRowToVehiculo(rows[0] as VehiculoRow)
    vehiculos.value.push(v)
    return v
  }

  const vincularImpronta = async (vin: string, improntaId: string, improntaFolio: string) => {
    const v = getByVin(vin)
    if (!v) return

    const { error: err } = await supabase
      .from('vehiculos')
      .update({ estado: 'en_impronta' })
      .eq('id', v.id)

    if (err) {
      console.error('Error vincularImpronta:', err)
      return
    }

    v.improntaId = improntaId
    v.improntaFolio = improntaFolio
    v.estado = 'impronta_pendiente'
  }

  const completarImpronta = async (vin: string) => {
    const v = getByVin(vin)
    if (!v) return

    const fechaImpronta = new Date().toISOString().split('T')[0]

    const { error: err } = await supabase
      .from('vehiculos')
      .update({ estado: 'impronta_completada' })
      .eq('id', v.id)

    if (err) {
      console.error('Error completarImpronta:', err)
      return
    }

    v.improntaCompletada = true
    v.fechaImpronta = fechaImpronta
    v.estado = 'impronta_completada'
  }

  const aprobarInventario = async (
    vin: string,
    resultado: VehiculoPipeline['inventarioResultado'],
    inspector: string
  ) => {
    const v = getByVin(vin)
    if (!v) return

    const inventarioFecha = new Date().toISOString().split('T')[0]

    const { error: err } = await supabase
      .from('vehiculos')
      .update({ estado: 'listo_despacho' })
      .eq('id', v.id)

    if (err) {
      console.error('Error aprobarInventario:', err)
      return
    }

    v.inventarioCompletado = true
    v.inventarioAprobado = true
    v.inventarioFecha = inventarioFecha
    v.inventarioInspector = inspector
    v.inventarioResultado = resultado
    v.estado = 'listo_despacho'
  }

  const rechazarInventario = async (vin: string, motivo: string) => {
    const v = getByVin(vin)
    if (!v) return

    const inventarioFecha = new Date().toISOString().split('T')[0]
    const resultado = { totalItems: 0, aprobados: 0, fallas: 0, na: 0, nota: motivo }

    const { error: err } = await supabase
      .from('vehiculos')
      .update({ estado: 'en_inventario' })
      .eq('id', v.id)

    if (err) {
      console.error('Error rechazarInventario:', err)
      return
    }

    v.inventarioCompletado = true
    v.inventarioAprobado = false
    v.inventarioFecha = inventarioFecha
    v.inventarioResultado = resultado
    v.estado = 'inventario_pendiente'
  }

  const despachar = async (vin: string, lote: string, despachador: string): Promise<boolean> => {
    const check = puedeDespachar(vin)
    if (!check.ok) return false
    const v = getByVin(vin)!
    const now = new Date()
    const fechaDespacho = now.toISOString().split('T')[0]
    const horaDespacho = now.toLocaleTimeString('es-VE', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    })

    const { error: err } = await supabase
      .from('vehiculos')
      .update({ estado: 'despachado' })
      .eq('id', v.id)

    if (err) {
      console.error('Error despachar:', err)
      return false
    }

    v.despachado = true
    v.fechaDespacho = fechaDespacho
    v.horaDespacho = horaDespacho
    v.lotDespacho = lote
    v.despachador = despachador
    v.estado = 'despachado'
    return true
  }

  // Init
  fetchVehiculos()

  return {
    vehiculos,
    loading,
    error,
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
    fetchVehiculos,
    registrarRecepcion,
    vincularImpronta,
    completarImpronta,
    aprobarInventario,
    rechazarInventario,
    despachar,
  }
})

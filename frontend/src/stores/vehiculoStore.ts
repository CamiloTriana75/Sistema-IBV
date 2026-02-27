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

function mapRowToVehiculo(row: any): VehiculoPipeline {
  return {
    id: row.id,
    vin: row.vin,
    placa: row.placa || '',
    marca: row.marca,
    modelo: row.modelo,
    anio: row.anio || '',
    color: row.color || '',
    cliente: row.cliente || '',
    contenedorId: row.contenedor_id || undefined,
    contenedorCodigo: row.contenedor_codigo || undefined,
    fechaRecepcion: row.fecha_recepcion,
    horaRecepcion: row.hora_recepcion?.substring(0, 5) || '',
    improntaId: row.impronta_id || undefined,
    improntaFolio: row.impronta_folio || undefined,
    improntaCompletada: row.impronta_completada,
    fechaImpronta: row.fecha_impronta || undefined,
    inventarioCompletado: row.inventario_completado,
    inventarioAprobado: row.inventario_aprobado,
    inventarioFecha: row.inventario_fecha || undefined,
    inventarioInspector: row.inventario_inspector || undefined,
    inventarioResultado: row.inventario_resultado || undefined,
    despachado: row.despachado,
    fechaDespacho: row.fecha_despacho || undefined,
    horaDespacho: row.hora_despacho?.substring(0, 5) || undefined,
    lotDespacho: row.lot_despacho || undefined,
    despachador: row.despachador || undefined,
    estado: row.estado,
  }
}

function calcularEstado(v: {
  despachado: boolean
  inventarioAprobado: boolean
  improntaCompletada: boolean
  inventarioCompletado?: boolean
  improntaId?: string
}): EstadoVehiculo {
  if (v.despachado) return 'despachado'
  if (v.inventarioAprobado && v.improntaCompletada) return 'listo_despacho'
  if (v.inventarioCompletado) return 'inventario_aprobado'
  if (v.improntaCompletada) return 'inventario_pendiente'
  if (v.improntaId) return 'impronta_pendiente'
  return 'recibido'
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
        .from('vehiculos_pipeline')
        .select('*')
        .order('created_at', { ascending: false })

      if (err) throw err
      vehiculos.value = (data || []).map(mapRowToVehiculo)
    } catch (err: any) {
      error.value = err.message || 'Error al cargar vehículos'
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
      vin: data.vin,
      placa: data.placa || '',
      marca: data.marca,
      modelo: data.modelo,
      anio: data.anio,
      color: data.color,
      cliente: data.cliente || '',
      contenedor_id: data.contenedorId || null,
      contenedor_codigo: data.contenedorCodigo || null,
      estado: 'recibido' as const,
    }

    const { data: rows, error: err } = await supabase
      .from('vehiculos_pipeline')
      .insert(insertData)
      .select()

    if (err) throw err
    if (!rows || rows.length === 0) throw new Error('No se pudo registrar el vehículo')

    const v = mapRowToVehiculo(rows[0])
    vehiculos.value.push(v)
    return v
  }

  const vincularImpronta = async (vin: string, improntaId: string, improntaFolio: string) => {
    const v = getByVin(vin)
    if (!v) return

    const nuevoEstado = calcularEstado({ ...v, improntaId })

    const { error: err } = await supabase
      .from('vehiculos_pipeline')
      .update({
        impronta_id: improntaId,
        impronta_folio: improntaFolio,
        estado: nuevoEstado,
      })
      .eq('id', v.id)

    if (err) {
      console.error('Error vincularImpronta:', err)
      return
    }

    v.improntaId = improntaId
    v.improntaFolio = improntaFolio
    v.estado = nuevoEstado
  }

  const completarImpronta = async (vin: string) => {
    const v = getByVin(vin)
    if (!v) return

    const fechaImpronta = new Date().toISOString().split('T')[0]
    const nuevoEstado = calcularEstado({ ...v, improntaCompletada: true })

    const { error: err } = await supabase
      .from('vehiculos_pipeline')
      .update({
        impronta_completada: true,
        fecha_impronta: fechaImpronta,
        estado: nuevoEstado,
      })
      .eq('id', v.id)

    if (err) {
      console.error('Error completarImpronta:', err)
      return
    }

    v.improntaCompletada = true
    v.fechaImpronta = fechaImpronta
    v.estado = nuevoEstado
  }

  const aprobarInventario = async (
    vin: string,
    resultado: VehiculoPipeline['inventarioResultado'],
    inspector: string
  ) => {
    const v = getByVin(vin)
    if (!v) return

    const inventarioFecha = new Date().toISOString().split('T')[0]
    const nuevoEstado = calcularEstado({
      ...v,
      inventarioCompletado: true,
      inventarioAprobado: true,
    })

    const { error: err } = await supabase
      .from('vehiculos_pipeline')
      .update({
        inventario_completado: true,
        inventario_aprobado: true,
        inventario_fecha: inventarioFecha,
        inventario_inspector: inspector,
        inventario_resultado: resultado,
        estado: nuevoEstado,
      })
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
    v.estado = nuevoEstado
  }

  const rechazarInventario = async (vin: string, motivo: string) => {
    const v = getByVin(vin)
    if (!v) return

    const inventarioFecha = new Date().toISOString().split('T')[0]
    const resultado = { totalItems: 0, aprobados: 0, fallas: 0, na: 0, nota: motivo }
    const nuevoEstado = calcularEstado({
      ...v,
      inventarioCompletado: true,
      inventarioAprobado: false,
    })

    const { error: err } = await supabase
      .from('vehiculos_pipeline')
      .update({
        inventario_completado: true,
        inventario_aprobado: false,
        inventario_fecha: inventarioFecha,
        inventario_resultado: resultado,
        estado: nuevoEstado,
      })
      .eq('id', v.id)

    if (err) {
      console.error('Error rechazarInventario:', err)
      return
    }

    v.inventarioCompletado = true
    v.inventarioAprobado = false
    v.inventarioFecha = inventarioFecha
    v.inventarioResultado = resultado
    v.estado = nuevoEstado
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
      .from('vehiculos_pipeline')
      .update({
        despachado: true,
        fecha_despacho: fechaDespacho,
        hora_despacho: horaDespacho,
        lot_despacho: lote,
        despachador,
        estado: 'despachado',
      })
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

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { SupabaseClient } from '@supabase/supabase-js'
import { supabaseUserService } from '~/services/supabaseUserService'
import { useAuthStore } from '~/stores/auth'

export type EstadoVehiculo =
  | 'recibido'
  | 'impronta_pendiente'
  | 'impronta_completada'
  | 'inventario_pendiente'
  | 'inventario_aprobado'
  | 'listo_despacho'
  | 'despachado'

export interface InventarioResultado {
  totalItems: number
  aprobados: number
  fallas: number
  na: number
  nota?: string
}

export interface InventarioVehiculo {
  id: number
  vin: string
  placa: string
  marca: string
  modelo: string
  anio: string
  color: string
  cliente: string
  fechaRecepcion: string
  horaRecepcion: string
  // Impronta
  improntaId?: string
  improntaFolio?: string
  improntaCompletada: boolean
  improntaRechazada: boolean
  fechaImpronta?: string
  // Inventario
  inventarioCompletado: boolean
  inventarioAprobado: boolean
  inventarioFecha?: string
  inventarioInspector?: string
  inventarioResultado?: InventarioResultado
  // Despacho
  despachado: boolean
  fechaDespacho?: string
  horaDespacho?: string
  lotDespacho?: string
  despachador?: string
  // Estado calculado
  estado: EstadoVehiculo
}

interface VehiculoRow {
  id: number
  bin: string
  qr_codigo: string
  color: string | null
  estado: string | null
  fecha_registro: string | null
  created_at: string | null
  updated_at: string | null
  modelo?:
    | { marca: string; modelo: string; anio: number | null; tipo: string | null }
    | Array<{ marca: string; modelo: string; anio: number | null; tipo: string | null }>
    | null
  improntas?: Array<{
    id: number
    estado: string | null
    fecha: string | null
    created_at: string | null
  }>
  inventarios?: Array<{
    id: number
    completo: boolean
    fecha: string | null
    checklist_json: any
    usuario?: { nombres: string; apellidos: string } | null
  }>
}

const getSupabase = (): SupabaseClient => {
  const { $supabase } = useNuxtApp()
  return $supabase as SupabaseClient
}

const normalizeEstado = (value?: string | null) => (value || '').toLowerCase()

const isImprontaCompletada = (estado?: string | null) => {
  const normalized = normalizeEstado(estado)
  return normalized === 'completada' || normalized === 'revisada'
}

const isImprontaRechazada = (estado?: string | null) => {
  const normalized = normalizeEstado(estado)
  return normalized === 'rechazado' || normalized === 'rechazada'
}

const toDateOnly = (value?: string | null) => {
  if (!value) return ''
  return value.split('T')[0]
}

const calcularEstado = (v: Omit<InventarioVehiculo, 'estado'>): EstadoVehiculo => {
  if (v.despachado) return 'despachado'
  if (v.inventarioAprobado && v.improntaCompletada) return 'listo_despacho'
  if (v.inventarioCompletado) return 'inventario_pendiente'
  if (v.improntaCompletada) return 'inventario_pendiente'
  if (v.improntaRechazada) return 'recibido' // impronta rechazada → vuelve al inicio
  if (v.improntaId) return 'impronta_pendiente'
  return 'recibido'
}

export const useInventarioStore = defineStore('inventario', () => {
  const vehiculos = ref<InventarioVehiculo[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const total = computed(() => vehiculos.value.length)
  const conImpronta = computed(() => vehiculos.value.filter((v) => v.improntaCompletada).length)
  const listosDespacho = computed(
    () => vehiculos.value.filter((v) => v.inventarioAprobado && !v.despachado).length
  )
  const despachados = computed(() => vehiculos.value.filter((v) => v.despachado).length)
  const pendientesInventario = computed(
    () =>
      vehiculos.value.filter((v) => v.improntaCompletada && !v.inventarioAprobado && !v.despachado)
        .length
  )

  const getByVin = (vin: string) =>
    vehiculos.value.find((v) => v.vin.toLowerCase() === vin.toLowerCase())

  const getListosParaDespacho = computed(() =>
    vehiculos.value.filter(
      (v) => v.improntaCompletada && v.inventarioAprobado && !v.despachado && !v.improntaRechazada
    )
  )

  const getPendientesInventario = computed(() =>
    vehiculos.value.filter(
      (v) => v.improntaCompletada && !v.inventarioAprobado && !v.despachado && !v.improntaRechazada
    )
  )

  const mapVehiculo = (row: VehiculoRow): InventarioVehiculo => {
    const improntas = Array.isArray(row.improntas) ? row.improntas : []
    const inventarios = Array.isArray(row.inventarios) ? row.inventarios : []

    const improntaLatest = [...improntas].sort((a, b) => {
      return (
        new Date(b.fecha || b.created_at || 0).getTime() -
        new Date(a.fecha || a.created_at || 0).getTime()
      )
    })[0]

    const inventarioLatest = [...inventarios].sort((a, b) => {
      return new Date(b.fecha || 0).getTime() - new Date(a.fecha || 0).getTime()
    })[0]

    const vehiculoEstadoDB = normalizeEstado(row.estado)
    const vehiculoRechazadoDB = vehiculoEstadoDB === 'rechazado'

    const improntaRechazada =
      vehiculoRechazadoDB || (improntaLatest ? isImprontaRechazada(improntaLatest.estado) : false)
    const improntaCompletada =
      !improntaRechazada && improntaLatest ? isImprontaCompletada(improntaLatest.estado) : false
    const inventarioCompletado = !!inventarioLatest
    const inventarioAprobado = inventarioLatest?.completo ?? false

    const inspectorName = inventarioLatest?.usuario
      ? `${inventarioLatest.usuario.nombres} ${inventarioLatest.usuario.apellidos}`.trim()
      : ''

    const resultado = inventarioLatest?.checklist_json?.resumen as InventarioResultado | undefined

    const modelo = Array.isArray(row.modelo) ? row.modelo[0] : row.modelo

    const vehiculoBase: Omit<InventarioVehiculo, 'estado'> = {
      id: row.id,
      vin: row.bin || row.qr_codigo,
      placa: '',
      marca: modelo?.marca || '—',
      modelo: modelo?.modelo || '',
      anio: modelo?.anio ? String(modelo.anio) : '',
      color: row.color || '—',
      cliente: '',
      fechaRecepcion: toDateOnly(row.fecha_registro || row.created_at),
      horaRecepcion: '',
      improntaId: improntaLatest ? String(improntaLatest.id) : undefined,
      improntaFolio: improntaLatest
        ? `IMP-${String(improntaLatest.id).padStart(4, '0')}`
        : undefined,
      improntaCompletada,
      improntaRechazada,
      fechaImpronta: improntaLatest?.fecha ? toDateOnly(improntaLatest.fecha) : undefined,
      inventarioCompletado,
      inventarioAprobado,
      inventarioFecha: inventarioLatest?.fecha ? toDateOnly(inventarioLatest.fecha) : undefined,
      inventarioInspector: inspectorName || undefined,
      inventarioResultado: resultado,
      despachado: normalizeEstado(row.estado) === 'despachado',
    }

    return {
      ...vehiculoBase,
      estado: calcularEstado(vehiculoBase),
    }
  }

  const load = async () => {
    if (process.server) return
    loading.value = true
    error.value = null

    try {
      const $supabase = getSupabase()
      const { data, error: fetchError } = await $supabase
        .from('vehiculos')
        .select(
          `
          id,
          bin,
          qr_codigo,
          color,
          estado,
          fecha_registro,
          created_at,
          updated_at,
          modelo:modelos_vehiculo(marca, modelo, anio, tipo),
          improntas:improntas(id, estado, fecha, created_at),
          inventarios:inventarios(id, completo, fecha, checklist_json, usuario:usuarios!inventarios_usuario_id_fkey(nombres, apellidos))
        `
        )
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError

      const list = (data || []) as unknown as VehiculoRow[]
      vehiculos.value = list.map(mapVehiculo)
    } catch (err: any) {
      console.error('Error cargando inventario:', err)
      error.value = err?.message || 'Error cargando inventario'
      vehiculos.value = []
    } finally {
      loading.value = false
    }
  }

  const getUsuarioId = async () => {
    const authStore = useAuthStore()
    const email = authStore.user?.email
    if (!email) return null
    const profile = await supabaseUserService.getUserProfile(email)
    return profile?.id ?? null
  }

  const aprobarInventario = async (
    vin: string,
    resultado: InventarioResultado,
    checklistJson: any
  ) => {
    const vehiculo = getByVin(vin)
    if (!vehiculo) return

    const $supabase = getSupabase()
    const usuarioId = await getUsuarioId()
    const now = new Date().toISOString()

    const payload = {
      vehiculo_id: vehiculo.id,
      checklist_json: checklistJson,
      completo: true,
      usuario_id: usuarioId,
      fecha: now,
    }

    const { error: invError } = await $supabase.from('inventarios').insert(payload)
    if (invError) {
      console.error('Error guardando inventario:', invError)
      throw new Error(invError.message)
    }

    const { error: vehError } = await $supabase
      .from('vehiculos')
      .update({ estado: 'listo_despacho', updated_at: now })
      .eq('id', vehiculo.id)

    if (vehError) {
      console.error('Error actualizando vehiculo:', vehError)
      throw new Error(vehError.message)
    }

    vehiculo.inventarioCompletado = true
    vehiculo.inventarioAprobado = true
    vehiculo.inventarioFecha = toDateOnly(now)
    vehiculo.inventarioResultado = resultado
  }

  const rechazarInventario = async (vin: string, motivo: string, checklistJson: any) => {
    const vehiculo = getByVin(vin)
    if (!vehiculo) return

    const $supabase = getSupabase()
    const usuarioId = await getUsuarioId()
    const now = new Date().toISOString()

    const payload = {
      vehiculo_id: vehiculo.id,
      checklist_json: checklistJson,
      completo: false,
      usuario_id: usuarioId,
      fecha: now,
    }

    const { error: invError } = await $supabase.from('inventarios').insert(payload)
    if (invError) {
      console.error('Error guardando inventario:', invError)
      throw new Error(invError.message)
    }

    const { error: vehError } = await $supabase
      .from('vehiculos')
      .update({ estado: 'rechazado', updated_at: now })
      .eq('id', vehiculo.id)

    if (vehError) {
      console.error('Error actualizando vehiculo:', vehError)
      throw new Error(vehError.message)
    }

    // Actualizar también la impronta a rechazado
    if (vehiculo.improntaId) {
      await $supabase
        .from('improntas')
        .update({ estado: 'rechazado', updated_at: now })
        .eq('id', Number(vehiculo.improntaId))
    }

    vehiculo.inventarioCompletado = true
    vehiculo.inventarioAprobado = false
    vehiculo.improntaCompletada = false
    vehiculo.improntaRechazada = true
    vehiculo.inventarioFecha = toDateOnly(now)
    vehiculo.inventarioResultado = {
      totalItems: 0,
      aprobados: 0,
      fallas: 0,
      na: 0,
      nota: motivo,
    }
  }

  return {
    vehiculos,
    loading,
    error,
    total,
    conImpronta,
    listosDespacho,
    despachados,
    pendientesInventario,
    getByVin,
    getListosParaDespacho,
    getPendientesInventario,
    load,
    aprobarInventario,
    rechazarInventario,
  }
})

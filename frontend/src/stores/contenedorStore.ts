import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { SupabaseClient } from '@supabase/supabase-js'

export interface VehiculoContenedor {
  id?: string
  contenedor_id?: string
  vin: string
  marca: string
  modelo: string
  anio: string
  color: string
  codigoImpronta: string
  escaneado: boolean
  improntaId?: string
}

export interface Contenedor {
  id: string
  codigo: string
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

function mapRowToContenedor(row: any, vehiculosRows: any[] = []): Contenedor {
  return {
    id: row.id,
    codigo: row.codigo,
    origen: row.origen,
    transportista: row.transportista,
    placaCamion: row.placa_camion,
    fechaLlegada: row.fecha_llegada,
    horaLlegada: row.hora_llegada?.substring(0, 5) || '',
    vehiculosEsperados: row.vehiculos_esperados,
    vehiculos: vehiculosRows.map(mapRowToVehiculo),
    estado: row.estado,
    recibidoPor: row.recibido_por || '',
    observaciones: row.observaciones || '',
  }
}

function mapRowToVehiculo(row: any): VehiculoContenedor {
  return {
    id: row.id,
    contenedor_id: row.contenedor_id,
    vin: row.vin,
    marca: row.marca,
    modelo: row.modelo,
    anio: row.anio,
    color: row.color,
    codigoImpronta: row.codigo_impronta,
    escaneado: row.escaneado,
    improntaId: row.impronta_id || undefined,
  }
}

export const useContenedorStore = defineStore('contenedor', () => {
  const { $supabase } = useNuxtApp()
  const supabase = $supabase as SupabaseClient

  // State
  const contenedores = ref<Contenedor[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

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

  // ===== Fetch all contenedores with their vehiculos =====
  const fetchContenedores = async () => {
    loading.value = true
    error.value = null
    try {
      const { data: contRows, error: contErr } = await supabase
        .from('contenedores')
        .select('*')
        .order('fecha_llegada', { ascending: false })

      if (contErr) throw contErr

      const ids = (contRows || []).map((c: any) => c.id)
      let vehRows: any[] = []
      if (ids.length > 0) {
        const { data, error: vehErr } = await supabase
          .from('contenedor_vehiculos')
          .select('*')
          .in('contenedor_id', ids)
          .order('created_at', { ascending: true })

        if (vehErr) throw vehErr
        vehRows = data || []
      }

      const vehMap: Record<string, any[]> = {}
      for (const v of vehRows) {
        if (!vehMap[v.contenedor_id]) vehMap[v.contenedor_id] = []
        vehMap[v.contenedor_id].push(v)
      }

      contenedores.value = (contRows || []).map((row: any) =>
        mapRowToContenedor(row, vehMap[row.id] || [])
      )
    } catch (err: any) {
      error.value = err.message || 'Error al cargar contenedores'
      console.error('Error fetchContenedores:', err)
    } finally {
      loading.value = false
    }
  }

  // ===== Getters =====
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

  // ===== Actions =====
  const iniciarRecepcion = async (id: string, recibidor: string) => {
    const { error: err } = await supabase
      .from('contenedores')
      .update({ estado: 'en_recepcion', recibido_por: recibidor })
      .eq('id', id)

    if (err) {
      console.error('Error iniciarRecepcion:', err)
      return
    }

    const cont = contenedores.value.find((c) => c.id === id)
    if (cont) {
      cont.estado = 'en_recepcion'
      cont.recibidoPor = recibidor
    }
  }

  const marcarVehiculoEscaneado = async (
    contenedorId: string,
    codigoImpronta: string,
    improntaId?: string
  ) => {
    const cont = contenedores.value.find((c) => c.id === contenedorId)
    if (!cont) return

    const veh = cont.vehiculos.find(
      (v) => v.codigoImpronta.toLowerCase() === codigoImpronta.toLowerCase()
    )
    if (!veh || !veh.id) return

    const updateData: Record<string, any> = { escaneado: true }
    if (improntaId) updateData.impronta_id = improntaId

    const { error: err } = await supabase
      .from('contenedor_vehiculos')
      .update(updateData)
      .eq('id', veh.id)

    if (err) {
      console.error('Error marcarVehiculoEscaneado:', err)
      return
    }

    veh.escaneado = true
    if (improntaId) veh.improntaId = improntaId

    if (cont.vehiculos.every((v) => v.escaneado)) {
      await completarRecepcion(contenedorId)
    }
  }

  const completarRecepcion = async (id: string, observaciones?: string) => {
    const updateData: Record<string, any> = { estado: 'completado' }
    if (observaciones) updateData.observaciones = observaciones

    const { error: err } = await supabase
      .from('contenedores')
      .update(updateData)
      .eq('id', id)

    if (err) {
      console.error('Error completarRecepcion:', err)
      return
    }

    const cont = contenedores.value.find((c) => c.id === id)
    if (cont) {
      cont.estado = 'completado'
      if (observaciones) cont.observaciones = observaciones
    }
  }

  // ===== Crear contenedor al registrar llegada =====
  const crearContenedor = async (data: {
    codigo: string
    origen: string
    transportista: string
    placaCamion: string
    fechaLlegada: string
    horaLlegada: string
    vehiculosEsperados: number
    recibidoPor?: string
  }): Promise<Contenedor | null> => {
    const { data: row, error: err } = await supabase
      .from('contenedores')
      .insert({
        codigo: data.codigo,
        origen: data.origen,
        transportista: data.transportista,
        placa_camion: data.placaCamion,
        fecha_llegada: data.fechaLlegada,
        hora_llegada: data.horaLlegada || null,
        vehiculos_esperados: data.vehiculosEsperados,
        recibido_por: data.recibidoPor || null,
        estado: 'en_recepcion',
      })
      .select()
      .single()

    if (err) {
      console.error('Error crearContenedor:', err)
      return null
    }

    const nuevo = mapRowToContenedor(row, [])
    contenedores.value.unshift(nuevo)
    return nuevo
  }

  // ===== Agregar vehículo escaneado al contenedor =====
  const agregarVehiculoEscaneado = async (
    contenedorId: string,
    data: {
      vin: string
      marca: string
      modelo: string
      anio: string
      color: string
      codigoImpronta: string
    }
  ): Promise<VehiculoContenedor | null> => {
    const { data: row, error: err } = await supabase
      .from('contenedor_vehiculos')
      .insert({
        contenedor_id: contenedorId,
        vin: data.vin,
        marca: data.marca,
        modelo: data.modelo,
        anio: data.anio,
        color: data.color,
        codigo_impronta: data.codigoImpronta,
        escaneado: true,
      })
      .select()
      .single()

    if (err) {
      console.error('Error agregarVehiculoEscaneado:', err)
      return null
    }

    const nuevoVeh = mapRowToVehiculo(row)
    const cont = contenedores.value.find((c) => c.id === contenedorId)
    if (cont) {
      cont.vehiculos.push(nuevoVeh)
      // Expand expected count if we scan more than expected
      if (cont.vehiculos.length > cont.vehiculosEsperados) {
        cont.vehiculosEsperados = cont.vehiculos.length
      }
    }
    return nuevoVeh
  }

  // Init on creation
  fetchContenedores()

  return {
    contenedores,
    loading,
    error,
    totalContenedores,
    pendientes,
    enRecepcion,
    completados,
    totalVehiculosHoy,
    fetchContenedores,
    getById,
    getByCodigo,
    buscarVehiculoPorCodigo,
    buscarVehiculoPorVin,
    iniciarRecepcion,
    marcarVehiculoEscaneado,
    completarRecepcion,
    crearContenedor,
    agregarVehiculoEscaneado,
  }
})

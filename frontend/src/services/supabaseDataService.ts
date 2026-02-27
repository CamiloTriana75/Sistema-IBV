/**
 * Servicio para obtener datos del dashboard directamente desde Supabase
 * Reemplaza las llamadas al backend API (/api/vehicles/, /api/stats/, /api/activities/)
 */
import type { SupabaseClient } from '@supabase/supabase-js'

const getSupabase = (): SupabaseClient => {
  const { $supabase } = useNuxtApp()
  return $supabase as SupabaseClient
}

export interface VehicleData {
  id: number
  bin: string
  qr_codigo: string
  buque_id: number | null
  modelo_id: number | null
  color: string | null
  estado: string | null
  fecha_registro: string
  created_at: string
  updated_at: string
  buque?: { nombre: string; identificacion: string } | null
  modelo?: { marca: string; modelo: string; anio: number; tipo: string } | null
}

export interface DashboardStats {
  total_vehiculos: number
  en_impronta: number
  en_inventario: number
  listos_despacho: number
  despachados: number
  problemas_encontrados: number
}

export interface ActivityItem {
  id: number
  description: string
  timestamp: string
  user?: { nombres: string; apellidos: string } | null
  role: string
  type: string
}

export const supabaseDataService = {
  /**
   * Obtiene todos los vehículos con sus relaciones
   */
  async getVehicles(): Promise<VehicleData[]> {
    const $supabase = getSupabase()

    const { data, error } = await $supabase
      .from('vehiculos')
      .select(
        `
        *,
        buque:buques(nombre, identificacion),
        modelo:modelos_vehiculo(marca, modelo, anio, tipo)
      `
      )
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error obteniendo vehículos:', error)
      return []
    }

    return (data || []) as VehicleData[]
  },

  /**
   * Calcula las estadísticas del dashboard a partir de los vehículos
   */
  async getDashboardStats(): Promise<DashboardStats> {
    const $supabase = getSupabase()

    // Obtener conteos por estado
    const { data: vehiculos, error } = await $supabase.from('vehiculos').select('estado')

    if (error || !vehiculos) {
      console.error('Error obteniendo stats:', error)
      return {
        total_vehiculos: 0,
        en_impronta: 0,
        en_inventario: 0,
        listos_despacho: 0,
        despachados: 0,
        problemas_encontrados: 0,
      }
    }

    const total = vehiculos.length
    const counts: Record<string, number> = {}
    for (const v of vehiculos) {
      const estado = (v.estado || 'sin_estado').toLowerCase()
      counts[estado] = (counts[estado] || 0) + 1
    }

    return {
      total_vehiculos: total,
      en_impronta: counts['en_impronta'] || counts['impronta'] || 0,
      en_inventario: counts['en_inventario'] || counts['inventario'] || 0,
      listos_despacho: counts['listo_despacho'] || counts['listo'] || counts['aprobado'] || 0,
      despachados: counts['despachado'] || counts['entregado'] || 0,
      problemas_encontrados:
        counts['problema'] || counts['rechazado'] || counts['dañado'] || counts['danado'] || 0,
    }
  },

  /**
   * Obtiene las actividades recientes combinando múltiples tablas
   */
  async getActivities(limit: number = 5): Promise<ActivityItem[]> {
    const $supabase = getSupabase()
    const activities: ActivityItem[] = []

    // Obtener improntas recientes
    const { data: improntas } = await $supabase
      .from('improntas')
      .select('id, fecha, estado, usuario:usuarios!improntas_usuario_id_fkey(nombres, apellidos)')
      .order('fecha', { ascending: false })
      .limit(limit)

    if (improntas) {
      for (const imp of improntas) {
        const usuario = imp.usuario as any
        activities.push({
          id: imp.id,
          description: `realizó impronta (${imp.estado || 'completada'})`,
          timestamp: imp.fecha,
          user: usuario ? { nombres: usuario.nombres, apellidos: usuario.apellidos } : null,
          role: 'recibidor',
          type: 'impronta',
        })
      }
    }

    // Obtener inventarios recientes
    const { data: inventarios } = await $supabase
      .from('inventarios')
      .select(
        'id, fecha, completo, usuario:usuarios!inventarios_usuario_id_fkey(nombres, apellidos)'
      )
      .order('fecha', { ascending: false })
      .limit(limit)

    if (inventarios) {
      for (const inv of inventarios) {
        const usuario = inv.usuario as any
        activities.push({
          id: inv.id + 10000,
          description: `${inv.completo ? 'completó' : 'inició'} inventario`,
          timestamp: inv.fecha,
          user: usuario ? { nombres: usuario.nombres, apellidos: usuario.apellidos } : null,
          role: 'inventario',
          type: 'inventario',
        })
      }
    }

    // Obtener despachos recientes
    const { data: despachos } = await $supabase
      .from('despachos')
      .select(
        'id, fecha, estado, cantidad_vehiculos, usuario:usuarios!despachos_usuario_id_fkey(nombres, apellidos)'
      )
      .order('fecha', { ascending: false })
      .limit(limit)

    if (despachos) {
      for (const desp of despachos) {
        const usuario = desp.usuario as any
        activities.push({
          id: desp.id + 20000,
          description: `despacho de ${desp.cantidad_vehiculos} vehículos (${desp.estado || 'en proceso'})`,
          timestamp: desp.fecha,
          user: usuario ? { nombres: usuario.nombres, apellidos: usuario.apellidos } : null,
          role: 'despachador',
          type: 'despacho',
        })
      }
    }

    // Obtener movimientos de portería recientes
    const { data: movimientos } = await $supabase
      .from('movimientos_porteria')
      .select(
        'id, tipo, persona, fecha, observacion, usuario:usuarios!movimientos_porteria_usuario_id_fkey(nombres, apellidos)'
      )
      .order('fecha', { ascending: false })
      .limit(limit)

    if (movimientos) {
      for (const mov of movimientos) {
        const usuario = mov.usuario as any
        activities.push({
          id: mov.id + 30000,
          description: `movimiento ${mov.tipo}${mov.persona ? ` - ${mov.persona}` : ''}`,
          timestamp: mov.fecha,
          user: usuario ? { nombres: usuario.nombres, apellidos: usuario.apellidos } : null,
          role: 'porteria',
          type: 'porteria',
        })
      }
    }

    // Ordenar por fecha descÿ y limitar
    activities.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
    return activities.slice(0, limit)
  },

  /**
   * Obtiene los buques
   */
  async getBuques() {
    const $supabase = getSupabase()

    const { data, error } = await $supabase
      .from('buques')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('Error obteniendo buques:', error)
      return []
    }

    return data || []
  },
}

export default supabaseDataService

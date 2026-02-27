/**
 * Servicio para gestionar notificaciones desde Supabase
 * Tabla: notificaciones
 */
import type { SupabaseClient } from '@supabase/supabase-js'

const getSupabase = (): SupabaseClient => {
  const { $supabase } = useNuxtApp()
  return $supabase as SupabaseClient
}

export type NotificationModule =
  | 'admin'
  | 'recibidor'
  | 'inventario'
  | 'despachador'
  | 'porteria'
  | 'general'

export interface NotificationItem {
  id: number
  titulo: string
  mensaje: string
  modulo: NotificationModule
  recipient_user_id: number | null
  created_by_user_id: number | null
  created_by_role: string
  action_url: string | null
  metadata: Record<string, any>
  leida_en: string | null
  created_at: string
}

export interface NotificationInput {
  titulo: string
  mensaje: string
  modulo: NotificationModule
  recipientUserId: number | null
  createdByUserId: number | null
  createdByRole: string
  actionUrl?: string | null
  metadata?: Record<string, any>
}

export interface NotificationQueryOptions {
  limit?: number
  onlyUnread?: boolean
  recipientUserId?: number | null
  module?: NotificationModule
  createdByRole?: string
  search?: string
}

export const supabaseNotificationService = {
  async getNotifications(options?: NotificationQueryOptions): Promise<NotificationItem[]> {
    const $supabase = getSupabase()
    const limit = options?.limit ?? 10
    const onlyUnread = options?.onlyUnread ?? false
    const recipientUserId = options?.recipientUserId
    const module = options?.module
    const createdByRole = options?.createdByRole
    const search = options?.search?.trim()

    let query = $supabase
      .from('notificaciones')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit)

    if (onlyUnread) {
      query = query.is('leida_en', null)
    }

    if (typeof recipientUserId === 'number') {
      query = query.eq('recipient_user_id', recipientUserId)
    }

    if (module) {
      query = query.eq('modulo', module)
    }

    if (createdByRole) {
      query = query.eq('created_by_role', createdByRole)
    }

    if (search) {
      const escaped = search.replace(/%/g, '\\%').replace(/_/g, '\\_')
      query = query.or(`titulo.ilike.%${escaped}%,mensaje.ilike.%${escaped}%`)
    }

    const { data, error } = await query

    if (error) {
      console.error('Error obteniendo notificaciones:', error)
      return []
    }

    return (data || []) as NotificationItem[]
  },

  async markAsRead(id: number): Promise<void> {
    const $supabase = getSupabase()

    const { error } = await $supabase
      .from('notificaciones')
      .update({ leida_en: new Date().toISOString() })
      .eq('id', id)

    if (error) {
      console.error('Error marcando notificacion como leida:', error)
      throw new Error(error.message)
    }
  },

  async markAllAsReadForUser(userId: number): Promise<void> {
    const $supabase = getSupabase()

    const { error } = await $supabase
      .from('notificaciones')
      .update({ leida_en: new Date().toISOString() })
      .eq('recipient_user_id', userId)
      .is('leida_en', null)

    if (error) {
      console.error('Error marcando todas las notificaciones:', error)
      throw new Error(error.message)
    }
  },

  async createNotification(input: NotificationInput): Promise<NotificationItem | null> {
    const $supabase = getSupabase()

    const { data, error } = await $supabase
      .from('notificaciones')
      .insert({
        titulo: input.titulo,
        mensaje: input.mensaje,
        modulo: input.modulo,
        recipient_user_id: input.recipientUserId,
        created_by_user_id: input.createdByUserId,
        created_by_role: input.createdByRole,
        action_url: input.actionUrl ?? null,
        metadata: input.metadata ?? {},
      })
      .select()
      .single()

    if (error) {
      console.error('Error creando notificacion:', error)
      throw new Error(error.message)
    }

    return data as NotificationItem
  },
}

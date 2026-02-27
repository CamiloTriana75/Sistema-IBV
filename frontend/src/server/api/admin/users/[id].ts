/**
 * API para gestionar usuarios específicos
 * GET /api/admin/users/:id - Obtiene un usuario
 * PATCH /api/admin/users/:id - Actualiza usuario
 * DELETE /api/admin/users/:id - Elimina usuario
 */
import { createClient } from '@supabase/supabase-js'

const getSupabaseAdmin = (supabaseUrl: string, supabaseServiceKey: string) => {
  if (!supabaseUrl || !supabaseServiceKey) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Supabase configuration missing on server'
    })
  }

  return createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  })
}

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const supabaseUrl = config.supabaseUrl
  const supabaseServiceKey = config.supabaseServiceKey
  
  console.log('[Admin Users] Configuración:', {
    hasUrl: !!supabaseUrl,
    hasKey: !!supabaseServiceKey,
    urlLength: supabaseUrl?.length || 0,
    keyLength: supabaseServiceKey?.length || 0,
  })
  
  if (!supabaseUrl || !supabaseServiceKey) {
    console.error('[Admin Users] Missing Supabase config:', { supabaseUrl: !!supabaseUrl, supabaseServiceKey: !!supabaseServiceKey })
    throw createError({
      statusCode: 500,
      statusMessage: 'Supabase configuration missing on server'
    })
  }
  
  const method = getMethod(event)
  const userId = getRouterParam(event, 'id')
  
  console.log('[Admin Users] Request:', { method, userId })

  if (!userId) {
    throw createError({
      statusCode: 400,
      statusMessage: 'ID de usuario requerido'
    })
  }

  let $supabaseAdmin
  try {
    $supabaseAdmin = getSupabaseAdmin(supabaseUrl, supabaseServiceKey)
  } catch (err) {
    console.error('[Admin Users] Error creando cliente Supabase:', err)
    throw createError({
      statusCode: 500,
      statusMessage: 'Error inicializando cliente Supabase'
    })
  }

  try {
    // ============================================
    // GET /api/admin/users/:id
    // ============================================
    if (method === 'GET') {
      const { data, error } = await $supabaseAdmin
        .from('usuarios')
        .select('*')
        .eq('id', Number(userId))
        .single()

      if (error) throw error

      return { success: true, data }
    }

    // ============================================
    // PATCH /api/admin/users/:id
    // ============================================
    if (method === 'PATCH') {
      const body = await readBody(event)
      const userIdNum = Number(userId)
      
      console.log('[PATCH /api/admin/users/:id] Body recibido:', body)
      console.log('[PATCH /api/admin/users/:id] Usuario ID:', userIdNum)

      const { data: currentUser, error: getError } = await $supabaseAdmin
        .from('usuarios')
        .select('*')
        .eq('id', userIdNum)
        .single()

      if (getError || !currentUser) {
        console.error('[PATCH] Usuario no encontrado:', { getError, userIdNum })
        throw createError({
          statusCode: 404,
          statusMessage: 'Usuario no encontrado'
        })
      }
      
      console.log('[PATCH] Usuario actual:', currentUser)

      // Preparar datos a actualizar
      const updateData = {
        nombres: body.nombres ?? currentUser.nombres,
        apellidos: body.apellidos ?? currentUser.apellidos,
        rol: body.rol ?? currentUser.rol,
        activo: body.activo ?? currentUser.activo,
      }
      
      console.log('[PATCH] Datos a actualizar:', updateData)

      // Actualizar en tabla usuarios
      const { data: updatedUser, error: updateError } = await $supabaseAdmin
        .from('usuarios')
        .update(updateData)
        .eq('id', userIdNum)
        .select()
        .single()

      if (updateError) {
        console.error('[PATCH] Error actualizando en BD:', updateError)
        throw new Error(`Error actualizando: ${updateError.message}`)
      }
      
      console.log('[PATCH] Usuario actualizado en BD:', updatedUser)

      // Actualizar en Supabase Auth
      const { data: authUsers, error: authGetError } = await $supabaseAdmin.auth.admin.listUsers()
      if (!authGetError) {
        const authUser = authUsers.users.find((u) => u.email === currentUser.correo)
        if (authUser) {
          const nombreCompleto = `${updatedUser.nombres} ${updatedUser.apellidos}`.trim()
          await $supabaseAdmin.auth.admin.updateUserById(authUser.id, {
            user_metadata: {
              nombres: updatedUser.nombres,
              apellidos: updatedUser.apellidos,
              full_name: nombreCompleto,
              display_name: nombreCompleto,
              rol: updatedUser.rol,
            },
          })
        }
      }

      return {
        success: true,
        message: 'Usuario actualizado',
        user: updatedUser,
      }
    }

    // ============================================
    // DELETE /api/admin/users/:id
    // ============================================
    if (method === 'DELETE') {
      const userIdNum = Number(userId)
      
      const { data: usuario, error: getError } = await $supabaseAdmin
        .from('usuarios')
        .select('correo')
        .eq('id', userIdNum)
        .single()

      if (getError) {
        throw createError({
          statusCode: 404,
          statusMessage: 'Usuario no encontrado'
        })
      }

      // Obtener auth users
      const { data: authUsers, error: authGetError } = await $supabaseAdmin.auth.admin.listUsers()

      if (authGetError) {
        throw new Error('Error consultando Auth')
      }

      const authUser = authUsers.users.find((u) => u.email === usuario.correo)

      // Eliminar de Auth
      if (authUser) {
        const { error: authDeleteError } = await $supabaseAdmin.auth.admin.deleteUser(authUser.id)
        if (authDeleteError) {
          throw new Error(`Error en Auth: ${authDeleteError.message}`)
        }
      }

      // Eliminar de BD
      const { error: deleteError } = await $supabaseAdmin
        .from('usuarios')
        .delete()
        .eq('id', userIdNum)

      if (deleteError) {
        throw new Error(`Error en BD: ${deleteError.message}`)
      }

      return {
        success: true,
        message: 'Usuario eliminado',
      }
    }

    throw createError({
      statusCode: 405,
      statusMessage: 'Método no permitido',
    })
  } catch (err: any) {
    console.error('[Admin Users Dynamic]', err)

    if (err.statusCode) {
      throw err
    }

    throw createError({
      statusCode: 500,
      statusMessage: err.message || 'Error procesando solicitud',
    })
  }
})

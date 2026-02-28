/**
 * API para gestionar usuarios específicos
 * GET /api/admin/users/:id - Obtiene un usuario
 * PATCH /api/admin/users/:id - Actualiza usuario
 * DELETE /api/admin/users/:id - Elimina usuario
 */
import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const supabaseUrl = config.supabaseUrl
  const supabaseServiceKey = config.supabaseServiceKey

  if (!supabaseUrl || !supabaseServiceKey) {
    console.error('[Admin Users ID] Configuración faltante:', {
      hasUrl: !!supabaseUrl,
      hasKey: !!supabaseServiceKey,
    })
    throw createError({
      statusCode: 500,
      statusMessage: 'Supabase configuration missing on server. Set NUXT_SUPABASE_URL and NUXT_SUPABASE_SERVICE_KEY in Vercel.'
    })
  }

  const $supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  })

  const method = getMethod(event)
  const userId = getRouterParam(event, 'id')

  if (!userId) {
    throw createError({
      statusCode: 400,
      statusMessage: 'ID de usuario requerido'
    })
  }

  const userIdNum = Number(userId)
  if (isNaN(userIdNum)) {
    throw createError({
      statusCode: 400,
      statusMessage: 'ID de usuario debe ser un número'
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
        .eq('id', userIdNum)
        .single()

      if (error) throw error

      return { success: true, data }
    }

    // ============================================
    // PATCH /api/admin/users/:id
    // ============================================
    if (method === 'PATCH') {
      // Paso 1: Leer body
      let body: any
      try {
        body = await readBody(event)
      } catch (e: any) {
        throw createError({ statusCode: 400, statusMessage: `Error leyendo body: ${e.message}` })
      }

      // Paso 2: Obtener usuario actual
      let currentUser: any
      try {
        const { data, error } = await $supabaseAdmin
          .from('usuarios')
          .select('*')
          .eq('id', userIdNum)
          .single()
        if (error) throw error
        if (!data) throw new Error('No data returned')
        currentUser = data
      } catch (e: any) {
        throw createError({ statusCode: 404, statusMessage: `Usuario ${userIdNum} no encontrado: ${e.message}` })
      }

      // Paso 3: Preparar datos
      const updateData: Record<string, any> = {}
      if (body.nombres !== undefined) updateData.nombres = body.nombres
      if (body.apellidos !== undefined) updateData.apellidos = body.apellidos
      if (body.rol !== undefined) updateData.rol = body.rol
      if (body.activo !== undefined) updateData.activo = body.activo

      if (Object.keys(updateData).length === 0) {
        return { success: true, message: 'Sin cambios', user: currentUser }
      }

      // Paso 4: Ejecutar UPDATE
      let updatedUser: any
      try {
        const { data, error } = await $supabaseAdmin
          .from('usuarios')
          .update(updateData)
          .eq('id', userIdNum)
          .select('*')
          .maybeSingle()

        if (error) {
          throw createError({
            statusCode: 500,
            statusMessage: `Supabase update error: ${error.message} | code: ${error.code} | details: ${error.details}`
          })
        }

        if (!data) {
          // Si maybeSingle devuelve null, intentar update sin select
          const { error: err2 } = await $supabaseAdmin
            .from('usuarios')
            .update(updateData)
            .eq('id', userIdNum)

          if (err2) {
            throw createError({
              statusCode: 500,
              statusMessage: `Fallback update error: ${err2.message}`
            })
          }

          // Leer el usuario para verificar
          const { data: reread } = await $supabaseAdmin
            .from('usuarios')
            .select('*')
            .eq('id', userIdNum)
            .single()

          updatedUser = reread || { ...currentUser, ...updateData }
        } else {
          updatedUser = data
        }
      } catch (e: any) {
        if (e.statusCode) throw e
        throw createError({
          statusCode: 500,
          statusMessage: `Error en paso UPDATE: ${e.message}`
        })
      }

      // Paso 5: Actualizar Auth metadata (opcional, no debe romper el flujo)
      try {
        const { data: authUsers } = await $supabaseAdmin.auth.admin.listUsers()
        if (authUsers?.users) {
          const authUser = authUsers.users.find((u: any) => u.email === currentUser.correo)
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
      } catch (_authErr) {
        // Auth update es opcional - no romper si falla
        console.error('[PATCH] Error actualizando Auth (no crítico):', _authErr)
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
      statusMessage: `[Server Error] ${err.message || 'Error desconocido'} | stack: ${(err.stack || '').substring(0, 200)}`,
    })
  }
})

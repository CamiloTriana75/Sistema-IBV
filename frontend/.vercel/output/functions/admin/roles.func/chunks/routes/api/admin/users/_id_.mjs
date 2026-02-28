import { d as defineEventHandler, c as createError, a as getMethod, b as getRouterParam, r as readBody, e as useRuntimeConfig } from '../../../../_/nitro.mjs';
import { createClient } from '@supabase/supabase-js';
import 'node:http';
import 'node:https';
import 'node:events';
import 'node:buffer';
import 'node:fs';
import 'node:path';
import 'node:crypto';

const _id_ = defineEventHandler(async (event) => {
  var _a, _b, _c, _d;
  const config = useRuntimeConfig();
  const supabaseUrl = config.supabaseUrl;
  const supabaseServiceKey = config.supabaseServiceKey;
  if (!supabaseUrl || !supabaseServiceKey) {
    console.error("[Admin Users ID] Configuraci\xF3n faltante:", {
      hasUrl: !!supabaseUrl,
      hasKey: !!supabaseServiceKey
    });
    throw createError({
      statusCode: 500,
      statusMessage: "Supabase configuration missing on server. Set NUXT_SUPABASE_URL and NUXT_SUPABASE_SERVICE_KEY in Vercel."
    });
  }
  const $supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
  const method = getMethod(event);
  const userId = getRouterParam(event, "id");
  if (!userId) {
    throw createError({
      statusCode: 400,
      statusMessage: "ID de usuario requerido"
    });
  }
  try {
    if (method === "GET") {
      const { data, error } = await $supabaseAdmin.from("usuarios").select("*").eq("id", userId).single();
      if (error) throw error;
      return { success: true, data };
    }
    if (method === "PATCH") {
      const body = await readBody(event);
      console.log("[PATCH /api/admin/users/:id] Body recibido:", body);
      console.log("[PATCH /api/admin/users/:id] Usuario ID:", userId);
      const { data: currentUser, error: getError } = await $supabaseAdmin.from("usuarios").select("*").eq("id", userId).single();
      if (getError || !currentUser) {
        throw createError({
          statusCode: 404,
          statusMessage: "Usuario no encontrado"
        });
      }
      console.log("[PATCH] Usuario actual:", currentUser);
      const updateData = {
        nombres: (_a = body.nombres) != null ? _a : currentUser.nombres,
        apellidos: (_b = body.apellidos) != null ? _b : currentUser.apellidos,
        rol: (_c = body.rol) != null ? _c : currentUser.rol,
        activo: (_d = body.activo) != null ? _d : currentUser.activo
      };
      console.log("[PATCH] Datos a actualizar:", updateData);
      const { data: updatedUser, error: updateError } = await $supabaseAdmin.from("usuarios").update(updateData).eq("id", userId).select().single();
      if (updateError) {
        console.error("[PATCH] Error actualizando en BD:", updateError);
        throw new Error(`Error actualizando: ${updateError.message}`);
      }
      console.log("[PATCH] Usuario actualizado en BD:", updatedUser);
      const { data: authUsers, error: authGetError } = await $supabaseAdmin.auth.admin.listUsers();
      if (!authGetError) {
        const authUser = authUsers.users.find((u) => u.email === currentUser.correo);
        if (authUser) {
          const nombreCompleto = `${updatedUser.nombres} ${updatedUser.apellidos}`.trim();
          await $supabaseAdmin.auth.admin.updateUserById(authUser.id, {
            user_metadata: {
              nombres: updatedUser.nombres,
              apellidos: updatedUser.apellidos,
              full_name: nombreCompleto,
              display_name: nombreCompleto,
              rol: updatedUser.rol
            }
          });
        }
      }
      return {
        success: true,
        message: "Usuario actualizado",
        user: updatedUser
      };
    }
    if (method === "DELETE") {
      const { data: usuario, error: getError } = await $supabaseAdmin.from("usuarios").select("correo").eq("id", userId).single();
      if (getError) {
        throw createError({
          statusCode: 404,
          statusMessage: "Usuario no encontrado"
        });
      }
      const { data: authUsers, error: authGetError } = await $supabaseAdmin.auth.admin.listUsers();
      if (authGetError) {
        throw new Error("Error consultando Auth");
      }
      const authUser = authUsers.users.find((u) => u.email === usuario.correo);
      if (authUser) {
        const { error: authDeleteError } = await $supabaseAdmin.auth.admin.deleteUser(authUser.id);
        if (authDeleteError) {
          throw new Error(`Error en Auth: ${authDeleteError.message}`);
        }
      }
      const { error: deleteError } = await $supabaseAdmin.from("usuarios").delete().eq("id", userId);
      if (deleteError) {
        throw new Error(`Error en BD: ${deleteError.message}`);
      }
      return {
        success: true,
        message: "Usuario eliminado"
      };
    }
    throw createError({
      statusCode: 405,
      statusMessage: "M\xE9todo no permitido"
    });
  } catch (err) {
    console.error("[Admin Users Dynamic]", err);
    if (err.statusCode) {
      throw err;
    }
    throw createError({
      statusCode: 500,
      statusMessage: err.message || "Error procesando solicitud"
    });
  }
});

export { _id_ as default };
//# sourceMappingURL=_id_.mjs.map

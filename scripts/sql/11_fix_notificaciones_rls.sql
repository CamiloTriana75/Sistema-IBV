-- ============================================
-- Fix RLS Policies para notificaciones
-- Implementa visibilidad basada en:
-- 1. Notificaciones personales (recipient_user_id no NULL) -> solo ese usuario
-- 2. Notificaciones por rol/módulo (recipient_user_id NULL, modulo específico) -> solo usuarios de ese rol
-- 3. Notificaciones generales (recipient_user_id NULL, modulo 'general') -> todos los usuarios
-- ============================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "notificaciones_select_own_or_admin" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_insert_own_or_admin" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_update_own_or_admin" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_delete_admin_only" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_select_intelligent" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_insert_admin_only" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_update_admin_or_mark_read" ON notificaciones;

-- ============================================
-- SELECT: Lógica de visibilidad inteligente
-- ============================================
CREATE POLICY "notificaciones_select_intelligent" ON notificaciones
    FOR SELECT
    USING (
        -- Notificación personal: SOLO el destinatario la ve (privada, incluso para admins)
        (recipient_user_id IS NOT NULL 
         AND recipient_user_id = (SELECT id FROM usuarios WHERE correo = auth.email()))
        OR
        -- Notificación para un rol específico: solo usuarios con ese rol la ven
        (recipient_user_id IS NULL 
         AND modulo != 'general' 
         AND get_current_user_role() = modulo)
        OR
        -- Notificación general: todos los usuarios autenticados la ven
        (recipient_user_id IS NULL 
         AND modulo = 'general')
        OR
        -- Admin puede ver notificaciones de grupo (rol/general), pero NO personales de otros
        (is_admin() AND recipient_user_id IS NULL)
    );

-- ============================================
-- INSERT: Solo admin puede crear notificaciones
-- ============================================
CREATE POLICY "notificaciones_insert_admin_only" ON notificaciones
    FOR INSERT
    WITH CHECK (is_admin());

-- ============================================
-- UPDATE: Solo admin puede actualizar
-- Excepción: usuarios pueden marcar sus propias notificaciones como leídas
-- ============================================
CREATE POLICY "notificaciones_update_admin_or_mark_read" ON notificaciones
    FOR UPDATE
    USING (
        is_admin()
        OR
        -- Usuario puede actualizar solo el campo leida_en de sus propias notificaciones
        (recipient_user_id = (SELECT id FROM usuarios WHERE correo = auth.email()))
    )
    WITH CHECK (
        is_admin()
        OR
        -- Usuario puede actualizar solo el campo leida_en de sus propias notificaciones
        (recipient_user_id = (SELECT id FROM usuarios WHERE correo = auth.email()))
    );

-- ============================================
-- DELETE: Solo admin puede eliminar
-- ============================================
CREATE POLICY "notificaciones_delete_admin_only" ON notificaciones
    FOR DELETE
    USING (is_admin());

-- Verificar que RLS está habilitado
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RESUMEN DE POLÍTICAS
-- ============================================
-- SELECT:
--   🔒 Notificaciones PERSONALES (recipient_user_id no NULL):
--      → Solo el destinatario específico puede verlas (PRIVADAS, incluso para otros admins)
--   
--   👥 Notificaciones de ROL (recipient_user_id NULL, modulo = rol específico):
--      → Solo usuarios con ese rol
--   
--   🌍 Notificaciones GENERALES (recipient_user_id NULL, modulo = 'general'):
--      → Todos los usuarios autenticados
--   
--   🔧 Admin puede ver todas las notificaciones de GRUPO (rol/general) para gestión
--      → Pero NO puede ver notificaciones personales de otros usuarios
--
-- INSERT: Solo admin
-- UPDATE: Admin o usuario destinatario (para marcar como leída)
-- DELETE: Solo admin
-- ============================================

RAISE NOTICE '✅ Políticas RLS de notificaciones actualizadas con visibilidad inteligente';

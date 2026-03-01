-- ============================================
-- FIX: Error 403 al crear notificaciones desde Admin
-- Causa común: rol en usuarios con mayúsculas/espacios (ej: 'Admin')
-- y políticas que comparan contra 'admin' en minúsculas.
-- ============================================

-- 1) Normalizar funciones auxiliares de rol
CREATE OR REPLACE FUNCTION get_current_user_role()
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT LOWER(TRIM(rol)) INTO user_role
    FROM usuarios
    WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email()))
    LIMIT 1;

    RETURN COALESCE(user_role, 'cliente');
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
BEGIN
    RETURN get_current_user_role() = 'admin';
END;
$$ LANGUAGE plpgsql STABLE;

-- 2) Re-crear políticas de notificaciones de forma idempotente
DROP POLICY IF EXISTS "notificaciones_select_own_or_admin" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_insert_own_or_admin" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_update_own_or_admin" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_delete_admin_only" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_select_intelligent" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_insert_admin_only" ON notificaciones;
DROP POLICY IF EXISTS "notificaciones_update_admin_or_mark_read" ON notificaciones;

-- SELECT: visibilidad inteligente
CREATE POLICY "notificaciones_select_intelligent" ON notificaciones
    FOR SELECT
    USING (
        (recipient_user_id IS NOT NULL
         AND recipient_user_id = (SELECT id FROM usuarios WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email())) LIMIT 1))
        OR
        (recipient_user_id IS NULL
         AND modulo != 'general'
         AND LOWER(TRIM(get_current_user_role())) = LOWER(TRIM(modulo)))
        OR
        (recipient_user_id IS NULL
         AND modulo = 'general')
        OR
        (is_admin() AND recipient_user_id IS NULL)
    );

-- INSERT: solo admin
CREATE POLICY "notificaciones_insert_admin_only" ON notificaciones
    FOR INSERT
    WITH CHECK (is_admin());

-- UPDATE: admin o destinatario (marcar leída)
CREATE POLICY "notificaciones_update_admin_or_mark_read" ON notificaciones
    FOR UPDATE
    USING (
        is_admin()
        OR
        (recipient_user_id = (SELECT id FROM usuarios WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email())) LIMIT 1))
    )
    WITH CHECK (
        is_admin()
        OR
        (recipient_user_id = (SELECT id FROM usuarios WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email())) LIMIT 1))
    );

-- DELETE: solo admin
CREATE POLICY "notificaciones_delete_admin_only" ON notificaciones
    FOR DELETE
    USING (is_admin());

ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;

RAISE NOTICE '✅ FIX aplicado: notificaciones admin 403 resuelto (rol case-insensitive)';

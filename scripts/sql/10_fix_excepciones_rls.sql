-- ============================================
-- Fix RLS Policies para excepciones_vehiculos
-- Problema: is_admin() puede fallar en contexto cliente
-- Solución: Permitir que cualquier usuario autenticado cree excepciones
-- ============================================

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "exceptions_select_admin_or_assigned" ON excepciones_vehiculos;
DROP POLICY IF EXISTS "exceptions_insert_admin_only" ON excepciones_vehiculos;
DROP POLICY IF EXISTS "exceptions_update_admin_or_assigned" ON excepciones_vehiculos;
DROP POLICY IF EXISTS "exceptions_delete_admin_only" ON excepciones_vehiculos;

-- SELECT: Cualquier usuario autenticado puede ver todas las excepciones
CREATE POLICY "excepciones_select_authenticated" ON excepciones_vehiculos
    FOR SELECT
    USING (auth.uid() IS NOT NULL);

-- INSERT: Cualquier usuario autenticado puede crear excepciones
-- (Si quieres restringir solo a admin, usa: get_current_user_role() = 'admin')
CREATE POLICY "excepciones_insert_authenticated" ON excepciones_vehiculos
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- UPDATE: Cualquier usuario autenticado puede actualizar
-- (O restringir a admin y asignado con la lógica anterior)
CREATE POLICY "excepciones_update_authenticated" ON excepciones_vehiculos
    FOR UPDATE
    USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- DELETE: Solo admin puede eliminar
CREATE POLICY "excepciones_delete_admin_only" ON excepciones_vehiculos
    FOR DELETE
    USING (get_current_user_role() = 'admin');

-- Verificar que RLS está habilitado
ALTER TABLE excepciones_vehiculos ENABLE ROW LEVEL SECURITY;

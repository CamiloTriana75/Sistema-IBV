-- ============================================
-- SISTEMA IBV - RLS (ROW LEVEL SECURITY) POLICIES
-- Políticas de seguridad por rol
-- ============================================

BEGIN;

-- ============================================
-- 1. DISABLE ALL RLS (LIMPIEZA)
-- ============================================

-- Eliminar todas las políticas existentes
DROP POLICY IF EXISTS "admin_all" ON roles;
DROP POLICY IF EXISTS "admin_all" ON usuarios;
DROP POLICY IF EXISTS "admin_all" ON buques;
DROP POLICY IF EXISTS "admin_all" ON modelos_vehiculo;
DROP POLICY IF EXISTS "admin_all" ON vehiculos;
DROP POLICY IF EXISTS "admin_all" ON improntas;
DROP POLICY IF EXISTS "admin_all" ON inventarios;
DROP POLICY IF EXISTS "admin_all" ON despachos;
DROP POLICY IF EXISTS "admin_all" ON despacho_vehiculos;
DROP POLICY IF EXISTS "admin_all" ON movimientos_porteria;
DROP POLICY IF EXISTS "admin_all" ON recibos;

-- Deshabilitar RLS temporalmente para limpiar
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE buques DISABLE ROW LEVEL SECURITY;
ALTER TABLE modelos_vehiculo DISABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculos DISABLE ROW LEVEL SECURITY;
ALTER TABLE improntas DISABLE ROW LEVEL SECURITY;
ALTER TABLE inventarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE despachos DISABLE ROW LEVEL SECURITY;
ALTER TABLE despacho_vehiculos DISABLE ROW LEVEL SECURITY;
ALTER TABLE movimientos_porteria DISABLE ROW LEVEL SECURITY;
ALTER TABLE recibos DISABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. UTILITY FUNCTION - Get current user role
-- ============================================

CREATE OR REPLACE FUNCTION get_current_user_role() 
RETURNS TEXT
SECURITY DEFINER
AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT rol INTO user_role 
    FROM usuarios 
    WHERE correo = auth.email()
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

-- ============================================
-- 3. ROLES TABLE - Only admins can modify
-- ============================================

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "roles_select_all" ON roles
    FOR SELECT
    USING (TRUE);

CREATE POLICY "roles_insert_admin_only" ON roles
    FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "roles_update_admin_only" ON roles
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "roles_delete_admin_only" ON roles
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 4. USUARIOS TABLE - Users see themselves, admins see all
-- ============================================

ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "usuarios_select_own_or_admin" ON usuarios
    FOR SELECT
    USING (
        correo = auth.email() OR is_admin()
    );

CREATE POLICY "usuarios_update_own_or_admin" ON usuarios
    FOR UPDATE
    USING (
        correo = auth.email() OR is_admin()
    )
    WITH CHECK (
        correo = auth.email() OR is_admin()
    );

CREATE POLICY "usuarios_insert_admin_only" ON usuarios
    FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "usuarios_delete_admin_only" ON usuarios
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 5. BUQUES TABLE - All users can read, only admin modify
-- ============================================

ALTER TABLE buques ENABLE ROW LEVEL SECURITY;

CREATE POLICY "buques_select_all" ON buques
    FOR SELECT
    USING (TRUE);

CREATE POLICY "buques_insert_admin_only" ON buques
    FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "buques_update_admin_only" ON buques
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "buques_delete_admin_only" ON buques
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 6. MODELOS_VEHICULO TABLE - All can read, admin modify
-- ============================================

ALTER TABLE modelos_vehiculo ENABLE ROW LEVEL SECURITY;

CREATE POLICY "modelos_select_all" ON modelos_vehiculo
    FOR SELECT
    USING (TRUE);

CREATE POLICY "modelos_insert_admin_only" ON modelos_vehiculo
    FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "modelos_update_admin_only" ON modelos_vehiculo
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "modelos_delete_admin_only" ON modelos_vehiculo
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 7. VEHICULOS TABLE - Complex access control
-- ============================================

ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;

-- Admin: ver todo
CREATE POLICY "vehiculos_select_admin" ON vehiculos
    FOR SELECT
    USING (is_admin());

-- Recibidor: ver todo (es quien recibe los vehículos)
CREATE POLICY "vehiculos_select_recibidor" ON vehiculos
    FOR SELECT
    USING (
        get_current_user_role() = 'recibidor' OR
        get_current_user_role() = 'inventario' OR
        get_current_user_role() = 'despachador'
    );

-- Recibidor: crear vehículos (recepción)
CREATE POLICY "vehiculos_insert_recibidor" ON vehiculos
    FOR INSERT
    WITH CHECK (
        get_current_user_role() = 'recibidor' AND
        usuario_recibe_id = (SELECT id FROM usuarios WHERE correo = auth.email())
    );

-- Inventario: actualizar vehículos en inventario
CREATE POLICY "vehiculos_update_inventario" ON vehiculos
    FOR UPDATE
    USING (
        get_current_user_role() = 'inventario' AND
        estado IN ('en_inventario', 'en_impronta')
    )
    WITH CHECK (
        get_current_user_role() = 'inventario' AND
        estado IN ('en_inventario', 'en_impronta', 'listo_despacho', 'problema')
    );

-- Despachador: actualizar vehículos listos para despacho
CREATE POLICY "vehiculos_update_despachador" ON vehiculos
    FOR UPDATE
    USING (
        get_current_user_role() = 'despachador' AND
        estado IN ('listo_despacho', 'despachado')
    )
    WITH CHECK (
        get_current_user_role() = 'despachador' AND
        estado IN ('listo_despacho', 'despachado')
    );

-- Admin: acceso total
CREATE POLICY "vehiculos_insert_admin" ON vehiculos
    FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "vehiculos_update_admin" ON vehiculos
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "vehiculos_delete_admin" ON vehiculos
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 8. IMPRONTAS TABLE - Recibidor creates, others read
-- ============================================

ALTER TABLE improntas ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, recibidor, inventario
CREATE POLICY "improntas_select_allowed_roles" ON improntas
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario')
    );

-- Creación: solo recibidor
CREATE POLICY "improntas_insert_recibidor" ON improntas
    FOR INSERT
    WITH CHECK (
        get_current_user_role() = 'recibidor' AND
        usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email())
    );

-- Actualización: admin solo
CREATE POLICY "improntas_update_admin" ON improntas
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "improntas_delete_admin" ON improntas
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 9. INVENTARIOS TABLE - Inventario role manages
-- ============================================

ALTER TABLE inventarios ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, inventario, despachador
CREATE POLICY "inventarios_select_allowed_roles" ON inventarios
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('inventario', 'despachador')
    );

-- Creación: inventario
CREATE POLICY "inventarios_insert_inventario" ON inventarios
    FOR INSERT
    WITH CHECK (
        get_current_user_role() = 'inventario' AND
        usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email())
    );

-- Actualización: inventario
CREATE POLICY "inventarios_update_inventario" ON inventarios
    FOR UPDATE
    USING (
        is_admin() OR
        (get_current_user_role() = 'inventario' AND usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email()))
    )
    WITH CHECK (
        is_admin() OR
        get_current_user_role() = 'inventario'
    );

CREATE POLICY "inventarios_delete_admin" ON inventarios
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 10. DESPACHOS TABLE - Despachador manages
-- ============================================

ALTER TABLE despachos ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, despachador, porteria
CREATE POLICY "despachos_select_allowed_roles" ON despachos
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('despachador', 'porteria')
    );

-- Creación: despachador
CREATE POLICY "despachos_insert_despachador" ON despachos
    FOR INSERT
    WITH CHECK (
        get_current_user_role() = 'despachador' AND
        usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email())
    );

-- Actualización: despachador o admin
CREATE POLICY "despachos_update_allowed" ON despachos
    FOR UPDATE
    USING (
        is_admin() OR
        (get_current_user_role() = 'despachador' AND usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email()))
    )
    WITH CHECK (
        is_admin() OR
        get_current_user_role() = 'despachador'
    );

CREATE POLICY "despachos_delete_admin" ON despachos
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 11. DESPACHO_VEHICULOS TABLE - Link table
-- ============================================

ALTER TABLE despacho_vehiculos ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, despachador
CREATE POLICY "despacho_vehiculos_select_allowed" ON despacho_vehiculos
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() = 'despachador'
    );

-- Creación: despachador
CREATE POLICY "despacho_vehiculos_insert_despachador" ON despacho_vehiculos
    FOR INSERT
    WITH CHECK (
        get_current_user_role() = 'despachador' OR is_admin()
    );

-- Actualización: despachador
CREATE POLICY "despacho_vehiculos_update_allowed" ON despacho_vehiculos
    FOR UPDATE
    USING (
        is_admin() OR
        get_current_user_role() = 'despachador'
    )
    WITH CHECK (
        is_admin() OR
        get_current_user_role() = 'despachador'
    );

CREATE POLICY "despacho_vehiculos_delete_admin" ON despacho_vehiculos
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 12. MOVIMIENTOS_PORTERIA TABLE - Porteria manages
-- ============================================

ALTER TABLE movimientos_porteria ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, porteria, despachador
CREATE POLICY "movimientos_select_allowed" ON movimientos_porteria
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('porteria', 'despachador')
    );

-- Creación: porteria
CREATE POLICY "movimientos_insert_porteria" ON movimientos_porteria
    FOR INSERT
    WITH CHECK (
        get_current_user_role() = 'porteria' AND
        usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email())
    );

-- Actualización: porteria o admin
CREATE POLICY "movimientos_update_allowed" ON movimientos_porteria
    FOR UPDATE
    USING (
        is_admin() OR
        (get_current_user_role() = 'porteria' AND usuario_id = (SELECT id FROM usuarios WHERE correo = auth.email()))
    )
    WITH CHECK (
        is_admin() OR
        get_current_user_role() = 'porteria'
    );

CREATE POLICY "movimientos_delete_admin" ON movimientos_porteria
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 13. RECIBOS TABLE - Recibidor reads, admin manages
-- ============================================

ALTER TABLE recibos ENABLE ROW LEVEL SECURITY;

-- Lectura: admin, recibidor
CREATE POLICY "recibos_select_allowed" ON recibos
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'despachador')
    );

-- Creación: admin
CREATE POLICY "recibos_insert_admin" ON recibos
    FOR INSERT
    WITH CHECK (is_admin());

-- Actualización: admin
CREATE POLICY "recibos_update_admin" ON recibos
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "recibos_delete_admin" ON recibos
    FOR DELETE
    USING (is_admin());

COMMIT;

-- ============================================
-- DONE - RLS Policies applied
-- ============================================

DO $$
BEGIN
    RAISE NOTICE 'RLS Policies configured successfully!';
END $$;

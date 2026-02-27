-- ============================================
-- AGREGAR POLÍTICAS RLS FALTANTES
-- Políticas para: contenedores, contenedor_vehiculos, improntas_registro
-- ============================================

BEGIN;

-- ============================================
-- 1. LIMPIAR POLÍTICAS EXISTENTES
-- ============================================

DROP POLICY IF EXISTS "contenedores_select_all" ON contenedores;
DROP POLICY IF EXISTS "contenedores_insert_admin_or_recibidor" ON contenedores;
DROP POLICY IF EXISTS "contenedores_update_admin_or_roles" ON contenedores;
DROP POLICY IF EXISTS "contenedores_delete_admin" ON contenedores;

DROP POLICY IF EXISTS "contenedor_vehiculos_select_all" ON contenedor_vehiculos;
DROP POLICY IF EXISTS "contenedor_vehiculos_insert_recibidor" ON contenedor_vehiculos;
DROP POLICY IF EXISTS "contenedor_vehiculos_update_admin" ON contenedor_vehiculos;
DROP POLICY IF EXISTS "contenedor_vehiculos_delete_admin" ON contenedor_vehiculos;

DROP POLICY IF EXISTS "improntas_registro_select_allowed" ON improntas_registro;
DROP POLICY IF EXISTS "improntas_registro_insert_recibidor" ON improntas_registro;
DROP POLICY IF EXISTS "improntas_registro_update_admin" ON improntas_registro;
DROP POLICY IF EXISTS "improntas_registro_delete_admin" ON improntas_registro;

-- ============================================
-- 2. DESHABILITAR Y HABILITAR RLS
-- ============================================

ALTER TABLE contenedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE contenedor_vehiculos DISABLE ROW LEVEL SECURITY;
ALTER TABLE improntas_registro DISABLE ROW LEVEL SECURITY;

ALTER TABLE contenedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE contenedor_vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE improntas_registro ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. CONTENEDORES TABLE - Admin and relevant roles
-- ============================================

CREATE POLICY "contenedores_select_all" ON contenedores
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario', 'despachador')
    );

CREATE POLICY "contenedores_insert_admin_or_recibidor" ON contenedores
    FOR INSERT
    WITH CHECK (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario')
    );

CREATE POLICY "contenedores_update_admin_or_roles" ON contenedores
    FOR UPDATE
    USING (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario', 'despachador')
    )
    WITH CHECK (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario', 'despachador')
    );

CREATE POLICY "contenedores_delete_admin" ON contenedores
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 4. CONTENEDOR_VEHICULOS TABLE - Link table
-- ============================================

CREATE POLICY "contenedor_vehiculos_select_all" ON contenedor_vehiculos
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario', 'despachador')
    );

CREATE POLICY "contenedor_vehiculos_insert_recibidor" ON contenedor_vehiculos
    FOR INSERT
    WITH CHECK (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario')
    );

CREATE POLICY "contenedor_vehiculos_update_admin" ON contenedor_vehiculos
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "contenedor_vehiculos_delete_admin" ON contenedor_vehiculos
    FOR DELETE
    USING (is_admin());

-- ============================================
-- 5. IMPRONTAS_REGISTRO TABLE - Recibidor creates and reads
-- ============================================

CREATE POLICY "improntas_registro_select_allowed" ON improntas_registro
    FOR SELECT
    USING (
        is_admin() OR
        get_current_user_role() IN ('recibidor', 'inventario')
    );

CREATE POLICY "improntas_registro_insert_recibidor" ON improntas_registro
    FOR INSERT
    WITH CHECK (
        is_admin() OR
        get_current_user_role() = 'recibidor'
    );

CREATE POLICY "improntas_registro_update_admin" ON improntas_registro
    FOR UPDATE
    USING (is_admin())
    WITH CHECK (is_admin());

CREATE POLICY "improntas_registro_delete_admin" ON improntas_registro
    FOR DELETE
    USING (is_admin());

COMMIT;

-- ============================================
-- DONE
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Políticas RLS aplicadas correctamente!';
    RAISE NOTICE '   • contenedores: 4 políticas';
    RAISE NOTICE '   • contenedor_vehiculos: 4 políticas';
    RAISE NOTICE '   • improntas_registro: 4 políticas';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Total: 12 políticas RLS agregadas';
END $$;

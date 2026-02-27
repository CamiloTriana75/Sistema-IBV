-- ============================================
-- APLICAR POLÍTICAS RLS COMPLETAS
-- Incluye funciones auxiliares + todas las políticas
-- ============================================

BEGIN;

-- ============================================
-- 1. CREAR/RECREAR FUNCIONES AUXILIARES
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
-- 2. LIMPIAR POLÍTICAS EXISTENTES DE LAS 3 TABLAS
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
-- 3. HABILITAR RLS EN LAS 3 TABLAS
-- ============================================

ALTER TABLE contenedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE contenedor_vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE improntas_registro ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. POLÍTICAS PARA CONTENEDORES
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
-- 5. POLÍTICAS PARA CONTENEDOR_VEHICULOS
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
-- 6. POLÍTICAS PARA IMPRONTAS_REGISTRO
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
-- VERIFICACIÓN
-- ============================================

DO $$
DECLARE
    contenedores_count INTEGER;
    contenedor_vehiculos_count INTEGER;
    improntas_registro_count INTEGER;
BEGIN
    -- Contar políticas de contenedores
    SELECT COUNT(*) INTO contenedores_count
    FROM pg_policies
    WHERE tablename = 'contenedores';
    
    -- Contar políticas de contenedor_vehiculos
    SELECT COUNT(*) INTO contenedor_vehiculos_count
    FROM pg_policies
    WHERE tablename = 'contenedor_vehiculos';
    
    -- Contar políticas de improntas_registro
    SELECT COUNT(*) INTO improntas_registro_count
    FROM pg_policies
    WHERE tablename = 'improntas_registro';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ POLÍTICAS RLS APLICADAS EXITOSAMENTE';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Políticas por tabla:';
    RAISE NOTICE '   • contenedores: % políticas', contenedores_count;
    RAISE NOTICE '   • contenedor_vehiculos: % políticas', contenedor_vehiculos_count;
    RAISE NOTICE '   • improntas_registro: % políticas', improntas_registro_count;
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Funciones auxiliares:';
    RAISE NOTICE '   • get_current_user_role() ✓';
    RAISE NOTICE '   • is_admin() ✓';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 RLS habilitado en las 3 tablas';
    RAISE NOTICE '';
    
    -- Verificar que todas tengan 4 políticas
    IF contenedores_count = 4 AND contenedor_vehiculos_count = 4 AND improntas_registro_count = 4 THEN
        RAISE NOTICE '✅ TODO CORRECTO - 12 políticas totales';
    ELSE
        RAISE WARNING '⚠️  Cantidad de políticas incorrecta';
    END IF;
END $$;

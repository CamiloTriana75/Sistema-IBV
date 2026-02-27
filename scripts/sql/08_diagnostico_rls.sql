-- ============================================
-- DIAGNÓSTICO DE POLÍTICAS RLS
-- Verifica el estado actual de las políticas
-- ============================================

DO $$
DECLARE
    func_count INTEGER;
    policy_record RECORD;
    rls_enabled BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '🔍 DIAGNÓSTICO DE POLÍTICAS RLS';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
    -- 1. Verificar funciones auxiliares
    RAISE NOTICE '1️⃣ VERIFICANDO FUNCIONES AUXILIARES:';
    RAISE NOTICE '----------------------------------------';
    
    SELECT COUNT(*) INTO func_count
    FROM pg_proc
    WHERE proname = 'get_current_user_role';
    
    IF func_count > 0 THEN
        RAISE NOTICE '   ✅ get_current_user_role() existe';
    ELSE
        RAISE NOTICE '   ❌ get_current_user_role() NO EXISTE';
    END IF;
    
    SELECT COUNT(*) INTO func_count
    FROM pg_proc
    WHERE proname = 'is_admin';
    
    IF func_count > 0 THEN
        RAISE NOTICE '   ✅ is_admin() existe';
    ELSE
        RAISE NOTICE '   ❌ is_admin() NO EXISTE';
    END IF;
    
    RAISE NOTICE '';
    
    -- 2. Verificar RLS habilitado
    RAISE NOTICE '2️⃣ VERIFICANDO RLS HABILITADO:';
    RAISE NOTICE '----------------------------------------';
    
    SELECT relrowsecurity INTO rls_enabled
    FROM pg_class
    WHERE relname = 'contenedores';
    
    IF rls_enabled THEN
        RAISE NOTICE '   ✅ contenedores: RLS HABILITADO';
    ELSE
        RAISE NOTICE '   ❌ contenedores: RLS DESHABILITADO';
    END IF;
    
    SELECT relrowsecurity INTO rls_enabled
    FROM pg_class
    WHERE relname = 'contenedor_vehiculos';
    
    IF rls_enabled THEN
        RAISE NOTICE '   ✅ contenedor_vehiculos: RLS HABILITADO';
    ELSE
        RAISE NOTICE '   ❌ contenedor_vehiculos: RLS DESHABILITADO';
    END IF;
    
    SELECT relrowsecurity INTO rls_enabled
    FROM pg_class
    WHERE relname = 'improntas_registro';
    
    IF rls_enabled THEN
        RAISE NOTICE '   ✅ improntas_registro: RLS HABILITADO';
    ELSE
        RAISE NOTICE '   ❌ improntas_registro: RLS DESHABILITADO';
    END IF;
    
    RAISE NOTICE '';
    
    -- 3. Listar políticas de contenedores
    RAISE NOTICE '3️⃣ POLÍTICAS DE CONTENEDORES:';
    RAISE NOTICE '----------------------------------------';
    
    FOR policy_record IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'contenedores'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '   ✓ % (%)', policy_record.policyname, policy_record.cmd;
    END LOOP;
    
    IF NOT FOUND THEN
        RAISE NOTICE '   ❌ NO HAY POLÍTICAS';
    END IF;
    
    RAISE NOTICE '';
    
    -- 4. Listar políticas de contenedor_vehiculos
    RAISE NOTICE '4️⃣ POLÍTICAS DE CONTENEDOR_VEHICULOS:';
    RAISE NOTICE '----------------------------------------';
    
    FOR policy_record IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'contenedor_vehiculos'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '   ✓ % (%)', policy_record.policyname, policy_record.cmd;
    END LOOP;
    
    IF NOT FOUND THEN
        RAISE NOTICE '   ❌ NO HAY POLÍTICAS';
    END IF;
    
    RAISE NOTICE '';
    
    -- 5. Listar políticas de improntas_registro
    RAISE NOTICE '5️⃣ POLÍTICAS DE IMPRONTAS_REGISTRO:';
    RAISE NOTICE '----------------------------------------';
    
    FOR policy_record IN
        SELECT policyname, cmd
        FROM pg_policies
        WHERE tablename = 'improntas_registro'
        ORDER BY policyname
    LOOP
        RAISE NOTICE '   ✓ % (%)', policy_record.policyname, policy_record.cmd;
    END LOOP;
    
    IF NOT FOUND THEN
        RAISE NOTICE '   ❌ NO HAY POLÍTICAS';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '🎯 FIN DEL DIAGNÓSTICO';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    
END $$;

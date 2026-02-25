-- ============================================
-- SCRIPT PARA DESHABILITAR RLS
-- Sistema IBV - Disable Row Level Security
-- ============================================
--
-- PROPÓSITO:
--   Deshabilitar Row Level Security en todas las tablas
--   Ya que Django maneja la autenticación y autorización
--
-- CUÁNDO EJECUTAR:
--   - Si en la verificación se detectaron tablas con RLS habilitado
--   - Después de las migraciones de Django
--
-- DÓNDE EJECUTAR:
--   Supabase Dashboard > SQL Editor > New Query
--
-- VERSIÓN: 1.0.0
-- FECHA: 2026-02-24
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  DESHABILITAR ROW LEVEL SECURITY                      ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

-- ============================================
-- DESHABILITAR RLS EN TODAS LAS TABLAS
-- ============================================

DO $$
DECLARE
    r RECORD;
    table_count INTEGER := 0;
    disabled_count INTEGER := 0;
BEGIN
    RAISE NOTICE 'Procesando tablas...';
    RAISE NOTICE '';

    FOR r IN (
        SELECT schemaname, tablename, rowsecurity
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    )
    LOOP
        table_count := table_count + 1;

        IF r.rowsecurity THEN
            -- Deshabilitar RLS
            EXECUTE format('ALTER TABLE %I.%I DISABLE ROW LEVEL SECURITY',
                          r.schemaname, r.tablename);
            RAISE NOTICE '✅ % - RLS deshabilitado', r.tablename;
            disabled_count := disabled_count + 1;
        ELSE
            RAISE NOTICE '  % - Ya estaba deshabilitado', r.tablename;
        END IF;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'Total de tablas procesadas: %', table_count;
    RAISE NOTICE 'Tablas con RLS deshabilitado: %', disabled_count;
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';

    IF disabled_count > 0 THEN
        RAISE NOTICE '✅ RLS deshabilitado en % tablas', disabled_count;
    ELSE
        RAISE NOTICE 'ℹ️  No había tablas con RLS habilitado';
    END IF;
END $$;

-- ============================================
-- ELIMINAR POLÍTICAS RLS EXISTENTES
-- ============================================

DO $$
DECLARE
    r RECORD;
    policy_count INTEGER := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Eliminando políticas RLS...';
    RAISE NOTICE '';

    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
        ORDER BY tablename, policyname
    )
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I',
                      r.policyname, r.schemaname, r.tablename);
        RAISE NOTICE '✅ Política eliminada: %.%', r.tablename, r.policyname;
        policy_count := policy_count + 1;
    END LOOP;

    RAISE NOTICE '';
    IF policy_count > 0 THEN
        RAISE NOTICE '✅ % políticas eliminadas', policy_count;
    ELSE
        RAISE NOTICE 'ℹ️  No había políticas RLS';
    END IF;
END $$;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

DO $$
DECLARE
    tables_with_rls INTEGER;
    total_policies INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'VERIFICACIÓN FINAL';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';

    -- Contar tablas con RLS
    SELECT COUNT(*) INTO tables_with_rls
    FROM pg_tables
    WHERE schemaname = 'public' AND rowsecurity = true;

    -- Contar políticas
    SELECT COUNT(*) INTO total_policies
    FROM pg_policies
    WHERE schemaname = 'public';

    IF tables_with_rls = 0 THEN
        RAISE NOTICE '✅ Ninguna tabla tiene RLS habilitado';
    ELSE
        RAISE WARNING '⚠️  Aún hay % tablas con RLS habilitado', tables_with_rls;
    END IF;

    IF total_policies = 0 THEN
        RAISE NOTICE '✅ No hay políticas RLS activas';
    ELSE
        RAISE WARNING '⚠️  Aún hay % políticas RLS', total_policies;
    END IF;

    RAISE NOTICE '';

    IF tables_with_rls = 0 AND total_policies = 0 THEN
        RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
        RAISE NOTICE '║  ✅ RLS COMPLETAMENTE DESHABILITADO                   ║';
        RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    ELSE
        RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
        RAISE NOTICE '║  ⚠️  REVISAR CONFIGURACIÓN                            ║';
        RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    END IF;

    RAISE NOTICE '';
END $$;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

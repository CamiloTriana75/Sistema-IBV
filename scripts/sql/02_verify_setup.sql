-- ============================================
-- SCRIPT DE VERIFICACIÓN - SUPABASE
-- Sistema IBV - PostgreSQL Verification
-- ============================================
--
-- PROPÓSITO:
--   Verificar que la configuración inicial y las migraciones
--   de Django se ejecutaron correctamente
--
-- CUÁNDO EJECUTAR:
--   Después de ejecutar:
--   1. 01_initial_setup.sql
--   2. python manage.py migrate
--
-- DÓNDE EJECUTAR:
--   Supabase Dashboard > SQL Editor > New Query
--
-- VERSIÓN: 1.0.0
-- FECHA: 2026-02-24
-- ============================================

-- ============================================
-- 1. BANNER
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  VERIFICACIÓN DE CONFIGURACIÓN - SISTEMA IBV          ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE 'Iniciando verificación...';
    RAISE NOTICE '';
END $$;

-- ============================================
-- 2. INFORMACIÓN DEL SISTEMA
-- ============================================

RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '📊 INFORMACIÓN DEL SISTEMA';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
BEGIN
    RAISE NOTICE 'Database: %', current_database();
    RAISE NOTICE 'Usuario: %', current_user;
    RAISE NOTICE 'Schema: public';
    RAISE NOTICE 'Timezone: %', current_setting('timezone');
    RAISE NOTICE 'Hora actual: %', NOW();
    RAISE NOTICE 'Versión PostgreSQL: %', split_part(version(), ' ', 2);
END $$;

-- ============================================
-- 3. VERIFICAR EXTENSIONES
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '📦 EXTENSIONES INSTALADAS';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    ext_record RECORD;
    expected_extensions TEXT[] := ARRAY['uuid-ossp', 'pgcrypto', 'pg_trgm'];
    found_count INTEGER := 0;
BEGIN
    FOR ext_record IN
        SELECT extname, extversion
        FROM pg_extension
        WHERE extname = ANY(expected_extensions)
        ORDER BY extname
    LOOP
        RAISE NOTICE '✅ % (versión: %)', ext_record.extname, ext_record.extversion;
        found_count := found_count + 1;
    END LOOP;

    IF found_count = array_length(expected_extensions, 1) THEN
        RAISE NOTICE '';
        RAISE NOTICE '✅ Todas las extensiones requeridas están instaladas';
    ELSE
        RAISE WARNING '⚠️  Faltan % extensiones',
                      array_length(expected_extensions, 1) - found_count;
    END IF;
END $$;

-- ============================================
-- 4. VERIFICAR TABLAS DE DJANGO
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '📋 TABLAS DE DJANGO';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    table_record RECORD;
    total_tables INTEGER;
    django_tables TEXT[] := ARRAY[
        'django_migrations',
        'django_content_type',
        'django_session',
        'auth_permission',
        'auth_group',
        'auth_group_permissions',
        'usuarios',
        'usuarios_grupos',
        'usuarios_permisos'
    ];
    found_tables INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_tables
    FROM pg_tables
    WHERE schemaname = 'public';

    RAISE NOTICE 'Total de tablas en schema public: %', total_tables;
    RAISE NOTICE '';

    IF total_tables = 0 THEN
        RAISE WARNING '⚠️  No hay tablas creadas. Ejecuta: python manage.py migrate';
    ELSE
        RAISE NOTICE 'Verificando tablas core de Django:';

        FOR table_record IN
            SELECT t.tablename,
                   pg_size_pretty(pg_total_relation_size(quote_ident(t.tablename))) as size
            FROM pg_tables t
            WHERE t.schemaname = 'public'
              AND t.tablename = ANY(django_tables)
            ORDER BY t.tablename
        LOOP
            RAISE NOTICE '  ✅ % (tamaño: %)', table_record.tablename, table_record.size;
            found_tables := found_tables + 1;
        END LOOP;

        RAISE NOTICE '';
        IF found_tables >= 5 THEN
            RAISE NOTICE '✅ Tablas core de Django encontradas';
        ELSE
            RAISE WARNING '⚠️  Algunas tablas de Django no se encontraron';
        END IF;
    END IF;
END $$;

-- ============================================
-- 5. VERIFICAR TABLAS DEL SISTEMA IBV
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '🚗 TABLAS DEL SISTEMA IBV';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    table_record RECORD;
    ibv_table_count INTEGER := 0;
BEGIN
    -- Listar todas las tablas que no son de Django
    FOR table_record IN
        SELECT
            t.tablename,
            pg_size_pretty(pg_total_relation_size(quote_ident(t.tablename))) as size,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = 'public'
               AND table_name = t.tablename) as column_count
        FROM pg_tables t
        WHERE t.schemaname = 'public'
          AND t.tablename NOT LIKE 'django_%'
          AND t.tablename NOT LIKE 'auth_%'
          AND t.tablename != 'audit_log'
        ORDER BY t.tablename
    LOOP
        RAISE NOTICE '  ✅ % (% columnas, tamaño: %)',
                     table_record.tablename,
                     table_record.column_count,
                     table_record.size;
        ibv_table_count := ibv_table_count + 1;
    END LOOP;

    RAISE NOTICE '';
    IF ibv_table_count > 0 THEN
        RAISE NOTICE '✅ % tablas del Sistema IBV encontradas', ibv_table_count;
    ELSE
        RAISE WARNING '⚠️  No se encontraron tablas específicas del Sistema IBV';
        RAISE NOTICE 'ℹ️  Esto es normal si aún no se han creado las apps';
    END IF;
END $$;

-- ============================================
-- 6. VERIFICAR ÍNDICES
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '📇 ÍNDICES';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    idx_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO idx_count
    FROM pg_indexes
    WHERE schemaname = 'public';

    RAISE NOTICE 'Total de índices: %', idx_count;

    IF idx_count > 0 THEN
        RAISE NOTICE '✅ Índices creados correctamente';
    ELSE
        RAISE WARNING '⚠️  No hay índices (revisar migraciones)';
    END IF;
END $$;

-- ============================================
-- 7. VERIFICAR ROW LEVEL SECURITY
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '🛡️  ROW LEVEL SECURITY (RLS)';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    table_record RECORD;
    rls_enabled_count INTEGER := 0;
    total_tables INTEGER := 0;
BEGIN
    FOR table_record IN
        SELECT tablename, rowsecurity
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    LOOP
        total_tables := total_tables + 1;

        IF table_record.rowsecurity THEN
            RAISE NOTICE '  ⚠️  % - RLS HABILITADO', table_record.tablename;
            rls_enabled_count := rls_enabled_count + 1;
        ELSE
            RAISE NOTICE '  ✅ % - RLS deshabilitado', table_record.tablename;
        END IF;
    END LOOP;

    RAISE NOTICE '';
    IF rls_enabled_count = 0 THEN
        RAISE NOTICE '✅ RLS deshabilitado en todas las tablas (configuración correcta)';
    ELSE
        RAISE WARNING '⚠️  RLS habilitado en % tablas', rls_enabled_count;
        RAISE NOTICE 'ℹ️  Para deshabilitar, ejecuta: scripts/sql/03_disable_rls.sql';
    END IF;
END $$;

-- ============================================
-- 8. VERIFICAR POLÍTICAS RLS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '📜 POLÍTICAS RLS';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    policy_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies
    WHERE schemaname = 'public';

    IF policy_count = 0 THEN
        RAISE NOTICE '✅ No hay políticas RLS (configuración correcta para Django)';
    ELSE
        RAISE WARNING '⚠️  Hay % políticas RLS activas', policy_count;
        RAISE NOTICE 'ℹ️  Lista de políticas:';

        PERFORM
        FROM pg_policies
        WHERE schemaname = 'public';

        -- Mostrar políticas
        FOR r IN
            SELECT tablename, policyname, cmd
            FROM pg_policies
            WHERE schemaname = 'public'
            ORDER BY tablename, policyname
        LOOP
            RAISE NOTICE '  - %.% (%)', r.tablename, r.policyname, r.cmd;
        END LOOP;
    END IF;
END $$;

-- ============================================
-- 9. VERIFICAR PERMISOS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '🔐 PERMISOS';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    can_create BOOLEAN;
    can_usage BOOLEAN;
BEGIN
    -- Verificar permisos en schema
    SELECT has_schema_privilege('postgres', 'public', 'CREATE') INTO can_create;
    SELECT has_schema_privilege('postgres', 'public', 'USAGE') INTO can_usage;

    IF can_create THEN
        RAISE NOTICE '✅ postgres puede CREAR objetos en schema public';
    ELSE
        RAISE WARNING '⚠️  postgres NO puede crear objetos';
    END IF;

    IF can_usage THEN
        RAISE NOTICE '✅ postgres puede USAR schema public';
    ELSE
        RAISE WARNING '⚠️  postgres NO puede usar schema';
    END IF;
END $$;

-- ============================================
-- 10. VERIFICAR FUNCIONES DE UTILIDAD
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '⚙️  FUNCIONES DE UTILIDAD';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    func_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO func_count
    FROM pg_proc
    WHERE pronamespace = 'public'::regnamespace
      AND proname IN ('update_updated_at_column', 'generate_unique_slug');

    IF func_count >= 2 THEN
        RAISE NOTICE '✅ Funciones de utilidad encontradas';
        RAISE NOTICE '  - update_updated_at_column()';
        RAISE NOTICE '  - generate_unique_slug()';
    ELSE
        RAISE WARNING '⚠️  Faltan funciones de utilidad';
        RAISE NOTICE 'ℹ️  Ejecuta: scripts/sql/01_initial_setup.sql';
    END IF;
END $$;

-- ============================================
-- 11. VERIFICAR DATOS DE USUARIOS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '👥 DATOS DE USUARIOS';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    user_count INTEGER;
    superuser_count INTEGER;
BEGIN
    -- Verificar si existe la tabla usuarios
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'usuarios') THEN
        EXECUTE 'SELECT COUNT(*) FROM usuarios' INTO user_count;
        EXECUTE 'SELECT COUNT(*) FROM usuarios WHERE es_superusuario = true' INTO superuser_count;

        RAISE NOTICE 'Total de usuarios: %', user_count;
        RAISE NOTICE 'Superusuarios: %', superuser_count;

        IF user_count > 0 THEN
            RAISE NOTICE '✅ Hay usuarios en el sistema';
        ELSE
            RAISE WARNING '⚠️  No hay usuarios creados';
            RAISE NOTICE 'ℹ️  Ejecuta: python manage.py createsuperuser';
        END IF;

        IF superuser_count = 0 THEN
            RAISE WARNING '⚠️  No hay superusuarios';
        END IF;
    ELSE
        RAISE WARNING '⚠️  Tabla usuarios no existe';
        RAISE NOTICE 'ℹ️  Ejecuta: python manage.py migrate';
    END IF;
END $$;

-- ============================================
-- 12. ESTADÍSTICAS DE BASE DE DATOS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
RAISE NOTICE '📊 ESTADÍSTICAS';
RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

DO $$
DECLARE
    db_size TEXT;
    table_count INTEGER;
    seq_count INTEGER;
    idx_count INTEGER;
BEGIN
    -- Tamaño de la base de datos
    SELECT pg_size_pretty(pg_database_size(current_database())) INTO db_size;

    -- Contar objetos
    SELECT COUNT(*) INTO table_count FROM pg_tables WHERE schemaname = 'public';
    SELECT COUNT(*) INTO seq_count FROM pg_sequences WHERE schemaname = 'public';
    SELECT COUNT(*) INTO idx_count FROM pg_indexes WHERE schemaname = 'public';

    RAISE NOTICE 'Tamaño de BD: %', db_size;
    RAISE NOTICE 'Tablas: %', table_count;
    RAISE NOTICE 'Secuencias: %', seq_count;
    RAISE NOTICE 'Índices: %', idx_count;
END $$;

-- ============================================
-- 13. RESUMEN FINAL
-- ============================================

DO $$
DECLARE
    has_tables BOOLEAN;
    has_users BOOLEAN := FALSE;
    rls_disabled BOOLEAN;
    all_ok BOOLEAN := TRUE;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '📋 RESUMEN DE VERIFICACIÓN';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';

    -- Verificar tablas
    SELECT EXISTS(SELECT FROM pg_tables WHERE schemaname = 'public') INTO has_tables;

    -- Verificar usuarios
    IF EXISTS(SELECT FROM pg_tables WHERE tablename = 'usuarios') THEN
        EXECUTE 'SELECT EXISTS(SELECT 1 FROM usuarios LIMIT 1)' INTO has_users;
    END IF;

    -- Verificar RLS
    SELECT NOT EXISTS(
        SELECT FROM pg_tables WHERE schemaname = 'public' AND rowsecurity = true
    ) INTO rls_disabled;

    -- Mostrar checklist
    IF has_tables THEN
        RAISE NOTICE '✅ Migraciones ejecutadas';
    ELSE
        RAISE WARNING '❌ Falta ejecutar migraciones';
        all_ok := FALSE;
    END IF;

    IF has_users THEN
        RAISE NOTICE '✅ Usuarios creados';
    ELSE
        RAISE WARNING '❌ Falta crear usuarios';
        all_ok := FALSE;
    END IF;

    IF rls_disabled THEN
        RAISE NOTICE '✅ RLS deshabilitado';
    ELSE
        RAISE WARNING '⚠️  RLS habilitado (considerar deshabilitar)';
    END IF;

    RAISE NOTICE '';

    IF all_ok AND has_users THEN
        RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
        RAISE NOTICE '║  ✅ ¡VERIFICACIÓN EXITOSA!                            ║';
        RAISE NOTICE '║  El sistema está configurado correctamente            ║';
        RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    ELSE
        RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
        RAISE NOTICE '║  ⚠️  ACCIÓN REQUERIDA                                 ║';
        RAISE NOTICE '║  Revisa los warnings arriba y completa los pasos      ║';
        RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    END IF;

    RAISE NOTICE '';
END $$;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

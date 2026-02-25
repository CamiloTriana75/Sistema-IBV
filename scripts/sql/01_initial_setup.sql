-- ============================================
-- SCRIPT DE CONFIGURACIÓN INICIAL - SUPABASE
-- Sistema IBV - PostgreSQL Setup
-- ============================================
--
-- PROPÓSITO:
--   Configurar permisos, extensiones y políticas iniciales
--   para el proyecto Sistema IBV en Supabase
--
-- CUÁNDO EJECUTAR:
--   Una sola vez, después de crear el proyecto en Supabase
--   y ANTES de ejecutar las migraciones de Django
--
-- DÓNDE EJECUTAR:
--   Supabase Dashboard > SQL Editor > New Query
--   Pegar este script completo y ejecutar
--
-- VERSIÓN: 1.0.0
-- FECHA: 2026-02-24
-- ============================================

-- ============================================
-- 1. INFORMACIÓN DEL SISTEMA
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  SISTEMA IBV - CONFIGURACIÓN INICIAL POSTGRESQL       ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE 'Iniciando configuración...';
    RAISE NOTICE 'Database: %', current_database();
    RAISE NOTICE 'Usuario: %', current_user;
    RAISE NOTICE 'Versión PostgreSQL: %', version();
    RAISE NOTICE '';
END $$;

-- ============================================
-- 2. EXTENSIONES DE POSTGRESQL
-- ============================================

RAISE NOTICE '▶ Instalando extensiones...';

-- UUID (Identificadores únicos universales)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
COMMENT ON EXTENSION "uuid-ossp" IS 'Generación de UUIDs para IDs únicos';

-- Criptografía (Hashing, encriptación)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
COMMENT ON EXTENSION "pgcrypto" IS 'Funciones criptográficas para seguridad';

-- Búsqueda de texto completo (Trigram matching)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
COMMENT ON EXTENSION "pg_trgm" IS 'Búsqueda de texto con trigrams para queries eficientes';

-- Verificar extensiones instaladas
DO $$
DECLARE
    ext_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO ext_count
    FROM pg_extension
    WHERE extname IN ('uuid-ossp', 'pgcrypto', 'pg_trgm');

    RAISE NOTICE '✅ Extensiones instaladas: %', ext_count;
END $$;

-- ============================================
-- 3. CONFIGURACIÓN DE PERMISOS
-- ============================================

RAISE NOTICE '▶ Configurando permisos para usuario postgres...';

-- Permisos en schema public
GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;

-- Permisos en tablas existentes
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;

-- Permisos en secuencias existentes (para IDs auto-incrementales)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Permisos en funciones existentes
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO postgres;

-- Permisos por defecto para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON TABLES TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON SEQUENCES TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON FUNCTIONS TO postgres;

RAISE NOTICE '✅ Permisos configurados correctamente';

-- ============================================
-- 4. CONFIGURACIÓN DE ROW LEVEL SECURITY (RLS)
-- ============================================

RAISE NOTICE '▶ Configurando Row Level Security...';

-- DECISIÓN: Deshabilitar RLS en todas las tablas
-- RAZÓN: Django maneja toda la autenticación y autorización
-- Las consultas no vienen directamente del frontend
DO $$
DECLARE
    r RECORD;
    table_count INTEGER := 0;
BEGIN
    -- Deshabilitar RLS en todas las tablas existentes
    FOR r IN (
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE schemaname = 'public'
    )
    LOOP
        EXECUTE format('ALTER TABLE %I.%I DISABLE ROW LEVEL SECURITY',
                      r.schemaname, r.tablename);
        table_count := table_count + 1;
    END LOOP;

    IF table_count > 0 THEN
        RAISE NOTICE '✅ RLS deshabilitado en % tablas existentes', table_count;
    ELSE
        RAISE NOTICE 'ℹ️  No hay tablas existentes (normal en primera ejecución)';
    END IF;
END $$;

-- ============================================
-- 5. CONFIGURACIÓN DE TIMEZONE
-- ============================================

RAISE NOTICE '▶ Configurando timezone...';

-- Establecer timezone por defecto (Colombia)
SET timezone TO 'America/Bogota';

-- Verificar
DO $$
BEGIN
    RAISE NOTICE '✅ Timezone configurado: %', current_setting('timezone');
    RAISE NOTICE '   Hora actual: %', NOW();
END $$;

-- ============================================
-- 6. CONFIGURACIÓN DE PERFORMANCE
-- ============================================

RAISE NOTICE '▶ Aplicando configuraciones de performance...';

-- Estadísticas automáticas (ya está habilitado por defecto en Supabase)
-- Solo verificamos la configuración

DO $$
BEGIN
    -- Verificar autovacuum (limpieza automática)
    IF current_setting('autovacuum')::boolean THEN
        RAISE NOTICE '✅ Autovacuum: HABILITADO';
    ELSE
        RAISE WARNING '⚠️  Autovacuum: DESHABILITADO (puede afectar performance)';
    END IF;

    -- Mostrar configuración de shared_buffers (memoria cache)
    RAISE NOTICE 'ℹ️  Shared Buffers: %', current_setting('shared_buffers');

    -- Mostrar max_connections
    RAISE NOTICE 'ℹ️  Max Connections: %', current_setting('max_connections');
END $$;

-- ============================================
-- 7. FUNCIONES DE UTILIDAD
-- ============================================

RAISE NOTICE '▶ Creando funciones de utilidad...';

-- Función para actualizar timestamps automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS
    'Trigger function para actualizar automáticamente el campo updated_at';

RAISE NOTICE '✅ Función update_updated_at_column() creada';

-- Función para generar slugs únicos
CREATE OR REPLACE FUNCTION generate_unique_slug(base_text TEXT)
RETURNS TEXT AS $$
DECLARE
    slug TEXT;
BEGIN
    -- Convertir a minúsculas y reemplazar espacios por guiones
    slug := lower(trim(base_text));
    slug := regexp_replace(slug, '[^a-z0-9\s-]', '', 'gi');
    slug := regexp_replace(slug, '\s+', '-', 'gi');
    slug := regexp_replace(slug, '-+', '-', 'gi');

    RETURN slug;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION generate_unique_slug(TEXT) IS
    'Genera un slug URL-friendly desde un texto';

RAISE NOTICE '✅ Función generate_unique_slug() creada';

-- ============================================
-- 8. TABLAS DE AUDITORÍA (Opcional)
-- ============================================

RAISE NOTICE '▶ Preparando estructura para auditoría...';

-- Tabla para logs de auditoría (se puede usar para tracking)
CREATE TABLE IF NOT EXISTS audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    user_id INTEGER,
    user_email VARCHAR(255),
    changed_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON audit_log(user_id);

COMMENT ON TABLE audit_log IS 'Registro de auditoría para tracking de cambios';

RAISE NOTICE '✅ Tabla audit_log creada';

-- ============================================
-- 9. VERIFICACIÓN FINAL
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Ejecutando verificaciones finales...';

-- Verificar extensiones
DO $$
DECLARE
    ext_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📦 EXTENSIONES INSTALADAS:';
    FOR ext_record IN
        SELECT extname, extversion
        FROM pg_extension
        WHERE extname NOT IN ('plpgsql')
        ORDER BY extname
    LOOP
        RAISE NOTICE '   ✓ % (v%)', ext_record.extname, ext_record.extversion;
    END LOOP;
END $$;

-- Verificar permisos
DO $$
DECLARE
    has_permissions BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔐 VERIFICACIÓN DE PERMISOS:';

    SELECT has_schema_privilege('postgres', 'public', 'CREATE') INTO has_permissions;
    IF has_permissions THEN
        RAISE NOTICE '   ✓ postgres puede crear objetos en schema public';
    ELSE
        RAISE WARNING '   ✗ Problemas con permisos de postgres';
    END IF;
END $$;

-- Listar funciones creadas
DO $$
DECLARE
    func_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '⚙️  FUNCIONES DE UTILIDAD:';
    FOR func_record IN
        SELECT proname
        FROM pg_proc
        WHERE pronamespace = 'public'::regnamespace
          AND proname IN ('update_updated_at_column', 'generate_unique_slug')
        ORDER BY proname
    LOOP
        RAISE NOTICE '   ✓ %()', func_record.proname;
    END LOOP;
END $$;

-- Mostrar configuración de RLS
DO $$
DECLARE
    table_record RECORD;
    total_tables INTEGER := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🛡️  ESTADO DE ROW LEVEL SECURITY:';

    SELECT COUNT(*) INTO total_tables
    FROM pg_tables
    WHERE schemaname = 'public';

    IF total_tables = 0 THEN
        RAISE NOTICE '   ℹ️  No hay tablas aún (normal antes de migraciones)';
    ELSE
        FOR table_record IN
            SELECT tablename, rowsecurity
            FROM pg_tables
            WHERE schemaname = 'public'
            ORDER BY tablename
        LOOP
            IF table_record.rowsecurity THEN
                RAISE NOTICE '   ⚠️  % - RLS HABILITADO', table_record.tablename;
            ELSE
                RAISE NOTICE '   ✓ % - RLS deshabilitado', table_record.tablename;
            END IF;
        END LOOP;
    END IF;
END $$;

-- ============================================
-- 10. RESUMEN FINAL
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  ✅ CONFIGURACIÓN INICIAL COMPLETADA                  ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE '📋 SIGUIENTES PASOS:';
    RAISE NOTICE '';
    RAISE NOTICE '1. Configurar DATABASE_URL en .env del proyecto Django';
    RAISE NOTICE '2. Ejecutar: python manage.py migrate';
    RAISE NOTICE '3. Ejecutar: python manage.py createsuperuser';
    RAISE NOTICE '4. [Opcional] Ejecutar script de verificación: 02_verify_setup.sql';
    RAISE NOTICE '';
    RAISE NOTICE '📚 DOCUMENTACIÓN:';
    RAISE NOTICE '   docs/SUPABASE_QUICK_START.md';
    RAISE NOTICE '   docs/SUPABASE_SETUP_GUIDE.md';
    RAISE NOTICE '';
    RAISE NOTICE '🎉 Sistema listo para recibir migraciones de Django!';
    RAISE NOTICE '';
END $$;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

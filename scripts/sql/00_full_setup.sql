-- ============================================
-- FULL DATABASE SETUP - SISTEMA IBV
-- One-shot script for Supabase SQL Editor
-- ============================================
--
-- PURPOSE:
--   Create full PostgreSQL structure for Sistema IBV in one run.
--   Includes extensions, permissions, utility functions, and all tables.
--
-- HOW TO USE:
--   Supabase Dashboard > SQL Editor > New Query
--   Paste this whole script and Run.
--
-- NOTE:
--   After running this script, in Django run:
--     python manage.py migrate --fake
--   so Django marks migrations as applied.
--
-- VERSION: 1.0.0
-- DATE: 2026-02-24
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE 'Starting full setup for Sistema IBV...';
    RAISE NOTICE 'Database: %', current_database();
    RAISE NOTICE 'User: %', current_user;
    RAISE NOTICE '';
END $$;

-- ============================================
-- 1. EXTENSIONS
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================
-- 2. PERMISSIONS
-- ============================================

GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON TABLES TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON SEQUENCES TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL ON FUNCTIONS TO postgres;

-- ============================================
-- 3. TIMEZONE
-- ============================================

SET timezone TO 'America/Bogota';

-- ============================================
-- 4. UTILITY FUNCTIONS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_unique_slug(base_text TEXT)
RETURNS TEXT AS $$
DECLARE
    slug TEXT;
BEGIN
    slug := lower(trim(base_text));
    slug := regexp_replace(slug, '[^a-z0-9\s-]', '', 'gi');
    slug := regexp_replace(slug, '\s+', '-', 'gi');
    slug := regexp_replace(slug, '-+', '-', 'gi');
    RETURN slug;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- 5. DJANGO CORE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS django_content_type (
    id SERIAL PRIMARY KEY,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE (app_label, model)
);

CREATE INDEX IF NOT EXISTS django_content_type_app_label_model_idx
    ON django_content_type(app_label, model);

CREATE TABLE IF NOT EXISTS django_migrations (
    id BIGSERIAL PRIMARY KEY,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS django_session (
    session_key VARCHAR(40) PRIMARY KEY,
    session_data TEXT NOT NULL,
    expire_date TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS django_session_expire_date_idx
    ON django_session(expire_date);

CREATE TABLE IF NOT EXISTS django_admin_log (
    id SERIAL PRIMARY KEY,
    action_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    object_id TEXT,
    object_repr VARCHAR(200) NOT NULL,
    action_flag SMALLINT NOT NULL CHECK (action_flag >= 0),
    change_message TEXT NOT NULL,
    content_type_id INTEGER REFERENCES django_content_type(id) ON DELETE SET NULL,
    user_id BIGINT NOT NULL
);

CREATE INDEX IF NOT EXISTS django_admin_log_content_type_id_idx
    ON django_admin_log(content_type_id);
CREATE INDEX IF NOT EXISTS django_admin_log_user_id_idx
    ON django_admin_log(user_id);

-- ============================================
-- 6. AUTH TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS auth_permission (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content_type_id INTEGER NOT NULL REFERENCES django_content_type(id) ON DELETE CASCADE,
    codename VARCHAR(100) NOT NULL,
    UNIQUE (content_type_id, codename)
);

CREATE INDEX IF NOT EXISTS auth_permission_content_type_id_idx
    ON auth_permission(content_type_id);

CREATE TABLE IF NOT EXISTS auth_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS auth_group_permissions (
    id BIGSERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL REFERENCES auth_group(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES auth_permission(id) ON DELETE CASCADE,
    UNIQUE (group_id, permission_id)
);

CREATE INDEX IF NOT EXISTS auth_group_permissions_group_id_idx
    ON auth_group_permissions(group_id);
CREATE INDEX IF NOT EXISTS auth_group_permissions_permission_id_idx
    ON auth_group_permissions(permission_id);

-- ============================================
-- 7. ROLES (SISTEMA IBV)
-- ============================================

CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    permisos JSONB NOT NULL DEFAULT '{}'::jsonb,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_roles_updated_at
    BEFORE UPDATE ON roles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. USERS TABLES (CUSTOM USER)
-- ============================================

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGSERIAL PRIMARY KEY,
    contrasena VARCHAR(128) NOT NULL,
    ultimo_ingreso TIMESTAMPTZ NULL,
    es_superusuario BOOLEAN NOT NULL DEFAULT FALSE,
    correo VARCHAR(254) NOT NULL UNIQUE,
    nombres VARCHAR(150) NOT NULL DEFAULT '',
    apellidos VARCHAR(150) NOT NULL DEFAULT '',
    rol VARCHAR(20) NOT NULL DEFAULT 'cliente'
        CHECK (rol IN ('admin', 'porteria', 'recibidor', 'inventario', 'despachador', 'cliente')),
    rol_id BIGINT NULL REFERENCES roles(id) ON DELETE SET NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    es_personal BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS usuarios_correo_idx ON usuarios(correo);
CREATE INDEX IF NOT EXISTS usuarios_rol_idx ON usuarios(rol);
CREATE INDEX IF NOT EXISTS usuarios_activo_idx ON usuarios(activo);

CREATE TABLE IF NOT EXISTS usuarios_grupos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    grupo_id INTEGER NOT NULL REFERENCES auth_group(id) ON DELETE CASCADE,
    UNIQUE (usuario_id, grupo_id)
);

CREATE INDEX IF NOT EXISTS usuarios_grupos_usuario_id_idx
    ON usuarios_grupos(usuario_id);
CREATE INDEX IF NOT EXISTS usuarios_grupos_grupo_id_idx
    ON usuarios_grupos(grupo_id);

CREATE TABLE IF NOT EXISTS usuarios_permisos (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    permiso_id INTEGER NOT NULL REFERENCES auth_permission(id) ON DELETE CASCADE,
    UNIQUE (usuario_id, permiso_id)
);

CREATE INDEX IF NOT EXISTS usuarios_permisos_usuario_id_idx
    ON usuarios_permisos(usuario_id);
CREATE INDEX IF NOT EXISTS usuarios_permisos_permiso_id_idx
    ON usuarios_permisos(permiso_id);

-- Add FK for django_admin_log.user_id now that usuarios exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'django_admin_log_user_id_fkey'
    ) THEN
        ALTER TABLE django_admin_log
        ADD CONSTRAINT django_admin_log_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ============================================
-- 9. BUQUES
-- ============================================

CREATE TABLE IF NOT EXISTS buques (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    identificacion VARCHAR(80) NOT NULL UNIQUE,
    fecha_arribo DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS buques_identificacion_idx ON buques(identificacion);

CREATE TRIGGER update_buques_updated_at
    BEFORE UPDATE ON buques
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 10. MODELOS DE VEHICULO
-- ============================================

CREATE TABLE IF NOT EXISTS modelos_vehiculo (
    id BIGSERIAL PRIMARY KEY,
    marca VARCHAR(80) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    anio SMALLINT,
    tipo VARCHAR(50),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS modelos_vehiculo_marca_idx ON modelos_vehiculo(marca);
CREATE INDEX IF NOT EXISTS modelos_vehiculo_modelo_idx ON modelos_vehiculo(modelo);

CREATE TRIGGER update_modelos_vehiculo_updated_at
    BEFORE UPDATE ON modelos_vehiculo
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 11. VEHICULOS
-- ============================================

CREATE TABLE IF NOT EXISTS vehiculos (
    id BIGSERIAL PRIMARY KEY,
    bin VARCHAR(50) NOT NULL UNIQUE,
    qr_codigo VARCHAR(120) NOT NULL UNIQUE,
    buque_id BIGINT REFERENCES buques(id) ON DELETE SET NULL,
    modelo_id BIGINT REFERENCES modelos_vehiculo(id) ON DELETE SET NULL,
    color VARCHAR(50),
    estado VARCHAR(40),
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario_recibe_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS vehiculos_bin_idx ON vehiculos(bin);
CREATE INDEX IF NOT EXISTS vehiculos_qr_codigo_idx ON vehiculos(qr_codigo);
CREATE INDEX IF NOT EXISTS vehiculos_buque_id_idx ON vehiculos(buque_id);
CREATE INDEX IF NOT EXISTS vehiculos_modelo_id_idx ON vehiculos(modelo_id);

CREATE TRIGGER update_vehiculos_updated_at
    BEFORE UPDATE ON vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 12. IMPRONTAS
-- ============================================

CREATE TABLE IF NOT EXISTS improntas (
    id BIGSERIAL PRIMARY KEY,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    foto_url TEXT,
    datos_impronta JSONB NOT NULL DEFAULT '{}'::jsonb,
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    estado VARCHAR(40),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS improntas_vehiculo_id_idx ON improntas(vehiculo_id);

CREATE TRIGGER update_improntas_updated_at
    BEFORE UPDATE ON improntas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 13. INVENTARIOS
-- ============================================

CREATE TABLE IF NOT EXISTS inventarios (
    id BIGSERIAL PRIMARY KEY,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    checklist_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    completo BOOLEAN NOT NULL DEFAULT FALSE,
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS inventarios_vehiculo_id_idx ON inventarios(vehiculo_id);
CREATE INDEX IF NOT EXISTS inventarios_completo_idx ON inventarios(completo);

CREATE TRIGGER update_inventarios_updated_at
    BEFORE UPDATE ON inventarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 14. DESPACHOS
-- ============================================

CREATE TABLE IF NOT EXISTS despachos (
    id BIGSERIAL PRIMARY KEY,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    cantidad_vehiculos INTEGER NOT NULL DEFAULT 0,
    estado VARCHAR(40),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS despachos_usuario_id_idx ON despachos(usuario_id);

CREATE TRIGGER update_despachos_updated_at
    BEFORE UPDATE ON despachos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 15. DESPACHO VEHICULOS
-- ============================================

CREATE TABLE IF NOT EXISTS despacho_vehiculos (
    id BIGSERIAL PRIMARY KEY,
    despacho_id BIGINT NOT NULL REFERENCES despachos(id) ON DELETE CASCADE,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    orden_escaneo INTEGER NOT NULL,
    fecha_escaneo TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (despacho_id, vehiculo_id),
    UNIQUE (despacho_id, orden_escaneo)
);

CREATE INDEX IF NOT EXISTS despacho_vehiculos_despacho_id_idx ON despacho_vehiculos(despacho_id);
CREATE INDEX IF NOT EXISTS despacho_vehiculos_vehiculo_id_idx ON despacho_vehiculos(vehiculo_id);

-- ============================================
-- 16. MOVIMIENTOS PORTERIA
-- ============================================

CREATE TABLE IF NOT EXISTS movimientos_porteria (
    id BIGSERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL,
    vehiculo_id BIGINT REFERENCES vehiculos(id) ON DELETE SET NULL,
    persona VARCHAR(150),
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    observacion TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS movimientos_porteria_tipo_idx ON movimientos_porteria(tipo);
CREATE INDEX IF NOT EXISTS movimientos_porteria_vehiculo_id_idx ON movimientos_porteria(vehiculo_id);

CREATE TRIGGER update_movimientos_porteria_updated_at
    BEFORE UPDATE ON movimientos_porteria
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 17. RECIBOS
-- ============================================

CREATE TABLE IF NOT EXISTS recibos (
    id BIGSERIAL PRIMARY KEY,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    despacho_id BIGINT REFERENCES despachos(id) ON DELETE SET NULL,
    datos_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS recibos_vehiculo_id_idx ON recibos(vehiculo_id);
CREATE INDEX IF NOT EXISTS recibos_despacho_id_idx ON recibos(despacho_id);

CREATE TRIGGER update_recibos_updated_at
    BEFORE UPDATE ON recibos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 18. INITIAL CONTENT TYPES AND PERMISSIONS
-- ============================================

INSERT INTO django_content_type (app_label, model) VALUES
    ('admin', 'logentry'),
    ('auth', 'permission'),
    ('auth', 'group'),
    ('contenttypes', 'contenttype'),
    ('sessions', 'session'),
    ('users', 'user')
ON CONFLICT (app_label, model) DO NOTHING;

DO $$
DECLARE
    ct_id INTEGER;
BEGIN
    SELECT id INTO ct_id FROM django_content_type WHERE app_label = 'users' AND model = 'user';
    IF ct_id IS NOT NULL THEN
        INSERT INTO auth_permission (name, content_type_id, codename) VALUES
            ('Can add user', ct_id, 'add_user'),
            ('Can change user', ct_id, 'change_user'),
            ('Can delete user', ct_id, 'delete_user'),
            ('Can view user', ct_id, 'view_user')
        ON CONFLICT (content_type_id, codename) DO NOTHING;
    END IF;
END $$;

-- ============================================
-- 9. DISABLE RLS
-- ============================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public')
    LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(r.tablename) || ' DISABLE ROW LEVEL SECURITY';
    END LOOP;
END $$;

-- ============================================
-- 10. MARK MIGRATIONS AS APPLIED
-- ============================================

INSERT INTO django_migrations (app, name, applied) VALUES
    ('contenttypes', '0001_initial', NOW()),
    ('contenttypes', '0002_remove_content_type_name', NOW()),
    ('auth', '0001_initial', NOW()),
    ('auth', '0002_alter_permission_name_max_length', NOW()),
    ('auth', '0003_alter_user_email_max_length', NOW()),
    ('auth', '0004_alter_user_username_opts', NOW()),
    ('auth', '0005_alter_user_last_login_null', NOW()),
    ('auth', '0006_require_contenttypes_0002', NOW()),
    ('auth', '0007_alter_validators_add_error_messages', NOW()),
    ('auth', '0008_alter_user_username_max_length', NOW()),
    ('auth', '0009_alter_user_last_name_max_length', NOW()),
    ('auth', '0010_alter_group_name_max_length', NOW()),
    ('auth', '0011_update_proxy_permissions', NOW()),
    ('auth', '0012_alter_user_first_name_max_length', NOW()),
    ('users', '0001_initial', NOW()),
    ('users', '0002_add_role', NOW()),
    ('admin', '0001_initial', NOW()),
    ('admin', '0002_logentry_remove_auto_add', NOW()),
    ('admin', '0003_logentry_add_action_flag_choices', NOW()),
    ('sessions', '0001_initial', NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 11. SUMMARY
-- ============================================

DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count FROM pg_tables WHERE schemaname = 'public';
    SELECT COUNT(*) INTO index_count FROM pg_indexes WHERE schemaname = 'public';
    RAISE NOTICE 'Tables created: %', table_count;
    RAISE NOTICE 'Indexes created: %', index_count;
    RAISE NOTICE 'Full setup completed.';
END $$;

-- ============================================
-- END OF SCRIPT
-- ============================================

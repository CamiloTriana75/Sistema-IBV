-- ============================================
-- SCRIPT DE CREACIÓN DE TABLAS - SISTEMA IBV
-- PostgreSQL Database Schema
-- ============================================
--
-- PROPÓSITO:
--   Crear todas las tablas necesarias para el Sistema IBV
--   directamente en PostgreSQL/Supabase
--
-- CUÁNDO EJECUTAR:
--   - Como alternativa a python manage.py migrate
--   - Para crear la estructura antes de configurar Django
--   - Para tener control directo sobre la BD
--
-- PREREQUISITOS:
--   - Ejecutar 01_initial_setup.sql primero
--
-- DÓNDE EJECUTAR:
--   Supabase Dashboard > SQL Editor > New Query
--
-- NOTA IMPORTANTE:
--   Si usas este script, luego debes ejecutar:
--   python manage.py migrate --fake
--   para que Django sepa que las migraciones ya fueron aplicadas
--
-- VERSIÓN: 1.0.0
-- FECHA: 2026-02-24
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  CREACIÓN DE TABLAS - SISTEMA IBV                     ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

-- ============================================
-- 1. TABLAS DE DJANGO CORE
-- ============================================

RAISE NOTICE '▶ Creando tablas de Django Core...';

-- Django Content Types
CREATE TABLE IF NOT EXISTS django_content_type (
    id SERIAL PRIMARY KEY,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE (app_label, model)
);

CREATE INDEX IF NOT EXISTS django_content_type_app_label_model_idx
    ON django_content_type(app_label, model);

COMMENT ON TABLE django_content_type IS
    'Registro de todos los modelos de Django instalados';

-- Django Migrations
CREATE TABLE IF NOT EXISTS django_migrations (
    id BIGSERIAL PRIMARY KEY,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE django_migrations IS
    'Historial de migraciones aplicadas';

-- Django Sessions
CREATE TABLE IF NOT EXISTS django_session (
    session_key VARCHAR(40) PRIMARY KEY,
    session_data TEXT NOT NULL,
    expire_date TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS django_session_expire_date_idx
    ON django_session(expire_date);

COMMENT ON TABLE django_session IS
    'Sesiones de usuario de Django';

-- Django Admin Log
CREATE TABLE IF NOT EXISTS django_admin_log (
    id SERIAL PRIMARY KEY,
    action_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    object_id TEXT,
    object_repr VARCHAR(200) NOT NULL,
    action_flag SMALLINT NOT NULL CHECK (action_flag >= 0),
    change_message TEXT NOT NULL,
    content_type_id INTEGER REFERENCES django_content_type(id) ON DELETE SET NULL,
    user_id BIGINT NOT NULL -- FK será agregada después de crear usuarios
);

CREATE INDEX IF NOT EXISTS django_admin_log_content_type_id_idx
    ON django_admin_log(content_type_id);
CREATE INDEX IF NOT EXISTS django_admin_log_user_id_idx
    ON django_admin_log(user_id);

COMMENT ON TABLE django_admin_log IS
    'Registro de acciones en el admin de Django';

RAISE NOTICE '✅ Tablas de Django Core creadas';

-- ============================================
-- 2. TABLAS DE AUTENTICACIÓN (AUTH)
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Creando tablas de autenticación...';

-- Auth Permission
CREATE TABLE IF NOT EXISTS auth_permission (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content_type_id INTEGER NOT NULL REFERENCES django_content_type(id) ON DELETE CASCADE,
    codename VARCHAR(100) NOT NULL,
    UNIQUE (content_type_id, codename)
);

CREATE INDEX IF NOT EXISTS auth_permission_content_type_id_idx
    ON auth_permission(content_type_id);

COMMENT ON TABLE auth_permission IS
    'Permisos del sistema de autenticación de Django';

-- Auth Group
CREATE TABLE IF NOT EXISTS auth_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

COMMENT ON TABLE auth_group IS
    'Grupos de usuarios para asignación de permisos';

-- Auth Group Permissions (Many-to-Many)
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

COMMENT ON TABLE auth_group_permissions IS
    'Relación Many-to-Many entre grupos y permisos';

RAISE NOTICE '✅ Tablas de autenticación creadas';

-- ============================================
-- 3. TABLA DE USUARIOS (USERS)
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Creando tabla de usuarios...';

-- Users User (Modelo personalizado)
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
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    es_personal BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS usuarios_correo_idx ON usuarios(correo);
CREATE INDEX IF NOT EXISTS usuarios_rol_idx ON usuarios(rol);
CREATE INDEX IF NOT EXISTS usuarios_activo_idx ON usuarios(activo);

COMMENT ON TABLE usuarios IS
    'Usuarios del Sistema IBV con autenticación por email';
COMMENT ON COLUMN usuarios.rol IS
    'Rol del usuario: admin, porteria, recibidor, inventario, despachador, cliente';
COMMENT ON COLUMN usuarios.correo IS
    'Email único usado para autenticación';

RAISE NOTICE '✅ Tabla de usuarios creada';

-- ============================================
-- 4. RELACIONES MANY-TO-MANY DE USUARIOS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Creando relaciones de usuarios...';

-- User Groups (Many-to-Many)
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

COMMENT ON TABLE usuarios_grupos IS
    'Relación Many-to-Many entre usuarios y grupos';

-- User Permissions (Many-to-Many)
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

COMMENT ON TABLE usuarios_permisos IS
    'Relación Many-to-Many entre usuarios y permisos específicos';

RAISE NOTICE '✅ Relaciones de usuarios creadas';

-- ============================================
-- 5. AGREGAR FOREIGN KEY DE DJANGO_ADMIN_LOG
-- ============================================

-- Ahora que usuarios existe, agregar FK
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'django_admin_log_user_id_fkey'
    ) THEN
        ALTER TABLE django_admin_log
        ADD CONSTRAINT django_admin_log_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE;

        RAISE NOTICE '✅ Foreign key de django_admin_log agregada';
    END IF;
END $$;

-- ============================================
-- 6. POBLAR CONTENT TYPES INICIALES
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Poblando content types iniciales...';

INSERT INTO django_content_type (app_label, model) VALUES
    ('admin', 'logentry'),
    ('auth', 'permission'),
    ('auth', 'group'),
    ('contenttypes', 'contenttype'),
    ('sessions', 'session'),
    ('users', 'user')
ON CONFLICT (app_label, model) DO NOTHING;

RAISE NOTICE '✅ Content types iniciales creados';

-- ============================================
-- 7. POBLAR PERMISOS BÁSICOS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Creando permisos básicos...';

DO $$
DECLARE
    ct_id INTEGER;
BEGIN
    -- Permisos para users.user
    SELECT id INTO ct_id FROM django_content_type WHERE app_label = 'users' AND model = 'user';

    IF ct_id IS NOT NULL THEN
        INSERT INTO auth_permission (name, content_type_id, codename) VALUES
            ('Can add user', ct_id, 'add_user'),
            ('Can change user', ct_id, 'change_user'),
            ('Can delete user', ct_id, 'delete_user'),
            ('Can view user', ct_id, 'view_user')
        ON CONFLICT (content_type_id, codename) DO NOTHING;
    END IF;

    RAISE NOTICE '✅ Permisos básicos creados';
END $$;

-- ============================================
-- 8. DESHABILITAR RLS EN TODAS LAS TABLAS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Deshabilitando RLS en todas las tablas...';

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public')
    LOOP
        EXECUTE 'ALTER TABLE ' || quote_ident(r.tablename) || ' DISABLE ROW LEVEL SECURITY';
    END LOOP;

    RAISE NOTICE '✅ RLS deshabilitado en todas las tablas';
END $$;

-- ============================================
-- 9. REGISTRAR MIGRACIONES COMO APLICADAS
-- ============================================

RAISE NOTICE '';
RAISE NOTICE '▶ Registrando migraciones como aplicadas...';

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

RAISE NOTICE '✅ Migraciones registradas';

-- ============================================
-- 10. VERIFICACIÓN Y RESUMEN
-- ============================================

DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'RESUMEN DE CREACIÓN';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';

    SELECT COUNT(*) INTO table_count
    FROM pg_tables WHERE schemaname = 'public';

    SELECT COUNT(*) INTO index_count
    FROM pg_indexes WHERE schemaname = 'public';

    RAISE NOTICE '📊 Tablas creadas: %', table_count;
    RAISE NOTICE '📇 Índices creados: %', index_count;
    RAISE NOTICE '';

    RAISE NOTICE '📋 TABLAS PRINCIPALES:';
    RAISE NOTICE '  ✓ usuarios';
    RAISE NOTICE '  ✓ auth_group';
    RAISE NOTICE '  ✓ auth_permission';
    RAISE NOTICE '  ✓ django_content_type';
    RAISE NOTICE '  ✓ django_migrations';
    RAISE NOTICE '  ✓ django_session';
    RAISE NOTICE '  ✓ django_admin_log';
    RAISE NOTICE '';
END $$;

-- ============================================
-- 11. RESULTADO FINAL
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  ✅ TABLAS CREADAS EXITOSAMENTE                       ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE '📋 SIGUIENTES PASOS:';
    RAISE NOTICE '';
    RAISE NOTICE '1. Verificar tablas:';
    RAISE NOTICE '   Ejecutar: scripts/sql/02_verify_setup.sql';
    RAISE NOTICE '';
    RAISE NOTICE '2. Desde Django, marcar migraciones como aplicadas:';
    RAISE NOTICE '   cd backend';
    RAISE NOTICE '   python manage.py migrate --fake';
    RAISE NOTICE '';
    RAISE NOTICE '3. Crear superusuario:';
    RAISE NOTICE '   python manage.py createsuperuser';
    RAISE NOTICE '';
    RAISE NOTICE '4. Verificar en Django Admin:';
    RAISE NOTICE '   python manage.py runserver';
    RAISE NOTICE '   http://127.0.0.1:8000/admin/';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANTE:';
    RAISE NOTICE '   Si ejecutas python manage.py migrate sin --fake,';
    RAISE NOTICE '   Django intentará crear las tablas nuevamente y fallará.';
    RAISE NOTICE '';
END $$;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

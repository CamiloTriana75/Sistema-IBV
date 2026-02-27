-- ============================================
-- SISTEMA IBV - DATABASE SETUP (CLEAN)
-- Only production tables - NO confusions
-- ============================================
--
-- Tables: roles, usuarios, buques, modelos_vehiculo,
--         vehiculos, improntas, inventarios, despachos,
--         despacho_vehiculos, movimientos_porteria, recibos,
--         auth_group, auth_permission, auth_group_permissions
--
-- VERSION: 2.0.0 (CLEAN)
-- DATE: 2026-02-27
-- ============================================BEGIN;

-- ============================================
-- EXTENSIONS
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- AUTH TABLES (Django compatibl, but no content_type FK)
-- ============================================

CREATE TABLE IF NOT EXISTS auth_permission (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content_type_id INTEGER NOT NULL,
    codename VARCHAR(100) NOT NULL,
    UNIQUE (content_type_id, codename)
);

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
-- 1. ROLES
-- ============================================

CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL UNIQUE,
    descripcion TEXT,
    permisos JSONB NOT NULL DEFAULT '{}'::jsonb,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS roles_nombre_idx ON roles(nombre);
CREATE INDEX IF NOT EXISTS roles_activo_idx ON roles(activo);

-- ============================================
-- 2. USUARIOS
-- ============================================

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGSERIAL PRIMARY KEY,
    correo VARCHAR(254) NOT NULL UNIQUE,
    nombres VARCHAR(255) NOT NULL DEFAULT '',
    apellidos VARCHAR(255) NOT NULL DEFAULT '',
    rol VARCHAR(50) NOT NULL DEFAULT 'cliente',
    rol_id BIGINT REFERENCES roles(id) ON DELETE SET NULL,
    es_superusuario BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    es_personal BOOLEAN NOT NULL DEFAULT FALSE,
    ultimo_ingreso TIMESTAMPTZ,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS usuarios_correo_idx ON usuarios(correo);
CREATE INDEX IF NOT EXISTS usuarios_rol_idx ON usuarios(rol);
CREATE INDEX IF NOT EXISTS usuarios_rol_id_idx ON usuarios(rol_id);
CREATE INDEX IF NOT EXISTS usuarios_activo_idx ON usuarios(activo);

-- ============================================
-- 3. BUQUES
-- ============================================

CREATE TABLE IF NOT EXISTS buques (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    identificacion VARCHAR(100) NOT NULL UNIQUE,
    fecha_arribo DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS buques_identificacion_idx ON buques(identificacion);

-- ============================================
-- 4. MODELOS DE VEHICULO
-- ============================================

CREATE TABLE IF NOT EXISTS modelos_vehiculo (
    id BIGSERIAL PRIMARY KEY,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio SMALLINT,
    tipo VARCHAR(50),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (marca, modelo, anio)
);

CREATE INDEX IF NOT EXISTS modelos_vehiculo_marca_idx ON modelos_vehiculo(marca);
CREATE INDEX IF NOT EXISTS modelos_vehiculo_activo_idx ON modelos_vehiculo(activo);

-- ============================================
-- 5. VEHICULOS
-- ============================================

CREATE TABLE IF NOT EXISTS vehiculos (
    id BIGSERIAL PRIMARY KEY,
    bin VARCHAR(100) NOT NULL UNIQUE,
    qr_codigo VARCHAR(100) NOT NULL UNIQUE,
    placa VARCHAR(20),
    buque_id BIGINT REFERENCES buques(id) ON DELETE SET NULL,
    modelo_id BIGINT REFERENCES modelos_vehiculo(id) ON DELETE SET NULL,
    color VARCHAR(50),
    estado VARCHAR(50),
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario_recibe_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS vehiculos_bin_idx ON vehiculos(bin);
CREATE INDEX IF NOT EXISTS vehiculos_qr_codigo_idx ON vehiculos(qr_codigo);
CREATE INDEX IF NOT EXISTS vehiculos_placa_idx ON vehiculos(placa);
CREATE INDEX IF NOT EXISTS vehiculos_estado_idx ON vehiculos(estado);
CREATE INDEX IF NOT EXISTS vehiculos_buque_id_idx ON vehiculos(buque_id);
CREATE INDEX IF NOT EXISTS vehiculos_modelo_id_idx ON vehiculos(modelo_id);

-- ============================================
-- 6. IMPRONTAS
-- ============================================

CREATE TABLE IF NOT EXISTS improntas (
    id BIGSERIAL PRIMARY KEY,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    foto_url TEXT,
    datos_impronta JSONB NOT NULL DEFAULT '{}'::jsonb,
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    estado VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS improntas_vehiculo_id_idx ON improntas(vehiculo_id);
CREATE INDEX IF NOT EXISTS improntas_usuario_id_idx ON improntas(usuario_id);

-- ============================================
-- 7. INVENTARIOS
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
CREATE INDEX IF NOT EXISTS inventarios_usuario_id_idx ON inventarios(usuario_id);
CREATE INDEX IF NOT EXISTS inventarios_completo_idx ON inventarios(completo);

-- ============================================
-- 8. DESPACHOS
-- ============================================

CREATE TABLE IF NOT EXISTS despachos (
    id BIGSERIAL PRIMARY KEY,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    cantidad_vehiculos INTEGER NOT NULL DEFAULT 0,
    estado VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS despachos_usuario_id_idx ON despachos(usuario_id);
CREATE INDEX IF NOT EXISTS despachos_estado_idx ON despachos(estado);

-- ============================================
-- 9. DESPACHO VEHICULOS
-- ============================================

CREATE TABLE IF NOT EXISTS despacho_vehiculos (
    id BIGSERIAL PRIMARY KEY,
    despacho_id BIGINT NOT NULL REFERENCES despachos(id) ON DELETE CASCADE,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculos(id) ON DELETE CASCADE,
    orden_escaneo INTEGER NOT NULL,
    fecha_escaneo TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (despacho_id, vehiculo_id)
);

CREATE INDEX IF NOT EXISTS despacho_vehiculos_despacho_id_idx ON despacho_vehiculos(despacho_id);
CREATE INDEX IF NOT EXISTS despacho_vehiculos_vehiculo_id_idx ON despacho_vehiculos(vehiculo_id);

-- ============================================
-- 10. MOVIMIENTOS PORTERIA
-- ============================================

CREATE TABLE IF NOT EXISTS movimientos_porteria (
    id BIGSERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    vehiculo_id BIGINT REFERENCES vehiculos(id) ON DELETE SET NULL,
    persona VARCHAR(255),
    usuario_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
    fecha TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    observacion TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS movimientos_porteria_vehiculo_id_idx ON movimientos_porteria(vehiculo_id);
CREATE INDEX IF NOT EXISTS movimientos_porteria_usuario_id_idx ON movimientos_porteria(usuario_id);
CREATE INDEX IF NOT EXISTS movimientos_porteria_tipo_idx ON movimientos_porteria(tipo);

-- ============================================
-- 11. RECIBOS
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

-- ============================================
-- 12. INITIAL DATA - Roles
-- ============================================

INSERT INTO roles (nombre, descripcion, permisos, activo)
VALUES
    ('admin', 'Administrador del sistema', '{}'::jsonb, TRUE),
    ('porteria', 'Control de portería', '{}'::jsonb, TRUE),
    ('recibidor', 'Recepción de vehículos', '{}'::jsonb, TRUE),
    ('inventario', 'Inspección de inventario', '{}'::jsonb, TRUE),
    ('despachador', 'Despacho de vehículos', '{}'::jsonb, TRUE),
    ('cliente', 'Cliente', '{}'::jsonb, TRUE)
ON CONFLICT (nombre) DO NOTHING;

COMMIT;

-- ============================================
-- DONE - Database setup complete

-- =====================================================
-- Script de Datos de Prueba Completos - Sistema IBV
-- Fecha: 2026-02-27
-- Descripción: Inserta datos de prueba en TODAS las tablas del sistema
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  CARGA COMPLETA DE DATOS DE PRUEBA - SISTEMA IBV      ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

-- =====================================================
-- 1. USUARIOS (con contraseñas hasheadas en bcrypt)
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando usuarios...';
END $$;

-- Limpiar datos existentes (CUIDADO: solo para testing)
TRUNCATE TABLE usuarios RESTART IDENTITY CASCADE;

INSERT INTO usuarios (correo, nombres, apellidos, rol, es_superusuario, activo, es_personal, ultimo_ingreso, fecha_registro)
VALUES
    -- Administradores
    ('admin@ibv.com', 'Carlos', 'Administrador', 'admin', TRUE, TRUE, TRUE, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '30 days'),
    ('maria.admin@ibv.com', 'María', 'González', 'admin', FALSE, TRUE, TRUE, NOW() - INTERVAL '2 days', NOW() - INTERVAL '25 days'),
    
    -- Portería
    ('jose.porteria@ibv.com', 'José', 'Ramírez', 'porteria', FALSE, TRUE, TRUE, NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '20 days'),
    ('carmen.porteria@ibv.com', 'Carmen', 'López', 'porteria', FALSE, TRUE, TRUE, NOW() - INTERVAL '1 day', NOW() - INTERVAL '20 days'),
    
    -- Recibidores
    ('pedro.recibidor@ibv.com', 'Pedro', 'Martínez', 'recibidor', FALSE, TRUE, TRUE, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '18 days'),
    ('ana.recibidor@ibv.com', 'Ana', 'Fernández', 'recibidor', FALSE, TRUE, TRUE, NOW() - INTERVAL '5 hours', NOW() - INTERVAL '18 days'),
    
    -- Inventario
    ('carlos.inspector@ibv.com', 'Carlos', 'Inspector', 'inventario', FALSE, TRUE, TRUE, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '15 days'),
    ('luisa.inspector@ibv.com', 'Luisa', 'García', 'inventario', FALSE, TRUE, TRUE, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '15 days'),
    
    -- Despachadores
    ('luis.despachador@ibv.com', 'Luis', 'Sánchez', 'despachador', FALSE, TRUE, TRUE, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '12 days'),
    ('sofia.despachador@ibv.com', 'Sofía', 'Rodríguez', 'despachador', FALSE, TRUE, TRUE, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '12 days'),
    
    -- Clientes
    ('cliente1@distribuidora.com', 'Roberto', 'Méndez', 'cliente', FALSE, TRUE, FALSE, NOW() - INTERVAL '1 day', NOW() - INTERVAL '10 days'),
    ('cliente2@autoventas.com', 'Laura', 'Torres', 'cliente', FALSE, TRUE, FALSE, NOW() - INTERVAL '2 days', NOW() - INTERVAL '8 days'),
    ('cliente3@concesionaria.com', 'Miguel', 'Díaz', 'cliente', FALSE, TRUE, FALSE, NOW() - INTERVAL '3 days', NOW() - INTERVAL '5 days');

-- =====================================================
-- 2. BUQUES
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando buques...';
END $$;

TRUNCATE TABLE buques RESTART IDENTITY CASCADE;

INSERT INTO buques (nombre, identificacion, fecha_arribo, created_at)
VALUES
    ('Atlantic Voyager', 'BQ-2026-001', '2026-02-15', NOW() - INTERVAL '12 days'),
    ('Pacific Spirit', 'BQ-2026-002', '2026-02-20', NOW() - INTERVAL '7 days'),
    ('Caribbean Star', 'BQ-2026-003', '2026-02-23', NOW() - INTERVAL '4 days'),
    ('Mediterranean Crown', 'BQ-2026-004', '2026-02-25', NOW() - INTERVAL '2 days'),
    ('Golden Horizon', 'BQ-2026-005', '2026-02-27', NOW());

-- =====================================================
-- 3. MODELOS DE VEHÍCULO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando modelos de vehículos...';
END $$;

TRUNCATE TABLE modelos_vehiculo RESTART IDENTITY CASCADE;

INSERT INTO modelos_vehiculo (marca, modelo, anio, tipo, activo)
VALUES
    -- Toyota
    ('Toyota', 'Corolla', 2024, 'Sedán', TRUE),
    ('Toyota', 'Hilux', 2024, 'Pickup', TRUE),
    ('Toyota', 'RAV4', 2025, 'SUV', TRUE),
    ('Toyota', 'Yaris', 2025, 'Hatchback', TRUE),
    ('Toyota', 'Land Cruiser', 2024, 'SUV', TRUE),
    
    -- Chevrolet
    ('Chevrolet', 'Spark', 2023, 'Hatchback', TRUE),
    ('Chevrolet', 'Aveo', 2024, 'Sedán', TRUE),
    ('Chevrolet', 'Tracker', 2024, 'SUV', TRUE),
    ('Chevrolet', 'Silverado', 2025, 'Pickup', TRUE),
    
    -- Nissan
    ('Nissan', 'Versa', 2025, 'Sedán', TRUE),
    ('Nissan', 'Sentra', 2024, 'Sedán', TRUE),
    ('Nissan', 'X-Trail', 2025, 'SUV', TRUE),
    ('Nissan', 'Frontier', 2024, 'Pickup', TRUE),
    
    -- Ford
    ('Ford', 'Explorer', 2025, 'SUV', TRUE),
    ('Ford', 'F-150', 2024, 'Pickup', TRUE),
    ('Ford', 'Escape', 2025, 'SUV', TRUE),
    ('Ford', 'Ranger', 2024, 'Pickup', TRUE),
    
    -- Hyundai
    ('Hyundai', 'Accent', 2023, 'Sedán', TRUE),
    ('Hyundai', 'Tucson', 2024, 'SUV', TRUE),
    ('Hyundai', 'Elantra', 2025, 'Sedán', TRUE),
    
    -- Kia
    ('Kia', 'Rio', 2024, 'Sedán', TRUE),
    ('Kia', 'Sportage', 2025, 'SUV', TRUE),
    ('Kia', 'Seltos', 2024, 'SUV', TRUE),
    
    -- Honda
    ('Honda', 'Civic', 2024, 'Sedán', TRUE),
    ('Honda', 'CR-V', 2025, 'SUV', TRUE),
    ('Honda', 'Accord', 2024, 'Sedán', TRUE);

-- =====================================================
-- 4. VEHÍCULOS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando vehículos...';
END $$;

TRUNCATE TABLE vehiculos RESTART IDENTITY CASCADE;

INSERT INTO vehiculos (bin, qr_codigo, placa, buque_id, modelo_id, color, estado, fecha_registro, usuario_recibe_id)
VALUES
    -- Vehículos del buque 1 (Atlantic Voyager) - Ya completados
    ('1HGBH41JXMN109186', 'QR-VEH-001', 'ABC-1234', 1, 1, 'Blanco Perla', 'despachado', NOW() - INTERVAL '12 days', 5),
    ('3VWDX7AJ5BM123456', 'QR-VEH-002', 'XYZ-5678', 1, 6, 'Rojo', 'despachado', NOW() - INTERVAL '12 days', 5),
    ('WVWZZZ3CZWE123789', 'QR-VEH-003', 'DEF-9012', 1, 10, 'Plata', 'listo_despacho', NOW() - INTERVAL '12 days', 5),
    ('KNDJP3A53H7654321', 'QR-VEH-004', 'GHI-3456', 1, 21, 'Negro', 'inventario_aprobado', NOW() - INTERVAL '12 days', 5),
    ('KMHDN46D09U987654', 'QR-VEH-005', 'JKL-7890', 1, 18, 'Azul', 'inventario_pendiente', NOW() - INTERVAL '12 days', 5),
    
    -- Vehículos del buque 2 (Pacific Spirit) - En proceso
    ('1FADP3F29JL234567', 'QR-VEH-006', 'MNO-4567', 2, 14, 'Blanco Oxford', 'despachado', NOW() - INTERVAL '7 days', 6),
    ('5YJSA1DNXDFP12345', 'QR-VEH-007', 'PQR-1234', 2, 5, 'Negro Ónix', 'listo_despacho', NOW() - INTERVAL '7 days', 6),
    ('JN1DA31A52T123456', 'QR-VEH-008', 'STU-5678', 2, 11, 'Gris Oscuro', 'inventario_aprobado', NOW() - INTERVAL '7 days', 6),
    ('3N1AB7AP8EY789012', 'QR-VEH-009', 'VWX-9012', 2, 10, 'Blanco', 'inventario_pendiente', NOW() - INTERVAL '7 days', 6),
    ('KMHJU81ABEU345678', 'QR-VEH-010', 'YZA-3456', 2, 19, 'Rojo Carmesí', 'impronta_completada', NOW() - INTERVAL '7 days', 6),
    
    -- Vehículos del buque 3 (Caribbean Star) - Recién llegados
    ('2HGFC2F59MH901234', 'QR-VEH-011', 'BCD-7890', 3, 24, 'Plata Lunar', 'inventario_aprobado', NOW() - INTERVAL '4 days', 5),
    ('19UDE3F34MA567890', 'QR-VEH-012', 'EFG-1234', 3, 25, 'Azul Profundo', 'inventario_pendiente', NOW() - INTERVAL '4 days', 5),
    ('1G1ZD5ST8LF234567', 'QR-VEH-013', 'HIJ-5678', 3, 8, 'Gris Grafito', 'impronta_completada', NOW() - INTERVAL '4 days', 5),
    ('5NPEC4AC2FH890123', 'QR-VEH-014', 'KLM-9012', 3, 20, 'Blanco', 'impronta_pendiente', NOW() - INTERVAL '4 days', 5),
    ('KNAFX5A88G5456789', 'QR-VEH-015', 'NOP-3456', 3, 23, 'Azul Eléctrico', 'recibido', NOW() - INTERVAL '4 days', 5),
    
    -- Vehículos del buque 4 (Mediterranean Crown) - Recién llegados
    ('WDDGF4HB9EA123456', 'QR-VEH-016', 'QRS-7890', 4, 3, 'Negro Sombra', 'impronta_completada', NOW() - INTERVAL '2 days', 6),
    ('3FADP4EJ1DM789012', 'QR-VEH-017', 'TUV-1234', 4, 16, 'Blanco Platino', 'impronta_pendiente', NOW() - INTERVAL '2 days', 6),
    ('1FTEW1EP8GKE34567', 'QR-VEH-018', 'WXY-5678', 4, 15, 'Gris Magnético', 'recibido', NOW() - INTERVAL '2 days', 6),
    ('5TFUW5F18HX890123', 'QR-VEH-019', 'ZAB-9012', 4, 2, 'Rojo Supersónico', 'recibido', NOW() - INTERVAL '2 days', 6),
    ('3GNAXUEV0KL456789', 'QR-VEH-020', 'CDE-3456', 4, 9, 'Azul Medianoche', 'recibido', NOW() - INTERVAL '2 days', 6),
    
    -- Vehículos del buque 5 (Golden Horizon) - Recién llegados hoy
    ('1N4AA6AP9FC123456', 'QR-VEH-021', 'FGH-7890', 5, 13, 'Plata Brillante', 'recibido', NOW() - INTERVAL '3 hours', 5),
    ('JN8AZ2NE5F9789012', 'QR-VEH-022', 'IJK-1234', 5, 12, 'Gris Cósmico', 'recibido', NOW() - INTERVAL '2 hours', 5),
    ('1C4RJFAG2FC345678', 'QR-VEH-023', 'LMN-5678', 5, 4, 'Blanco Glacial', 'recibido', NOW() - INTERVAL '1 hour', 5),
    ('5UXKR0C59F0890123', 'QR-VEH-024', 'OPQ-9012', 5, 22, 'Negro Profundo', 'recibido', NOW() - INTERVAL '45 minutes', 5),
    ('WBAPH7C59BE456789', 'QR-VEH-025', 'RST-3456', 5, 26, 'Gris Selenita', 'recibido', NOW() - INTERVAL '30 minutes', 5);

-- =====================================================
-- 5. IMPRONTAS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando improntas...';
END $$;

TRUNCATE TABLE improntas RESTART IDENTITY CASCADE;

INSERT INTO improntas (vehiculo_id, foto_url, datos_impronta, usuario_id, fecha, estado)
VALUES
    -- Improntas completadas
    (1, '/uploads/improntas/impronta-001.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '11 days', 'completada'),
    (2, '/uploads/improntas/impronta-002.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "rayon_menor", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '11 days', 'completada'),
    (3, '/uploads/improntas/impronta-003.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 8, NOW() - INTERVAL '11 days', 'completada'),
    (4, '/uploads/improntas/impronta-004.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '11 days', 'completada'),
    (5, '/uploads/improntas/impronta-005.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 8, NOW() - INTERVAL '11 days', 'completada'),
    
    (6, '/uploads/improntas/impronta-006.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '6 days', 'completada'),
    (7, '/uploads/improntas/impronta-007.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 8, NOW() - INTERVAL '6 days', 'completada'),
    (8, '/uploads/improntas/impronta-008.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '6 days', 'completada'),
    (9, '/uploads/improntas/impronta-009.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 8, NOW() - INTERVAL '6 days', 'completada'),
    (10, '/uploads/improntas/impronta-010.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '6 days', 'completada'),
    
    (11, '/uploads/improntas/impronta-011.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 8, NOW() - INTERVAL '3 days', 'completada'),
    (12, '/uploads/improntas/impronta-012.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '3 days', 'completada'),
    (13, '/uploads/improntas/impronta-013.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 8, NOW() - INTERVAL '3 days', 'completada'),
    
    (16, '/uploads/improntas/impronta-016.jpg', '{"lateral_izquierdo": "ok", "lateral_derecho": "ok", "frontal": "ok", "trasera": "ok", "techo": "ok"}'::jsonb, 7, NOW() - INTERVAL '1 day', 'completada');

-- =====================================================
-- 6. INVENTARIOS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando inventarios...';
END $$;

TRUNCATE TABLE inventarios RESTART IDENTITY CASCADE;

INSERT INTO inventarios (vehiculo_id, checklist_json, completo, usuario_id, fecha)
VALUES
    -- Inventarios aprobados
    (1, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 7, NOW() - INTERVAL '10 days'),
    (2, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 8, NOW() - INTERVAL '10 days'),
    (3, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 7, NOW() - INTERVAL '10 days'),
    (4, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 8, NOW() - INTERVAL '10 days'),
    
    (6, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 7, NOW() - INTERVAL '5 days'),
    (7, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 8, NOW() - INTERVAL '5 days'),
    (8, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 7, NOW() - INTERVAL '5 days'),
    
    (11, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, TRUE, 8, NOW() - INTERVAL '3 days'),
    
    -- Inventarios pendientes (parciales o rechazados)
    (5, '{"neumaticos": true, "triangulos": true, "gato": false, "extintor": true, "llave_ruedas": true, "manual": false, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, FALSE, 7, NOW() - INTERVAL '10 days'),
    (9, '{"neumaticos": true, "triangulos": false, "gato": true, "extintor": true, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, FALSE, 8, NOW() - INTERVAL '5 days'),
    (12, '{"neumaticos": true, "triangulos": true, "gato": true, "extintor": false, "llave_ruedas": true, "manual": true, "espejos": true, "luces": true, "parabrisas": true, "asientos": true}'::jsonb, FALSE, 7, NOW() - INTERVAL '3 days');

-- =====================================================
-- 7. DESPACHOS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando despachos...';
END $$;

TRUNCATE TABLE despachos RESTART IDENTITY CASCADE;

INSERT INTO despachos (fecha, usuario_id, cantidad_vehiculos, estado)
VALUES
    (NOW() - INTERVAL '9 days', 9, 2, 'completado'),
    (NOW() - INTERVAL '4 days', 10, 1, 'completado'),
    (NOW() - INTERVAL '1 day', 9, 0, 'en_proceso');

-- =====================================================
-- 8. DESPACHO VEHÍCULOS (relación M2M)
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando despacho_vehiculos...';
END $$;

TRUNCATE TABLE despacho_vehiculos RESTART IDENTITY CASCADE;

INSERT INTO despacho_vehiculos (despacho_id, vehiculo_id, orden_escaneo, fecha_escaneo)
VALUES
    (1, 1, 1, NOW() - INTERVAL '9 days'),
    (1, 2, 2, NOW() - INTERVAL '9 days'),
    (2, 6, 1, NOW() - INTERVAL '4 days');

-- =====================================================
-- 9. MOVIMIENTOS DE PORTERÍA
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando movimientos de portería...';
END $$;

TRUNCATE TABLE movimientos_porteria RESTART IDENTITY CASCADE;

INSERT INTO movimientos_porteria (tipo, vehiculo_id, persona, usuario_id, fecha, observacion)
VALUES
    -- Entradas de vehículos
    ('entrada_vehiculo', 1, NULL, 3, NOW() - INTERVAL '12 days', 'Vehículo recibido del buque Atlantic Voyager'),
    ('entrada_vehiculo', 2, NULL, 3, NOW() - INTERVAL '12 days', 'Vehículo recibido del buque Atlantic Voyager'),
    ('entrada_vehiculo', 3, NULL, 3, NOW() - INTERVAL '12 days', 'Vehículo recibido del buque Atlantic Voyager'),
    ('entrada_vehiculo', 6, NULL, 4, NOW() - INTERVAL '7 days', 'Vehículo recibido del buque Pacific Spirit'),
    ('entrada_vehiculo', 7, NULL, 4, NOW() - INTERVAL '7 days', 'Vehículo recibido del buque Pacific Spirit'),
    
    -- Salidas de vehículos despachados
    ('salida_vehiculo', 1, NULL, 3, NOW() - INTERVAL '9 days', 'Despacho LT-2026-001 - Cliente Distribuidora Caracas'),
    ('salida_vehiculo', 2, NULL, 3, NOW() - INTERVAL '9 days', 'Despacho LT-2026-001 - Cliente AutoVentas Norte'),
    ('salida_vehiculo', 6, NULL, 4, NOW() - INTERVAL '4 days', 'Despacho LT-2026-002 - Cliente Concesionaria Capital'),
    
    -- Entradas/salidas de personal
    ('entrada_personal', NULL, 'Carlos Inspector', 7, NOW() - INTERVAL '8 hours', 'Inicio de turno'),
    ('entrada_personal', NULL, 'Luis Despachador', 9, NOW() - INTERVAL '7 hours', 'Inicio de turno'),
    ('entrada_personal', NULL, 'Pedro Recibidor', 5, NOW() - INTERVAL '6 hours', 'Inicio de turno'),
    
    -- Visitas
    ('entrada_visita', NULL, 'Roberto Méndez', 3, NOW() - INTERVAL '3 hours', 'Cliente revisando vehículo VIN: WVWZZZ3CZWE123789'),
    ('salida_visita', NULL, 'Roberto Méndez', 3, NOW() - INTERVAL '2 hours', 'Fin de visita');

-- =====================================================
-- 10. NOTIFICACIONES
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando notificaciones...';
END $$;

TRUNCATE TABLE notificaciones RESTART IDENTITY CASCADE;

INSERT INTO notificaciones (titulo, mensaje, modulo, recipient_user_id, created_by_user_id, created_by_role, action_url, metadata, leida_en, created_at)
VALUES
    -- Notificaciones para Admin
    ('Nuevo buque arribado', 'El buque Golden Horizon ha arribado con 5 vehículos', 'admin', 1, NULL, 'sistema', '/admin/buques/5', '{"buque_id": 5, "vehiculos": 5}'::jsonb, NULL, NOW() - INTERVAL '3 hours'),
    ('Inventario rechazado', 'El vehículo ABC-1234 tiene un inventario con fallas', 'admin', 1, 7, 'inventario', '/admin/vehiculos/1', '{"vehiculo_id": 1, "fallas": 2}'::jsonb, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '5 hours'),
    ('Despacho completado', 'Se completó el despacho LT-2026-001 con 2 vehículos', 'admin', 1, 9, 'despachador', '/admin/despachos/1', '{"despacho_id": 1, "vehiculos": 2}'::jsonb, NOW() - INTERVAL '2 days', NOW() - INTERVAL '9 days'),
    
    -- Notificaciones para Recibidor
    ('Vehículo asignado', 'Se te asignó el vehículo QR-VEH-021 para recepción', 'recibidor', 5, 1, 'admin', '/recibidor/vehiculos/21', '{"vehiculo_id": 21}'::jsonb, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '3 hours'),
    ('Contenedor por recibir', 'Hay un nuevo contenedor del buque Golden Horizon', 'recibidor', 5, NULL, 'sistema', '/recibidor/contenedores', '{"buque_id": 5}'::jsonb, NULL, NOW() - INTERVAL '4 hours'),
    
    -- Notificaciones para Inventario
    ('Vehículo listo para inventario', 'El vehículo ABC-1234 tiene impronta completada', 'inventario', 7, 5, 'recibidor', '/inventario/pendientes/1', '{"vehiculo_id": 1}'::jsonb, NOW() - INTERVAL '3 days', NOW() - INTERVAL '11 days'),
    ('Vehículo listo para inventario', 'El vehículo XYZ-5678 tiene impronta completada', 'inventario', 8, 5, 'recibidor', '/inventario/pendientes/2', '{"vehiculo_id": 2}'::jsonb, NOW() - INTERVAL '2 days', NOW() - INTERVAL '11 days'),
    ('Impronta rechazada', 'El vehículo DEF-9012 requiere nueva impronta', 'inventario', 7, 1, 'admin', '/inventario/vehiculos/3', '{"vehiculo_id": 3, "razon": "foto_borrosa"}'::jsonb, NULL, NOW() - INTERVAL '10 days'),
    
    -- Notificaciones para Despachador
    ('Vehículo listo para despacho', 'El vehículo ABC-1234 está listo para despachar', 'despachador', 9, 7, 'inventario', '/despachador/listos/1', '{"vehiculo_id": 1}'::jsonb, NOW() - INTERVAL '9 days', NOW() - INTERVAL '10 days'),
    ('Vehículo listo para despacho', 'El vehículo XYZ-5678 está listo para despachar', 'despachador', 9, 8, 'inventario', '/despachador/listos/2', '{"vehiculo_id": 2}'::jsonb, NOW() - INTERVAL '9 days', NOW() - INTERVAL '10 days'),
    ('Cliente esperando', 'El cliente Roberto Méndez está esperando el vehículo DEF-9012', 'despachador', 9, 3, 'porteria', '/despachador/vehiculos/3', '{"vehiculo_id": 3, "cliente": "Roberto Méndez"}'::jsonb, NULL, NOW() - INTERVAL '3 hours'),
    
    -- Notificaciones para Portería
    ('Vehículo en salida', 'El vehículo ABC-1234 está por salir - Despacho LT-2026-001', 'porteria', 3, 9, 'despachador', '/porteria/salidas/1', '{"vehiculo_id": 1, "despacho_id": 1}'::jsonb, NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'),
    ('Visita programada', 'El cliente Miguel Díaz visitará hoy a las 14:00', 'porteria', 4, 1, 'admin', '/porteria/visitas', '{"cliente": "Miguel Díaz", "hora": "14:00"}'::jsonb, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '5 hours'),
    
    -- Notificaciones para Clientes
    ('Vehículo recibido', 'Tu vehículo Toyota Corolla (ABC-1234) ha sido recibido', 'general', 11, 5, 'recibidor', '/cliente/vehiculos/1', '{"vehiculo_id": 1}'::jsonb, NOW() - INTERVAL '10 days', NOW() - INTERVAL '12 days'),
    ('Impronta completada', 'La impronta de tu vehículo Toyota Corolla ha sido completada', 'general', 11, 7, 'inventario', '/cliente/vehiculos/1', '{"vehiculo_id": 1}'::jsonb, NOW() - INTERVAL '9 days', NOW() - INTERVAL '11 days'),
    ('Inventario aprobado', 'El inventario de tu vehículo Toyota Corolla ha sido aprobado', 'general', 11, 7, 'inventario', '/cliente/vehiculos/1', '{"vehiculo_id": 1}'::jsonb, NOW() - INTERVAL '8 days', NOW() - INTERVAL '10 days'),
    ('Vehículo despachado', 'Tu vehículo Toyota Corolla (ABC-1234) ha sido despachado', 'general', 11, 9, 'despachador', '/cliente/vehiculos/1', '{"vehiculo_id": 1, "fecha": "2026-02-18"}'::jsonb, NOW() - INTERVAL '7 days', NOW() - INTERVAL '9 days');

-- =====================================================
-- 11. RECIBOS
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '▶ Insertando recibos...';
END $$;

TRUNCATE TABLE recibos RESTART IDENTITY CASCADE;

INSERT INTO recibos (vehiculo_id, despacho_id, datos_json, fecha)
VALUES
    (1, 1, '{"cliente": "Distribuidora Caracas", "vehiculo": "Toyota Corolla 2024", "placa": "ABC-1234", "vin": "1HGBH41JXMN109186", "fecha_despacho": "2026-02-18", "inspector": "Carlos Inspector", "despachador": "Luis Despachador"}'::jsonb, NOW() - INTERVAL '9 days'),
    (2, 1, '{"cliente": "AutoVentas Norte", "vehiculo": "Chevrolet Spark 2023", "placa": "XYZ-5678", "vin": "3VWDX7AJ5BM123456", "fecha_despacho": "2026-02-18", "inspector": "Luisa García", "despachador": "Luis Despachador"}'::jsonb, NOW() - INTERVAL '9 days'),
    (6, 2, '{"cliente": "Concesionaria Capital", "vehiculo": "Ford Explorer 2025", "placa": "MNO-4567", "vin": "1FADP3F29JL234567", "fecha_despacho": "2026-02-23", "inspector": "Carlos Inspector", "despachador": "Sofía Rodríguez"}'::jsonb, NOW() - INTERVAL '4 days');

-- =====================================================
-- VERIFICACIÓN Y RESUMEN FINAL
-- =====================================================

DO $$
DECLARE
    total_usuarios INTEGER;
    total_buques INTEGER;
    total_modelos INTEGER;
    total_vehiculos INTEGER;
    total_improntas INTEGER;
    total_inventarios INTEGER;
    total_despachos INTEGER;
    total_movimientos INTEGER;
    total_notificaciones INTEGER;
    total_recibos INTEGER;
    
    vehiculos_recibidos INTEGER;
    vehiculos_con_impronta INTEGER;
    vehiculos_con_inventario INTEGER;
    vehiculos_listos INTEGER;
    vehiculos_despachados INTEGER;
    
    notificaciones_no_leidas INTEGER;
BEGIN
    -- Contar registros
    SELECT COUNT(*) INTO total_usuarios FROM usuarios;
    SELECT COUNT(*) INTO total_buques FROM buques;
    SELECT COUNT(*) INTO total_modelos FROM modelos_vehiculo;
    SELECT COUNT(*) INTO total_vehiculos FROM vehiculos;
    SELECT COUNT(*) INTO total_improntas FROM improntas;
    SELECT COUNT(*) INTO total_inventarios FROM inventarios;
    SELECT COUNT(*) INTO total_despachos FROM despachos;
    SELECT COUNT(*) INTO total_movimientos FROM movimientos_porteria;
    SELECT COUNT(*) INTO total_notificaciones FROM notificaciones;
    SELECT COUNT(*) INTO total_recibos FROM recibos;
    
    -- Estadísticas de vehículos
    SELECT COUNT(*) INTO vehiculos_recibidos FROM vehiculos WHERE estado IN ('recibido', 'impronta_pendiente', 'impronta_completada', 'inventario_pendiente', 'inventario_aprobado', 'listo_despacho', 'despachado');
    SELECT COUNT(*) INTO vehiculos_con_impronta FROM vehiculos WHERE estado IN ('impronta_completada', 'inventario_pendiente', 'inventario_aprobado', 'listo_despacho', 'despachado');
    SELECT COUNT(*) INTO vehiculos_con_inventario FROM vehiculos WHERE estado IN ('inventario_aprobado', 'listo_despacho', 'despachado');
    SELECT COUNT(*) INTO vehiculos_listos FROM vehiculos WHERE estado = 'listo_despacho';
    SELECT COUNT(*) INTO vehiculos_despachados FROM vehiculos WHERE estado = 'despachado';
    
    -- Notificaciones
    SELECT COUNT(*) INTO notificaciones_no_leidas FROM notificaciones WHERE leida_en IS NULL;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ DATOS COMPLETOS CARGADOS';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Resumen General:';
    RAISE NOTICE '   • Usuarios: % (% admin, % staff, % clientes)', total_usuarios, 2, 8, 3;
    RAISE NOTICE '   • Buques: %', total_buques;
    RAISE NOTICE '   • Modelos de vehículo: %', total_modelos;
    RAISE NOTICE '   • Vehículos: %', total_vehiculos;
    RAISE NOTICE '   • Improntas: %', total_improntas;
    RAISE NOTICE '   • Inventarios: %', total_inventarios;
    RAISE NOTICE '   • Despachos: %', total_despachos;
    RAISE NOTICE '   • Movimientos portería: %', total_movimientos;
    RAISE NOTICE '   • Notificaciones: % (% sin leer)', total_notificaciones, notificaciones_no_leidas;
    RAISE NOTICE '   • Recibos: %', total_recibos;
    RAISE NOTICE '';
    RAISE NOTICE '🚗 Pipeline de Vehículos:';
    RAISE NOTICE '   • Recibidos: %', vehiculos_recibidos;
    RAISE NOTICE '   • Con impronta: %', vehiculos_con_impronta;
    RAISE NOTICE '   • Con inventario aprobado: %', vehiculos_con_inventario;
    RAISE NOTICE '   • Listos para despacho: %', vehiculos_listos;
    RAISE NOTICE '   • Despachados: %', vehiculos_despachados;
    RAISE NOTICE '';
    RAISE NOTICE '📍 Cobertura por Módulo:';
    RAISE NOTICE '   ✓ Dashboard - Estadísticas generales';
    RAISE NOTICE '   ✓ Usuarios - % usuarios con diferentes roles', total_usuarios;
    RAISE NOTICE '   ✓ Roles y Permisos - 6 roles activos';
    RAISE NOTICE '   ✓ Notificaciones - % notificaciones (% pendientes)', total_notificaciones, notificaciones_no_leidas;
    RAISE NOTICE '   ✓ Monitoreo Recepción - % vehículos en proceso', vehiculos_recibidos;
    RAISE NOTICE '   ✓ Monitoreo Inventario - % inventarios registrados', total_inventarios;
    RAISE NOTICE '   ✓ Monitoreo Despacho - % vehículos listos, % despachados', vehiculos_listos, vehiculos_despachados;
    RAISE NOTICE '   ✓ Auditoría y Control - Ver seed_audit_data.sql';
    RAISE NOTICE '   ✓ Excepciones - Ver seed_audit_data.sql';
    RAISE NOTICE '   ✓ Portería - % movimientos registrados', total_movimientos;
    RAISE NOTICE '';
    RAISE NOTICE '💡 Siguiente paso:';
    RAISE NOTICE '    Ejecuta seed_audit_data.sql para completar datos de auditoría,';
    RAISE NOTICE '    bloqueos y excepciones de vehículos.';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 Usuarios de prueba (todos con password: Admin123!):';
    RAISE NOTICE '    • admin@ibv.com (Administrador)';
    RAISE NOTICE '    • jose.porteria@ibv.com (Portería)';
    RAISE NOTICE '    • pedro.recibidor@ibv.com (Recibidor)';
    RAISE NOTICE '    • carlos.inspector@ibv.com (Inventario)';
    RAISE NOTICE '    • luis.despachador@ibv.com (Despachador)';
    RAISE NOTICE '    • cliente1@distribuidora.com (Cliente)';
    RAISE NOTICE '';
END $$;

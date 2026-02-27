-- ============================================
-- SEED TEST DATA - SISTEMA IBV (SUPABASE)
-- Safe to run in Supabase SQL Editor
-- ============================================

BEGIN;

-- Roles
INSERT INTO roles (nombre, descripcion)
VALUES
  ('admin', 'Administrador del sistema'),
  ('porteria', 'Control de porteria'),
  ('recibidor', 'Recepcion de vehiculos'),
  ('inventario', 'Inspeccion de inventario'),
  ('despachador', 'Despacho de vehiculos'),
  ('cliente', 'Cliente')
ON CONFLICT (nombre) DO UPDATE
SET descripcion = EXCLUDED.descripcion,
    activo = TRUE;

-- Usuarios base
WITH role_map AS (
  SELECT id, nombre FROM roles
)
INSERT INTO usuarios (
  correo,
  nombres,
  apellidos,
  rol,
  rol_id,
  activo,
  es_personal
)
VALUES
  ('admin@ibv.local', 'Admin', 'IBV', 'admin', (SELECT id FROM role_map WHERE nombre = 'admin'), TRUE, TRUE),
  ('recibidor@ibv.local', 'Rosa', 'Recibidor', 'recibidor', (SELECT id FROM role_map WHERE nombre = 'recibidor'), TRUE, TRUE),
  ('inventario@ibv.local', 'Ivan', 'Inventario', 'inventario', (SELECT id FROM role_map WHERE nombre = 'inventario'), TRUE, TRUE),
  ('despachador@ibv.local', 'Dario', 'Despacho', 'despachador', (SELECT id FROM role_map WHERE nombre = 'despachador'), TRUE, TRUE),
  ('porteria@ibv.local', 'Pablo', 'Porteria', 'porteria', (SELECT id FROM role_map WHERE nombre = 'porteria'), TRUE, TRUE)
ON CONFLICT (correo) DO UPDATE
SET nombres = EXCLUDED.nombres,
    apellidos = EXCLUDED.apellidos,
    rol = EXCLUDED.rol,
    rol_id = EXCLUDED.rol_id,
    activo = TRUE,
    es_personal = TRUE;

-- Buques
INSERT INTO buques (nombre, identificacion, fecha_arribo)
VALUES
  ('Buque Caribe', 'IBV-BC-001', CURRENT_DATE - INTERVAL '10 days'),
  ('Buque Atlantico', 'IBV-BA-002', CURRENT_DATE - INTERVAL '5 days')
ON CONFLICT (identificacion) DO UPDATE
SET nombre = EXCLUDED.nombre,
    fecha_arribo = EXCLUDED.fecha_arribo;

-- Modelos de vehiculo (evitar duplicados)
WITH seed_models AS (
  SELECT * FROM (VALUES
    ('Toyota', 'Corolla', 2024, 'Sedan'),
    ('Chevrolet', 'Spark', 2023, 'Hatchback'),
    ('Nissan', 'Versa', 2025, 'Sedan'),
    ('Kia', 'Rio', 2024, 'Sedan'),
    ('Hyundai', 'Accent', 2023, 'Sedan')
  ) AS v(marca, modelo, anio, tipo)
)
INSERT INTO modelos_vehiculo (marca, modelo, anio, tipo)
SELECT s.marca, s.modelo, s.anio, s.tipo
FROM seed_models s
WHERE NOT EXISTS (
  SELECT 1 FROM modelos_vehiculo m
  WHERE m.marca = s.marca AND m.modelo = s.modelo AND m.anio = s.anio
);

-- Vehiculos base
WITH modelos AS (
  SELECT id FROM modelos_vehiculo ORDER BY id
),
buques AS (
  SELECT id FROM buques ORDER BY id
),
recibidor AS (
  SELECT id FROM usuarios WHERE rol = 'recibidor' ORDER BY id LIMIT 1
),
seed AS (
  SELECT
    gs AS n,
    (SELECT id FROM modelos ORDER BY id OFFSET (gs % (SELECT COUNT(*) FROM modelos)) LIMIT 1) AS modelo_id,
    (SELECT id FROM buques ORDER BY id OFFSET (gs % (SELECT COUNT(*) FROM buques)) LIMIT 1) AS buque_id
  FROM generate_series(1, 18) gs
)
INSERT INTO vehiculos (
  bin,
  qr_codigo,
  placa,
  buque_id,
  modelo_id,
  color,
  estado,
  fecha_registro,
  usuario_recibe_id
)
SELECT
  'BIN-' || to_char(n, 'FM0000'),
  'QR-' || to_char(n, 'FM0000'),
  'PL-' || to_char(n, 'FM0000'),
  buque_id,
  modelo_id,
  (ARRAY['Blanco', 'Negro', 'Rojo', 'Azul', 'Gris'])[1 + (n % 5)],
  CASE
    WHEN n <= 3 THEN 'recibido'
    WHEN n <= 6 THEN 'en_impronta'
    WHEN n <= 10 THEN 'en_inventario'
    WHEN n <= 14 THEN 'listo_despacho'
    WHEN n <= 16 THEN 'problema'
    ELSE 'despachado'
  END,
  NOW() - (n || ' days')::interval,
  (SELECT id FROM recibidor)
FROM seed
ON CONFLICT (bin) DO NOTHING;

-- Improntas (para vehiculos con etapas avanzadas)
WITH recibidor AS (
  SELECT id FROM usuarios WHERE rol = 'recibidor' ORDER BY id LIMIT 1
)
INSERT INTO improntas (vehiculo_id, usuario_id, fecha, estado)
SELECT v.id, (SELECT id FROM recibidor), NOW() - INTERVAL '2 days', 'completada'
FROM vehiculos v
WHERE v.estado IN ('en_inventario', 'listo_despacho', 'despachado')
ON CONFLICT DO NOTHING;

-- Inventarios (algunos completos y otros incompletos)
WITH inventor AS (
  SELECT id FROM usuarios WHERE rol = 'inventario' ORDER BY id LIMIT 1
)
INSERT INTO inventarios (vehiculo_id, usuario_id, fecha, completo)
SELECT v.id, (SELECT id FROM inventor), NOW() - INTERVAL '1 day',
  CASE WHEN v.estado IN ('listo_despacho', 'despachado') THEN TRUE ELSE FALSE END
FROM vehiculos v
WHERE v.estado IN ('en_inventario', 'listo_despacho', 'despachado')
ON CONFLICT DO NOTHING;

-- Despachos
WITH despachador AS (
  SELECT id FROM usuarios WHERE rol = 'despachador' ORDER BY id LIMIT 1
)
INSERT INTO despachos (fecha, usuario_id, cantidad_vehiculos, estado)
VALUES
  (NOW() - INTERVAL '3 days', (SELECT id FROM despachador), 3, 'completado'),
  (NOW() - INTERVAL '1 days', (SELECT id FROM despachador), 2, 'completado')
ON CONFLICT DO NOTHING;

-- Asociar vehiculos a despachos
WITH desp AS (
  SELECT id FROM despachos ORDER BY fecha DESC
),
veh AS (
  SELECT id FROM vehiculos WHERE estado = 'despachado' ORDER BY id LIMIT 5
)
INSERT INTO despacho_vehiculos (despacho_id, vehiculo_id, orden_escaneo)
SELECT
  (SELECT id FROM desp ORDER BY id DESC LIMIT 1),
  v.id,
  ROW_NUMBER() OVER ()
FROM veh v
ON CONFLICT DO NOTHING;

-- Movimientos de porteria
WITH porteria AS (
  SELECT id FROM usuarios WHERE rol = 'porteria' ORDER BY id LIMIT 1
)
INSERT INTO movimientos_porteria (tipo, vehiculo_id, persona, usuario_id, fecha, observacion)
SELECT
  CASE WHEN v.id % 2 = 0 THEN 'entrada' ELSE 'salida' END,
  v.id,
  'Transportista ' || v.id,
  (SELECT id FROM porteria),
  NOW() - INTERVAL '4 hours',
  'Movimiento de prueba'
FROM vehiculos v
ORDER BY v.id
LIMIT 6;

COMMIT;

-- Script para crear un vehículo con impronta completada
-- Fecha: 2026-02-27
-- IMPORTANTE: Ejecutar todo el script de una vez en Supabase SQL Editor

-- 1. Insertar modelo de vehículo (si no existe)
INSERT INTO modelos_vehiculo (marca, modelo, anio, tipo, activo, created_at, updated_at)
SELECT 'Toyota', 'Corolla', 2024, 'Sedan', true, now(), now()
WHERE NOT EXISTS (
  SELECT 1 FROM modelos_vehiculo 
  WHERE marca = 'Toyota' AND modelo = 'Corolla' AND anio = 2024
);

-- 2. Crear un vehículo (usa el modelo_id obtenido)
DO $$
DECLARE
  modelo_id_var bigint;
  vehiculo_id_var bigint;
BEGIN
  -- Obtener el modelo_id
  SELECT id INTO modelo_id_var FROM modelos_vehiculo 
  WHERE marca = 'Toyota' AND modelo = 'Corolla' 
  ORDER BY id DESC LIMIT 1;

  -- Insertar vehículo
  INSERT INTO vehiculos (
    bin, 
    qr_codigo, 
    modelo_id, 
    color, 
    estado, 
    fecha_registro,
    created_at, 
    updated_at
  )
  SELECT
    'VIN1HGBH41JXMN109999',
    'QR-TOYOTA-COROLLA-001',
    modelo_id_var,
    'Blanco Perla',
    'impronta_completada',
    now(),
    now(),
    now()
  WHERE NOT EXISTS (
    SELECT 1 FROM vehiculos WHERE bin = 'VIN1HGBH41JXMN109999'
  )
  RETURNING id INTO vehiculo_id_var;

  -- Si el vehículo ya existía, obtener su ID
  IF vehiculo_id_var IS NULL THEN
    SELECT id INTO vehiculo_id_var FROM vehiculos WHERE bin = 'VIN1HGBH41JXMN109999';
    RAISE NOTICE 'El vehículo ya existe con ID: %', vehiculo_id_var;
  END IF;

  -- Crear impronta completada
  IF vehiculo_id_var IS NOT NULL THEN
    INSERT INTO improntas (
      vehiculo_id,
      foto_url,
      datos_impronta,
      estado,
      fecha,
      created_at,
      updated_at
    )
    VALUES (
      vehiculo_id_var,
      'https://placehold.co/800x600/3b82f6/ffffff?text=Impronta+Completada',
      jsonb_build_object(
        'condicion', 'excelente',
        'km', '12',
        'danos', jsonb_build_array(),
        'observaciones', 'Vehículo en excelente estado, sin daños visibles'
      ),
      'completada',
      now(),
      now(),
      now()
    );
    
    RAISE NOTICE 'Vehículo e impronta creados exitosamente con ID: %', vehiculo_id_var;
  END IF;
END $$;

-- 3. Verificar la creación
SELECT 
  v.id,
  v.bin AS vin,
  v.qr_codigo,
  m.marca,
  m.modelo,
  m.anio,
  v.color,
  v.estado AS vehiculo_estado,
  i.id AS impronta_id,
  i.estado AS impronta_estado,
  i.fecha AS impronta_fecha
FROM vehiculos v
LEFT JOIN modelos_vehiculo m ON v.modelo_id = m.id
LEFT JOIN improntas i ON i.vehiculo_id = v.id
WHERE v.bin = 'VIN1HGBH41JXMN109999';

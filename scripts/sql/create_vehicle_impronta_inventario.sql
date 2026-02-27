-- Crear vehículo con impronta completada (listo para inventario)
DO $$
DECLARE
  v_vehiculo_id BIGINT;
  v_impronta_id BIGINT;
BEGIN
  -- 1. Insertar vehículo
  INSERT INTO vehiculos (bin, qr_codigo, color, estado, fecha_registro)
  VALUES ('TEST-BIN-002', 'TEST-QR-002', 'Azul', 'en_impronta', NOW())
  ON CONFLICT (bin) DO UPDATE SET estado = 'en_impronta'
  RETURNING id INTO v_vehiculo_id;

  RAISE NOTICE 'Vehículo ID: %', v_vehiculo_id;

  -- 2. Insertar impronta con estado completada
  -- Columnas reales: vehiculo_id, datos_impronta(jsonb), estado, fecha
  INSERT INTO improntas (vehiculo_id, datos_impronta, estado, fecha)
  VALUES (
    v_vehiculo_id,
    '{"condicion": "bueno", "observaciones": "Sin daños"}'::jsonb,
    'completada',
    NOW()
  )
  RETURNING id INTO v_impronta_id;

  RAISE NOTICE 'Impronta ID: %', v_impronta_id;
END $$;

-- Verificar
SELECT v.id, v.bin, v.color, v.estado,
  i.id as impronta_id, i.estado as impronta_estado
FROM vehiculos v
LEFT JOIN improntas i ON i.vehiculo_id = v.id
WHERE v.bin = 'TEST-BIN-002';


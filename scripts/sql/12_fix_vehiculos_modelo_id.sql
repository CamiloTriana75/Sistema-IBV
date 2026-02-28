-- ============================================================================
-- FIX: Asignar modelo_id a vehículos que no lo tienen
-- ============================================================================
-- Problema: Los vehículos no tienen modelo_id, por lo que el join con 
-- modelos_vehiculo en el frontend devuelve null para marca/modelo/año
-- ============================================================================

-- 1. Verificar cuántos vehículos NO tienen modelo_id asignado
SELECT COUNT(*) AS "Vehículos sin modelo_id"
FROM vehiculos
WHERE modelo_id IS NULL;

-- 2. Verificar cuántos modelos hay disponibles
SELECT COUNT(*) AS "Modelos disponibles"
FROM modelos_vehiculo;

-- 3. Si no hay modelos, crear algunos modelos de ejemplo comunes
INSERT INTO modelos_vehiculo (marca, modelo, anio, tipo, activo)
VALUES 
    ('Toyota', 'Corolla', 2023, 'sedan', true),
    ('Honda', 'Civic', 2023, 'sedan', true),
    ('Ford', 'F-150', 2023, 'pickup', true),
    ('Chevrolet', 'Silverado', 2023, 'pickup', true),
    ('Nissan', 'Sentra', 2023, 'sedan', true),
    ('Mazda', 'CX-5', 2023, 'suv', true),
    ('Hyundai', 'Elantra', 2023, 'sedan', true),
    ('Kia', 'Sportage', 2023, 'suv', true),
    ('Volkswagen', 'Jetta', 2023, 'sedan', true),
    ('BMW', '320i', 2023, 'sedan', true)
ON CONFLICT DO NOTHING;

-- 4. Asignar un modelo aleatorio a los vehículos que no tienen modelo_id
-- Esto es solo para datos de prueba. En producción deberías asignar el modelo correcto.
UPDATE vehiculos
SET modelo_id = (
    SELECT id 
    FROM modelos_vehiculo 
    ORDER BY RANDOM() 
    LIMIT 1
)
WHERE modelo_id IS NULL
AND EXISTS (SELECT 1 FROM modelos_vehiculo LIMIT 1);

-- 5. Verificar los resultados
SELECT 
    v.id,
    v.bin,
    v.placa,
    v.modelo_id,
    m.marca,
    m.modelo,
    m.anio
FROM vehiculos v
LEFT JOIN modelos_vehiculo m ON v.modelo_id = m.id
ORDER BY v.id DESC
LIMIT 10;

-- 6. Resumen final
SELECT 
    COUNT(*) FILTER (WHERE modelo_id IS NOT NULL) AS "Con modelo asignado",
    COUNT(*) FILTER (WHERE modelo_id IS NULL) AS "Sin modelo asignado",
    COUNT(*) AS "Total vehículos"
FROM vehiculos;

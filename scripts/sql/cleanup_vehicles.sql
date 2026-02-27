-- Script para limpiar todos los vehículos EXCEPTO el Toyota Corolla (ID: 19)
-- Fecha: 2026-02-27
-- Descripción: Elimina despachos, improntas, inventarios y vehículos
--              manteniendo solo: ID=19 (Toyota Corolla VIN1HGBH41JXMN109999)

-- Paso 1: Eliminar despacho_vehiculos de todos los vehículos EXCEPTO ID 19
DELETE FROM despacho_vehiculos
WHERE vehiculo_id != 19;

-- Paso 2: Eliminar despachos que NO tienen vehículos asociados
DELETE FROM despachos
WHERE id NOT IN (
  SELECT DISTINCT despacho_id FROM despacho_vehiculos
);

-- Paso 3: Eliminar inventarios de todos los vehículos EXCEPTO ID 19
DELETE FROM inventarios
WHERE vehiculo_id != 19;

-- Paso 4: Eliminar improntas de todos los vehículos EXCEPTO ID 19
DELETE FROM improntas
WHERE vehiculo_id != 19;

-- Paso 5: Eliminar vehículos EXCEPTO ID 19
DELETE FROM vehiculos
WHERE id != 19;

-- Verificar resultado: solo debe quedar el Toyota Corolla
SELECT 
  v.id,
  v.bin as vin,
  m.id as modelo_id,
  m.marca,
  m.modelo,
  v.color,
  v.estado,
  v.created_at
FROM vehiculos v
LEFT JOIN modelos_vehiculo m ON v.modelo_id = m.id
ORDER BY v.created_at DESC;

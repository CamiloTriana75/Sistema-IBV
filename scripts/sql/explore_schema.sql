-- Script para explorar la estructura de la tabla vehiculos
-- Esto te mostrará las columnas reales de la tabla

SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'vehiculos'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- ============================================================================
-- FIX: Asignar usuario_recibe a vehículos que no lo tienen
-- ============================================================================
-- Problema: Los vehículos no tienen usuario_recibe_id, por lo que cliente 
-- aparece vacío en el frontend
-- ============================================================================

-- 1. Ver qué usuarios existen
SELECT id, nombres, apellidos, rol
FROM usuarios
WHERE activo = true
ORDER BY id;

-- 2. Contar vehículos sin usuario asignado
SELECT COUNT(*) AS "Vehículos sin usuario"
FROM vehiculos
WHERE usuario_recibe_id IS NULL;

-- 3. Asignar un usuario a los vehículos que no tienen
-- Esto asigna al primer usuario activo (generalmente el admin o primer usuario creado)
UPDATE vehiculos
SET usuario_recibe_id = (
    SELECT id 
    FROM usuarios 
    WHERE activo = true
    ORDER BY id 
    LIMIT 1
)
WHERE usuario_recibe_id IS NULL
AND EXISTS (SELECT 1 FROM usuarios WHERE activo = true LIMIT 1);

-- 4. Verificar los resultados
SELECT 
    v.id,
    v.bin,
    v.placa,
    v.usuario_recibe_id,
    u.nombres || ' ' || u.apellidos AS usuario_nombre,
    u.rol
FROM vehiculos v
LEFT JOIN usuarios u ON v.usuario_recibe_id = u.id
ORDER BY v.id DESC
LIMIT 10;

-- 5. Resumen
SELECT 
    COUNT(*) FILTER (WHERE usuario_recibe_id IS NOT NULL) AS "Con usuario asignado",
    COUNT(*) FILTER (WHERE usuario_recibe_id IS NULL) AS "Sin usuario asignado",
    COUNT(*) AS "Total vehículos"
FROM vehiculos;

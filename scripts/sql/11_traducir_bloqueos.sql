-- =====================================================
-- Script de Migración: Traducir tabla bloqueos_vehiculos al español
-- Fecha: 2026-02-27
-- Descripción: Renombra columnas y actualiza valores de enums al español
-- =====================================================

-- Paso 1: Eliminar constraints antiguos PRIMERO
ALTER TABLE bloqueos_vehiculos 
    DROP CONSTRAINT IF EXISTS bloqueos_vehiculos_reason_check;

-- Paso 2: Actualizar valores de reason a español
UPDATE bloqueos_vehiculos
SET reason = CASE reason
    WHEN 'stuck_in_status' THEN 'bloqueada_en_estado'
    WHEN 'awaiting_manual_review' THEN 'esperando_revision_manual'
    WHEN 'pending_escalation' THEN 'escalacion_pendiente'
    WHEN 'maintenance' THEN 'mantenimiento'
    WHEN 'other' THEN 'otra'
    ELSE reason
END;

-- Paso 3: Renombrar columnas al español
ALTER TABLE bloqueos_vehiculos 
    RENAME COLUMN locked_by_user_id TO bloqueado_por_usuario_id;

ALTER TABLE bloqueos_vehiculos 
    RENAME COLUMN locked_by_role TO bloqueado_por_rol;

ALTER TABLE bloqueos_vehiculos 
    RENAME COLUMN reason TO razon;

ALTER TABLE bloqueos_vehiculos 
    RENAME COLUMN description TO descripcion;

ALTER TABLE bloqueos_vehiculos 
    RENAME COLUMN locked_at TO bloqueado_en;

ALTER TABLE bloqueos_vehiculos 
    RENAME COLUMN unlocked_at TO desbloqueado_en;

-- Paso 4: Agregar nuevos constraints con valores en español
ALTER TABLE bloqueos_vehiculos 
    ADD CONSTRAINT bloqueos_vehiculos_razon_check 
    CHECK (razon IN ('bloqueada_en_estado', 'esperando_revision_manual', 'escalacion_pendiente', 'mantenimiento', 'otra'));

-- Paso 5: Renombrar índices para consistencia
DROP INDEX IF EXISTS bloqueos_vehiculos_reason_idx;
DROP INDEX IF EXISTS bloqueos_vehiculos_locked_at_idx;

CREATE INDEX bloqueos_vehiculos_razon_idx 
    ON bloqueos_vehiculos(razon);
    
CREATE INDEX bloqueos_vehiculos_bloqueado_en_idx 
    ON bloqueos_vehiculos(bloqueado_en);

-- Verificación final
SELECT 
    'Migración bloqueos_vehiculos completada' as mensaje,
    COUNT(*) as total_bloqueos,
    COUNT(DISTINCT razon) as razones_distintas,
    COUNT(CASE WHEN desbloqueado_en IS NULL THEN 1 END) as bloqueos_activos
FROM bloqueos_vehiculos;

-- Mostrar distribución de bloqueos
SELECT 
    razon,
    COUNT(*) as cantidad,
    COUNT(CASE WHEN desbloqueado_en IS NULL THEN 1 END) as activos
FROM bloqueos_vehiculos
GROUP BY razon
ORDER BY cantidad DESC;

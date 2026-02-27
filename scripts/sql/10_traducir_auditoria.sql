-- =====================================================
-- Script de Migración: Traducir tabla auditoria_vehiculos al español
-- Fecha: 2026-02-27
-- Descripción: Renombra columnas y actualiza valores de enums al español
-- =====================================================

-- Paso 1: Eliminar constraints antiguos PRIMERO
ALTER TABLE auditoria_vehiculos 
    DROP CONSTRAINT IF EXISTS auditoria_vehiculos_action_type_check;

-- Paso 2: Actualizar valores de action_type a español
UPDATE auditoria_vehiculos
SET action_type = CASE action_type
    WHEN 'status_change' THEN 'cambio_estado'
    WHEN 'admin_override' THEN 'anulacion_admin'
    WHEN 'manual_unlock' THEN 'desbloqueo_manual'
    WHEN 'escalation' THEN 'escalacion'
    WHEN 'note_added' THEN 'nota_agregada'
    ELSE action_type
END;

-- Paso 3: Renombrar columnas al español
ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN changed_by_user_id TO cambiado_por_usuario_id;

ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN changed_by_role TO cambiado_por_rol;

ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN action_type TO tipo_accion;

ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN old_state TO estado_anterior;

ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN new_state TO estado_nuevo;

ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN reason TO razon;

ALTER TABLE auditoria_vehiculos 
    RENAME COLUMN created_at TO creada_en;

-- Paso 4: Agregar nuevos constraints con valores en español
ALTER TABLE auditoria_vehiculos 
    ADD CONSTRAINT auditoria_vehiculos_tipo_accion_check 
    CHECK (tipo_accion IN ('cambio_estado', 'anulacion_admin', 'desbloqueo_manual', 'escalacion', 'nota_agregada'));

-- Paso 5: Renombrar índices para consistencia
DROP INDEX IF EXISTS auditoria_vehiculos_changed_by_user_id_idx;
DROP INDEX IF EXISTS auditoria_vehiculos_action_type_idx;
DROP INDEX IF EXISTS auditoria_vehiculos_created_at_idx;

CREATE INDEX auditoria_vehiculos_cambiado_por_usuario_id_idx 
    ON auditoria_vehiculos(cambiado_por_usuario_id);
    
CREATE INDEX auditoria_vehiculos_tipo_accion_idx 
    ON auditoria_vehiculos(tipo_accion);
    
CREATE INDEX auditoria_vehiculos_creada_en_idx 
    ON auditoria_vehiculos(creada_en);

-- Verificación final
SELECT 
    'Migración auditoria_vehiculos completada' as mensaje,
    COUNT(*) as total_registros,
    COUNT(DISTINCT tipo_accion) as tipos_accion_distintos
FROM auditoria_vehiculos;

-- Mostrar distribución de acciones
SELECT 
    tipo_accion,
    COUNT(*) as cantidad
FROM auditoria_vehiculos
GROUP BY tipo_accion
ORDER BY cantidad DESC;

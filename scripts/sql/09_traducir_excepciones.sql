-- =====================================================
-- Script de Migración: Traducir tabla excepciones_vehiculos al español
-- Fecha: 2026-02-27
-- Descripción: Renombra columnas y actualiza valores de enums al español
-- =====================================================

-- Paso 1: Eliminar constraints antiguos PRIMERO (para permitir valores en español)
ALTER TABLE excepciones_vehiculos 
    DROP CONSTRAINT IF EXISTS excepciones_vehiculos_exception_type_check;
    
ALTER TABLE excepciones_vehiculos 
    DROP CONSTRAINT IF EXISTS excepciones_vehiculos_severity_check;
    
ALTER TABLE excepciones_vehiculos 
    DROP CONSTRAINT IF EXISTS excepciones_vehiculos_status_check;

-- Paso 2: Actualizar valores de exception_type a español
UPDATE excepciones_vehiculos
SET exception_type = CASE exception_type
    WHEN 'stuck_in_status' THEN 'bloqueada_en_estado'
    WHEN 'delayed_more_than_3_days' THEN 'retrasada_mas_de_3_dias'
    WHEN 'missing_required_document' THEN 'documento_faltante'
    WHEN 'quality_issue' THEN 'problema_calidad'
    WHEN 'other' THEN 'otra'
    ELSE exception_type
END;

-- Paso 3: Actualizar valores de severity a español
UPDATE excepciones_vehiculos
SET severity = CASE severity
    WHEN 'low' THEN 'baja'
    WHEN 'medium' THEN 'media'
    WHEN 'high' THEN 'alta'
    WHEN 'critical' THEN 'critica'
    ELSE severity
END;

-- Paso 4: Actualizar valores de status a español
UPDATE excepciones_vehiculos
SET status = CASE status
    WHEN 'open' THEN 'abierta'
    WHEN 'in_progress' THEN 'en_progreso'
    WHEN 'resolved' THEN 'resuelta'
    WHEN 'escalated' THEN 'escalada'
    ELSE status
END;

-- Paso 5: Renombrar columnas al español
ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN exception_type TO tipo_excepcion;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN severity TO severidad;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN assigned_to_user_id TO asignado_a_usuario_id;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN resolved_at TO resuelta_en;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN resolved_by_user_id TO resuelta_por_usuario_id;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN resolution_notes TO notas_resolucion;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN created_at TO creada_en;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN description TO descripcion;

ALTER TABLE excepciones_vehiculos 
    RENAME COLUMN status TO estado;

-- Paso 6: Agregar nuevos constraints con valores en español
ALTER TABLE excepciones_vehiculos 
    ADD CONSTRAINT excepciones_vehiculos_tipo_excepcion_check 
    CHECK (tipo_excepcion IN ('bloqueada_en_estado', 'retrasada_mas_de_3_dias', 'documento_faltante', 'problema_calidad', 'otra'));

ALTER TABLE excepciones_vehiculos 
    ADD CONSTRAINT excepciones_vehiculos_severidad_check 
    CHECK (severidad IN ('baja', 'media', 'alta', 'critica'));

ALTER TABLE excepciones_vehiculos 
    ADD CONSTRAINT excepciones_vehiculos_estado_check 
    CHECK (estado IN ('abierta', 'en_progreso', 'resuelta', 'escalada'));

-- Paso 7: Renombrar índices para consistencia
DROP INDEX IF EXISTS excepciones_vehiculos_exception_type_idx;
DROP INDEX IF EXISTS excepciones_vehiculos_severity_idx;
DROP INDEX IF EXISTS excepciones_vehiculos_assigned_to_idx;

CREATE INDEX excepciones_vehiculos_tipo_excepcion_idx 
    ON excepciones_vehiculos(tipo_excepcion);
    
CREATE INDEX excepciones_vehiculos_severidad_idx 
    ON excepciones_vehiculos(severidad);
    
CREATE INDEX excepciones_vehiculos_asignado_a_idx 
    ON excepciones_vehiculos(asignado_a_usuario_id);

-- Verificación final
SELECT 
    'Migración completada' as mensaje,
    COUNT(*) as total_excepciones,
    COUNT(DISTINCT tipo_excepcion) as tipos_distintos,
    COUNT(DISTINCT severidad) as severidades_distintas,
    COUNT(DISTINCT estado) as estados_distintos
FROM excepciones_vehiculos;

-- Mostrar distribución de excepciones
SELECT 
    tipo_excepcion,
    severidad,
    estado,
    COUNT(*) as cantidad
FROM excepciones_vehiculos
GROUP BY tipo_excepcion, severidad, estado
ORDER BY cantidad DESC;

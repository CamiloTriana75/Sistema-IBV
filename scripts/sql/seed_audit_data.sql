-- ============================================
-- DATOS DE EJEMPLO - SISTEMA DE AUDITORÍA
-- Auditoría, Bloqueos y Excepciones
-- ============================================
--
-- PROPÓSITO:
--   Insertar datos de ejemplo realistas en:
--   - auditoria_vehiculos (logs de cambios)
--   - bloqueos_vehiculos (bloqueos activos/resueltos)
--   - excepciones_vehiculos (excepciones del sistema)
--
-- PREREQUISITOS:
--   - Ejecutar seed_test_data.sql primero
--   - Tener usuarios y vehículos ya creados
--
-- NOTA IMPORTANTE:
--   Este script usa IDs REALES de vehículos y usuarios de tu BD.
--   Usa subconsultas (CTEs) para obtener los IDs correctos automáticamente.
--   Si tienes menos de 18 vehículos, algunos ejemplos no se insertarán.
--   Es seguro ejecutar múltiples veces (usa ON CONFLICT DO NOTHING).
--
-- FECHA: 2026-02-27
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  CARGANDO DATOS DE EJEMPLO - SISTEMA DE AUDITORÍA     ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
END $$;

-- ============================================
-- 1. AUDITORÍA DE VEHÍCULOS
-- ============================================

DO $$ 
BEGIN
    RAISE NOTICE '▶ Insertando logs de auditoría...';
END $$;

-- Logs de cambios de estado normales
-- Usamos subconsultas para obtener IDs reales de vehículos
WITH vehiculos_ids AS (
  SELECT id, bin, ROW_NUMBER() OVER (ORDER BY id) as rn
  FROM vehiculos
  ORDER BY id
  LIMIT 18
),
recibidor_id AS (
  SELECT id FROM usuarios WHERE correo = 'recibidor@ibv.local' LIMIT 1
),
inventario_id AS (
  SELECT id FROM usuarios WHERE correo = 'inventario@ibv.local' LIMIT 1
),
admin_id AS (
  SELECT id FROM usuarios WHERE correo = 'admin@ibv.local' LIMIT 1
),
despachador_id AS (
  SELECT id FROM usuarios WHERE correo = 'despachador@ibv.local' LIMIT 1
)
INSERT INTO auditoria_vehiculos (
    vehiculo_id,
    cambiado_por_usuario_id,
    cambiado_por_rol,
    tipo_accion,
    estado_anterior,
    estado_nuevo,
    razon,
    metadata,
    creada_en
)
SELECT * FROM (VALUES
    -- Vehículo 1: recepción → impronta
    ((SELECT id FROM vehiculos_ids WHERE rn = 1), 
     (SELECT id FROM recibidor_id),
     'recibidor',
     'cambio_estado',
     '{"estado": "recibido", "fecha": "2026-02-20"}'::jsonb,
     '{"estado": "en_impronta", "fecha": "2026-02-21"}'::jsonb,
     'Inicio de proceso de impronta',
     '{"automatic": true, "timestamp": "2026-02-21T09:15:00Z"}'::jsonb,
     NOW() - INTERVAL '6 days'
    ),
    
    -- Vehículo 2: impronta → inventario
    ((SELECT id FROM vehiculos_ids WHERE rn = 2),
     (SELECT id FROM recibidor_id),
     'recibidor',
     'cambio_estado',
     '{"estado": "en_impronta", "impronta_completada": false}'::jsonb,
     '{"estado": "en_inventario", "impronta_completada": true}'::jsonb,
     'Impronta completada, enviado a inventario',
     '{"folio": "IMP-2026-0002", "inspector": "Rosa Recibidor"}'::jsonb,
     NOW() - INTERVAL '5 days'
    ),
    
    -- Vehículo 3: Admin override - forzar a listo_despacho
    ((SELECT id FROM vehiculos_ids WHERE rn = 3),
     (SELECT id FROM admin_id),
     'admin',
     'anulacion_admin',
     '{"estado": "en_inventario", "inventario_aprobado": false}'::jsonb,
     '{"estado": "listo_despacho", "inventario_aprobado": true}'::jsonb,
     'Cliente urgente - aprobación directa del Director',
     '{"priority": "high", "authorized_by": "Director Operaciones", "reason": "Pedido urgente"}'::jsonb,
     NOW() - INTERVAL '4 days'
    ),
    
    -- Vehículo 4: cambio normal inventario → listo_despacho
    ((SELECT id FROM vehiculos_ids WHERE rn = 4),
     (SELECT id FROM inventario_id),
     'inventario',
     'cambio_estado',
     '{"estado": "en_inventario", "inventario_resultado": {"aprobados": 15, "fallas": 0}}'::jsonb,
     '{"estado": "listo_despacho", "inventario_aprobado": true}'::jsonb,
     'Inventario aprobado sin observaciones',
     '{"inspector": "Ivan Inventario", "total_items": 15}'::jsonb,
     NOW() - INTERVAL '3 days'
    ),
    
    -- Vehículo 5: Admin override - desbloqueo manual
    ((SELECT id FROM vehiculos_ids WHERE rn = 5),
     (SELECT id FROM admin_id),
     'admin',
     'desbloqueo_manual',
     '{"estado": "problema", "bloqueado": true}'::jsonb,
     '{"estado": "en_inventario", "bloqueado": false}'::jsonb,
     'Problema de documentación resuelto - continuar proceso',
     '{"resolved_by": "Admin IBV", "issue": "missing_document"}'::jsonb,
     NOW() - INTERVAL '2 days'
    ),
    
    -- Vehículo 6: Escalada a supervisor
    ((SELECT id FROM vehiculos_ids WHERE rn = 6),
     (SELECT id FROM inventario_id),
     'inventario',
     'escalacion',
     '{"estado": "en_inventario", "dias_transcurridos": 5}'::jsonb,
     '{"estado": "en_inventario", "escalado": true}'::jsonb,
     'Vehículo atrapado en inventario por más de 3 días',
     '{"escalated_to": "supervisor", "reason": "delayed_more_than_3_days"}'::jsonb,
     NOW() - INTERVAL '1 day'
    ),
    
    -- Vehículo 7: Nota agregada por admin
    ((SELECT id FROM vehiculos_ids WHERE rn = 7),
     (SELECT id FROM admin_id),
     'admin',
     'nota_agregada',
     '{"estado": "listo_despacho"}'::jsonb,
     '{"estado": "listo_despacho"}'::jsonb,
     'Cliente solicita retener vehículo hasta nueva orden',
     '{"note_type": "retention", "client_request": true, "contact": "+58-412-1234567"}'::jsonb,
     NOW() - INTERVAL '12 hours'
    ),
    
    -- Vehículo 8: Cambio rápido despachador
    ((SELECT id FROM vehiculos_ids WHERE rn = 8),
     (SELECT id FROM despachador_id),
     'despachador',
     'cambio_estado',
     '{"estado": "listo_despacho", "lote": null}'::jsonb,
     '{"estado": "despachado", "lote": "LOTE-2026-001"}'::jsonb,
     'Despachado en lote matutino',
     '{"lote": "LOTE-2026-001", "hora": "08:30", "inspector": "Dario Despacho"}'::jsonb,
     NOW() - INTERVAL '6 hours'
    ),
    
    -- Vehículo 9: Admin override - saltarse inventario
    ((SELECT id FROM vehiculos_ids WHERE rn = 9),
     (SELECT id FROM admin_id),
     'admin',
     'anulacion_admin',
     '{"estado": "en_impronta", "inventario_completado": false}'::jsonb,
     '{"estado": "listo_despacho", "inventario_completado": false}'::jsonb,
     'Vehículo de prueba - no requiere inventario formal',
     '{"special_case": true, "vehicle_type": "internal_test"}'::jsonb,
     NOW() - INTERVAL '3 hours'
    ),
    
    -- Vehículo 10: Cambio normal con metadatos detallados
    ((SELECT id FROM vehiculos_ids WHERE rn = 10),
     (SELECT id FROM inventario_id),
     'inventario',
     'cambio_estado',
     '{"estado": "en_inventario", "inicio": "2026-02-25T10:00:00Z"}'::jsonb,
     '{"estado": "listo_despacho", "fin": "2026-02-27T11:30:00Z"}'::jsonb,
     'Inventario completado con observaciones menores',
     '{"duracion_horas": 25.5, "items_ok": 14, "items_observacion": 1, "observacion": "Rayón menor en puerta trasera"}'::jsonb,
     NOW() - INTERVAL '1 hour'
    )
) AS t(vehiculo_id, cambiado_por_usuario_id, cambiado_por_rol, tipo_accion, estado_anterior, estado_nuevo, razon, metadata, creada_en)
WHERE t.vehiculo_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. BLOQUEOS DE VEHÍCULOS
-- ============================================

DO $$ 
BEGIN
    RAISE NOTICE '▶ Insertando bloqueos de vehículos...';
END $$;

WITH vehiculos_ids AS (
  SELECT id, bin, ROW_NUMBER() OVER (ORDER BY id) as rn
  FROM vehiculos
  ORDER BY id
  LIMIT 18
),
recibidor_id AS (
  SELECT id FROM usuarios WHERE correo = 'recibidor@ibv.local' LIMIT 1
),
inventario_id AS (
  SELECT id FROM usuarios WHERE correo = 'inventario@ibv.local' LIMIT 1
),
admin_id AS (
  SELECT id FROM usuarios WHERE correo = 'admin@ibv.local' LIMIT 1
),
despachador_id AS (
  SELECT id FROM usuarios WHERE correo = 'despachador@ibv.local' LIMIT 1
)
INSERT INTO bloqueos_vehiculos (
    vehiculo_id,
    bloqueado_por_usuario_id,
    bloqueado_por_rol,
    razon,
    descripcion,
    bloqueado_en,
    desbloqueado_en,
    metadata
)
SELECT * FROM (VALUES
    -- Vehículo 11: Bloqueado actualmente - atrapado en estado
    ((SELECT id FROM vehiculos_ids WHERE rn = 11),
     (SELECT id FROM inventario_id),
     'inventario',
     'bloqueada_en_estado',
     'Vehículo no avanza de inventario - posible problema en sistema',
     NOW() - INTERVAL '2 days',
     NULL, -- Aún bloqueado
     '{"status_stuck": "en_inventario", "dias_atrapado": 2, "intentos_cambio": 3}'::jsonb
    ),
    
    -- Vehículo 12: Bloqueado activamente - esperando revisión
    ((SELECT id FROM vehiculos_ids WHERE rn = 12),
     (SELECT id FROM admin_id),
     'admin',
     'esperando_revision_manual',
     'Cliente reporta discrepancia en documentación - verificar antes de continuar',
     NOW() - INTERVAL '1 day',
     NULL, -- Aún bloqueado
     '{"reported_by": "cliente", "issue": "documentacion_inconsistente", "priority": "high"}'::jsonb
    ),
    
    -- Vehículo 5: Ya fue desbloqueado (relacionado con audit log anterior)
    ((SELECT id FROM vehiculos_ids WHERE rn = 5),
     (SELECT id FROM inventario_id),
     'inventario',
     'esperando_revision_manual',
     'Falta certificado de origen - esperando gestión',
     NOW() - INTERVAL '3 days',
     NOW() - INTERVAL '2 days', -- Desbloqueado
     '{"issue": "missing_document", "document_type": "certificado_origen", "resolved": true}'::jsonb
    ),
    
    -- Vehículo 13: Bloqueo por escalada pendiente
    ((SELECT id FROM vehiculos_ids WHERE rn = 13),
     (SELECT id FROM inventario_id),
     'inventario',
     'escalacion_pendiente',
     'Anomalía detectada en chasis - requiere aprobación supervisor',
     NOW() - INTERVAL '6 hours',
     NULL, -- Aún bloqueado
     '{"anomaly": "chasis_number_mismatch", "severity": "high", "escalated_to": "supervisor"}'::jsonb
    ),
    
    -- Vehículo 14: Mantenimiento del sistema
    ((SELECT id FROM vehiculos_ids WHERE rn = 14),
     (SELECT id FROM admin_id),
     'admin',
     'mantenimiento',
     'Sistema de actualización de impronta en mantenimiento',
     NOW() - INTERVAL '5 hours',
     NOW() - INTERVAL '3 hours', -- Ya desbloqueado
     '{"maintenance_type": "system_update", "affected_module": "impronta"}'::jsonb
    ),
    
    -- Vehículo 15: Otro motivo - cliente
    ((SELECT id FROM vehiculos_ids WHERE rn = 15),
     (SELECT id FROM despachador_id),
     'despachador',
     'otra',
     'Cliente solicitó retención temporal - pendiente de pago',
     NOW() - INTERVAL '4 hours',
     NULL, -- Aún bloqueado
     '{"reason_detail": "pending_payment", "client": "Distribuidora Caracas", "contact": "Carlos Pérez"}'::jsonb
    )
) AS t(vehiculo_id, bloqueado_por_usuario_id, bloqueado_por_rol, razon, descripcion, bloqueado_en, desbloqueado_en, metadata)
WHERE t.vehiculo_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. EXCEPCIONES DE VEHÍCULOS
-- ============================================

DO $$ 
BEGIN
    RAISE NOTICE '▶ Insertando excepciones de vehículos...';
END $$;

WITH vehiculos_ids AS (
  SELECT id, bin, ROW_NUMBER() OVER (ORDER BY id) as rn
  FROM vehiculos
  ORDER BY id
  LIMIT 18
),
recibidor_id AS (
  SELECT id FROM usuarios WHERE correo = 'recibidor@ibv.local' LIMIT 1
),
inventario_id AS (
  SELECT id FROM usuarios WHERE correo = 'inventario@ibv.local' LIMIT 1
),
admin_id AS (
  SELECT id FROM usuarios WHERE correo = 'admin@ibv.local' LIMIT 1
),
despachador_id AS (
  SELECT id FROM usuarios WHERE correo = 'despachador@ibv.local' LIMIT 1
)
INSERT INTO excepciones_vehiculos (
    vehiculo_id,
    tipo_excepcion,
    severidad,
    descripcion,
    asignado_a_usuario_id,
    estado,
    creada_en,
    resuelta_en,
    resuelta_por_usuario_id,
    notas_resolucion,
    metadata
)
SELECT * FROM (VALUES
    -- Vehículo 6: Excepción crítica - retraso > 3 días (relacionada con audit log)
    ((SELECT id FROM vehiculos_ids WHERE rn = 6),
     'retrasada_mas_de_3_dias',
     'alta',
     'Vehículo lleva 5 días en inventario sin avanzar - posible bloqueo sistémico',
     (SELECT id FROM admin_id),
     'en_progreso',
     NOW() - INTERVAL '1 day',
     NULL, -- No resuelta aún
     NULL,
     NULL,
     '{"dias_transcurridos": 5, "estado_actual": "en_inventario", "fecha_inicio": "2026-02-22"}'::jsonb
    ),
    
    -- Vehículo 16: Excepción crítica - documento faltante
    ((SELECT id FROM vehiculos_ids WHERE rn = 16),
     'documento_faltante',
     'critica',
     'Falta certificado de aduana - vehículo no puede continuar proceso',
     (SELECT id FROM inventario_id),
     'abierta',
     NOW() - INTERVAL '3 hours',
     NULL,
     NULL,
     NULL,
     '{"document_type": "certificado_aduana", "required_by_law": true, "blocking": true}'::jsonb
    ),
    
    -- Vehículo 17: Problema de calidad - resuelto
    ((SELECT id FROM vehiculos_ids WHERE rn = 17),
     'problema_calidad',
     'media',
     'Rayón detectado en inventario - cliente notificado y acepta',
     (SELECT id FROM inventario_id),
     'resuelta',
     NOW() - INTERVAL '2 days',
     NOW() - INTERVAL '1 day',
     (SELECT id FROM inventario_id),
     'Cliente aceptó vehículo con descuento del 2%. Documentación firmada.',
     '{"issue": "rayon_puerta_trasera", "severity_original": "medium", "discount": 0.02, "client_accepted": true}'::jsonb
    ),
    
    -- Vehículo 11: Atrapado en estado (relacionado con bloqueo)
    ((SELECT id FROM vehiculos_ids WHERE rn = 11),
     'bloqueada_en_estado',
     'alta',
     'Vehículo no puede avanzar de inventario - sistema no responde a cambios',
     (SELECT id FROM admin_id),
     'en_progreso',
     NOW() - INTERVAL '2 days',
     NULL,
     NULL,
     NULL,
     '{"estado_atrapado": "en_inventario", "intentos_cambio": 3, "error_sistema": "timeout_connection"}'::jsonb
    ),
    
    -- Vehículo 18: Otro tipo - escalada
    ((SELECT id FROM vehiculos_ids WHERE rn = 18),
     'otra',
     'baja',
     'Cliente solicita modificación en orden de despacho',
     (SELECT id FROM despachador_id),
     'escalada',
     NOW() - INTERVAL '4 hours',
     NULL,
     NULL,
     NULL,
     '{"client_request": true, "request_type": "change_dispatch_order", "escalated_to": "operations_manager"}'::jsonb
    ),
    
    -- Vehículo 13: Calidad - chasis (relacionado con bloqueo)
    ((SELECT id FROM vehiculos_ids WHERE rn = 13),
     'problema_calidad',
     'critica',
     'Discrepancia en número de chasis vs documentación',
     (SELECT id FROM admin_id),
     'en_progreso',
     NOW() - INTERVAL '6 hours',
     NULL,
     NULL,
     NULL,
     '{"issue": "chasis_mismatch", "chasis_fisico": "ABC123456", "chasis_documento": "ABC123457", "requires_legal": true}'::jsonb
    ),
    
    -- Vehículo 4: Resuelta rápido - documento menor
    ((SELECT id FROM vehiculos_ids WHERE rn = 4),
     'documento_faltante',
     'baja',
     'Faltaba copia de póliza de seguro - cliente la envió',
     (SELECT id FROM recibidor_id),
     'resuelta',
     NOW() - INTERVAL '5 days',
     NOW() - INTERVAL '4 days',
     (SELECT id FROM recibidor_id),
     'Cliente envió copia digital de póliza. Verificada y archivada.',
     '{"document_type": "poliza_seguro", "resolution_time_hours": 24, "method": "digital"}'::jsonb
    ),
    
    -- Vehículo 8: Retraso leve - resuelto
    ((SELECT id FROM vehiculos_ids WHERE rn = 8),
     'retrasada_mas_de_3_dias',
     'media',
     'Vehículo estuvo 4 días en listo_despacho - falta de lote',
     (SELECT id FROM despachador_id),
     'resuelta',
     NOW() - INTERVAL '12 hours',
     NOW() - INTERVAL '6 hours',
     (SELECT id FROM despachador_id),
     'Se creó lote especial para despacho inmediato. Cliente satisfecho.',
     '{"dias_retraso": 4, "causa": "falta_lote", "solucion": "lote_especial"}'::jsonb
    )
) AS t(vehiculo_id, tipo_excepcion, severidad, descripcion, asignado_a_usuario_id, estado, creada_en, resuelta_en, resuelta_por_usuario_id, notas_resolucion, metadata)
WHERE t.vehiculo_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICACIÓN Y RESUMEN
-- ============================================

DO $$
DECLARE
    audit_count INTEGER;
    locks_count INTEGER;
    locks_active INTEGER;
    exceptions_count INTEGER;
    exceptions_open INTEGER;
    exceptions_in_progress INTEGER;
    exceptions_resolved INTEGER;
    vehiculos_disponibles INTEGER;
BEGIN
    -- Verificar vehículos disponibles
    SELECT COUNT(*) INTO vehiculos_disponibles FROM vehiculos;
    
    IF vehiculos_disponibles < 18 THEN
        RAISE WARNING '⚠️  Solo hay % vehículos en la BD. Se recomienda tener al menos 18 para todos los ejemplos.', vehiculos_disponibles;
    END IF;
    
    -- Contar registros
    SELECT COUNT(*) INTO audit_count FROM auditoria_vehiculos;
    SELECT COUNT(*) INTO locks_count FROM bloqueos_vehiculos;
    SELECT COUNT(*) INTO locks_active FROM bloqueos_vehiculos WHERE desbloqueado_en IS NULL;
    SELECT COUNT(*) INTO exceptions_count FROM excepciones_vehiculos;
    SELECT COUNT(*) INTO exceptions_open FROM excepciones_vehiculos WHERE estado = 'abierta';
    SELECT COUNT(*) INTO exceptions_in_progress FROM excepciones_vehiculos WHERE estado = 'en_progreso';
    SELECT COUNT(*) INTO exceptions_resolved FROM excepciones_vehiculos WHERE estado = 'resuelta';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ DATOS DE AUDITORÍA CARGADOS';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE '🗄️  Base de datos:';
    RAISE NOTICE '   • Vehículos disponibles: %', vehiculos_disponibles;
    RAISE NOTICE '';
    RAISE NOTICE '📊 Resumen:';
    RAISE NOTICE '   • Logs de auditoría: % registros', audit_count;
    RAISE NOTICE '   • Bloqueos totales: % (% activos)', locks_count, locks_active;
    RAISE NOTICE '   • Excepciones totales: %', exceptions_count;
    RAISE NOTICE '     - Abiertas: %', exceptions_open;
    RAISE NOTICE '     - En progreso: %', exceptions_in_progress;
    RAISE NOTICE '     - Resueltas: %', exceptions_resolved;
    RAISE NOTICE '';
    RAISE NOTICE '🔍 Tipos de acciones en auditoría:';
    RAISE NOTICE '   - cambio_estado: cambios normales de estado';
    RAISE NOTICE '   - anulacion_admin: intervenciones de administrador';
    RAISE NOTICE '   - desbloqueo_manual: desbloqueos manuales';
    RAISE NOTICE '   - escalacion: escaladas a supervisor';
    RAISE NOTICE '   - nota_agregada: notas agregadas';
    RAISE NOTICE '';
    
    IF locks_active > 0 THEN
        RAISE NOTICE '🔒 Vehículos actualmente bloqueados: %', locks_active;
    END IF;
    
    IF exceptions_open + exceptions_in_progress > 0 THEN
        RAISE NOTICE '🚨 Excepciones que requieren atención: %', exceptions_open + exceptions_in_progress;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '💡 Nota: El script usa IDs reales de vehículos en tu BD';
    RAISE NOTICE '    Si tienes menos de 18 vehículos, algunos ejemplos no se insertarán.';
    RAISE NOTICE '';
END $$;

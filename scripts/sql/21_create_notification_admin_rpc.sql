-- ============================================
-- RPC seguro para crear notificaciones admin sin romper policies existentes
-- Evita 403 de RLS en INSERT directo a tabla notificaciones
-- ============================================

CREATE OR REPLACE FUNCTION public.create_notification_admin(
  p_titulo TEXT,
  p_mensaje TEXT,
  p_modulo TEXT,
  p_recipient_user_id BIGINT,
  p_created_by_user_id BIGINT,
  p_created_by_role TEXT,
  p_action_url TEXT,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS public.notificaciones
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row public.notificaciones;
  v_modulo TEXT;
BEGIN
  -- Validar creador
  IF p_created_by_user_id IS NULL THEN
    RAISE EXCEPTION 'created_by_user_id es requerido' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.usuarios u
    WHERE u.id = p_created_by_user_id
      AND LOWER(TRIM(u.rol)) IN ('admin', 'administrador', 'superadmin', 'super_admin')
  ) THEN
    RAISE EXCEPTION 'usuario creador no autorizado para crear notificaciones' USING ERRCODE = '42501';
  END IF;

  -- Normalizar y validar módulo contra los valores permitidos por CHECK de la tabla
  v_modulo := LOWER(TRIM(COALESCE(p_modulo, 'general')));
  IF v_modulo NOT IN ('admin', 'porteria', 'recibidor', 'inventario', 'despachador', 'general') THEN
    RAISE EXCEPTION 'modulo invalido: %', p_modulo USING ERRCODE = '22023';
  END IF;

  -- Insertar notificación
  INSERT INTO public.notificaciones (
    titulo,
    mensaje,
    modulo,
    recipient_user_id,
    created_by_user_id,
    created_by_role,
    action_url,
    metadata
  ) VALUES (
    p_titulo,
    p_mensaje,
    v_modulo,
    p_recipient_user_id,
    p_created_by_user_id,
    COALESCE(NULLIF(TRIM(p_created_by_role), ''), 'admin'),
    p_action_url,
    COALESCE(p_metadata, '{}'::jsonb)
  )
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

-- Permitir ejecutar RPC desde frontend (anon/authenticated)
GRANT EXECUTE ON FUNCTION public.create_notification_admin(
  TEXT,
  TEXT,
  TEXT,
  BIGINT,
  BIGINT,
  TEXT,
  TEXT,
  JSONB
) TO anon, authenticated;

RAISE NOTICE '✅ RPC create_notification_admin creado y permisos otorgados';

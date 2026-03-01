-- ============================================
-- HOTFIX: Resolver 403 en INSERT de notificaciones
-- Estrategia: resetear políticas y usar INSERT para usuarios autenticados
-- ============================================

-- 0) Asegurar RLS habilitado
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;

-- 1) Eliminar TODAS las políticas existentes de la tabla (sin depender del nombre)
DO $$
DECLARE
  p RECORD;
BEGIN
  FOR p IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notificaciones'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.notificaciones', p.policyname);
  END LOOP;
END $$;

-- 2) SELECT: visibilidad inteligente (igual que diseño actual)
CREATE POLICY notificaciones_select_intelligent ON public.notificaciones
FOR SELECT
USING (
  (
    recipient_user_id IS NOT NULL
    AND recipient_user_id = (
      SELECT id
      FROM public.usuarios
      WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email()))
      LIMIT 1
    )
  )
  OR
  (
    recipient_user_id IS NULL
    AND modulo = 'general'
  )
  OR
  (
    recipient_user_id IS NULL
    AND modulo <> 'general'
    AND LOWER(TRIM(modulo)) = LOWER(TRIM(COALESCE((
      SELECT rol
      FROM public.usuarios
      WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email()))
      LIMIT 1
    ), '')))
  )
  OR
  (
    recipient_user_id IS NULL
    AND EXISTS (
      SELECT 1
      FROM public.usuarios u
      WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()))
        AND LOWER(TRIM(u.rol)) = 'admin'
    )
  )
);

-- 3) INSERT: permitir a cualquier usuario autenticado (evita fallo por función/rol)
CREATE POLICY notificaciones_insert_authenticated ON public.notificaciones
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- 4) UPDATE: admin o destinatario personal
CREATE POLICY notificaciones_update_admin_or_owner ON public.notificaciones
FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM public.usuarios u
    WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()))
      AND LOWER(TRIM(u.rol)) = 'admin'
  )
  OR recipient_user_id = (
    SELECT id
    FROM public.usuarios
    WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email()))
    LIMIT 1
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.usuarios u
    WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()))
      AND LOWER(TRIM(u.rol)) = 'admin'
  )
  OR recipient_user_id = (
    SELECT id
    FROM public.usuarios
    WHERE LOWER(TRIM(correo)) = LOWER(TRIM(auth.email()))
    LIMIT 1
  )
);

-- 5) DELETE: solo admin
CREATE POLICY notificaciones_delete_admin_only ON public.notificaciones
FOR DELETE
USING (
  EXISTS (
    SELECT 1
    FROM public.usuarios u
    WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()))
      AND LOWER(TRIM(u.rol)) = 'admin'
  )
);

-- 6) Verificación rápida
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'notificaciones'
ORDER BY policyname;

RAISE NOTICE '✅ HOTFIX aplicado: INSERT de notificaciones habilitado para autenticados';

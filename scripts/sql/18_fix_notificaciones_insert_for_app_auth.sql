-- ============================================
-- FIX COMPATIBLE CON AUTH DE APP (sin Supabase Auth)
-- Problema: policies basadas en auth.email()/auth.uid() fallan cuando el
-- frontend no envía JWT de Supabase (403 en INSERT de notificaciones).
--
-- Este fix NO elimina policies existentes.
-- Solo agrega una policy adicional para INSERT validando el payload:
--   - created_by_role debe ser admin-like
--   - created_by_user_id debe existir en usuarios
-- ============================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notificaciones'
      AND policyname = 'notificaciones_insert_admin_from_payload'
  ) THEN
    CREATE POLICY notificaciones_insert_admin_from_payload
    ON public.notificaciones
    FOR INSERT
    WITH CHECK (
      LOWER(TRIM(COALESCE(created_by_role, ''))) IN ('admin', 'administrador', 'superadmin', 'super_admin')
      AND created_by_user_id IS NOT NULL
      AND EXISTS (
        SELECT 1
        FROM public.usuarios u
        WHERE u.id = created_by_user_id
      )
    );
  END IF;
END $$;

-- Verificación de policies INSERT activas
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'notificaciones'
  AND cmd = 'INSERT'
ORDER BY policyname;

RAISE NOTICE '✅ Policy adicional creada: notificaciones_insert_admin_from_payload';

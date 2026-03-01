-- ============================================
-- SAFE FIX 3: fallback INSERT policy (rol contiene 'admin')
-- No elimina políticas existentes.
-- ============================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notificaciones'
      AND policyname = 'notificaciones_insert_admin_contains'
  ) THEN
    CREATE POLICY notificaciones_insert_admin_contains
    ON public.notificaciones
    FOR INSERT
    WITH CHECK (
      created_by_user_id IS NOT NULL
      AND EXISTS (
        SELECT 1
        FROM public.usuarios u
        WHERE u.id = created_by_user_id
      )
      AND LOWER(TRIM(COALESCE(created_by_role, ''))) LIKE '%admin%'
    );
  END IF;
END $$;

SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'notificaciones'
  AND cmd = 'INSERT'
ORDER BY policyname;

RAISE NOTICE '✅ Policy adicional creada: notificaciones_insert_admin_contains';

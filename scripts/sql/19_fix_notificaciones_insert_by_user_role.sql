-- ============================================
-- SAFE FIX 2: INSERT notificaciones por rol real del usuario
-- No elimina políticas existentes.
-- Agrega policy adicional que valida admin por created_by_user_id en tabla usuarios.
-- ============================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notificaciones'
      AND policyname = 'notificaciones_insert_admin_by_user_role'
  ) THEN
    CREATE POLICY notificaciones_insert_admin_by_user_role
    ON public.notificaciones
    FOR INSERT
    WITH CHECK (
      created_by_user_id IS NOT NULL
      AND EXISTS (
        SELECT 1
        FROM public.usuarios u
        WHERE u.id = created_by_user_id
          AND LOWER(TRIM(u.rol)) IN ('admin', 'administrador', 'superadmin', 'super_admin')
      )
    );
  END IF;
END $$;

-- Ver INSERT policies activas
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'notificaciones'
  AND cmd = 'INSERT'
ORDER BY policyname;

RAISE NOTICE '✅ Policy adicional creada: notificaciones_insert_admin_by_user_role';

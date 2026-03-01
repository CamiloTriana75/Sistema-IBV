-- ============================================
-- SAFE FIX (NO DESTRUCTIVO): 403 en INSERT notificaciones
-- No elimina políticas existentes.
-- Solo agrega una policy adicional de INSERT para admin,
-- con comparación robusta por email/rol en tabla usuarios.
-- ============================================

-- 1) Función robusta para detectar admin por email (case-insensitive)
CREATE OR REPLACE FUNCTION public.is_admin_safe()
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.usuarios u
    WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()))
      AND LOWER(TRIM(u.rol)) = 'admin'
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- 2) Agregar policy de INSERT solo si no existe (sin tocar las demás)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notificaciones'
      AND policyname = 'notificaciones_insert_admin_safe'
  ) THEN
    CREATE POLICY notificaciones_insert_admin_safe
    ON public.notificaciones
    FOR INSERT
    WITH CHECK (public.is_admin_safe());
  END IF;
END $$;

-- 3) Verificar políticas actuales (solo lectura)
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'notificaciones'
ORDER BY policyname;

RAISE NOTICE '✅ SAFE FIX aplicado: se agregó policy adicional de INSERT sin borrar políticas existentes';

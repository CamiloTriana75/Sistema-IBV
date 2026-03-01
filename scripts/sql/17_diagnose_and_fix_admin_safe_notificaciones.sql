-- ============================================
-- DIAGNÓSTICO + FIX SEGURO para INSERT notificaciones (403)
-- No elimina policies existentes.
-- ============================================

-- 1) Ajustar función admin-safe para aceptar variantes comunes de rol
CREATE OR REPLACE FUNCTION public.is_admin_safe()
RETURNS BOOLEAN
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.usuarios u
    WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()))
      AND LOWER(TRIM(u.rol)) IN ('admin', 'administrador', 'superadmin', 'super_admin')
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- 2) Diagnóstico del contexto de sesión actual
SELECT 
  auth.uid() AS auth_uid,
  auth.email() AS auth_email,
  public.get_current_user_role() AS role_from_function,
  public.is_admin() AS is_admin_old,
  public.is_admin_safe() AS is_admin_safe_new;

-- 3) Diagnóstico en tabla usuarios para el email autenticado
SELECT 
  u.id,
  u.correo,
  u.rol,
  LOWER(TRIM(u.correo)) AS correo_normalizado,
  LOWER(TRIM(u.rol)) AS rol_normalizado
FROM public.usuarios u
WHERE LOWER(TRIM(u.correo)) = LOWER(TRIM(auth.email()));

RAISE NOTICE '✅ Diagnóstico ejecutado. Si is_admin_safe_new=true, el INSERT debe funcionar.';

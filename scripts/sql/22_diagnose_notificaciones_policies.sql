-- ============================================
-- DIAGNÓSTICO: estructura + RLS + políticas de notificaciones
-- Solo lectura
-- ============================================

-- 1) Estructura de columnas de la tabla
SELECT
  c.column_name,
  c.data_type,
  c.is_nullable,
  c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'notificaciones'
ORDER BY c.ordinal_position;

-- 2) Restricciones CHECK/FK/PK
SELECT
  tc.constraint_name,
  tc.constraint_type,
  cc.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name = 'notificaciones'
ORDER BY tc.constraint_type, tc.constraint_name;

-- 3) RLS habilitado y forzado
SELECT
  n.nspname AS schemaname,
  c.relname AS tablename,
  c.relrowsecurity AS rls_enabled,
  c.relforcerowsecurity AS rls_forced
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname = 'notificaciones';

-- 4) Policies activas
SELECT
  schemaname,
  tablename,
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'notificaciones'
ORDER BY cmd, policyname;

RAISE NOTICE '✅ Diagnóstico notificaciones generado';

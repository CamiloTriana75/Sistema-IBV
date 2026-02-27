-- Configurar políticas RLS para el sistema IBV
-- Fecha: 2026-02-27
-- NOTA: Este script elimina políticas existentes y las recrea
-- Políticas permiten acceso anónimo para desarrollo (ajustar en producción)

-- =======================
-- LIMPIAR POLÍTICAS EXISTENTES
-- =======================

-- Eliminar políticas de usuarios
DROP POLICY IF EXISTS "Usuarios pueden ver todos los usuarios" ON usuarios;
DROP POLICY IF EXISTS "Service role puede insertar usuarios" ON usuarios;
DROP POLICY IF EXISTS "Anon puede ver usuarios para auth" ON usuarios;
DROP POLICY IF EXISTS "Todos pueden ver usuarios" ON usuarios;
DROP POLICY IF EXISTS "Usuarios pueden insertar en usuarios" ON usuarios;
DROP POLICY IF EXISTS "Usuarios autenticados pueden actualizar usuarios" ON usuarios;

-- Eliminar políticas de vehiculos
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "Usuarios autenticados pueden actualizar vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "Todos pueden ver vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "Todos pueden crear vehiculos" ON vehiculos;
DROP POLICY IF EXISTS "Todos pueden actualizar vehiculos" ON vehiculos;

-- Eliminar políticas de improntas
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver improntas" ON improntas;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear improntas" ON improntas;
DROP POLICY IF EXISTS "Usuarios autenticados pueden actualizar improntas" ON improntas;
DROP POLICY IF EXISTS "Todos pueden ver improntas" ON improntas;
DROP POLICY IF EXISTS "Todos pueden crear improntas" ON improntas;
DROP POLICY IF EXISTS "Todos pueden actualizar improntas" ON improntas;

-- Eliminar políticas de inventarios
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver inventarios" ON inventarios;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear inventarios" ON inventarios;
DROP POLICY IF EXISTS "Usuarios autenticados pueden actualizar inventarios" ON inventarios;
DROP POLICY IF EXISTS "Todos pueden ver inventarios" ON inventarios;
DROP POLICY IF EXISTS "Todos pueden crear inventarios" ON inventarios;
DROP POLICY IF EXISTS "Todos pueden actualizar inventarios" ON inventarios;

-- Eliminar políticas de modelos_vehiculo
DROP POLICY IF EXISTS "Todos pueden ver modelos" ON modelos_vehiculo;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear modelos" ON modelos_vehiculo;
DROP POLICY IF EXISTS "Todos pueden crear modelos" ON modelos_vehiculo;

-- Eliminar políticas de buques
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver buques" ON buques;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear buques" ON buques;
DROP POLICY IF EXISTS "Todos pueden ver buques" ON buques;
DROP POLICY IF EXISTS "Todos pueden crear buques" ON buques;

-- Eliminar políticas de despachos
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver despachos" ON despachos;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear despachos" ON despachos;
DROP POLICY IF EXISTS "Usuarios autenticados pueden actualizar despachos" ON despachos;
DROP POLICY IF EXISTS "Todos pueden ver despachos" ON despachos;
DROP POLICY IF EXISTS "Todos pueden crear despachos" ON despachos;
DROP POLICY IF EXISTS "Todos pueden actualizar despachos" ON despachos;

-- Eliminar políticas de despacho_vehiculos
DROP POLICY IF EXISTS "Usuarios autenticados pueden ver despacho_vehiculos" ON despacho_vehiculos;
DROP POLICY IF EXISTS "Usuarios autenticados pueden crear despacho_vehiculos" ON despacho_vehiculos;
DROP POLICY IF EXISTS "Todos pueden ver despacho_vehiculos" ON despacho_vehiculos;
DROP POLICY IF EXISTS "Todos pueden crear despacho_vehiculos" ON despacho_vehiculos;

-- =======================
-- TABLA: usuarios
-- =======================

-- Habilitar RLS
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Política: Permitir SELECT a usuarios autenticados y anónimos (para login)
CREATE POLICY "Todos pueden ver usuarios"
ON usuarios FOR SELECT
TO authenticated, anon
USING (true);

-- Política: Permitir INSERT a usuarios autenticados y anon (para seed automático)
CREATE POLICY "Usuarios pueden insertar en usuarios"
ON usuarios FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- Política: Permitir UPDATE a usuarios autenticados
CREATE POLICY "Usuarios autenticados pueden actualizar usuarios"
ON usuarios FOR UPDATE
TO authenticated
USING (true);

-- =======================
-- TABLA: vehiculos
-- =======================

ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;

-- Permitir lectura a todos los roles autenticados y anónimos (para desarrollo)
CREATE POLICY "Todos pueden ver vehiculos"
ON vehiculos FOR SELECT
TO authenticated, anon
USING (true);

-- Permitir escritura a usuarios autenticados y anon (para desarrollo)
CREATE POLICY "Todos pueden crear vehiculos"
ON vehiculos FOR INSERT
TO authenticated, anon
WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar vehiculos"
ON vehiculos FOR UPDATE
TO authenticated, anon
USING (true);

-- =======================
-- TABLA: improntas
-- =======================

ALTER TABLE improntas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver improntas"
ON improntas FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY "Todos pueden crear improntas"
ON improntas FOR INSERT
TO authenticated, anon
WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar improntas"
ON improntas FOR UPDATE
TO authenticated, anon
USING (true);

-- =======================
-- TABLA: inventarios
-- =======================

ALTER TABLE inventarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver inventarios"
ON inventarios FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY "Todos pueden crear inventarios"
ON inventarios FOR INSERT
TO authenticated, anon
WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar inventarios"
ON inventarios FOR UPDATE
TO authenticated, anon
USING (true);

-- =======================
-- TABLA: modelos_vehiculo
-- =======================

ALTER TABLE modelos_vehiculo ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver modelos"
ON modelos_vehiculo FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY "Todos pueden crear modelos"
ON modelos_vehiculo FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- =======================
-- TABLA: buques
-- =======================

ALTER TABLE buques ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver buques"
ON buques FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY "Todos pueden crear buques"
ON buques FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- =======================
-- TABLA: despachos
-- =======================

ALTER TABLE despachos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver despachos"
ON despachos FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY "Todos pueden crear despachos"
ON despachos FOR INSERT
TO authenticated, anon
WITH CHECK (true);

CREATE POLICY "Todos pueden actualizar despachos"
ON despachos FOR UPDATE
TO authenticated, anon
USING (true);

-- =======================
-- TABLA: despacho_vehiculos
-- =======================

ALTER TABLE despacho_vehiculos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Todos pueden ver despacho_vehiculos"
ON despacho_vehiculos FOR SELECT
TO authenticated, anon
USING (true);

CREATE POLICY "Todos pueden crear despacho_vehiculos"
ON despacho_vehiculos FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- =======================
-- Verificar políticas creadas
-- =======================

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

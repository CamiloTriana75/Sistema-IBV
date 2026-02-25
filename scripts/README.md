# Scripts de Configuración y Migración - Sistema IBV

## 📚 Índice

- [SQL Scripts](#sql-scripts)
- [PowerShell Scripts](#powershell-scripts)
- [Python Scripts](#python-scripts)
- [Orden de Ejecución](#orden-de-ejecución)
- [Troubleshooting](#troubleshooting)

---

## SQL Scripts

Scripts para ejecutar en **Supabase Dashboard > SQL Editor**

### [`sql/01_initial_setup.sql`](./sql/01_initial_setup.sql)

**Propósito**: Configuración inicial de PostgreSQL en Supabase

**Cuándo ejecutar**: Una sola vez, después de crear el proyecto en Supabase

**Qué hace**:
- ✅ Instala extensiones PostgreSQL (uuid-ossp, pgcrypto, pg_trgm)
- ✅ Configura permisos para usuario postgres
- ✅ Deshabilita Row Level Security (RLS)
- ✅ Configura timezone
- ✅ Crea funciones de utilidad
- ✅ Crea tabla de auditoría

**Uso**:
```sql
-- 1. Ir a Supabase Dashboard > SQL Editor
-- 2. New Query
-- 3. Copiar y pegar el contenido completo de 01_initial_setup.sql
-- 4. Ejecutar (Run)
```

**Tiempo estimado**: ~30 segundos

---

### [`sql/02_verify_setup.sql`](./sql/02_verify_setup.sql)

**Propósito**: Verificar que la configuración se aplicó correctamente

**Cuándo ejecutar**:
- Después de ejecutar `01_initial_setup.sql`
- Después de ejecutar migraciones de Django
- Cualquier momento para verificar el estado

**Qué verifica**:
- ✅ Extensiones instaladas
- ✅ Tablas de Django creadas
- ✅ Tablas del Sistema IBV
- ✅ Índices
- ✅ Estado de RLS
- ✅ Permisos
- ✅ Funciones de utilidad
- ✅ Datos de usuarios

**Uso**:
```sql
-- 1. Ir a Supabase Dashboard > SQL Editor
-- 2. New Query
-- 3. Copiar y pegar el contenido de 02_verify_setup.sql
-- 4. Ejecutar (Run)
-- 5. Revisar output en Messages tab
```

**Output esperado**:
```
✅ Todas las extensiones requeridas están instaladas
✅ Tablas core de Django encontradas
✅ Migraciones ejecutadas
✅ RLS deshabilitado
✅ ¡VERIFICACIÓN EXITOSA!
```

---

### [`sql/03_disable_rls.sql`](./sql/03_disable_rls.sql)

**Propósito**: Deshabilitar Row Level Security en todas las tablas

**Cuándo ejecutar**:
- Si la verificación detecta RLS habilitado
- Después de agregar nuevas apps/tablas

**Qué hace**:
- ✅ Deshabilita RLS en todas las tablas
- ✅ Elimina políticas RLS existentes
- ✅ Verifica que RLS esté completamente deshabilitado

**Uso**:
```sql
-- 1. Ejecutar solo si 02_verify_setup.sql muestra RLS habilitado
-- 2. Copiar y pegar en SQL Editor
-- 3. Ejecutar (Run)
```

---

### [`sql/04_create_tables.sql`](./sql/04_create_tables.sql)

**Propósito**: Crear todas las tablas del sistema directamente en PostgreSQL

**Cuándo ejecutar**:
- Como alternativa a `python manage.py migrate`
- Para crear la estructura antes de configurar Django
- Para tener control directo sobre la BD

**Qué hace**:
- ✅ Crea todas las tablas de Django (auth, contenttypes, sessions, admin)
- ✅ Crea tabla de usuarios personalizada (users_user)
- ✅ Crea índices y foreign keys
- ✅ Pobla content types y permisos iniciales
- ✅ Registra migraciones como aplicadas
- ✅ Deshabilita RLS automáticamente

**Tablas creadas**:
- `usuarios` - Usuarios del sistema con roles
- `auth_group`, `auth_permission`, `auth_group_permissions`
- `django_content_type`, `django_migrations`, `django_session`
- `django_admin_log`
- `usuarios_grupos`, `usuarios_permisos`

**Uso**:
```sql
-- 1. Ejecutar 01_initial_setup.sql primero
-- 2. Copiar y pegar 04_create_tables.sql en SQL Editor
-- 3. Ejecutar (Run)

-- 4. Luego en Django, marcar migraciones como aplicadas:
cd backend
python manage.py migrate --fake
python manage.py createsuperuser
```

**⚠️ IMPORTANTE**:
Si ejecutas este script, NO ejecutes `python manage.py migrate` sin el flag `--fake`,
o Django intentará crear las tablas nuevamente.

---

## PowerShell Scripts

Scripts para ejecutar desde **PowerShell/Terminal en Windows**

### [`setup-supabase.ps1`](./setup-supabase.ps1)

**Propósito**: Guía interactiva de configuración y verificación

**Cuándo ejecutar**:
- Primera vez configurando Supabase
- Para verificar configuración actual

**Qué hace**:
- ✅ Verifica instalación de Python
- ✅ Verifica archivo .env
- ✅ Verifica DATABASE_URL
- ✅ Verifica dependencias Python
- ✅ Verifica conectividad a BD
- ✅ Verifica migraciones
- ✅ Muestra siguientes pasos

**Uso**:
```powershell
# Desde la raíz del proyecto
cd C:\Users\Deibyd\Sistema-IBV
.\scripts\setup-supabase.ps1
```

**Output esperado**:
```
═══════════════════════════════════════════════════════════
   Sistema IBV - Configuración de Supabase PostgreSQL
═══════════════════════════════════════════════════════════

✅ Ubicación correcta
✅ Python encontrado
✅ Archivo .env encontrado
✅ DATABASE_URL configurado
...
```

---

## Python Scripts

Scripts Python para migración y mantenimiento

### [`migrate_data.py`](./migrate_data.py)

**Propósito**: Migrar datos de SQLite a PostgreSQL

**Cuándo ejecutar**:
- Cuando tienes datos en `db.sqlite3` que necesitas en producción
- Para migración de desarrollo a staging/producción

**Prerequisitos**:
- SQLite con datos existentes
- PostgreSQL configurado con migraciones aplicadas
- Variables de entorno configuradas

**Uso**:
```powershell
# Migración simple
python scripts\migrate_data.py

# Con backup y modo verbose
python scripts\migrate_data.py --backup --verbose

# Simular (no aplica cambios)
python scripts\migrate_data.py --dry-run

# Ver ayuda
python scripts\migrate_data.py --help
```

**Opciones**:
- `--dry-run`: Simular sin aplicar cambios
- `--backup, -b`: Crear backup antes de migrar
- `--verbose, -v`: Mostrar información detallada

**Proceso**:
1. Verifica configuración de PostgreSQL
2. Verifica existencia de SQLite
3. Crea backup (opcional)
4. Exporta datos desde SQLite
5. Importa datos a PostgreSQL
6. Verifica integridad

---

## Orden de Ejecución

### Configuración Inicial (Primera vez)

#### Opción A: Usando Migraciones de Django (Recomendado)

```
1. Crear proyecto en Supabase
   └─ https://supabase.com

2. Obtener credenciales
   └─ Settings > Database (CONNECTION STRING)
   └─ Settings > API (PROJECT URL, KEYS)

3. Configurar .env local
   └─ Copiar .env.example a .env
   └─ Agregar credenciales de Supabase

4. Ejecutar setup inicial en Supabase
   └─ SQL: sql/01_initial_setup.sql

5. Verificar configuración local
   └─ PowerShell: .\scripts\setup-supabase.ps1

6. Ejecutar migraciones de Django
   └─ cd backend
   └─ python manage.py migrate

7. Crear superusuario
   └─ python manage.py createsuperuser

8. Verificar setup en Supabase
   └─ SQL: sql/02_verify_setup.sql

9. [Opcional] Migrar datos de SQLite
   └─ python scripts\migrate_data.py --backup
```

#### Opción B: Creación Directa con SQL

```
1. Crear proyecto en Supabase
   └─ https://supabase.com

2. Obtener credenciales
   └─ Settings > Database (CONNECTION STRING)
   └─ Settings > API (PROJECT URL, KEYS)

3. Ejecutar setup inicial en Supabase
   └─ SQL: sql/01_initial_setup.sql

4. Crear todas las tablas en Supabase
   └─ SQL: sql/04_create_tables.sql

5. Configurar .env local
   └─ Copiar .env.example a .env
   └─ Agregar credenciales de Supabase

6. Marcar migraciones como aplicadas en Django
   └─ cd backend
   └─ python manage.py migrate --fake

7. Crear superusuario
   └─ python manage.py createsuperuser

8. Verificar setup
   └─ SQL: sql/02_verify_setup.sql
```

### Verificación Periódica

```
1. Verificar configuración
   └─ PowerShell: .\scripts\setup-supabase.ps1

2. Verificar BD en Supabase
   └─ SQL: sql/02_verify_setup.sql
```

### Si se detectan problemas con RLS

```
1. Deshabilitar RLS
   └─ SQL: sql/03_disable_rls.sql

2. Verificar
   └─ SQL: sql/02_verify_setup.sql
```

---

## Troubleshooting

### Error: "No se puede conectar a PostgreSQL"

**Síntomas**: Scripts fallan con error de conexión

**Soluciones**:
```powershell
# 1. Verificar DATABASE_URL en .env
Get-Content .env | Select-String "DATABASE_URL"

# 2. Verificar conectividad
# Desde backend
cd backend
python manage.py dbshell
# Debería conectar a PostgreSQL

# 3. Verificar credenciales en Supabase
# Dashboard > Settings > Database
```

### Error: "Migraciones no se aplican"

**Síntomas**: `python manage.py migrate` falla

**Soluciones**:
```powershell
# 1. Ver estado de migraciones
python manage.py showmigrations

# 2. Verificar que 01_initial_setup.sql se ejecutó
# Ejecutar 02_verify_setup.sql en Supabase

# 3. Si persiste, fake initial
python manage.py migrate --fake-initial
python manage.py migrate
```

### Error: "RLS bloquea acceso"

**Síntomas**: Django no puede leer/escribir tablas

**Soluciones**:
```sql
-- Ejecutar en Supabase SQL Editor
-- sql/03_disable_rls.sql
```

### Error: "Faltan extensiones"

**Síntomas**: Error con uuid-ossp, pgcrypto, etc.

**Soluciones**:
```sql
-- Ejecutar en Supabase SQL Editor
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

### migrate_data.py falla

**Síntomas**: Error al migrar datos

**Soluciones**:
```powershell
# 1. Verificar que PostgreSQL tiene migraciones aplicadas
cd backend
python manage.py showmigrations

# 2. Intentar dry-run para ver el error
python ..\scripts\migrate_data.py --dry-run --verbose

# 3. Migración manual con dumpdata/loaddata
# Exportar desde SQLite
$env:DATABASE_URL = "sqlite:///db.sqlite3"
python manage.py dumpdata --natural-foreign --natural-primary > backup.json

# Cambiar a PostgreSQL (editar .env)
# Importar
python manage.py loaddata backup.json
```

---

## Archivos Generados

Los scripts pueden generar archivos temporales:

```
backup_data_YYYYMMDD_HHMMSS.json    # Backup de datos (migrate_data.py)
temp_migration_data.json             # Temporal durante migración
supabase-credentials.txt             # NO COMMITEAR - Solo local
```

⚠️ **IMPORTANTE**: Nunca commitear archivos con credenciales o datos sensibles.

Agregar a `.gitignore`:
```
*.json
supabase-credentials.txt
backup_*.json
temp_*.json
```

---

## Mejores Prácticas

### ✅ DO (Hacer)

1. **Ejecutar scripts en orden**: Seguir la secuencia recomendada
2. **Crear backups**: Usar `--backup` en migrate_data.py
3. **Verificar siempre**: Ejecutar 02_verify_setup.sql después de cambios
4. **Leer output**: Los scripts muestran información útil
5. **Documentar cambios**: Si modificas scripts, actualiza este README

### ❌ DON'T (No Hacer)

1. **No ejecutar en producción sin probar**: Probar en desarrollo primero
2. **No ignorar errores**: Si un script falla, investigar antes de continuar
3. **No commitear credenciales**: Nunca subir archivos con passwords
4. **No modificar scripts SQL en Supabase**: Usar archivos locales
5. **No saltarse verificaciones**: Siempre ejecutar 02_verify_setup.sql

---

## Documentación Relacionada

### Guías Completas
- [`docs/SUPABASE_SETUP_GUIDE.md`](../docs/SUPABASE_SETUP_GUIDE.md) - Guía técnica completa
- [`docs/SUPABASE_QUICK_START.md`](../docs/SUPABASE_QUICK_START.md) - Inicio rápido 30 min
- [`docs/SUPABASE_RLS_POLICIES.md`](../docs/SUPABASE_RLS_POLICIES.md) - Políticas RLS
- [`docs/DATABASE_SUPABASE_INDEX.md`](../docs/DATABASE_SUPABASE_INDEX.md) - Índice general

### Documentación de Backend
- [`backend/README.md`](../backend/README.md) - Configuración de Django
- [`backend/MODELS_DOCUMENTATION.md`](../backend/MODELS_DOCUMENTATION.md) - Modelos

---

## Soporte

### Recursos
- [Supabase Documentation](https://supabase.com/docs)
- [Django Database Settings](https://docs.djangoproject.com/en/5.0/ref/settings/#databases)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Issues Comunes
Ver sección [Troubleshooting](#troubleshooting) arriba

### Contacto
Para problemas no documentados, crear issue en el repositorio con:
- Script que falla
- Error completo
- Output de `02_verify_setup.sql`
- Versión de Python y Django

---

## Changelog

| Versión | Fecha | Cambios |
|---------|-------|---------|
| 1.0.0 | 2026-02-24 | Creación inicial de scripts |

---

**💡 TIP**: Para comenzar, sigue la guía rápida: [`docs/SUPABASE_QUICK_START.md`](../docs/SUPABASE_QUICK_START.md)

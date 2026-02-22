# Sistema IBV - Inventario y Despacho de Vehículos en Bodegas

Sistema web/responsivo para gestionar el ciclo completo de recepción, inventario, impronta y despacho de vehículos provenientes de buques hacia bodegas.

## Descripción

Sistema integral que permite controlar todo el flujo operativo de vehículos en bodegas portuarias: desde la recepción del buque, el registro e impronta de cada vehículo, la verificación de inventario, hasta el despacho condicionado y la generación de reportes.

## Funcionalidades principales

- **Escaneo QR** — Cámara de celular y pistola de escaneo
- **Recepción de vehículos** — Registro desde buques con datos y QR
- **Impronta** — Registro fotográfico y de datos por vehículo
- **Inventario** — Checklist de verificación de equipamiento
- **Despacho condicionado** — Solo si impronta e inventario están completos
- **Gestión de roles** — Administrador, Portería, Recibidor, Inventario, Despachador, Cliente
- **Reportes** — Estadísticas, exportación a Excel, recibos imprimibles

## Stack Tecnologico (Pendiente de confirmacion)

> ⚠️ **Las tecnologias aun no estan definidas oficialmente.** Las siguientes son propuestas iniciales sujetas a revision y aprobacion del equipo.

| Capa | Propuesta | Estado |
|---|---|---|
| **Frontend** | Vue 3 + Nuxt 3 | 🟡 Pendiente |
| **Backend** | Django (API RESTful) | 🟡 Pendiente |
| **Lenguaje** | Python 3.12 | 🟡 Pendiente |
| **Base de datos** | Supabase (PostgreSQL) | 🟡 Pendiente |
| **Autenticacion** | Django REST Framework + JWT | 🟡 Pendiente |
| **Almacenamiento** | Supabase Storage | 🟡 Pendiente |

## Estructura del proyecto

```
Sistema-IBV/
├── frontend/          # Nuxt 3 + Vue 3 (Frontend)
├── backend/           # Django + DRF (API Backend) - Por crear
├── venv/              # Entorno virtual Python
├── .github/           # Templates de GitHub (PR, Issues)
├── requirements.txt   # Dependencias Python
└── README.md
```

## Requisitos previos

- **Python:** 3.12+ (actualmente usando 3.13.9)
- **Node.js:** 18+ (para Nuxt/Vue)
- **PostgreSQL:** Supabase (cloud)
- **Git:** Para control de versiones

## Instalación

### Backend (Python/Django)

1. **Crear y activar entorno virtual:**
   ```bash
   # Crear entorno virtual
   python -m venv venv
   
   # Activar (Windows PowerShell)
   .\venv\Scripts\Activate.ps1
   
   # Activar (Windows CMD)
   .\venv\Scripts\activate.bat
   
   # Activar (Linux/Mac)
   source venv/bin/activate
   ```

2. **Instalar dependencias:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configurar variables de entorno:**
   ```bash
   # Crear archivo .env en la raíz
   cp .env.example .env
   # Editar .env con las credenciales de Supabase
   ```

4. **Crear estructura del proyecto Django** (pendiente)

### Frontend (Nuxt 3)

1. **Instalar dependencias:**
   ```bash
   cd frontend
   npm install
   ```

2. **Ejecutar en desarrollo:**
   ```bash
   npm run dev
   ```

## Equipo

| Rol | Enfoque |
|---|---|
| Dev 1 — Frontend Lead | Vue, Nuxt, UI/UX, componentes QR |
| Dev 2 — Backend Lead | Django, API, base de datos |
| Dev 3 — Fullstack | Integracion, reportes, modulos secundarios |

## Metodología

Scrum — Sprints de 2 semanas

## Estrategia de Ramas (Git Branching)

Este proyecto utiliza una estrategia basada en **Git Flow simplificado** para mantener un desarrollo ordenado y colaborativo.

### Ramas Principales

| Rama | Propósito | Protección |
|---|---|---|
| `main` | Código en producción, siempre estable | ✅ Protegida |
| `develop` | Rama de desarrollo principal, integración continua | ✅ Protegida |

### Ramas de Trabajo

#### Features (Nuevas funcionalidades)
```
feature/<nombre-descriptivo>
```
**Ejemplos:**
- `feature/qr-scanner`
- `feature/vehicle-reception`
- `feature/inventory-checklist`

**Flujo:**
1. Crear desde `develop`
2. Desarrollar la funcionalidad
3. Pull Request hacia `develop`
4. Code review y merge

#### Bugfixes (Correcciones)
```
bugfix/<descripcion-del-bug>
```
**Ejemplos:**
- `bugfix/login-validation`
- `bugfix/qr-scan-crash`

**Flujo:**
1. Crear desde `develop`
2. Corregir el bug
3. Pull Request hacia `develop`

#### Hotfixes (Correcciones urgentes en producción)
```
hotfix/<descripcion-urgente>
```
**Ejemplos:**
- `hotfix/security-patch`
- `hotfix/critical-dispatch-error`

**Flujo:**
1. Crear desde `main`
2. Corregir el problema
3. Pull Request hacia `main` **y** `develop`

#### Refactor (Mejoras de código sin cambiar funcionalidad)
```
refactor/<componente-o-modulo>
```
**Ejemplos:**
- `refactor/auth-service`
- `refactor/database-queries`

### Convenciones de Commits

Seguimos **Conventional Commits** para mensajes claros:

```
<tipo>(<scope>): <descripción corta>

[cuerpo opcional]
[footer opcional]
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato, espacios (sin cambios de código)
- `refactor`: Refactorización de código
- `test`: Agregar o modificar tests
- `chore`: Tareas de mantenimiento

**Ejemplos:**
```
feat(qr): agregar scanner de códigos QR
fix(login): corregir validación de credenciales
docs(readme): actualizar instrucciones de instalación
refactor(api): mejorar estructura de servicios
```

### Flujo de Trabajo

1. **Crear rama desde `develop`:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/mi-funcionalidad
   ```

2. **Desarrollar y commitear:**
   ```bash
   git add .
   git commit -m "feat(modulo): descripción del cambio"
   ```

3. **Mantener actualizado con `develop`:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/mi-funcionalidad
   git merge develop
   ```

4. **Push y crear Pull Request:**
   ```bash
   git push origin feature/mi-funcionalidad
   ```
   - Crear PR en GitHub hacia `develop`
   - Completar el template de PR
   - Solicitar code review

5. **Después del merge, eliminar rama:**
   ```bash
   git checkout develop
   git pull origin develop
   git branch -d feature/mi-funcionalidad
   ```

### Releases

Para publicar a producción:
1. Crear PR de `develop` → `main`
2. Revisión final del equipo
3. Merge a `main`
4. Tag de versión: `git tag -a v1.0.0 -m "Release 1.0.0"`

## Licencia

Privado — Todos los derechos reservados.

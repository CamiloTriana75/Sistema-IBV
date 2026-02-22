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

## Stack Tecnológico (Pendiente de confirmación)

> ⚠️ **Las tecnologías aún no están definidas oficialmente.** Las siguientes son propuestas iniciales sujetas a revisión y aprobación del equipo.

| Capa | Propuesta | Estado |
|---|---|---|
| **Frontend** | React 18+ (Vite) + TailwindCSS | 🟡 Pendiente |
| **Backend** | Laravel 11+ (API RESTful) | 🟡 Pendiente |
| **Base de datos** | Supabase (PostgreSQL) | 🟡 Pendiente |
| **Autenticación** | Laravel Sanctum | 🟡 Pendiente |
| **Almacenamiento** | Supabase Storage | 🟡 Pendiente |

## Estructura del proyecto (por definir)

```
Sistema-IBV/
├── frontend/          # Por definir
├── backend/           # Por definir
├── docs/              # Documentación del proyecto
└── README.md
```

## Requisitos previos

> Se definirán una vez confirmado el stack tecnológico.

## Instalación

> Se documentará una vez iniciado el desarrollo.

## Equipo

| Rol | Enfoque |
|---|---|
| Dev 1 — Frontend Lead | React, UI/UX, componentes QR |
| Dev 2 — Backend Lead | Laravel, API, base de datos |
| Dev 3 — Fullstack | Integración, reportes, módulos secundarios |

## Metodología

Scrum — Sprints de 2 semanas

## Licencia

Privado — Todos los derechos reservados.

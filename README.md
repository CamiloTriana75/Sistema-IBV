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
| Dev 1 — Frontend Lead | Vue, Nuxt, UI/UX, componentes QR |
| Dev 2 — Backend Lead | Django, API, base de datos |
| Dev 3 — Fullstack | Integracion, reportes, modulos secundarios |

## Metodología

Scrum — Sprints de 2 semanas

## Licencia

Privado — Todos los derechos reservados.

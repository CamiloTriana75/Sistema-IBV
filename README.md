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

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| **Frontend** | React 18+ (Vite) + TailwindCSS |
| **Backend** | Laravel 11+ (API RESTful) |
| **Base de datos** | Supabase (PostgreSQL) |
| **Autenticación** | Laravel Sanctum |
| **Almacenamiento** | Supabase Storage |

## Estructura del proyecto

```
Sistema-IBV/
├── frontend/          # React + Vite + TailwindCSS
├── backend/           # Laravel API
├── docs/              # Documentación del proyecto
└── README.md
```

## Requisitos previos

- Node.js 18+
- PHP 8.2+
- Composer
- Cuenta de Supabase (plan pago)

## Instalación

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Backend
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

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

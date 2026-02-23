# Estructura del Proyecto Frontend - Nuxt 3

Este documento describe la estructura de carpetas recomendada para el proyecto Nuxt 3 Sistema IBV.

## 📁 Estructura General

```
frontend/
├── public/                          # Archivos estáticos
│   └── README.md
│
├── src/                             # Código fuente
│   ├── app.vue                      # Componente raíz
│   │
│   ├── assets/                      # Recursos estáticos
│   │   ├── images/                  # Imágenes
│   │   ├── styles/                  # Estilos globales
│   │   ├── fonts/                   # Fuentes personalizadas
│   │   └── README.md
│   │
│   ├── components/                  # Componentes Vue reutilizables
│   │   ├── common/                  # Componentes comunes (Button, Input, Modal)
│   │   ├── forms/                   # Componentes de formulario
│   │   ├── layout/                  # Componentes de layout (Header, Sidebar)
│   │   ├── admin/                   # Componentes específicos del admin
│   │   ├── QrScanner.vue
│   │   └── README.md
│   │
│   ├── composables/                 # Lógica reutilizable (Composition API)
│   │   └── README.md
│   │
│   ├── layouts/                     # Layouts para páginas
│   │   ├── default.vue              # Layout por defecto
│   │   ├── blank.vue                # Layout vacío (login, etc)
│   │   └── README.md
│   │
│   ├── middleware/                  # Middlewares de rutas
│   │   └── README.md
│   │
│   ├── pages/                       # Páginas (rutas)
│   │   ├── index.vue                # / (inicio)
│   │   ├── login.vue                # /login
│   │   ├── admin/
│   │   │   ├── index.vue            # /admin
│   │   │   ├── usuarios.vue         # /admin/usuarios
│   │   │   └── usuarios/
│   │   │       ├── [id].vue         # /admin/usuarios/:id
│   │   │       └── crear.vue        # /admin/usuarios/crear
│   │   └── README.md
│   │
│   ├── plugins/                     # Plugins de Nuxt
│   │   └── README.md
│   │
│   ├── server/                      # Código del servidor (Nitro)
│   │   ├── api/                     # Rutas API
│   │   │   └── README.md
│   │   └── middleware/              # Middlewares de servidor
│   │       └── README.md
│   │
│   ├── services/                    # Servicios (API calls, lógica de negocio)
│   │   ├── api.ts                   # Instancia de HTTP
│   │   ├── userService.ts
│   │   └── README.md
│   │
│   ├── stores/                      # Stores de Pinia
│   │   ├── auth.ts
│   │   ├── userStore.ts
│   │   └── README.md
│   │
│   ├── types/                       # Definiciones TypeScript
│   │   ├── index.ts
│   │   └── README.md
│   │
│   └── utils/                       # Funciones de utilidad
│       ├── helpers.ts
│       └── README.md
│
├── .env.example                     # Variables de entorno (ejemplo)
├── .env                             # Variables de entorno (local, NO commitear)
├── .gitignore                       # Archivos ignorados en git
├── nuxt.config.ts                  # Configuración de Nuxt
├── tailwind.config.ts              # Configuración de Tailwind
├── tsconfig.json                   # Configuración de TypeScript
├── package.json                    # Dependencias
├── package-lock.json               # Lock file
└── README.md                       # Este archivo
```

## 🚀 Guía Rápida por Directorio

### 📄 Pages

- **Propósito:** Define las rutas de la aplicación
- **Automático:** Nuxt genera rutas basadas en la estructura
- **Convención:** kepan-case para archivos, `[id]` para parámetros dinámicos

### 🧩 Components

- **Propósito:** Componentes Vue reutilizables
- **Subdirectorios:** `common/`, `forms/`, `layout/`, `admin/`
- **Convención:** PascalCase, `scoped` styles

### 🎨 Layouts

- **Propósito:** Envuelven las páginas
- **Disponibles:** `default.vue`, `blank.vue`
- **Uso:** `definePageMeta({ layout: 'admin' })`

### 🏪 Stores

- **Propósito:** Estado global con Pinia
- **Disponibles:** `auth.ts`, `userStore.ts`
- **Convención:** `useAuthStore()`, `useUserStore()`

### 🔧 Services

- **Propósito:** Lógica de negocio e integración con API
- **Disponibles:** `api.ts` (axios), `userService.ts`
- **Convención:** CRUD methods, stateless

### 🛠️ Composables

- **Propósito:** Lógica reutilizable con Composition API
- **Convención:** Prefijo `use`: `useAuth()`, `useFetch()`

### 📝 Middleware

- **Propósito:** Proteger rutas y ejecutar lógica antes de renderizar
- **Convención:** Auto-importados y nombrados por archivo

### 🗂️ Assets

- **Propósito:** Recursos estáticos: imágenes, estilos, fuentes
- **Subdirectorios:** `images/`, `styles/`, `fonts/`
- **Acceso:** `~/assets/...` o `@/assets/...`

### 📡 Server

- **Propósito:** Backend con Nitro
- **Subdirectorios:** `api/`, `middleware/`
- **Acceso:** `/api/*` desde cliente

## 🔗 Alias de Importación

```typescript
import Component from '~/components/common/Button.vue'
import { useAuth } from '~/composables/useAuth'
import { useAuthStore } from '~/stores/auth'
import { User } from '~/types/index'
import { helpers } from '~/utils/helpers'
```

## 📦 Scripts Disponibles

```bash
# Desarrollo
npm run dev              # Iniciar servidor de desarrollo

# Producción
npm run build           # Compilar para producción
npm run generate        # Generar sitio estático
npm run preview         # Preview de compilación

# Code Quality
npm run lint            # Ejecutar ESLint
npm run format          # Formatear con Prettier
```

## 📋 Checklist de Estructura

- ✅ Directorio `/public` para archivos estáticos
- ✅ Directorio `/src/components` con subdirectorios organizados
- ✅ Directorio `/src/layouts` con layouts disponibles
- ✅ Directorio `/src/pages` con rutas
- ✅ Directorio `/src/stores` con Pinia
- ✅ Directorio `/src/services` para integración API
- ✅ Directorio `/src/types` para type definitions
- ✅ Directorio `/src/middleware` para protección de rutas
- ✅ Directorio `/src/server` para backend Nitro
- ✅ Archivo `.env.example` documentado
- ✅ README.md en directorios clave

## 🎯 Próximos Pasos

1. Revisar y ajustar la estructura según necesidades específicas del proyecto
2. Completar componentes en `src/components/common/`
3. Implementar servicios en `src/services/`
4. Configurar tipos en `src/types/index.ts`
5. Crear páginas según requerimientos de Sistema IBV

---

**Última actualización:** Febrero 2026

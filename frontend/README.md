# Sistema IBV - Frontend

## Estructura del Proyecto

```
frontend/
├── src/
│   ├── pages/              # Páginas (rutas automáticas)
│   ├── components/         # Componentes reutilizables
│   ├── layouts/            # Layouts de página
│   ├── stores/             # Pinia stores (estado global)
│   ├── services/           # Servicios API
│   ├── composables/        # Composables reutilizables
│   ├── types/              # TypeScript types
│   ├── utils/              # Utilidades
│   ├── assets/             # Imágenes, fonts, etc.
│   └── app.vue            # Componente raíz
├── public/                 # Archivos estáticos
├── nuxt.config.ts         # Configuración Nuxt
├── tailwind.config.ts     # Configuración Tailwind
├── tsconfig.json          # Configuración TypeScript
├── .eslintrc.json         # Configuración ESLint
├── .env.example           # Variables de ejemplo
└── package.json
```

## Instalación

```bash
cd frontend
npm install
```

## Desarrollo

```bash
npm run dev
```

Accede a `http://localhost:3000`

## Build

```bash
npm run build
npm run preview
```

## Tecnologías

- **Vue 3**: Framework de UI
- **Nuxt 3**: Meta-framework para Vue
- **TailwindCSS**: Utilidades de CSS
- **Pinia**: Gestión de estado
- **TypeScript**: Tipado estático
- **html5-qrcode**: Escaneo de QR
- **Axios**: Cliente HTTP

## Próximas Tareas

- [ ] Página de Login completa
- [ ] Sistema de autenticación con JWT
- [ ] Rutas protegidas por rol
- [ ] Módulo de Recepción de Vehículos
- [ ] Módulo de Impronta
- [ ] Módulo de Inventario
- [ ] Módulo de Despacho

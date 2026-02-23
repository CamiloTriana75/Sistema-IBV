# TailwindCSS - Configuración y Guía

Este proyecto está configurado con TailwindCSS 3.4 integrado con Nuxt 3 a través del módulo `@nuxtjs/tailwindcss`.

## 📋 Archivos de Configuración

### 1. `tailwind.config.ts`

Configuración de TailwindCSS con:

- **Content**: Paths donde Tailwind busca clases (componentes, layouts, páginas)
- **Theme**: Personalizaciones de colores, fuentes y espaciado
- **Plugins**: Extensiones de Tailwind (actualmente vacío)

**Colores personalizados:**

```typescript
primary: {
  ;(50, 100, 500, 600, 700, 900)
} // Azul corporativo
success: {
  ;(500, 600)
} // Verde
warning: {
  ;(500, 600)
} // Naranja
danger: {
  ;(500, 600)
} // Rojo
```

### 2. `postcss.config.js`

Configuración de PostCSS:

- **TailwindCSS**: Procesador principal
- **Autoprefixer**: Añade prefijos CSS para compatibilidad

### 3. `nuxt.config.ts`

Integración con Nuxt:

```typescript
modules: ['@nuxtjs/tailwindcss'],
postcss: {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
}
```

## 📁 Archivos de Estilos

### `src/assets/styles/global.css`

- Importa directivas de Tailwind: `@tailwind base, components, utilities`
- Estilos globales para elementos HTML
- Reset de estilos por defecto
- Styles personalizados para inputs, buttons, scrollbar

### `src/assets/styles/variables.css`

- Variables CSS globales accesibles en componentes
- Colores, espaciado, bordes, sombras
- Soporte para modo oscuro

## 🎨 Cómo Usar TailwindCSS

### En Templates

```vue
<template>
  <div class="flex items-center justify-center min-h-screen bg-gray-50">
    <h1 class="text-4xl font-bold text-primary-600">Hola Mundo</h1>
  </div>
</template>
```

### En Estilos Scoped

```vue
<style scoped>
.custom-class {
  @apply flex items-center justify-between px-4 py-2 bg-white rounded-lg shadow;
}
</style>
```

### Responsive Design

```vue
<!-- Mobile: w-full, Tablet (md): w-1/2, Desktop (lg): w-1/3 -->
<div class="w-full md:w-1/2 lg:w-1/3">
  Contenido responsivo
</div>
```

### Estados (Hover, Focus, etc.)

```vue
<!-- Hover -->
<button class="bg-primary-600 hover:bg-primary-700">Botón</button>

<!-- Focus -->
<input class="focus:ring-2 focus:ring-primary-500" />

<!-- Dark mode -->
<div class="bg-white dark:bg-gray-900">Contenido</div>
```

## 🧩 Componentes Incluidos

### `Button.vue`

Botón reutilizable con variantes:

```vue
<script setup lang="ts">
import Button from '~/components/common/Button.vue'
</script>

<template>
  <Button variant="primary" @click="handleClick">Click me</Button>
  <Button variant="success">Éxito</Button>
  <Button variant="danger" disabled>Deshabilitado</Button>
</template>
```

**Props:**

- `variant`: primary | secondary | success | danger
- `disabled`: boolean

### `FormInput.vue`

Input de formulario con etiqueta:

```vue
<template>
  <FormInput v-model="email" type="email" label="Email" placeholder="tu@email.com" required />
</template>
```

**Props:**

- `modelValue`: string
- `label`: string
- `type`: string (default: text)
- `placeholder`: string
- `required`: boolean
- `disabled`: boolean

### `Card.vue`

Contenedor de contenido:

```vue
<template>
  <Card title="Mi Tarjeta">
    Contenido de la tarjeta

    <template #footer>
      <button>Aceptar</button>
    </template>
  </Card>
</template>
```

**Props:**

- `title`: string (encabezado opcional)

**Slots:**

- `default`: Contenido principal
- `footer`: Contenido del pie de página

## 📐 Breakpoints

TailwindCSS incluye breakpoints predefinidos:

- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

Uso:

```html
<!-- Oculto en mobile, visible en md y arriba -->
<div class="hidden md:block">Contenido</div>

<!-- Flex en mobile, inline en lg y arriba -->
<div class="flex lg:inline-flex">Item</div>
```

## 🎯 Paleta de Colores

### Colores Primarios

```
bg-primary-50   #f0f9ff
bg-primary-100  #e0f2fe
bg-primary-500  #0ea5e9  ← Principal
bg-primary-600  #0284c7  ← Hover
bg-primary-700  #0369a1  ← Active
bg-primary-900  #082f49  ← Dark
```

### Estados

```
bg-success-500  #10b981  (Verde)
bg-warning-500  #f59e0b  (Naranja)
bg-danger-500   #ef4444  (Rojo)
```

### Escala Gris

```
bg-gray-50   (Muy claro)
bg-gray-100  (Claro)
bg-gray-500  (Medio)
bg-gray-900  (Muy oscuro)
```

## 🚀 Optimizaciones

1. **PurgeCSS**: TailwindCSS automáticamente elimina estilos no usados en producción
2. **Content**: Configurado para buscar en todos los archivos Vue, JS, TS
3. **JIT Mode**: Generación just-in-time de estilos (por defecto en Tailwind 3)

## 📚 Recursos

- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Tailwind UI Components](https://tailwindui.com)
- [Headless UI (sin estilos, combina con Tailwind)](https://headlessui.com)

## ✅ Checklist de Configuración

- ✅ TailwindCSS instalado (v3.4.19)
- ✅ @nuxtjs/tailwindcss módulo integrado
- ✅ tailwind.config.ts configurado con colores personalizados
- ✅ postcss.config.js configurado
- ✅ global.css con directivas de Tailwind
- ✅ variables.css con variables CSS globales
- ✅ Componentes de ejemplo (Button, FormInput, Card)
- ✅ app.vue importa estilos globales

---

**Última actualización:** Febrero 2026
**Versión TailwindCSS:** 3.4.19

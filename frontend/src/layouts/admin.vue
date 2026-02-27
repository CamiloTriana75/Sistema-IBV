<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAuthStore } from '~/stores/auth'
import NotificationBell from '~/components/notifications/NotificationBell.vue'

const route = useRoute()
const authStore = useAuthStore()
const sidebarOpen = ref(false)

// Leer usuario actual del store de autenticación
const currentUser = computed(() => {
  const u = authStore.user
  if (!u) {
    return { name: 'Usuario', initials: 'U', role: 'admin', roleName: 'Sin rol' }
  }
  
  // Obtener iniciales del nombre
  const initials = u.name
    ?.split(' ')
    .map((w: string) => w[0])
    .join('')
    .substring(0, 2)
    .toUpperCase() || 'U'
  
  // Mapear roles a nombres legibles
  const roleNames: Record<string, string> = {
    admin: 'Administrador',
    recibidor: 'Recibidor',
    inventario: 'Inventario',
    despachador: 'Despachador',
    porteria: 'Portería',
    cliente: 'Cliente',
  }
  
  return {
    name: u.name || 'Usuario',
    initials,
    role: u.role || 'admin',
    roleName: roleNames[u.role] || u.role || 'Usuario',
  }
})

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/admin': 'Dashboard',
    '/admin/estadisticas': 'Estadísticas y Reportes',
    '/admin/usuarios': 'Gestión de Usuarios',
    '/admin/roles': 'Roles y Permisos',
    '/admin/notificaciones': 'Centro de Notificaciones',
    '/admin/recepcion': 'Monitoreo Recepción',
    '/admin/inventario': 'Monitoreo Inventario',
    '/admin/despacho': 'Monitoreo Despacho',
    '/admin/auditoria': 'Auditoría y Control',
    '/admin/excepciones': 'Gestión de Excepciones',
    '/recibidor': 'Panel Recibidor',
    '/recibidor/escaneo': 'Recepción de Vehículos',
    '/recibidor/impronta': 'Registro de Impronta',
    '/recibidor/recepciones': 'Recepciones Realizadas',
    '/inventario': 'Panel Inventario',
    '/inventario/checklist': 'Inspección de Vehículo',
    '/despachador': 'Panel Despachador',
    '/despachador/escaneo': 'Escaneo de Lote',
    '/porteria': 'Panel Portería',
  }
  return titles[route.path] || 'Dashboard'
})

// Detectar módulo actual basado en la ruta (no en el rol del usuario)
const currentModule = computed(() => {
  const path = route.path
  if (currentUser.value.role === 'admin') return 'admin'
  if (path.startsWith('/admin')) return 'admin'
  if (path.startsWith('/recibidor')) return 'recibidor'
  if (path.startsWith('/inventario')) return 'inventario'
  if (path.startsWith('/despachador')) return 'despachador'
  if (path.startsWith('/porteria')) return 'porteria'
  // Fallback al rol del usuario si la ruta no coincide con ningún módulo
  return currentUser.value.role
})

// Menú basado en la ruta actual (independiente del rol)
const menuItems = computed(() => {
  const module = currentModule.value
  const allMenus: Record<
    string,
    Array<{ to: string; label: string; icon: string; badge?: number }>
  > = {
    admin: [
      {
        to: '/admin',
        label: 'Dashboard',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/admin/estadisticas',
        label: 'Estadísticas',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" /></svg>',
      },
      {
        to: '/admin/usuarios',
        label: 'Usuarios',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" /></svg>',
      },
      {
        to: '/admin/roles',
        label: 'Roles y Permisos',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>',
      },
      {
        to: '/admin/notificaciones',
        label: 'Notificaciones',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>',
      },
      {
        to: '/admin/recepcion',
        label: 'Monitoreo Recepción',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m7 0a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
      },
      {
        to: '/admin/inventario',
        label: 'Monitoreo Inventario',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m7 0a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
      },
      {
        to: '/admin/despacho',
        label: 'Monitoreo Despacho',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m7 0a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
      },
      {
        to: '/admin/auditoria',
        label: 'Auditoría y Control',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4v.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
      },
      {
        to: '/admin/excepciones',
        label: 'Excepciones',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 8v4m0 4v.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
      },
    ],
    recibidor: [
      {
        to: '/recibidor',
        label: 'Panel Recibidor',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/recibidor/escaneo',
        label: 'Escaneo',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" /></svg>',
      },
      {
        to: '/recibidor/recepciones',
        label: 'Recepciones',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" /></svg>',
      },
      {
        to: '/recibidor/impronta',
        label: 'Nueva Impronta',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4v16m8-8H4" /></svg>',
      },
    ],
    inventario: [
      {
        to: '/inventario',
        label: 'Panel Inventario',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/inventario/checklist',
        label: 'Inspecciones',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" /></svg>',
        badge: 3,
      },
    ],
    despachador: [
      {
        to: '/despachador',
        label: 'Panel Despacho',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/despachador/escaneo',
        label: 'Escaneo de Lote',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>',
        badge: 2,
      },
    ],
    porteria: [
      {
        to: '/porteria',
        label: 'Panel Portería',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
    ],
  }
  return allMenus[module] || allMenus.admin
})

const isActive = (path: string) => {
  if (path === route.path) return true
  // Para sub-rutas, marcar el padre pero no si es la raíz exacta del rol
  const rolePaths = ['/admin', '/recibidor', '/inventario', '/despachador', '/porteria']
  if (rolePaths.includes(path) && route.path !== path) return false
  if (route.path.startsWith(path) && path !== route.path) return true
  return false
}

const handleLogout = () => {
  authStore.logout()
  navigateTo('/login')
}
</script>

<template>
  <ClientOnly>
    <div class="min-h-screen bg-gray-100">
      <!-- Overlay mobile -->
    <div
      v-if="sidebarOpen"
      class="fixed inset-0 bg-black/50 z-40 lg:hidden"
      @click="sidebarOpen = false"
    />

    <!-- Sidebar -->
    <aside
      :class="[
        'fixed top-0 left-0 bottom-0 z-50 w-72 bg-gray-900 text-white transform transition-transform duration-300 ease-in-out lg:translate-x-0 flex flex-col',
        sidebarOpen ? 'translate-x-0' : '-translate-x-full',
      ]"
    >
      <!-- Logo y Header -->
      <div class="relative px-6 h-20 border-b border-gray-800/50 shrink-0 bg-gray-900">
        <div class="relative flex items-center gap-4 h-full">
          <!-- Ícono con efecto moderno -->
          <div class="relative">
            <div class="absolute inset-0 bg-primary-500 rounded-xl blur-md opacity-40"></div>
            <div class="relative w-12 h-12 bg-gradient-to-br from-primary-500 to-primary-600 rounded-xl flex items-center justify-center shadow-lg shadow-primary-500/30 transform hover:scale-105 transition-transform duration-200">
              <svg class="w-7 h-7 text-white drop-shadow-md" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
                />
              </svg>
            </div>
          </div>
          
          <!-- Texto del sistema -->
          <div class="flex-1 min-w-0">
            <h1 class="text-xl font-bold text-white tracking-tight mb-0.5">
              Sistema IBV
            </h1>
            <div class="flex items-center gap-2">
              <div class="h-px w-4 bg-gradient-to-r from-primary-400 to-transparent"></div>
              <p class="text-xs font-medium text-gray-400 tracking-wide uppercase">
                Gestión Vehicular
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Navegación -->
      <nav class="flex-1 px-4 py-4 space-y-1 overflow-y-auto">
        <template v-for="item in menuItems" :key="item.to">
          <NuxtLink
            :to="item.to"
            :class="[
              'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200',
              isActive(item.to)
                ? 'bg-primary-600 text-white shadow-lg shadow-primary-600/30'
                : 'text-gray-300 hover:bg-gray-800 hover:text-white',
            ]"
            @click="sidebarOpen = false"
          >
            <!-- eslint-disable-next-line vue/no-v-html -->
            <span class="w-5 h-5 shrink-0" v-html="item.icon" />
            <span>{{ item.label }}</span>
            <span
              v-if="item.badge"
              class="ml-auto bg-danger-500 text-white text-xs px-2 py-0.5 rounded-full"
            >
              {{ item.badge }}
            </span>
          </NuxtLink>
        </template>

      </nav>

      <!-- Cerrar sesión -->
      <div class="px-4 py-4 border-t border-gray-800 shrink-0">
        <button
          class="flex items-center gap-3 w-full px-3 py-2.5 rounded-lg text-sm font-medium text-gray-300 hover:bg-red-600/20 hover:text-red-400 transition-all"
          @click="handleLogout"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
            />
          </svg>
          <span>Cerrar Sesión</span>
        </button>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div class="lg:pl-72">
      <!-- Top Header -->
      <header
        class="sticky top-0 z-30 bg-white border-b border-gray-200 h-20 flex items-center justify-between px-4 sm:px-6 shadow-sm"
      >
        <!-- Toggle sidebar (mobile) -->
        <button
          class="lg:hidden text-gray-500 hover:text-gray-700"
          @click="sidebarOpen = !sidebarOpen"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 6h16M4 12h16M4 18h16"
            />
          </svg>
        </button>

        <!-- Breadcrumb / Título -->
        <div class="hidden lg:block">
          <h2 class="text-lg font-semibold text-gray-800">{{ pageTitle }}</h2>
        </div>

        <!-- Right side -->
        <div class="flex items-center gap-4">
          <!-- Notificaciones -->
          <NotificationBell />

          <!-- Perfil -->
          <div class="flex items-center gap-2 pl-4 border-l border-gray-200">
            <div
              class="w-8 h-8 bg-primary-600 rounded-full flex items-center justify-center text-xs font-bold text-white"
            >
              {{ currentUser.initials }}
            </div>
            <div class="hidden sm:block">
              <p class="text-sm font-medium text-gray-700">{{ currentUser.name }}</p>
            </div>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="p-4 sm:p-6 lg:p-8">
        <slot />
      </main>
    </div>
  </div>
  </ClientOnly>
</template>

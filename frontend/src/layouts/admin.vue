<script setup lang="ts">
import { ref, computed } from 'vue'
import { useAuthStore } from '~/stores/auth'

const route = useRoute()
const sidebarOpen = ref(false)
const authStore = useAuthStore()

const roleLabels: Record<string, string> = {
  admin: 'Administrador',
  porteria: 'Porteria',
  recibidor: 'Recibidor',
  inventario: 'Inventario',
  despachador: 'Despachador',
  cliente: 'Cliente',
}

const buildInitials = (fullName: string) => {
  const parts = fullName.trim().split(/\s+/).filter(Boolean)
  const initials = parts
    .slice(0, 2)
    .map((part) => part[0])
    .join('')
  return initials || 'U'
}

const currentUser = computed(() => {
  const user = authStore.user
  if (!user) {
    return {
      name: 'Usuario',
      initials: 'U',
      role: 'cliente',
      roleName: roleLabels.cliente,
    }
  }

  return {
    name: user.name,
    initials: buildInitials(user.name || user.email),
    role: user.role,
    roleName: roleLabels[user.role] || user.role,
  }
})

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/admin': 'Dashboard',
    '/admin/usuarios': 'Gestión de Usuarios',
    '/admin/roles': 'Roles y Permisos',
    '/recibidor': 'Panel Recibidor',
    '/inventario': 'Panel Inventario',
    '/despachador': 'Panel Despachador',
    '/porteria': 'Panel Portería',
  }
  return titles[route.path] || 'Dashboard'
})

// Menú basado en rol
const menuItems = computed(() => {
  const role = currentUser.value.role
  const allMenus: Record<string, any[]> = {
    admin: [
      {
        to: '/admin',
        label: 'Dashboard',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
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
    ],
    recibidor: [
      {
        to: '/recibidor',
        label: 'Panel Recibidor',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/recibidor/vehiculos',
        label: 'Recibir Vehículos',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4v16m8-8H4" /></svg>',
        badge: '5',
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
        badge: '3',
      },
    ],
    despachador: [
      {
        to: '/despachador',
        label: 'Panel Despacho',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/despachador/despachos',
        label: 'Despachar',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>',
        badge: '2',
      },
    ],
    porteria: [
      {
        to: '/porteria',
        label: 'Panel Portería',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" /></svg>',
      },
      {
        to: '/porteria/escanear',
        label: 'Escanear QR',
        icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" /></svg>',
      },
    ],
  }
  return allMenus[role] || allMenus.admin
})

const isActive = (path: string) => {
  if (path === '/admin' && route.path === '/admin') return true
  if (path !== '/admin' && route.path.startsWith(path)) return true
  return false
}

const handleLogout = async () => {
  await authStore.logout()
  navigateTo('/login')
}
</script>

<template>
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
      <!-- Logo -->
      <div class="flex items-center gap-3 px-6 h-16 border-b border-gray-800 shrink-0">
        <div class="w-9 h-9 bg-primary-500 rounded-lg flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
            />
          </svg>
        </div>
        <div>
          <h1 class="text-lg font-bold">Sistema IBV</h1>
          <p class="text-xs text-gray-400">Gestión de Vehículos</p>
        </div>
      </div>

      <!-- Perfil del usuario -->
      <div class="px-6 py-4 border-b border-gray-800 shrink-0">
        <div class="flex items-center gap-3">
          <div
            class="w-10 h-10 bg-primary-600 rounded-full flex items-center justify-center text-sm font-bold"
          >
            {{ currentUser.initials }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium truncate">{{ currentUser.name }}</p>
            <p class="text-xs text-gray-400 truncate">{{ currentUser.roleName }}</p>
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
        class="sticky top-0 z-30 bg-white border-b border-gray-200 h-16 flex items-center justify-between px-4 sm:px-6 shadow-sm"
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
          <button class="relative text-gray-400 hover:text-gray-600 transition">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
              />
            </svg>
            <span
              class="absolute -top-1 -right-1 w-4 h-4 bg-danger-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center"
            >
              3
            </span>
          </button>

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
</template>

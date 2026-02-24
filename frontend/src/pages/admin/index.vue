<script setup lang="ts">
import { ref } from 'vue'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const stats = ref([
  {
    label: 'Usuarios Activos',
    value: '24',
    trend: '+3 esta semana',
    trendUp: true,
    bgColor: 'bg-primary-50',
    iconColor: 'text-primary-600',
    icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" /></svg>'
  },
  {
    label: 'Vehículos en Patio',
    value: '156',
    trend: '+12 hoy',
    trendUp: true,
    bgColor: 'bg-success-50',
    iconColor: 'text-success-600',
    icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z" /></svg>'
  },
  {
    label: 'Despachos Hoy',
    value: '38',
    trend: '-5 vs ayer',
    trendUp: false,
    bgColor: 'bg-warning-50',
    iconColor: 'text-warning-600',
    icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>'
  },
  {
    label: 'Inspecciones Pendientes',
    value: '7',
    trend: '-2 vs ayer',
    trendUp: true,
    bgColor: 'bg-danger-50',
    iconColor: 'text-danger-600',
    icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" /></svg>'
  }
])

const quickLinks = ref([
  { to: '/admin/usuarios', label: 'Gestionar Usuarios', desc: 'Crear, editar y eliminar', bgColor: 'bg-primary-50', iconColor: 'text-primary-600', icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" /></svg>' },
  { to: '/admin/roles', label: 'Roles y Permisos', desc: 'Configurar accesos', bgColor: 'bg-purple-50', iconColor: 'text-purple-600', icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>' },
  { to: '/recibidor', label: 'Ver Recepción', desc: 'Panel recibidor', bgColor: 'bg-blue-50', iconColor: 'text-blue-600', icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>' },
  { to: '/inventario', label: 'Ver Inventario', desc: 'Estado de inspecciones', bgColor: 'bg-amber-50', iconColor: 'text-amber-600', icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" /></svg>' },
  { to: '/despachador', label: 'Ver Despachos', desc: 'Estado del despacho', bgColor: 'bg-green-50', iconColor: 'text-green-600', icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>' },
])

const activities = ref([
  { user: 'María Recibidora', action: 'registró impronta del vehículo ABC-123', time: 'Hace 15 min', avatar: 'MR', color: 'bg-blue-500', badge: 'Impronta', badgeClass: 'bg-blue-50 text-blue-600' },
  { user: 'Juan Inventario', action: 'completó inspección del vehículo XYZ-789', time: 'Hace 32 min', avatar: 'JI', color: 'bg-amber-500', badge: 'Inventario', badgeClass: 'bg-amber-50 text-amber-600' },
  { user: 'Luis Despachador', action: 'despachó lote #2045 (8 vehículos)', time: 'Hace 1 hora', avatar: 'LD', color: 'bg-green-500', badge: 'Despacho', badgeClass: 'bg-green-50 text-green-600' },
  { user: 'Ana Portería', action: 'autorizó salida del vehículo DEF-456', time: 'Hace 2 horas', avatar: 'AP', color: 'bg-purple-500', badge: 'Portería', badgeClass: 'bg-purple-50 text-purple-600' },
  { user: 'Carlos Admin', action: 'creó usuario nuevo: Pedro Inspector', time: 'Hace 3 horas', avatar: 'CA', color: 'bg-primary-500', badge: 'Admin', badgeClass: 'bg-primary-50 text-primary-600' },
])

const roles = ref([
  { name: 'Admin', count: 2, color: 'bg-primary-600', desc: 'Gestión total' },
  { name: 'Recibidor', count: 5, color: 'bg-blue-500', desc: 'Recepción' },
  { name: 'Inventario', count: 6, color: 'bg-amber-500', desc: 'Inspección' },
  { name: 'Despachador', count: 4, color: 'bg-green-500', desc: 'Despacho' },
  { name: 'Portería', count: 7, color: 'bg-purple-500', desc: 'Control' },
])
</script>

<template>
  <div>
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Dashboard Administrativo</h1>
      <p class="text-gray-500 mt-1">Resumen general del sistema</p>
    </div>

    <!-- Estadísticas principales -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
      <div v-for="stat in stats" :key="stat.label" class="bg-white rounded-xl p-5 shadow-sm border border-gray-100 hover:shadow-md transition">
        <div class="flex items-center justify-between mb-3">
          <div :class="['w-11 h-11 rounded-lg flex items-center justify-center', stat.bgColor]">
            <!-- eslint-disable-next-line vue/no-v-html -->
            <span :class="['w-5 h-5', stat.iconColor]" v-html="stat.icon" />
          </div>
          <span :class="['text-xs font-semibold px-2 py-1 rounded-full', stat.trendUp ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600']">
            {{ stat.trend }}
          </span>
        </div>
        <p class="text-3xl font-bold text-gray-900">{{ stat.value }}</p>
        <p class="text-sm text-gray-500 mt-1">{{ stat.label }}</p>
      </div>
    </div>

    <!-- Grid principal -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
      <!-- Acceso rápido -->
      <div class="lg:col-span-1 bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Acceso Rápido</h3>
        <div class="space-y-3">
          <NuxtLink
            v-for="link in quickLinks"
            :key="link.to"
            :to="link.to"
            class="flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition group"
          >
            <div :class="['w-10 h-10 rounded-lg flex items-center justify-center shrink-0', link.bgColor]">
              <!-- eslint-disable-next-line vue/no-v-html -->
              <span :class="['w-5 h-5', link.iconColor]" v-html="link.icon" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 group-hover:text-primary-600 transition">{{ link.label }}</p>
              <p class="text-xs text-gray-500">{{ link.desc }}</p>
            </div>
            <svg class="w-4 h-4 text-gray-400 group-hover:text-primary-500 transition" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </NuxtLink>
        </div>
      </div>

      <!-- Actividad reciente -->
      <div class="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold text-gray-900">Actividad Reciente</h3>
          <span class="text-xs text-gray-400">Últimas 24 horas</span>
        </div>
        <div class="space-y-4">
          <div v-for="(activity, i) in activities" :key="i" class="flex items-start gap-3">
            <div :class="['w-8 h-8 rounded-full flex items-center justify-center shrink-0 text-xs font-bold text-white', activity.color]">
              {{ activity.avatar }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm text-gray-800">
                <span class="font-medium">{{ activity.user }}</span>
                {{ activity.action }}
              </p>
              <p class="text-xs text-gray-400 mt-0.5">{{ activity.time }}</p>
            </div>
            <span :class="['text-xs px-2 py-1 rounded-full font-medium', activity.badgeClass]">
              {{ activity.badge }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Usuarios por rol -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">Distribución por Rol</h3>
      <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
        <div v-for="role in roles" :key="role.name" class="text-center p-4 rounded-xl bg-gray-50 hover:bg-gray-100 transition">
          <div :class="['w-12 h-12 rounded-full mx-auto flex items-center justify-center mb-2 text-white font-bold', role.color]">
            {{ role.count }}
          </div>
          <p class="text-sm font-medium text-gray-700">{{ role.name }}</p>
          <p class="text-xs text-gray-400">{{ role.desc }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

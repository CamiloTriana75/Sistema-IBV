<script setup lang="ts">
definePageMeta({
  layout: 'admin',
  middleware: ['auth', 'admin'],
})

const stats = [
  {
    label: 'Total Usuarios',
    value: '24',
    change: '+3 este mes',
    changePositive: true,
    bgColor: 'bg-primary-100',
    icon: '<svg class="text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" /></svg>',
  },
  {
    label: 'Vehículos Activos',
    value: '156',
    change: '+12 esta semana',
    changePositive: true,
    bgColor: 'bg-success-500/10',
    icon: '<svg class="text-success-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z" /></svg>',
  },
  {
    label: 'Despachos Hoy',
    value: '8',
    change: '-2 vs ayer',
    changePositive: false,
    bgColor: 'bg-warning-500/10',
    icon: '<svg class="text-warning-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>',
  },
  {
    label: 'Pendientes',
    value: '5',
    change: '3 urgentes',
    changePositive: false,
    bgColor: 'bg-danger-500/10',
    icon: '<svg class="text-danger-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
  },
]

const recentActivity = [
  {
    id: 1,
    title: 'Nuevo vehículo recibido',
    description: 'Toyota Corolla - BIN: VH-2024-0156',
    time: 'Hace 5 min',
    color: 'bg-success-500/10 text-success-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M12 4v16m8-8H4" /></svg>',
  },
  {
    id: 2,
    title: 'Usuario creado',
    description: 'Carlos Pérez - Rol: Recibidor',
    time: 'Hace 15 min',
    color: 'bg-primary-100 text-primary-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>',
  },
  {
    id: 3,
    title: 'Despacho completado',
    description: 'Lote #D-045 - 12 vehículos',
    time: 'Hace 1h',
    color: 'bg-warning-500/10 text-warning-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
  },
  {
    id: 4,
    title: 'Inspección finalizada',
    description: 'Chevrolet Spark - VH-2024-0148',
    time: 'Hace 2h',
    color: 'bg-blue-100 text-blue-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" /></svg>',
  },
  {
    id: 5,
    title: 'Vehículo despachado',
    description: 'Nissan Versa - BIN: VH-2024-0140',
    time: 'Hace 3h',
    color: 'bg-gray-100 text-gray-600',
    icon: '<svg fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>',
  },
]

const vehicleStatuses = [
  {
    label: 'Pendientes',
    count: 12,
    percent: 8,
    textColor: 'text-gray-600',
    barColor: 'bg-gray-400',
  },
  {
    label: 'Recibidos',
    count: 38,
    percent: 24,
    textColor: 'text-primary-600',
    barColor: 'bg-primary-500',
  },
  {
    label: 'Improntados',
    count: 45,
    percent: 29,
    textColor: 'text-warning-600',
    barColor: 'bg-warning-500',
  },
  {
    label: 'Inventariados',
    count: 42,
    percent: 27,
    textColor: 'text-success-600',
    barColor: 'bg-success-500',
  },
  {
    label: 'Despachados',
    count: 19,
    percent: 12,
    textColor: 'text-blue-600',
    barColor: 'bg-blue-500',
  },
]
</script>

<template>
  <div>
    <!-- Bienvenida -->
    <div class="mb-8">
      <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Bienvenido, Admin</h1>
      <p class="text-gray-500 mt-1">Resumen general del sistema de gestión de vehículos</p>
    </div>

    <!-- Tarjetas de estadísticas -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8">
      <div
        v-for="stat in stats"
        :key="stat.label"
        class="bg-white rounded-xl p-5 shadow-sm border border-gray-100 hover:shadow-md transition-shadow"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-500 font-medium">{{ stat.label }}</p>
            <p class="text-2xl font-bold text-gray-900 mt-1">{{ stat.value }}</p>
            <p
              :class="[
                'text-xs mt-1 font-medium',
                stat.changePositive ? 'text-success-500' : 'text-danger-500',
              ]"
            >
              {{ stat.change }}
            </p>
          </div>
          <div :class="['w-12 h-12 rounded-xl flex items-center justify-center', stat.bgColor]">
            <span class="w-6 h-6" v-html="stat.icon" />
          </div>
        </div>
      </div>
    </div>

    <!-- Actividad reciente + Accesos rápidos -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
      <!-- Actividad Reciente -->
      <div class="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100">
        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
          <h3 class="font-semibold text-gray-900">Actividad Reciente</h3>
          <button class="text-sm text-primary-600 hover:text-primary-700 font-medium">
            Ver todo
          </button>
        </div>
        <div class="divide-y divide-gray-50">
          <div
            v-for="activity in recentActivity"
            :key="activity.id"
            class="px-6 py-4 flex items-center gap-4 hover:bg-gray-50 transition"
          >
            <div
              :class="[
                'w-10 h-10 rounded-full flex items-center justify-center shrink-0',
                activity.color,
              ]"
            >
              <span class="w-5 h-5" v-html="activity.icon" />
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900">{{ activity.title }}</p>
              <p class="text-xs text-gray-500">{{ activity.description }}</p>
            </div>
            <span class="text-xs text-gray-400 shrink-0">{{ activity.time }}</span>
          </div>
        </div>
      </div>

      <!-- Accesos Rápidos -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-100">
        <div class="px-6 py-4 border-b border-gray-100">
          <h3 class="font-semibold text-gray-900">Accesos Rápidos</h3>
        </div>
        <div class="p-4 space-y-2">
          <NuxtLink
            to="/admin/usuarios"
            class="flex items-center gap-3 p-3 rounded-lg hover:bg-primary-50 transition group"
          >
            <div
              class="w-10 h-10 bg-primary-100 text-primary-600 rounded-lg flex items-center justify-center group-hover:bg-primary-200 transition"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-900">Gestionar Usuarios</p>
              <p class="text-xs text-gray-500">Crear, editar y eliminar</p>
            </div>
          </NuxtLink>

          <NuxtLink
            to="/admin/roles"
            class="flex items-center gap-3 p-3 rounded-lg hover:bg-primary-50 transition group"
          >
            <div
              class="w-10 h-10 bg-warning-500/10 text-warning-600 rounded-lg flex items-center justify-center group-hover:bg-warning-500/20 transition"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-900">Roles y Permisos</p>
              <p class="text-xs text-gray-500">Configurar accesos</p>
            </div>
          </NuxtLink>

          <div
            class="flex items-center gap-3 p-3 rounded-lg hover:bg-primary-50 transition group cursor-pointer"
          >
            <div
              class="w-10 h-10 bg-success-500/10 text-success-600 rounded-lg flex items-center justify-center group-hover:bg-success-500/20 transition"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-900">Reportes</p>
              <p class="text-xs text-gray-500">Generar informes</p>
            </div>
          </div>

          <div
            class="flex items-center gap-3 p-3 rounded-lg hover:bg-primary-50 transition group cursor-pointer"
          >
            <div
              class="w-10 h-10 bg-danger-500/10 text-danger-600 rounded-lg flex items-center justify-center group-hover:bg-danger-500/20 transition"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                />
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
            </div>
            <div>
              <p class="text-sm font-medium text-gray-900">Configuración</p>
              <p class="text-xs text-gray-500">Ajustes del sistema</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estado de vehículos -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100">
      <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <h3 class="font-semibold text-gray-900">Estado de Vehículos</h3>
        <span class="text-sm text-gray-500">Últimas 24 horas</span>
      </div>
      <div class="p-6">
        <div class="grid grid-cols-2 sm:grid-cols-5 gap-4">
          <div
            v-for="status in vehicleStatuses"
            :key="status.label"
            class="text-center p-4 rounded-xl bg-gray-50"
          >
            <p class="text-2xl font-bold" :class="status.textColor">{{ status.count }}</p>
            <p class="text-xs text-gray-500 mt-1 font-medium">{{ status.label }}</p>
            <div class="mt-2 h-1.5 bg-gray-200 rounded-full overflow-hidden">
              <div
                :class="['h-full rounded-full', status.barColor]"
                :style="{ width: status.percent + '%' }"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

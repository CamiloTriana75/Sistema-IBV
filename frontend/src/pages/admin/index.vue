<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useStatsStore } from '~/stores/statsStore'
import { supabaseDataService } from '~/services/supabaseDataService'
import { supabaseUserService } from '~/services/supabaseUserService'
import type { VehicleData, DashboardStats, ActivityItem } from '~/services/supabaseDataService'
import type { SupabaseUser } from '~/services/supabaseUserService'

definePageMeta({ layout: 'admin', middleware: ['auth', 'admin'] })

const stats = useStatsStore()
const periodo = ref<'hoy' | 'semana' | 'mes'>('semana')

// States
const loading = ref(true)
const error = ref('')
const dashboardStats = ref<DashboardStats | null>(null)
const vehicles = ref<VehicleData[]>([])
const users = ref<SupabaseUser[]>([])
const activities = ref<ActivityItem[]>([])

// Computed stats for KPIs
const kpiData = computed(() => {
  if (!dashboardStats.value) return []
  
  const stats = dashboardStats.value
  return [
    {
      label: 'Vehículos Totales',
      value: stats.total_vehiculos,
      icon: 'truck',
      bg: 'bg-blue-50',
      color: 'text-blue-600',
      trend: '+12% esta semana',
      trendUp: true,
    },
    {
      label: 'Listos para Despacho',
      value: stats.listos_despacho,
      icon: 'check',
      bg: 'bg-green-50',
      color: 'text-green-600',
      trend: 'Aprobados',
      trendUp: true,
    },
    {
      label: 'Despachados',
      value: stats.despachados,
      icon: 'exit',
      bg: 'bg-purple-50',
      color: 'text-purple-600',
      trend: 'En tránsito',
      trendUp: true,
    },
    {
      label: 'Problemas Encontrados',
      value: stats.problemas_encontrados,
      icon: 'alert',
      bg: 'bg-red-50',
      color: 'text-red-600',
      trend: 'Requieren atención',
      trendUp: false,
    },
  ]
})

// Computed pipeline data
const pipelineData = computed(() => {
  if (!dashboardStats.value) return []
  
  const stats = dashboardStats.value
  const total = stats.total_vehiculos || 1
  
  return [
    {
      label: 'Recibidos',
      value: stats.total_vehiculos,
      pct: 100,
      color: 'bg-blue-500',
      light: 'bg-blue-50',
      text: 'text-blue-700',
    },
    {
      label: 'En Impronta',
      value: stats.en_impronta,
      pct: Math.round((stats.en_impronta / total) * 100),
      color: 'bg-amber-500',
      light: 'bg-amber-50',
      text: 'text-amber-700',
    },
    {
      label: 'En Inventario',
      value: stats.en_inventario,
      pct: Math.round((stats.en_inventario / total) * 100),
      color: 'bg-orange-500',
      light: 'bg-orange-50',
      text: 'text-orange-700',
    },
    {
      label: 'Despachados',
      value: stats.despachados,
      pct: Math.round((stats.despachados / total) * 100),
      color: 'bg-green-500',
      light: 'bg-green-50',
      text: 'text-green-700',
    },
  ]
})

// Load data
const loadDashboard = async () => {
  try {
    loading.value = true
    error.value = ''
    
    // Asegurar que los usuarios seed existan
    await supabaseUserService.seedAllUsers()
    
    const [statsData, vehiclesData, usersData, activitiesData] = await Promise.all([
      supabaseDataService.getDashboardStats(),
      supabaseDataService.getVehicles(),
      supabaseUserService.getAllUsers(),
      supabaseDataService.getActivities(5),
    ])
    
    dashboardStats.value = statsData
    vehicles.value = vehiclesData
    users.value = usersData
    activities.value = activitiesData || []
  } catch (e: any) {
    error.value = e.message || 'Error al cargar datos del dashboard'
    console.error('Error loading dashboard:', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboard()
})

const iconMap: Record<string, string> = {
  truck:
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z" /></svg>',
  check:
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
  exit: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>',
  alert:
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>',
}
</script>

<template>
  <div class="space-y-8">
    <!-- ── Header ── -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Dashboard Administrativo</h1>
        <p class="text-gray-500 mt-1">KPIs y métricas del sistema IBV en tiempo real</p>
      </div>
      <div class="flex items-center gap-3 self-start sm:self-auto">
        <NuxtLink
          to="/admin/estadisticas"
          class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-xl text-sm font-medium hover:bg-primary-700 transition shadow-sm"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
            />
          </svg>
          Estadísticas
        </NuxtLink>
        <div class="flex items-center gap-1 bg-gray-100 rounded-xl p-1">
          <button
            v-for="p in ['hoy', 'semana', 'mes'] as const"
            :key="p"
            :class="[
              'px-3 py-1.5 text-sm font-medium rounded-lg transition',
              periodo === p ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700',
            ]"
            @click="periodo = p"
          >
            {{ p === 'hoy' ? 'Hoy' : p === 'semana' ? 'Semana' : 'Mes' }}
          </button>
        </div>
      </div>
    </div>

    <!-- ── KPI Cards ── -->
    <div v-if="!loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
      <div
        v-for="kpi in kpiData"
        :key="kpi.label"
        class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 hover:shadow-md transition"
      >
        <div class="flex items-center justify-between mb-4">
          <div :class="['w-11 h-11 rounded-xl flex items-center justify-center', kpi.bg]">
            <!-- eslint-disable-next-line vue/no-v-html -->
            <span :class="['w-5 h-5', kpi.color]" v-html="iconMap[kpi.icon]" />
          </div>
          <span
            :class="[
              'text-xs font-medium px-2 py-1 rounded-full',
              kpi.trendUp ? 'bg-success-50 text-success-700' : 'bg-warning-50 text-warning-700',
            ]"
          >
            {{ kpi.trendUp ? '▲' : '▼' }}
          </span>
        </div>
        <p class="text-3xl font-bold text-gray-900">{{ kpi.value }}</p>
        <p class="text-sm font-medium text-gray-700 mt-0.5">{{ kpi.label }}</p>
        <p class="text-xs text-gray-400 mt-1">{{ kpi.trend }}</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
      <div v-for="i in 4" :key="i" class="bg-gray-200 rounded-2xl p-5 h-32 animate-pulse" />
    </div>

    <!-- Error Message -->
    <div v-if="error" class="bg-red-50 border border-red-200 rounded-xl p-4 text-red-700">
      {{ error }}
    </div>

    <!-- ── Pipeline Funnel + Donut ── -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Funnel (2/3) -->
      <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Pipeline de Vehículos</h3>
            <p class="text-xs text-gray-400 mt-0.5">
              Flujo completo desde recepción hasta despacho
            </p>
          </div>
        </div>
        <div class="space-y-3">
          <div v-for="stage in pipelineData" :key="stage.label">
            <div class="flex items-center justify-between mb-1.5">
              <div class="flex items-center gap-2">
                <span :class="['w-2 h-2 rounded-full', stage.color]" />
                <span class="text-sm font-medium text-gray-700">{{ stage.label }}</span>
              </div>
              <div class="flex items-center gap-3">
                <span
                  :class="[
                    'text-xs font-semibold px-2 py-0.5 rounded-full',
                    stage.light,
                    stage.text,
                  ]"
                >
                  {{ stage.value }}
                </span>
                <span class="text-xs text-gray-400 w-9 text-right">{{ stage.pct }}%</span>
              </div>
            </div>
            <div class="h-2.5 bg-gray-100 rounded-full overflow-hidden">
              <div
                :class="['h-full rounded-full transition-all duration-700', stage.color]"
                :style="{ width: `${stage.pct}%` }"
              />
            </div>
          </div>
        </div>
        <div class="flex items-center justify-center gap-1 mt-5 flex-wrap">
          <template v-for="(stage, i) in pipelineData" :key="stage.label">
            <span :class="['text-xs px-2 py-1 rounded-lg font-medium', stage.light, stage.text]">
              {{ stage.label }} ({{ stage.value }})
            </span>
            <span v-if="i < pipelineData.length - 1" class="text-gray-300 text-sm">›</span>
          </template>
        </div>
      </div>

      <!-- Donut (1/3) -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex flex-col">
        <div class="mb-4">
          <h3 class="text-base font-semibold text-gray-900">Distribución</h3>
          <p class="text-xs text-gray-400 mt-0.5">Por etapa del ciclo</p>
        </div>
        <div class="flex-1 flex items-center justify-center">
          <ChartsDonutChart :segments="stats.donutSegments" :size="190" :thickness="36" />
        </div>
      </div>
    </div>

    <!-- ── Tendencia Semanal + Eficiencia ── -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Gráfico de barras -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <div class="mb-6">
          <h3 class="text-base font-semibold text-gray-900">Tendencia Semanal</h3>
          <p class="text-xs text-gray-400 mt-0.5">Vehículos recibidos vs. despachados</p>
        </div>
        <ChartsBarChart :bars="stats.weekDays" :series="stats.weekSeries" :height="160" />
      </div>

      <!-- Eficiencia por módulo -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <div class="mb-6">
          <h3 class="text-base font-semibold text-gray-900">Eficiencia por Módulo</h3>
          <p class="text-xs text-gray-400 mt-0.5">Porcentaje de completado sobre el total</p>
        </div>
        <div class="space-y-5">
          <div v-for="mod in stats.moduleEfficiency" :key="mod.label">
            <div class="flex items-center justify-between mb-2">
              <div>
                <span class="text-sm font-medium text-gray-800">{{ mod.label }}</span>
                <span class="text-xs text-gray-400 ml-2">{{ mod.sublabel }}</span>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-sm font-semibold text-gray-700">{{ mod.value }}</span>
                <span
                  :class="[
                    'text-xs font-bold px-1.5 py-0.5 rounded',
                    mod.pct >= 75
                      ? 'bg-success-50 text-success-700'
                      : mod.pct >= 40
                        ? 'bg-warning-50 text-warning-700'
                        : 'bg-danger-50 text-danger-700',
                  ]"
                >
                  {{ mod.pct }}%
                </span>
              </div>
            </div>
            <div class="h-2 bg-gray-100 rounded-full overflow-hidden">
              <div
                :class="['h-full rounded-full transition-all duration-700', mod.color]"
                :style="{ width: `${mod.pct}%` }"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Actividad + Quick Links ── -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Actividad reciente -->
      <div class="lg:col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <div class="flex items-center justify-between mb-5">
          <h3 class="text-base font-semibold text-gray-900">Actividad Reciente</h3>
          <span class="text-xs text-gray-400 bg-gray-50 px-2 py-1 rounded-lg">Últimas actividades</span>
        </div>
        <div v-if="activities.length > 0" class="space-y-4">
          <div v-for="(act, i) in activities" :key="i" class="flex items-start gap-3">
            <div
              class="w-8 h-8 rounded-full flex items-center justify-center shrink-0 text-xs font-bold text-white bg-primary-500"
            >
              {{ act.user?.nombres?.[0] || 'U' }}{{ act.user?.apellidos?.[0] || '' }}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm text-gray-800">
                <span class="font-medium">{{ act.user?.nombres || 'Sistema' }} {{ act.user?.apellidos || '' }}</span>
                {{ act.description }}
              </p>
              <p class="text-xs text-gray-400 mt-0.5">{{ new Date(act.timestamp).toLocaleString('es') }}</p>
            </div>
            <span
              :class="[
                'text-xs px-2 py-1 rounded-full font-medium shrink-0',
                act.role === 'admin'
                  ? 'bg-primary-50 text-primary-600'
                  : act.role === 'recibidor'
                    ? 'bg-blue-50 text-blue-600'
                    : act.role === 'inventario'
                      ? 'bg-amber-50 text-amber-600'
                      : 'bg-green-50 text-green-600',
              ]"
            >
              {{ act.role || 'Actividad' }}
            </span>
          </div>
        </div>
        <div v-else class="text-center py-8 text-gray-400">
          No hay actividad reciente
        </div>
      </div>

      <!-- Accesos rápidos -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <h3 class="text-base font-semibold text-gray-900 mb-5">Acceso Rápido</h3>
        <div class="space-y-2">
          <NuxtLink
            v-for="link in [
              {
                to: '/admin/usuarios',
                label: 'Usuarios',
                desc: 'Crear y gestionar',
                bg: 'bg-primary-50',
                ic: 'text-primary-600',
              },
              {
                to: '/admin/roles',
                label: 'Roles',
                desc: 'Configurar permisos',
                bg: 'bg-purple-50',
                ic: 'text-purple-600',
              },
              {
                to: '/recibidor',
                label: 'Recepción',
                desc: 'Ver panel',
                bg: 'bg-blue-50',
                ic: 'text-blue-600',
              },
              {
                to: '/inventario',
                label: 'Inventario',
                desc: 'Inspecciones',
                bg: 'bg-amber-50',
                ic: 'text-amber-600',
              },
              {
                to: '/despachador',
                label: 'Despacho',
                desc: 'Ver lotes',
                bg: 'bg-success-50',
                ic: 'text-success-600',
              },
            ]"
            :key="link.to"
            :to="link.to"
            class="flex items-center gap-3 p-2.5 rounded-xl hover:bg-gray-50 transition group"
          >
            <div :class="['w-8 h-8 rounded-lg shrink-0 flex items-center justify-center', link.bg]">
              <svg
                :class="['w-4 h-4', link.ic]"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-800 group-hover:text-primary-600 transition">
                {{ link.label }}
              </p>
              <p class="text-xs text-gray-400">{{ link.desc }}</p>
            </div>
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

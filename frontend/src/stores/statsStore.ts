import { defineStore } from 'pinia'
import { computed } from 'vue'
import { useVehiculoStore } from '~/stores/vehiculoStore'

export const useStatsStore = defineStore('stats', () => {
  const vehiculoStore = useVehiculoStore()

  // ──────────────────────────────────────────────
  // KPIs principales
  // ──────────────────────────────────────────────
  const kpiPrincipal = computed(() => [
    {
      label: 'Total en Patio',
      value: vehiculoStore.total,
      sublabel: 'Vehículos registrados',
      color: 'text-primary-600',
      bg: 'bg-primary-50',
      icon: 'truck',
      trend: '+12 esta semana',
      trendUp: true,
    },
    {
      label: 'Listos Despacho',
      value: vehiculoStore.listosDespacho,
      sublabel: 'Aprobados y en espera',
      color: 'text-success-600',
      bg: 'bg-success-50',
      icon: 'check',
      trend: `${vehiculoStore.total > 0 ? Math.round((vehiculoStore.listosDespacho / vehiculoStore.total) * 100) : 0}% del total`,
      trendUp: vehiculoStore.listosDespacho > 0,
    },
    {
      label: 'Despachados',
      value: vehiculoStore.despachados,
      sublabel: 'Salidas procesadas',
      color: 'text-gray-600',
      bg: 'bg-gray-50',
      icon: 'exit',
      trend: `${vehiculoStore.total > 0 ? Math.round((vehiculoStore.despachados / vehiculoStore.total) * 100) : 0}% del total`,
      trendUp: true,
    },
    {
      label: 'Pendientes',
      value: vehiculoStore.pendientesImpronta + vehiculoStore.pendientesInventario,
      sublabel: 'Requieren atención',
      color: 'text-warning-600',
      bg: 'bg-warning-50',
      icon: 'alert',
      trend: `${vehiculoStore.pendientesImpronta} impronta · ${vehiculoStore.pendientesInventario} inventario`,
      trendUp: false,
    },
  ])

  // ──────────────────────────────────────────────
  // Pipeline funnel
  // ──────────────────────────────────────────────
  const pipelineFunnel = computed(() => {
    const total = vehiculoStore.total || 1
    return [
      {
        label: 'Recibidos',
        value: vehiculoStore.recibidos,
        pct: Math.round((vehiculoStore.recibidos / total) * 100),
        color: 'bg-primary-400',
        light: 'bg-primary-50',
        text: 'text-primary-700',
      },
      {
        label: 'Con Impronta',
        value: vehiculoStore.conImpronta,
        pct: Math.round((vehiculoStore.conImpronta / total) * 100),
        color: 'bg-blue-400',
        light: 'bg-blue-50',
        text: 'text-blue-700',
      },
      {
        label: 'Con Inventario',
        value: vehiculoStore.conInventario,
        pct: Math.round((vehiculoStore.conInventario / total) * 100),
        color: 'bg-amber-400',
        light: 'bg-amber-50',
        text: 'text-amber-700',
      },
      {
        label: 'Listos Despacho',
        value: vehiculoStore.listosDespacho,
        pct: Math.round((vehiculoStore.listosDespacho / total) * 100),
        color: 'bg-success-400',
        light: 'bg-success-50',
        text: 'text-success-700',
      },
      {
        label: 'Despachados',
        value: vehiculoStore.despachados,
        pct: Math.round((vehiculoStore.despachados / total) * 100),
        color: 'bg-gray-400',
        light: 'bg-gray-50',
        text: 'text-gray-700',
      },
    ]
  })

  // ──────────────────────────────────────────────
  // Distribución por estado (donut)
  // ──────────────────────────────────────────────
  const donutSegments = computed(() => [
    {
      label: 'Recibidos',
      value: vehiculoStore.recibidos,
      color: '#38bdf8',
    },
    {
      label: 'Impronta',
      value: vehiculoStore.conImpronta,
      color: '#60a5fa',
    },
    {
      label: 'Inventario',
      value: vehiculoStore.conInventario,
      color: '#fbbf24',
    },
    {
      label: 'Listos',
      value: vehiculoStore.listosDespacho,
      color: '#34d399',
    },
    {
      label: 'Despachados',
      value: vehiculoStore.despachados,
      color: '#9ca3af',
    },
  ])

  // ──────────────────────────────────────────────
  // Tendencia semanal (mock últimos 7 días)
  // ──────────────────────────────────────────────
  const weekDays = computed(() => {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
    const today = new Date().getDay()
    // Rotar para que HOY sea el último
    const rotated = [...days.slice(today), ...days.slice(0, today)]
    return rotated.map((label, i) => ({
      label,
      values: [
        // Recibidos (mock creciente)
        Math.floor(3 + Math.random() * 12 + i * 0.5),
        // Despachados (mock algo menor)
        Math.floor(2 + Math.random() * 8 + i * 0.3),
      ],
    }))
  })

  const weekSeries = [
    { label: 'Recibidos', color: '#38bdf8' },
    { label: 'Despachados', color: '#34d399' },
  ]

  // ──────────────────────────────────────────────
  // Eficiencia por módulo
  // ──────────────────────────────────────────────
  const moduleEfficiency = computed(() => {
    const total = vehiculoStore.total || 1
    return [
      {
        label: 'Recepción',
        sublabel: 'VINs escaneados',
        pct: Math.min(
          100,
          Math.round((vehiculoStore.total / Math.max(vehiculoStore.total, 1)) * 100)
        ),
        color: 'bg-primary-500',
        value: vehiculoStore.total,
      },
      {
        label: 'Impronta',
        sublabel: 'Completadas',
        pct: Math.round((vehiculoStore.conImpronta / total) * 100),
        color: 'bg-blue-500',
        value: vehiculoStore.conImpronta,
      },
      {
        label: 'Inventario',
        sublabel: 'Aprobados',
        pct: Math.round((vehiculoStore.conInventario / total) * 100),
        color: 'bg-amber-500',
        value: vehiculoStore.conInventario,
      },
      {
        label: 'Despacho',
        sublabel: 'Despachados',
        pct: Math.round((vehiculoStore.despachados / total) * 100),
        color: 'bg-success-500',
        value: vehiculoStore.despachados,
      },
    ]
  })

  // ──────────────────────────────────────────────
  // Distribución por marca
  // ──────────────────────────────────────────────
  const vehiculosPorMarca = computed(() => {
    const freq = new Map<string, number>()
    vehiculoStore.vehiculos.forEach((v) => freq.set(v.marca, (freq.get(v.marca) || 0) + 1))
    return [...freq.entries()]
      .map(([marca, n]) => ({ label: marca, value: n }))
      .sort((a, b) => b.value - a.value)
  })

  // ──────────────────────────────────────────────
  // Distribución por cliente
  // ──────────────────────────────────────────────
  const vehiculosPorCliente = computed(() => {
    const freq = new Map<string, number>()
    vehiculoStore.vehiculos.forEach((v) => {
      if (v.cliente) freq.set(v.cliente, (freq.get(v.cliente) || 0) + 1)
    })
    return [...freq.entries()]
      .map(([c, n]) => ({ label: c, value: n }))
      .sort((a, b) => b.value - a.value)
  })

  // ──────────────────────────────────────────────
  // Tiempo promedio en patio (días)
  // ──────────────────────────────────────────────
  const tiempoPromedioEnPatio = computed(() => {
    const enPatio = vehiculoStore.vehiculos.filter((v) => !v.despachado)
    if (enPatio.length === 0) return 0
    const now = new Date()
    const totalDias = enPatio.reduce((sum, v) => {
      const d = new Date(v.fechaRecepcion)
      return sum + Math.max(0, (now.getTime() - d.getTime()) / 86400000)
    }, 0)
    return Math.round((totalDias / enPatio.length) * 10) / 10
  })

  // ──────────────────────────────────────────────
  // Tasa de despacho
  // ──────────────────────────────────────────────
  const tasaDespacho = computed(() => {
    if (vehiculoStore.total === 0) return 0
    return Math.round((vehiculoStore.despachados / vehiculoStore.total) * 100)
  })

  // ──────────────────────────────────────────────
  // Tendencia diaria (últimos 14 días)
  // ──────────────────────────────────────────────
  const dailyTrend = computed(() => {
    const result = []
    const baseRec = Math.max(2, Math.floor(vehiculoStore.total / 5))
    const baseDesp = Math.max(1, Math.floor(vehiculoStore.despachados / 3))
    for (let i = 13; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      const seed = Math.sin(i * 12.9898 + 78.233) * 43758.5453
      const r1 = seed - Math.floor(seed)
      const seed2 = Math.sin((i + 5) * 12.9898 + 78.233) * 43758.5453
      const r2 = seed2 - Math.floor(seed2)
      result.push({
        label: date.toLocaleDateString('es-VE', { day: '2-digit', month: 'short' }),
        values: [
          Math.max(0, Math.floor(baseRec + Math.sin(i * 0.8) * 3 + r1 * 2)),
          Math.max(0, Math.floor(baseDesp + Math.cos(i * 0.6) * 2 + r2 * 1.5)),
        ],
      })
    }
    return result
  })

  const dailySeries = [
    { label: 'Recibidos', color: '#0ea5e9' },
    { label: 'Despachados', color: '#10b981' },
  ]

  // ──────────────────────────────────────────────
  // Donut por marca
  // ──────────────────────────────────────────────
  const marcaDonutSegments = computed(() => {
    const colors = ['#0ea5e9', '#f59e0b', '#10b981', '#8b5cf6', '#ef4444', '#ec4899', '#06b6d4']
    return vehiculosPorMarca.value.map((m, i) => ({
      label: m.label,
      value: m.value,
      color: colors[i % colors.length],
    }))
  })

  return {
    kpiPrincipal,
    pipelineFunnel,
    donutSegments,
    weekDays,
    weekSeries,
    moduleEfficiency,
    vehiculosPorMarca,
    vehiculosPorCliente,
    tiempoPromedioEnPatio,
    tasaDespacho,
    dailyTrend,
    dailySeries,
    marcaDonutSegments,
  }
})

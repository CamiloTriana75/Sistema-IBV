import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface DañoZona {
  zona: string
  tipo: string
  severidad: 'Baja' | 'Media' | 'Alta'
}

export interface Impronta {
  id: string
  folio: string
  // Datos del vehículo
  vin: string
  placa: string
  marca: string
  modelo: string
  anio: string
  color: string
  km: string
  cliente: string
  condicion: 'excelente' | 'bueno' | 'regular' | 'dañado' | ''
  // Daños
  zonasDañadas: string[]
  daños: DañoZona[]
  observaciones: string
  // Fotos (base64 o placeholder URLs)
  fotos: Record<string, string>
  fotosAdicionales: string[]
  // Metadata
  estado: 'borrador' | 'completada' | 'revisada'
  creadoPor: string
  fechaCreacion: string
  horaCreacion: string
  fechaActualizacion: string
}

const STORAGE_KEY = 'ibv_improntas'
const FOLIO_KEY = 'ibv_impronta_folio_seq'

function getNextFolio(): string {
  if (typeof window === 'undefined') return 'IMP-0001'
  const seq = parseInt(localStorage.getItem(FOLIO_KEY) || '0') + 1
  localStorage.setItem(FOLIO_KEY, String(seq))
  return `IMP-${String(seq).padStart(4, '0')}`
}

const INITIAL_IMPRONTAS: Impronta[] = [
  {
    id: '1',
    folio: 'IMP-0001',
    vin: '1HGBH41JXMN109186',
    placa: 'ABC-1234',
    marca: 'Toyota',
    modelo: 'Corolla',
    anio: '2024',
    color: 'Blanco Perla',
    km: '12',
    cliente: 'Distribuidora Caracas',
    condicion: 'bueno',
    zonasDañadas: ['frontal'],
    daños: [{ zona: 'Parte Frontal', tipo: 'Rayón superficial', severidad: 'Baja' }],
    observaciones: 'Rayón leve en parachoques frontal, pintura intacta.',
    fotos: {
      frontal: 'https://placehold.co/400x300/dbeafe/3b82f6?text=Frontal',
      trasera: 'https://placehold.co/400x300/dbeafe/3b82f6?text=Trasera',
      lateral_izq: 'https://placehold.co/400x300/dbeafe/3b82f6?text=Lat+Izq',
      lateral_der: 'https://placehold.co/400x300/dbeafe/3b82f6?text=Lat+Der',
      tablero: 'https://placehold.co/400x300/dbeafe/3b82f6?text=Tablero',
      odometro: 'https://placehold.co/400x300/dbeafe/3b82f6?text=Odometro',
    },
    fotosAdicionales: [],
    estado: 'completada',
    creadoPor: 'María Recibidora',
    fechaCreacion: '2026-02-22',
    horaCreacion: '09:30',
    fechaActualizacion: '2026-02-22',
  },
  {
    id: '2',
    folio: 'IMP-0002',
    vin: '3VWDX7AJ5BM123456',
    placa: 'XYZ-5678',
    marca: 'Chevrolet',
    modelo: 'Spark',
    anio: '2023',
    color: 'Rojo',
    km: '8543',
    cliente: 'AutoVentas Norte',
    condicion: 'regular',
    zonasDañadas: ['lateral_der', 'trasero'],
    daños: [
      { zona: 'Lateral Derecho', tipo: 'Abolladura', severidad: 'Media' },
      { zona: 'Parte Trasera', tipo: 'Rayón profundo', severidad: 'Alta' },
    ],
    observaciones: 'Abolladura en puerta trasera derecha y rayón profundo en bumper trasero.',
    fotos: {
      frontal: 'https://placehold.co/400x300/fef3c7/d97706?text=Frontal',
      trasera: 'https://placehold.co/400x300/fef3c7/d97706?text=Trasera',
      lateral_der: 'https://placehold.co/400x300/fef3c7/d97706?text=Lat+Der',
    },
    fotosAdicionales: ['https://placehold.co/200x150/fee2e2/dc2626?text=Daño+1'],
    estado: 'completada',
    creadoPor: 'María Recibidora',
    fechaCreacion: '2026-02-22',
    horaCreacion: '14:15',
    fechaActualizacion: '2026-02-22',
  },
  {
    id: '3',
    folio: 'IMP-0003',
    vin: 'WVWZZZ3CZWE123789',
    placa: 'DEF-9012',
    marca: 'Nissan',
    modelo: 'Versa',
    anio: '2025',
    color: 'Plata',
    km: '0',
    cliente: 'Distribuidora Valencia',
    condicion: 'excelente',
    zonasDañadas: [],
    daños: [],
    observaciones: '',
    fotos: {
      frontal: 'https://placehold.co/400x300/dcfce7/16a34a?text=Frontal',
      trasera: 'https://placehold.co/400x300/dcfce7/16a34a?text=Trasera',
    },
    fotosAdicionales: [],
    estado: 'borrador',
    creadoPor: 'María Recibidora',
    fechaCreacion: '2026-02-23',
    horaCreacion: '08:00',
    fechaActualizacion: '2026-02-23',
  },
  {
    id: '4',
    folio: 'IMP-0004',
    vin: 'KNDJP3A53H7654321',
    placa: 'GHI-3456',
    marca: 'Kia',
    modelo: 'Rio',
    anio: '2024',
    color: 'Negro',
    km: '340',
    cliente: 'Importadora Maracaibo',
    condicion: 'bueno',
    zonasDañadas: ['techo'],
    daños: [{ zona: 'Techo', tipo: 'Mancha de pintura', severidad: 'Baja' }],
    observaciones: 'Pequeña mancha de pintura industrial en el techo.',
    fotos: {
      frontal: 'https://placehold.co/400x300/e0e7ff/4f46e5?text=Frontal',
      trasera: 'https://placehold.co/400x300/e0e7ff/4f46e5?text=Trasera',
      lateral_izq: 'https://placehold.co/400x300/e0e7ff/4f46e5?text=Lat+Izq',
      lateral_der: 'https://placehold.co/400x300/e0e7ff/4f46e5?text=Lat+Der',
      tablero: 'https://placehold.co/400x300/e0e7ff/4f46e5?text=Tablero',
      odometro: 'https://placehold.co/400x300/e0e7ff/4f46e5?text=Odometro',
    },
    fotosAdicionales: [],
    estado: 'revisada',
    creadoPor: 'María Recibidora',
    fechaCreacion: '2026-02-21',
    horaCreacion: '16:45',
    fechaActualizacion: '2026-02-22',
  },
  {
    id: '5',
    folio: 'IMP-0005',
    vin: 'KMHDN46D09U987654',
    placa: 'JKL-7890',
    marca: 'Hyundai',
    modelo: 'Accent',
    anio: '2023',
    color: 'Azul',
    km: '15200',
    cliente: 'AutoCenter Barquisimeto',
    condicion: 'dañado',
    zonasDañadas: ['frontal', 'lateral_izq', 'lateral_der'],
    daños: [
      { zona: 'Parte Frontal', tipo: 'Parachoques roto', severidad: 'Alta' },
      { zona: 'Lateral Izquierdo', tipo: 'Rayones múltiples', severidad: 'Media' },
      { zona: 'Lateral Derecho', tipo: 'Abolladura menor', severidad: 'Baja' },
    ],
    observaciones: 'Vehículo con daños evidentes de transporte. Parachoques frontal fracturado.',
    fotos: {
      frontal: 'https://placehold.co/400x300/fee2e2/dc2626?text=Frontal',
      trasera: 'https://placehold.co/400x300/fee2e2/dc2626?text=Trasera',
      lateral_izq: 'https://placehold.co/400x300/fee2e2/dc2626?text=Lat+Izq',
      lateral_der: 'https://placehold.co/400x300/fee2e2/dc2626?text=Lat+Der',
    },
    fotosAdicionales: [
      'https://placehold.co/200x150/fee2e2/dc2626?text=Daño+F',
      'https://placehold.co/200x150/fee2e2/dc2626?text=Daño+LI',
    ],
    estado: 'completada',
    creadoPor: 'María Recibidora',
    fechaCreacion: '2026-02-23',
    horaCreacion: '10:20',
    fechaActualizacion: '2026-02-23',
  },
]

function loadImprontas(): Impronta[] {
  if (typeof window === 'undefined') return INITIAL_IMPRONTAS
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored) {
    try { return JSON.parse(stored) } catch { /* fallback */ }
  }
  // Inicializar folio sequence
  localStorage.setItem(FOLIO_KEY, '5')
  localStorage.setItem(STORAGE_KEY, JSON.stringify(INITIAL_IMPRONTAS))
  return [...INITIAL_IMPRONTAS]
}

function persistImprontas(list: Impronta[]) {
  if (typeof window !== 'undefined') {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(list))
  }
}

export const useImprontaStore = defineStore('impronta', () => {
  const improntas = ref<Impronta[]>(loadImprontas())
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Computados
  const totalImprontas = computed(() => improntas.value.length)
  const completadas = computed(() => improntas.value.filter(i => i.estado === 'completada').length)
  const borradores = computed(() => improntas.value.filter(i => i.estado === 'borrador').length)
  const revisadas = computed(() => improntas.value.filter(i => i.estado === 'revisada').length)
  const hoy = computed(() => {
    const today = new Date().toISOString().split('T')[0]
    return improntas.value.filter(i => i.fechaCreacion === today).length
  })

  const getById = (id: string): Impronta | undefined => {
    return improntas.value.find(i => i.id === id)
  }

  const getByFolio = (folio: string): Impronta | undefined => {
    return improntas.value.find(i => i.folio === folio)
  }

  const crear = async (data: Omit<Impronta, 'id' | 'folio' | 'fechaCreacion' | 'horaCreacion' | 'fechaActualizacion'>): Promise<Impronta> => {
    loading.value = true
    error.value = null
    try {
      await new Promise(r => setTimeout(r, 400))
      const now = new Date()
      const nueva: Impronta = {
        ...data,
        id: String(Date.now()),
        folio: getNextFolio(),
        fechaCreacion: now.toISOString().split('T')[0],
        horaCreacion: now.toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit' }),
        fechaActualizacion: now.toISOString().split('T')[0],
      }
      improntas.value.unshift(nueva)
      persistImprontas(improntas.value)
      return nueva
    } catch (err: any) {
      error.value = err.message || 'Error al crear impronta'
      throw err
    } finally {
      loading.value = false
    }
  }

  const actualizar = async (id: string, data: Partial<Impronta>): Promise<Impronta> => {
    loading.value = true
    error.value = null
    try {
      await new Promise(r => setTimeout(r, 300))
      const idx = improntas.value.findIndex(i => i.id === id)
      if (idx === -1) throw new Error('Impronta no encontrada')
      improntas.value[idx] = {
        ...improntas.value[idx],
        ...data,
        fechaActualizacion: new Date().toISOString().split('T')[0]
      }
      persistImprontas(improntas.value)
      return improntas.value[idx]
    } catch (err: any) {
      error.value = err.message || 'Error al actualizar'
      throw err
    } finally {
      loading.value = false
    }
  }

  const eliminar = async (id: string) => {
    loading.value = true
    try {
      await new Promise(r => setTimeout(r, 300))
      improntas.value = improntas.value.filter(i => i.id !== id)
      persistImprontas(improntas.value)
    } catch (err: any) {
      error.value = err.message || 'Error al eliminar'
      throw err
    } finally {
      loading.value = false
    }
  }

  const cambiarEstado = async (id: string, nuevoEstado: Impronta['estado']) => {
    return actualizar(id, { estado: nuevoEstado })
  }

  return {
    improntas,
    loading,
    error,
    totalImprontas,
    completadas,
    borradores,
    revisadas,
    hoy,
    getById,
    getByFolio,
    crear,
    actualizar,
    eliminar,
    cambiarEstado,
  }
})

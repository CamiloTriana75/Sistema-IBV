<template>
  <div class="min-h-screen bg-white">
    <!-- Controles de pantalla (no se imprimen) -->
    <div class="print:hidden flex items-center justify-between px-8 py-4 bg-gray-50 border-b border-gray-200 sticky top-0 z-10">
      <div class="flex items-center gap-3">
        <NuxtLink to="/recibidor/impronta"
          class="inline-flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900 transition">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Volver al formulario
        </NuxtLink>
      </div>
      <button @click="imprimir"
        class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
        </svg>
        Imprimir / Exportar PDF
      </button>
    </div>

    <!-- Documento imprimible -->
    <div class="max-w-[850px] mx-auto px-8 py-10 print:px-6 print:py-6">

      <!-- Encabezado de la empresa -->
      <div class="flex items-start justify-between border-b-2 border-gray-900 pb-6 mb-6">
        <div>
          <div class="flex items-center gap-3 mb-2">
            <div class="w-12 h-12 bg-primary-600 rounded-xl flex items-center justify-center">
              <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
              </svg>
            </div>
            <div>
              <h1 class="text-xl font-black text-gray-900">SISTEMA IBV</h1>
              <p class="text-xs text-gray-500">Inspección, Bodega y Verificación de Vehículos</p>
            </div>
          </div>
        </div>
        <div class="text-right">
          <div class="inline-block border-2 border-gray-900 px-4 py-2 rounded-xl">
            <p class="text-xs font-bold text-gray-500 uppercase tracking-wider">Folio N°</p>
            <p class="text-2xl font-black text-gray-900">IMP-0042</p>
          </div>
        </div>
      </div>

      <!-- Título del documento -->
      <div class="text-center mb-6">
        <h2 class="text-2xl font-black text-gray-900 uppercase tracking-widest">Acta de Impronta Vehicular</h2>
        <p class="text-sm text-gray-500 mt-1">Documento de registro de condición al ingreso</p>
      </div>

      <!-- Metadatos del registro -->
      <div class="grid grid-cols-3 gap-4 mb-6 bg-gray-50 rounded-xl p-4 border border-gray-200">
        <div>
          <p class="text-xs text-gray-500 font-semibold uppercase">Fecha de Ingreso</p>
          <p class="text-sm font-bold text-gray-900">{{ fechaHoy }}</p>
        </div>
        <div>
          <p class="text-xs text-gray-500 font-semibold uppercase">Hora</p>
          <p class="text-sm font-bold text-gray-900">{{ horaActual }}</p>
        </div>
        <div>
          <p class="text-xs text-gray-500 font-semibold uppercase">Recibido por</p>
          <p class="text-sm font-bold text-gray-900">Carlos Mendoza</p>
        </div>
      </div>

      <!-- Datos del vehículo -->
      <div class="mb-6">
        <h3 class="text-sm font-black text-gray-900 uppercase tracking-wider border-b border-gray-300 pb-2 mb-4">
          I. Datos del Vehículo
        </h3>
        <div class="grid grid-cols-2 gap-x-8 gap-y-3">
          <div v-for="campo in camposVehiculo" :key="campo.key" class="flex items-baseline gap-2">
            <span class="text-xs font-semibold text-gray-500 uppercase whitespace-nowrap w-24 shrink-0">{{ campo.label }}:</span>
            <div class="flex-1 border-b border-dotted border-gray-300 pb-0.5">
              <span class="text-sm text-gray-900 font-medium">{{ campo.valor || '—' }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Condición general -->
      <div class="mb-6">
        <h3 class="text-sm font-black text-gray-900 uppercase tracking-wider border-b border-gray-300 pb-2 mb-4">
          II. Condición General
        </h3>
        <div class="flex gap-6">
          <label v-for="opcion in condicionesOpciones" :key="opcion.value"
            class="flex items-center gap-2 cursor-pointer">
            <div class="w-4 h-4 border-2 border-gray-400 rounded flex items-center justify-center"
              :class="condicionSeleccionada === opcion.value ? 'bg-gray-900 border-gray-900' : ''">
              <svg v-if="condicionSeleccionada === opcion.value" class="w-2.5 h-2.5 text-white" fill="currentColor" viewBox="0 0 24 24">
                <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
              </svg>
            </div>
            <span class="text-sm font-medium text-gray-700">{{ opcion.label }}</span>
          </label>
        </div>
      </div>

      <!-- Mapa de daños (estático para impresión) -->
      <div class="mb-6">
        <h3 class="text-sm font-black text-gray-900 uppercase tracking-wider border-b border-gray-300 pb-2 mb-4">
          III. Diagrama de Daños
        </h3>
        <div class="flex gap-8 items-start">
          <!-- Diagrama SVG para impresión -->
          <div class="shrink-0">
            <svg viewBox="0 0 320 500" width="160" xmlns="http://www.w3.org/2000/svg">
              <rect x="60" y="140" width="200" height="220" rx="20" fill="#f1f5f9" stroke="#475569" stroke-width="2"/>
              <rect x="90" y="155" width="140" height="120" rx="10" fill="#e2e8f0" stroke="#475569" stroke-width="1.5"/>
              <rect x="80" y="60" width="160" height="85" rx="15" fill="#f1f5f9" stroke="#475569" stroke-width="2"/>
              <rect x="80" y="355" width="160" height="85" rx="15" fill="#f1f5f9" stroke="#475569" stroke-width="2"/>
              <circle cx="80" cy="170" r="28" fill="#334155" stroke="#1e293b" stroke-width="2"/>
              <circle cx="80" cy="170" r="14" fill="#64748b"/>
              <circle cx="240" cy="170" r="28" fill="#334155" stroke="#1e293b" stroke-width="2"/>
              <circle cx="240" cy="170" r="14" fill="#64748b"/>
              <circle cx="80" cy="330" r="28" fill="#334155" stroke="#1e293b" stroke-width="2"/>
              <circle cx="80" cy="330" r="14" fill="#64748b"/>
              <circle cx="240" cy="330" r="28" fill="#334155" stroke="#1e293b" stroke-width="2"/>
              <circle cx="240" cy="330" r="14" fill="#64748b"/>
              <text x="160" y="108" text-anchor="middle" fill="#475569" font-size="11" font-weight="600">FRONTAL</text>
              <text x="160" y="400" text-anchor="middle" fill="#475569" font-size="11" font-weight="600">TRASERO</text>
              <text x="160" y="218" text-anchor="middle" fill="#475569" font-size="11" font-weight="600">TECHO</text>
              <text x="42" y="252" text-anchor="middle" fill="#475569" font-size="10" font-weight="600" transform="rotate(-90 42 252)">LAT. IZQ</text>
              <text x="278" y="252" text-anchor="middle" fill="#475569" font-size="10" font-weight="600" transform="rotate(90 278 252)">LAT. DER</text>
              <!-- Marcadores de zona dañada (simulados) -->
              <circle cx="160" cy="95" r="12" fill="#ef4444"/>
              <text x="160" y="100" text-anchor="middle" fill="white" font-size="14" font-weight="bold">!</text>
            </svg>
          </div>
          <!-- Tabla de daños -->
          <div class="flex-1">
            <table class="w-full text-sm border-collapse">
              <thead>
                <tr class="bg-gray-100">
                  <th class="text-left py-2 px-3 text-xs font-bold text-gray-600 border border-gray-200">Zona</th>
                  <th class="text-left py-2 px-3 text-xs font-bold text-gray-600 border border-gray-200">Tipo de daño</th>
                  <th class="text-left py-2 px-3 text-xs font-bold text-gray-600 border border-gray-200">Severidad</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(daño, i) in dañosListados" :key="i" :class="i % 2 === 0 ? 'bg-white' : 'bg-gray-50'">
                  <td class="py-2 px-3 border border-gray-200 font-medium">{{ daño.zona }}</td>
                  <td class="py-2 px-3 border border-gray-200 text-gray-600">{{ daño.tipo }}</td>
                  <td class="py-2 px-3 border border-gray-200">
                    <span :class="{
                      'text-danger-600 font-semibold': daño.severidad === 'Alta',
                      'text-warning-600 font-semibold': daño.severidad === 'Media',
                      'text-gray-500': daño.severidad === 'Baja'
                    }">{{ daño.severidad }}</span>
                  </td>
                </tr>
                <tr v-if="dañosListados.length === 0">
                  <td colspan="3" class="py-3 px-3 text-center text-gray-400 border border-gray-200">Sin daños registrados</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Observaciones -->
      <div class="mb-6">
        <h3 class="text-sm font-black text-gray-900 uppercase tracking-wider border-b border-gray-300 pb-2 mb-3">
          IV. Observaciones Generales
        </h3>
        <div class="min-h-[80px] border border-gray-300 rounded-xl p-3">
          <p class="text-sm text-gray-700">{{ observaciones || 'Sin observaciones adicionales.' }}</p>
        </div>
      </div>

      <!-- Fotografías -->
      <div class="mb-8">
        <h3 class="text-sm font-black text-gray-900 uppercase tracking-wider border-b border-gray-300 pb-2 mb-4">
          V. Registro Fotográfico
        </h3>
        <div class="grid grid-cols-3 gap-3">
          <div v-for="foto in fotosImprimibles" :key="foto.label" class="border border-gray-200 rounded-xl overflow-hidden">
            <img :src="foto.url" :alt="foto.label" class="w-full h-28 object-cover bg-gray-100" />
            <p class="text-xs text-center text-gray-500 font-semibold py-1.5 border-t border-gray-200">{{ foto.label }}</p>
          </div>
        </div>
      </div>

      <!-- Firmas -->
      <div>
        <h3 class="text-sm font-black text-gray-900 uppercase tracking-wider border-b border-gray-300 pb-2 mb-6">
          VI. Firmas y Conformidad
        </h3>
        <div class="grid grid-cols-3 gap-8">
          <div v-for="firma in firmas" :key="firma.rol" class="text-center">
            <div class="border-b-2 border-gray-400 h-16 mb-2"></div>
            <p class="text-sm font-bold text-gray-700">{{ firma.nombre }}</p>
            <p class="text-xs text-gray-500">{{ firma.rol }}</p>
            <p class="text-xs text-gray-400 mt-1">C.I.: ___________________</p>
          </div>
        </div>
        <div class="mt-6 flex items-center justify-between text-xs text-gray-400 border-t border-gray-100 pt-4">
          <span>Sistema IBV — Documento generado digitalmente</span>
          <span>Folio IMP-0042 | {{ fechaHoy }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'blank' })

const fechaHoy = new Date().toLocaleDateString('es-VE', { day: '2-digit', month: 'long', year: 'numeric' })
const horaActual = new Date().toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit' })

const condicionSeleccionada = ref('excelente')
const observaciones = ref('')

const camposVehiculo = [
  { key: 'vin', label: 'VIN/Chasis', valor: '1HGBH41JXMN109186' },
  { key: 'placa', label: 'Placa', valor: 'ABC-1234' },
  { key: 'marca', label: 'Marca', valor: 'Toyota' },
  { key: 'modelo', label: 'Modelo', valor: 'Corolla' },
  { key: 'anio', label: 'Año', valor: '2024' },
  { key: 'color', label: 'Color', valor: 'Blanco Perla' },
  { key: 'km', label: 'Kilometraje', valor: '12 km' },
  { key: 'cliente', label: 'Cliente', valor: 'Distribuidora Caracas' }
]

const condicionesOpciones = [
  { value: 'excelente', label: 'Excelente' },
  { value: 'bueno', label: 'Bueno' },
  { value: 'regular', label: 'Regular' },
  { value: 'dañado', label: 'Con daños' }
]

const dañosListados = [
  { zona: 'Parte Frontal', tipo: 'Rayón superficial', severidad: 'Baja' },
  { zona: 'Lateral Derecho', tipo: 'Abolladura leve', severidad: 'Media' }
]

const fotosImprimibles = [
  { label: 'Vista Frontal', url: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Frontal' },
  { label: 'Vista Trasera', url: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Trasera' },
  { label: 'Lateral Izquierdo', url: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Lat+Izq' },
  { label: 'Lateral Derecho', url: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Lat+Der' },
  { label: 'Tablero', url: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Tablero' },
  { label: 'Odómetro', url: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Odómetro' }
]

const firmas = [
  { nombre: 'Carlos Mendoza', rol: 'Recibidor' },
  { nombre: '___________________', rol: 'Conductor / Transportista' },
  { nombre: '___________________', rol: 'Supervisor' }
]

const imprimir = () => window.print()
</script>

<style>
@page {
  size: A4;
  margin: 15mm;
}
@media print {
  .print\:hidden { display: none !important; }
  .print\:px-6 { padding-left: 1.5rem !important; padding-right: 1.5rem !important; }
  .print\:py-6 { padding-top: 1.5rem !important; padding-bottom: 1.5rem !important; }
  body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
}
</style>

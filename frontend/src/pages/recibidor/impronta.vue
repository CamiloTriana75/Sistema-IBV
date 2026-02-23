<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
      <div class="flex items-center gap-3">
        <NuxtLink to="/recibidor" class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </NuxtLink>
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Registro de Impronta</h1>
          <p class="text-gray-500 mt-1">Documenta el estado del vehículo al ingreso</p>
        </div>
      </div>
      <div class="flex gap-3">
        <NuxtLink :to="`/recibidor/impronta-print`" target="_blank"
          class="inline-flex items-center gap-2 px-4 py-2.5 border border-gray-200 bg-white text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-50 transition">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
          </svg>
          Vista Imprimible
        </NuxtLink>
        <button @click="guardarImpronta"
          class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          Guardar Impronta
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
      <!-- Columna izquierda: Datos del vehículo + Daños -->
      <div class="xl:col-span-2 space-y-6">

        <!-- Datos del Vehículo -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 class="text-base font-bold text-gray-900 mb-4 flex items-center gap-2">
            <div class="w-7 h-7 bg-primary-100 rounded-lg flex items-center justify-center">
              <svg class="w-4 h-4 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            Datos del Vehículo
          </h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">VIN / Chasis</label>
              <input v-model="form.vin" type="text" placeholder="1HGBH41JXMN109186"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Placa</label>
              <input v-model="form.placa" type="text" placeholder="ABC-1234"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Marca</label>
              <input v-model="form.marca" type="text" placeholder="Toyota"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Modelo</label>
              <input v-model="form.modelo" type="text" placeholder="Corolla"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Año</label>
              <input v-model="form.anio" type="number" placeholder="2024"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Color</label>
              <input v-model="form.color" type="text" placeholder="Blanco Perla"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Kilometraje</label>
              <input v-model="form.km" type="number" placeholder="0"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Cliente</label>
              <input v-model="form.cliente" type="text" placeholder="Distribuidora XXX"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition" />
            </div>
            <div>
              <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Condición General</label>
              <select v-model="form.condicion"
                class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition bg-white">
                <option value="">Seleccionar</option>
                <option value="excelente">Excelente</option>
                <option value="bueno">Bueno</option>
                <option value="regular">Regular</option>
                <option value="dañado">Con daños</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Mapa de daños -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 class="text-base font-bold text-gray-900 mb-4 flex items-center gap-2">
            <div class="w-7 h-7 bg-danger-100 rounded-lg flex items-center justify-center">
              <svg class="w-4 h-4 text-danger-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
            </div>
            Mapa de Daños
            <span class="text-xs text-gray-400 font-normal ml-1">— Haz clic en las zonas dañadas</span>
          </h2>

          <!-- Diagrama del auto -->
          <div class="flex flex-col lg:flex-row gap-6 items-start">
            <div class="flex-1">
              <div class="relative bg-gray-50 rounded-2xl p-6 flex items-center justify-center min-h-[280px]">
                <!-- Vista superior del auto (SVG simplificado) -->
                <svg viewBox="0 0 320 500" class="w-full max-w-[220px]" xmlns="http://www.w3.org/2000/svg">
                  <!-- Carrocería principal -->
                  <rect x="60" y="140" width="200" height="220" rx="20" fill="#e2e8f0" stroke="#94a3b8" stroke-width="2"/>
                  <!-- Techo -->
                  <rect x="90" y="155" width="140" height="120" rx="10" fill="#cbd5e1" stroke="#94a3b8" stroke-width="1.5"/>
                  <!-- Capó -->
                  <rect x="80" y="60" width="160" height="85" rx="15" fill="#e2e8f0" stroke="#94a3b8" stroke-width="2"/>
                  <!-- Maletero -->
                  <rect x="80" y="355" width="160" height="85" rx="15" fill="#e2e8f0" stroke="#94a3b8" stroke-width="2"/>
                  <!-- Ruedas -->
                  <circle cx="80" cy="170" r="28" fill="#475569" stroke="#1e293b" stroke-width="2"/>
                  <circle cx="80" cy="170" r="14" fill="#94a3b8"/>
                  <circle cx="240" cy="170" r="28" fill="#475569" stroke="#1e293b" stroke-width="2"/>
                  <circle cx="240" cy="170" r="14" fill="#94a3b8"/>
                  <circle cx="80" cy="330" r="28" fill="#475569" stroke="#1e293b" stroke-width="2"/>
                  <circle cx="80" cy="330" r="14" fill="#94a3b8"/>
                  <circle cx="240" cy="330" r="28" fill="#475569" stroke="#1e293b" stroke-width="2"/>
                  <circle cx="240" cy="330" r="14" fill="#94a3b8"/>

                  <!-- Zonas clickeables con estado -->
                  <!-- Frontal -->
                  <rect @click="toggleZona('frontal')" x="95" y="65" width="130" height="70" rx="10"
                    :fill="zonasDañadas.includes('frontal') ? '#fca5a5' : 'transparent'"
                    :stroke="zonasDañadas.includes('frontal') ? '#ef4444' : 'transparent'"
                    stroke-width="2" class="cursor-pointer hover:fill-red-100 transition-colors" opacity="0.7"/>
                  <!-- Trasero -->
                  <rect @click="toggleZona('trasero')" x="95" y="360" width="130" height="70" rx="10"
                    :fill="zonasDañadas.includes('trasero') ? '#fca5a5' : 'transparent'"
                    :stroke="zonasDañadas.includes('trasero') ? '#ef4444' : 'transparent'"
                    stroke-width="2" class="cursor-pointer hover:fill-red-100 transition-colors" opacity="0.7"/>
                  <!-- Lateral izq -->
                  <rect @click="toggleZona('lateral_izq')" x="60" y="150" width="30" height="200" rx="8"
                    :fill="zonasDañadas.includes('lateral_izq') ? '#fca5a5' : 'transparent'"
                    :stroke="zonasDañadas.includes('lateral_izq') ? '#ef4444' : 'transparent'"
                    stroke-width="2" class="cursor-pointer hover:fill-red-100 transition-colors" opacity="0.7"/>
                  <!-- Lateral der -->
                  <rect @click="toggleZona('lateral_der')" x="230" y="150" width="30" height="200" rx="8"
                    :fill="zonasDañadas.includes('lateral_der') ? '#fca5a5' : 'transparent'"
                    :stroke="zonasDañadas.includes('lateral_der') ? '#ef4444' : 'transparent'"
                    stroke-width="2" class="cursor-pointer hover:fill-red-100 transition-colors" opacity="0.7"/>
                  <!-- Techo -->
                  <rect @click="toggleZona('techo')" x="95" y="155" width="130" height="115" rx="8"
                    :fill="zonasDañadas.includes('techo') ? '#fca5a5' : 'transparent'"
                    :stroke="zonasDañadas.includes('techo') ? '#ef4444' : 'transparent'"
                    stroke-width="2" class="cursor-pointer hover:fill-red-100 transition-colors" opacity="0.7"/>

                  <!-- Labels -->
                  <text x="160" y="108" text-anchor="middle" fill="#64748b" font-size="11" font-weight="600">FRONTAL</text>
                  <text x="160" y="400" text-anchor="middle" fill="#64748b" font-size="11" font-weight="600">TRASERO</text>
                  <text x="160" y="218" text-anchor="middle" fill="#64748b" font-size="11" font-weight="600">TECHO</text>
                  <text x="42" y="252" text-anchor="middle" fill="#64748b" font-size="10" font-weight="600" transform="rotate(-90 42 252)">LAT. IZQ</text>
                  <text x="278" y="252" text-anchor="middle" fill="#64748b" font-size="10" font-weight="600" transform="rotate(90 278 252)">LAT. DER</text>

                  <!-- Marcadores de daño -->
                  <g v-for="zona in zonasDañadas" :key="zona">
                    <circle v-if="zona === 'frontal'" cx="160" cy="95" r="10" fill="#ef4444"/>
                    <text v-if="zona === 'frontal'" x="160" y="100" text-anchor="middle" fill="white" font-size="12" font-weight="bold">!</text>
                    <circle v-if="zona === 'trasero'" cx="160" cy="390" r="10" fill="#ef4444"/>
                    <text v-if="zona === 'trasero'" x="160" y="395" text-anchor="middle" fill="white" font-size="12" font-weight="bold">!</text>
                    <circle v-if="zona === 'lateral_izq'" cx="70" cy="250" r="10" fill="#ef4444"/>
                    <text v-if="zona === 'lateral_izq'" x="70" y="255" text-anchor="middle" fill="white" font-size="12" font-weight="bold">!</text>
                    <circle v-if="zona === 'lateral_der'" cx="250" cy="250" r="10" fill="#ef4444"/>
                    <text v-if="zona === 'lateral_der'" x="250" y="255" text-anchor="middle" fill="white" font-size="12" font-weight="bold">!</text>
                    <circle v-if="zona === 'techo'" cx="160" cy="212" r="10" fill="#ef4444"/>
                    <text v-if="zona === 'techo'" x="160" y="217" text-anchor="middle" fill="white" font-size="12" font-weight="bold">!</text>
                  </g>
                </svg>
              </div>
              <p class="text-xs text-gray-400 text-center mt-2">Haz clic en la zona para marcar/desmarcar daño</p>
            </div>

            <!-- Lista de daños -->
            <div class="flex-1 space-y-3">
              <p class="text-sm font-semibold text-gray-700">Zonas marcadas:</p>
              <div v-if="zonasDañadas.length === 0" class="text-sm text-gray-400 py-4 text-center bg-gray-50 rounded-xl">
                Sin daños marcados
              </div>
              <div v-for="zona in zonasDañadas" :key="zona" class="flex items-center gap-3 p-3 bg-danger-50 border border-danger-100 rounded-xl">
                <div class="w-2 h-2 bg-danger-500 rounded-full shrink-0" />
                <span class="text-sm font-medium text-danger-700 capitalize flex-1">{{ zonaNombre(zona) }}</span>
                <button @click="toggleZona(zona)" class="text-danger-400 hover:text-danger-600 transition">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <div class="mt-4">
                <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1.5">Observaciones generales</label>
                <textarea v-model="form.observaciones" rows="4" placeholder="Describa los daños encontrados, rayones, abolladuras, faltantes, etc."
                  class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition resize-none" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Columna derecha: Fotos -->
      <div class="space-y-6">
        <!-- Captura de Fotos -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h2 class="text-base font-bold text-gray-900 mb-4 flex items-center gap-2">
            <div class="w-7 h-7 bg-purple-100 rounded-lg flex items-center justify-center">
              <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>
            Fotografías
          </h2>

          <!-- Fotos requeridas -->
          <div class="space-y-3">
            <p class="text-xs text-gray-500 font-semibold uppercase tracking-wider">Vistas obligatorias</p>
            <div class="grid grid-cols-2 gap-3">
              <div v-for="vista in vistasRequeridas" :key="vista.key"
                class="relative group border-2 border-dashed rounded-xl overflow-hidden cursor-pointer transition-all"
                :class="fotosCapturadas[vista.key] ? 'border-success-400' : 'border-gray-200 hover:border-primary-300'"
                @click="capturarFoto(vista.key)">
                <div v-if="fotosCapturadas[vista.key]" class="relative">
                  <img :src="fotosCapturadas[vista.key]" :alt="vista.label" class="w-full h-28 object-cover" />
                  <div class="absolute top-1.5 right-1.5 w-6 h-6 bg-success-500 rounded-full flex items-center justify-center">
                    <svg class="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <button @click.stop="eliminarFoto(vista.key)"
                    class="absolute top-1.5 left-1.5 w-6 h-6 bg-danger-500 rounded-full items-center justify-center hidden group-hover:flex">
                    <svg class="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
                <div v-else class="flex flex-col items-center justify-center h-28 gap-2 px-2">
                  <svg class="w-8 h-8 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  </svg>
                  <span class="text-xs text-gray-400 text-center font-medium">{{ vista.label }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Input de archivo oculto -->
          <input ref="fileInput" type="file" accept="image/*" capture="environment" class="hidden" @change="onFileChange" />

          <!-- Fotos adicionales -->
          <div class="mt-4 space-y-3">
            <p class="text-xs text-gray-500 font-semibold uppercase tracking-wider">Fotos adicionales (daños)</p>
            <div class="grid grid-cols-3 gap-2">
              <div v-for="(foto, idx) in fotosAdicionales" :key="idx"
                class="relative group rounded-xl overflow-hidden border border-gray-200">
                <img :src="foto" class="w-full h-20 object-cover" />
                <button @click="fotosAdicionales.splice(idx, 1)"
                  class="absolute top-1 right-1 w-5 h-5 bg-danger-500 rounded-full items-center justify-center hidden group-hover:flex">
                  <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              <button @click="agregarFotoAdicional"
                class="flex flex-col items-center justify-center h-20 border-2 border-dashed border-gray-200 hover:border-primary-300 rounded-xl transition cursor-pointer gap-1">
                <svg class="w-5 h-5 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                <span class="text-xs text-gray-400">Agregar</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Progreso -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <h3 class="text-sm font-bold text-gray-900 mb-4">Progreso del Registro</h3>
          <div class="space-y-3">
            <div class="flex items-center justify-between">
              <span class="text-sm text-gray-600">Datos del vehículo</span>
              <span :class="progresoDatos >= 100 ? 'text-success-600' : 'text-gray-400'" class="text-sm font-semibold">
                {{ progresoDatos }}%
              </span>
            </div>
            <div class="w-full bg-gray-100 rounded-full h-1.5">
              <div class="h-1.5 rounded-full bg-primary-500 transition-all duration-500" :style="`width: ${progresoDatos}%`" />
            </div>

            <div class="flex items-center justify-between mt-2">
              <span class="text-sm text-gray-600">Fotos obligatorias</span>
              <span :class="progresoFotos >= 100 ? 'text-success-600' : 'text-gray-400'" class="text-sm font-semibold">
                {{ Object.keys(fotosCapturadas).length }}/{{ vistasRequeridas.length }}
              </span>
            </div>
            <div class="w-full bg-gray-100 rounded-full h-1.5">
              <div class="h-1.5 rounded-full bg-purple-500 transition-all duration-500" :style="`width: ${progresoFotos}%`" />
            </div>
          </div>

          <div class="mt-5 pt-4 border-t border-gray-100">
            <div class="flex items-center gap-2 text-sm" :class="listo ? 'text-success-600' : 'text-gray-400'">
              <svg v-if="listo" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {{ listo ? 'Listo para guardar' : 'Completa todos los campos' }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast de éxito -->
    <div v-if="showToast" class="fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-4 bg-success-600 text-white rounded-2xl shadow-2xl animate-slide-up">
      <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
      </svg>
      <span class="font-semibold">Impronta guardada correctamente</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'

definePageMeta({ layout: 'admin' })

const fileInput = ref<HTMLInputElement | null>(null)
const currentVista = ref<string | null>(null)
const showToast = ref(false)

const form = reactive({
  vin: '',
  placa: '',
  marca: '',
  modelo: '',
  anio: '',
  color: '',
  km: '',
  cliente: '',
  condicion: '',
  observaciones: ''
})

const zonasDañadas = ref<string[]>([])
const fotosCapturadas = ref<Record<string, string>>({})
const fotosAdicionales = ref<string[]>([])

const vistasRequeridas = [
  { key: 'frontal', label: 'Vista Frontal' },
  { key: 'trasera', label: 'Vista Trasera' },
  { key: 'lateral_izq', label: 'Lateral Izquierdo' },
  { key: 'lateral_der', label: 'Lateral Derecho' },
  { key: 'tablero', label: 'Tablero' },
  { key: 'odometro', label: 'Odómetro' }
]

const zonaNombres: Record<string, string> = {
  frontal: 'Parte Frontal',
  trasero: 'Parte Trasera',
  lateral_izq: 'Lateral Izquierdo',
  lateral_der: 'Lateral Derecho',
  techo: 'Techo'
}

const toggleZona = (zona: string) => {
  const idx = zonasDañadas.value.indexOf(zona)
  if (idx > -1) zonasDañadas.value.splice(idx, 1)
  else zonasDañadas.value.push(zona)
}

const zonaNombre = (key: string) => zonaNombres[key] || key

const capturarFoto = (vistaKey: string) => {
  currentVista.value = vistaKey
  // Simular captura con imagen placeholder
  const placeholders: Record<string, string> = {
    frontal: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Frontal',
    trasera: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Trasera',
    lateral_izq: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Lat+Izq',
    lateral_der: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Lat+Der',
    tablero: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Tablero',
    odometro: 'https://placehold.co/400x300/e2e8f0/94a3b8?text=Odómetro'
  }
  fotosCapturadas.value[vistaKey] = placeholders[vistaKey] || `https://placehold.co/400x300/e2e8f0/94a3b8?text=${vistaKey}`
}

const eliminarFoto = (vistaKey: string) => {
  delete fotosCapturadas.value[vistaKey]
}

const agregarFotoAdicional = () => {
  fotosAdicionales.value.push('https://placehold.co/200x150/fef3c7/d97706?text=Daño')
}

const onFileChange = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file && currentVista.value) {
    const url = URL.createObjectURL(file)
    fotosCapturadas.value[currentVista.value] = url
    currentVista.value = null
  }
}

const camposLlenos = computed(() => {
  const campos = ['vin', 'marca', 'modelo', 'condicion']
  return campos.filter(c => form[c as keyof typeof form]).length
})

const progresoDatos = computed(() => Math.round((camposLlenos.value / 4) * 100))
const progresoFotos = computed(() => Math.round((Object.keys(fotosCapturadas.value).length / vistasRequeridas.length) * 100))
const listo = computed(() => progresoDatos.value >= 75 && progresoFotos.value >= 50)

const guardarImpronta = () => {
  showToast.value = true
  setTimeout(() => { showToast.value = false }, 3000)
}
</script>

<style scoped>
@keyframes slide-up {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
.animate-slide-up { animation: slide-up 0.3s ease-out; }
</style>

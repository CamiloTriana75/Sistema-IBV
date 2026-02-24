<!--
Componente reutilizable para escaneo QR/Código de barras
Soporta entrada manual (teclado/pistola de escaneo) y simulación de cámara
-->

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'

interface Props {
  placeholder?: string
  hideResult?: boolean
  autoFocus?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: 'Escanea o digita el código...',
  hideResult: false,
  autoFocus: true,
})

const emit = defineEmits<{
  scan: [value: string]
}>()

const inputRef = ref<HTMLInputElement | null>(null)
const showCamera = ref(false)
const manualInput = ref('')
const scannedValue = ref('')
const error = ref('')
const justScanned = ref(false)

const focus = () => {
  nextTick(() => {
    inputRef.value?.focus()
  })
}

const reset = () => {
  manualInput.value = ''
  scannedValue.value = ''
  error.value = ''
  justScanned.value = false
  focus()
}

const setError = (msg: string) => {
  error.value = msg
  scannedValue.value = ''
  setTimeout(() => {
    error.value = ''
  }, 4000)
}

const handleManualInput = () => {
  if (manualInput.value.trim()) {
    const val = manualInput.value.trim()
    scannedValue.value = val
    error.value = ''
    justScanned.value = true
    setTimeout(() => {
      justScanned.value = false
    }, 1500)
    emit('scan', val)
    manualInput.value = ''
  }
}

onMounted(() => {
  if (props.autoFocus) focus()
})

onUnmounted(() => {
  showCamera.value = false
})

defineExpose({ focus, reset, setError })
</script>

<template>
  <div class="space-y-4">
    <!-- Modo cámara simulada -->
    <div v-if="showCamera" class="relative">
      <div
        class="bg-gray-900 rounded-2xl overflow-hidden aspect-[4/3] flex items-center justify-center relative"
      >
        <!-- Visor de cámara simulado -->
        <div class="absolute inset-0 flex items-center justify-center">
          <div class="w-56 h-56 relative">
            <!-- Esquinas del marco de escaneo -->
            <div
              class="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-primary-400 rounded-tl-lg"
            />
            <div
              class="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-primary-400 rounded-tr-lg"
            />
            <div
              class="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-primary-400 rounded-bl-lg"
            />
            <div
              class="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-primary-400 rounded-br-lg"
            />
            <!-- Línea de escaneo animada -->
            <div
              class="absolute left-2 right-2 h-0.5 bg-primary-400 shadow-lg shadow-primary-400/50 animate-scan-line"
            />
          </div>
        </div>
        <!-- Ícono central -->
        <div class="text-center z-10">
          <svg
            class="w-12 h-12 text-gray-500 mx-auto mb-2 opacity-50"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
            />
          </svg>
          <p class="text-gray-400 text-sm">Apunta al código QR</p>
        </div>
      </div>
      <!-- Botón cerrar cámara -->
      <button
        class="absolute top-3 right-3 p-2 bg-black/50 hover:bg-black/70 text-white rounded-full transition"
        @click="showCamera = false"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>
    </div>

    <!-- Controles -->
    <div class="flex gap-3">
      <button
        class="inline-flex items-center gap-2 px-4 py-2.5 text-sm font-semibold rounded-xl transition"
        :class="
          showCamera
            ? 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            : 'bg-primary-600 text-white hover:bg-primary-700 shadow-lg shadow-primary-500/25'
        "
        @click="showCamera = !showCamera"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            v-if="!showCamera"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
          />
          <circle v-if="!showCamera" cx="12" cy="13" r="3" stroke="currentColor" stroke-width="2" />
          <path
            v-if="showCamera"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
        {{ showCamera ? 'Cerrar Cámara' : 'Abrir Cámara' }}
      </button>
    </div>

    <!-- Campo de entrada manual / pistola de escaneo -->
    <div class="relative">
      <div class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
          />
        </svg>
      </div>
      <input
        ref="inputRef"
        v-model="manualInput"
        type="text"
        :placeholder="placeholder"
        class="w-full pl-10 pr-24 py-3 border-2 border-gray-200 rounded-xl text-sm font-mono focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition"
        :class="{ 'border-green-400 bg-green-50/30': justScanned }"
        @keyup.enter="handleManualInput"
      />
      <button
        :disabled="!manualInput.trim()"
        class="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1.5 bg-primary-600 text-white text-sm font-semibold rounded-lg hover:bg-primary-700 transition disabled:opacity-40 disabled:cursor-not-allowed"
        @click="handleManualInput"
      >
        Escanear
      </button>
    </div>

    <p class="text-xs text-gray-400 flex items-center gap-1.5">
      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      Usa la pistola de escaneo, digita el código y presiona Enter, o abre la cámara
    </p>

    <!-- Resultado exitoso -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="translate-y-1 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
    >
      <div
        v-if="scannedValue && !hideResult"
        class="flex items-center gap-3 p-3 bg-green-50 border border-green-200 rounded-xl"
      >
        <div class="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center shrink-0">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-xs text-green-600 font-semibold">Código escaneado</p>
          <p class="text-sm font-bold text-green-800 font-mono truncate">{{ scannedValue }}</p>
        </div>
      </div>
    </Transition>

    <!-- Error -->
    <Transition
      enter-active-class="transition duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
    >
      <div
        v-if="error"
        class="flex items-center gap-3 p-3 bg-red-50 border border-red-200 rounded-xl"
      >
        <div class="w-8 h-8 bg-red-500 rounded-lg flex items-center justify-center shrink-0">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </div>
        <p class="text-sm font-medium text-red-700">{{ error }}</p>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
@keyframes scan-line {
  0%,
  100% {
    top: 0.5rem;
  }
  50% {
    top: calc(100% - 0.5rem);
  }
}
.animate-scan-line {
  animation: scan-line 2s ease-in-out infinite;
}
</style>

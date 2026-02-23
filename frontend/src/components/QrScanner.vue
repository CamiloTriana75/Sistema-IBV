<!--
Componente reutilizable para escaneo QR
Soporta cámara de celular y pistola de escaneo
-->

<template>
  <div class="space-y-4">
    <div class="flex gap-2 flex-wrap">
      <button
        @click="toggleCamera"
        class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition"
      >
        {{ showCamera ? '❌ Cerrar cámara' : '📷 Abrir cámara' }}
      </button>
    </div>

    <!-- Preview de la cámara -->
    <div v-if="showCamera" class="bg-gray-900 rounded-lg overflow-hidden">
      <div id="qr-reader" class="w-full"></div>
    </div>

    <!-- Campo de entrada manual -->
    <div>
      <label class="block text-sm font-medium text-gray-700 mb-1">
        O digita/escanea manualmente:
      </label>
      <input
        v-model="manualInput"
        @keyup.enter="handleManualInput"
        type="text"
        placeholder="Escanea o digita el QR..."
        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
      />
    </div>

    <!-- Resultado -->
    <div v-if="scannedValue" class="bg-green-50 border border-green-200 p-4 rounded-lg">
      <p class="text-sm text-gray-600">QR Escaneado:</p>
      <p class="text-lg font-semibold text-green-600">{{ scannedValue }}</p>
    </div>

    <!-- Error -->
    <div v-if="error" class="bg-red-50 border border-red-200 p-4 rounded-lg">
      <p class="text-sm font-medium text-red-600">{{ error }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onUnmounted } from 'vue'

interface Props {
  onScan?: (value: string) => void
}

const props = defineProps<Props>()
const emit = defineEmits<{
  scan: [value: string]
}>()

const showCamera = ref(false)
const manualInput = ref('')
const scannedValue = ref('')
const error = ref('')

const toggleCamera = async () => {
  if (showCamera.value) {
    closeCamera()
  } else {
    openCamera()
  }
}

const openCamera = () => {
  showCamera.value = true
  // TODO: Implementar html5-qrcode
}

const closeCamera = () => {
  showCamera.value = false
}

const handleManualInput = () => {
  if (manualInput.value.trim()) {
    scannedValue.value = manualInput.value
    error.value = ''
    emit('scan', manualInput.value)
    if (props.onScan) props.onScan(manualInput.value)
  }
}

onUnmounted(() => {
  closeCamera()
})
</script>

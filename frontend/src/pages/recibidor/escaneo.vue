<script setup lang="ts">
import { ref, computed, reactive } from 'vue'
import { useContenedorStore, type Contenedor, type VehiculoContenedor } from '~/stores/contenedorStore'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ layout: 'admin' })

const contStore = useContenedorStore()
const authStore = useAuthStore()

const paso = ref(1)
const contenedorActual = ref<Contenedor | null>(null)
const observaciones = ref('')
const resumenFinal = reactive({ codigo: '', escaneados: 0, total: 0 })

type QrScannerRef = {
  startScan: () => void
  stopScan: () => void
  setError: (msg: string) => void
  setSuccess: (msg: string) => void
  reset: () => void
} | null

const scannerContenedor = ref<QrScannerRef>(null)
const scannerVehiculo = ref<QrScannerRef>(null)

const toast = reactive({ show: false, msg: '', type: 'ok' as 'ok' | 'warn' | 'error' })
const mostrarToast = (type: 'ok' | 'warn' | 'error', msg: string) => {
  toast.type = type
  toast.msg = msg
  toast.show = true
  setTimeout(() => {
    toast.show = false
  }, 3500)
}

// Contenedores pendientes/en recepcion
const contenedoresPendientes = computed(() =>
  contStore.contenedores.filter((c) => c.estado === 'pendiente' || c.estado === 'en_recepcion')
)

// Stats para paso 2
const vehiculosEscaneados = computed(
  () => contenedorActual.value?.vehiculos.filter((v) => v.escaneado).length || 0
)
const progresoVehiculos = computed(() => {
  if (!contenedorActual.value) return 0
  const esperados = contenedorActual.value.vehiculosEsperados
  const total = esperados > 0 ? Math.max(esperados, contenedorActual.value.vehiculos.length) : contenedorActual.value.vehiculos.length
  if (total === 0) return vehiculosEscaneados.value > 0 ? 100 : 0
  return Math.min(100, Math.round((vehiculosEscaneados.value / total) * 100))
})

// ===== Modal: crear contenedor =====
const showModalContenedor = ref(false)
const codigoEscaneadoContenedor = ref('')
const cargandoContenedor = ref(false)
const formContenedor = reactive({
  origen: '',
  transportista: '',
  placaCamion: '',
  fechaLlegada: new Date().toISOString().split('T')[0],
  horaLlegada: new Date().toTimeString().substring(0, 5),
  vehiculosEsperados: 0,
})

// ===== Modal: agregar vehículo =====
const showModalVehiculo = ref(false)
const cargandoVehiculo = ref(false)
const formVehiculo = reactive({
  vin: '',
  marca: '',
  modelo: '',
  anio: String(new Date().getFullYear()),
  color: '',
})

// ===== Paso 1: Escanear contenedor =====
const onScanContenedor = (codigo: string) => {
  const cont = contStore.getByCodigo(codigo)
  if (cont) {
    if (cont.estado === 'completado') {
      scannerContenedor.value?.setError(`El contenedor "${codigo}" ya fue recibido`)
      mostrarToast('warn', 'Este contenedor ya fue recibido')
      return
    }
    seleccionarContenedor(cont)
  } else {
    // Contenedor no existe → registrar nueva llegada
    codigoEscaneadoContenedor.value = codigo
    formContenedor.fechaLlegada = new Date().toISOString().split('T')[0]
    formContenedor.horaLlegada = new Date().toTimeString().substring(0, 5)
    showModalContenedor.value = true
    scannerContenedor.value?.setSuccess(`Código "${codigo}" — Completa los datos de llegada`)
  }
}

const confirmarCrearContenedor = async () => {
  if (!formContenedor.origen.trim() || !formContenedor.transportista.trim()) {
    mostrarToast('warn', 'Origen y transportista son requeridos')
    return
  }
  cargandoContenedor.value = true
  try {
    const user = authStore.user?.name || 'Recibidor'
    const nuevo = await contStore.crearContenedor({
      codigo: codigoEscaneadoContenedor.value,
      origen: formContenedor.origen.trim(),
      transportista: formContenedor.transportista.trim(),
      placaCamion: formContenedor.placaCamion.trim(),
      fechaLlegada: formContenedor.fechaLlegada,
      horaLlegada: formContenedor.horaLlegada,
      vehiculosEsperados: Number(formContenedor.vehiculosEsperados) || 0,
      recibidoPor: user,
    })
    if (!nuevo) {
      mostrarToast('error', 'Error al registrar el contenedor')
      return
    }
    showModalContenedor.value = false
    formContenedor.origen = ''
    formContenedor.transportista = ''
    formContenedor.placaCamion = ''
    formContenedor.vehiculosEsperados = 0
    seleccionarContenedor(nuevo)
  } catch {
    mostrarToast('error', 'Error al registrar el contenedor')
  } finally {
    cargandoContenedor.value = false
  }
}

const seleccionarContenedor = async (cont: Contenedor) => {
  contenedorActual.value = cont
  if (cont.estado !== 'en_recepcion') {
    const user = authStore.user?.name || 'Recibidor'
    await contStore.iniciarRecepcion(cont.id, user)
  }
  paso.value = 2
  mostrarToast('ok', `Contenedor ${cont.codigo} cargado`)
}

// ===== Paso 2: Escanear vehículos =====
const onScanVehiculo = (codigo: string) => {
  if (!contenedorActual.value) return

  // Verificar si ya fue escaneado
  const yaExiste = contenedorActual.value.vehiculos.find(
    (v) =>
      v.vin.toLowerCase() === codigo.toLowerCase() ||
      v.codigoImpronta.toLowerCase() === codigo.toLowerCase()
  )

  if (yaExiste) {
    if (yaExiste.escaneado) {
      scannerVehiculo.value?.setError('Este vehículo ya fue escaneado')
      mostrarToast('warn', 'Este vehículo ya fue escaneado')
      return
    }
    // Pre-cargado pero no escaneado aún → marcar como escaneado
    _marcarPreCargado(yaExiste)
    return
  }

  // Vehículo nuevo → abrir formulario
  formVehiculo.vin = codigo
  formVehiculo.marca = ''
  formVehiculo.modelo = ''
  formVehiculo.anio = String(new Date().getFullYear())
  formVehiculo.color = ''
  showModalVehiculo.value = true
}

const _marcarPreCargado = async (veh: VehiculoContenedor) => {
  await contStore.marcarVehiculoEscaneado(contenedorActual.value!.id, veh.codigoImpronta)
  mostrarToast('ok', `${veh.marca} ${veh.modelo} — escaneado`)
}

const confirmarAgregarVehiculo = async () => {
  if (!formVehiculo.vin.trim()) {
    mostrarToast('warn', 'El VIN / código es requerido')
    return
  }
  cargandoVehiculo.value = true
  try {
    const nuevo = await contStore.agregarVehiculoEscaneado(contenedorActual.value!.id, {
      vin: formVehiculo.vin.trim(),
      marca: formVehiculo.marca.trim() || 'N/A',
      modelo: formVehiculo.modelo.trim() || 'N/A',
      anio: formVehiculo.anio.trim() || String(new Date().getFullYear()),
      color: formVehiculo.color.trim() || 'N/A',
      codigoImpronta: formVehiculo.vin.trim(),
    })
    if (!nuevo) {
      mostrarToast('error', 'Error al registrar el vehículo')
      return
    }
    showModalVehiculo.value = false
    // Sync contenedorActual with store (store updates the array in-place)
    const enStore = contStore.getById(contenedorActual.value!.id)
    if (enStore) contenedorActual.value = enStore
    mostrarToast('ok', `${nuevo.marca} ${nuevo.modelo} — registrado`)
  } catch {
    mostrarToast('error', 'Error al registrar el vehículo')
  } finally {
    cargandoVehiculo.value = false
  }
}

// ===== Paso 3: Finalizar =====
const finalizarRecepcion = async () => {
  if (!contenedorActual.value) return
  await contStore.completarRecepcion(contenedorActual.value.id, observaciones.value)
  resumenFinal.codigo = contenedorActual.value.codigo
  resumenFinal.escaneados = vehiculosEscaneados.value
  resumenFinal.total = contenedorActual.value.vehiculosEsperados
  paso.value = 3
}

const nuevaRecepcion = () => {
  contenedorActual.value = null
  observaciones.value = ''
  paso.value = 1
}

const resetSeleccionContenedor = () => {
  paso.value = 1
  contenedorActual.value = null
}

// ===== Imprimir resumen de recepción =====
const imprimirResumen = () => {
  if (!contenedorActual.value) return
  const cont = contenedorActual.value
  const fecha = new Date().toLocaleDateString('es-VE', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
  const hora = new Date().toLocaleTimeString('es-VE', {
    hour: '2-digit',
    minute: '2-digit',
  })
  const vehiculosHTML = cont.vehiculos
    .map(
      (v, i) => `
      <tr style="border-bottom:1px solid #e5e7eb;">
        <td style="padding:8px 12px;text-align:center;font-weight:600;">${i + 1}</td>
        <td style="padding:8px 12px;font-family:monospace;font-size:11px;">${v.vin}</td>
        <td style="padding:8px 12px;font-weight:600;">${v.marca} ${v.modelo}</td>
        <td style="padding:8px 12px;text-align:center;">${v.anio}</td>
        <td style="padding:8px 12px;">${v.color}</td>
        <td style="padding:8px 12px;text-align:center;font-family:monospace;font-size:11px;">${v.codigoImpronta}</td>
        <td style="padding:8px 12px;text-align:center;">
          <span style="display:inline-block;padding:2px 10px;border-radius:12px;font-size:11px;font-weight:700;${v.escaneado ? 'background:#dcfce7;color:#15803d;' : 'background:#fef9c3;color:#a16207;'}">
            ${v.escaneado ? '✓ Escaneado' : 'Pendiente'}
          </span>
        </td>
      </tr>`
    )
    .join('')

  const html = `
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="utf-8"/>
      <title>Resumen Recepción - ${cont.codigo}</title>
      <style>
        @media print { body { -webkit-print-color-adjust: exact; print-color-adjust: exact; } }
        body { font-family: 'Segoe UI', sans-serif; margin: 0; padding: 24px; color: #1f2937; }
        .header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 3px solid #0ea5e9; padding-bottom: 16px; margin-bottom: 20px; }
        .logo { font-size: 22px; font-weight: 800; color: #0ea5e9; }
        .logo span { color: #64748b; font-weight: 400; font-size: 13px; display: block; }
        .badge { display: inline-block; padding: 4px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; }
        .info-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 20px; }
        .info-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px; }
        .info-box .label { font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; color: #94a3b8; font-weight: 700; }
        .info-box .value { font-size: 15px; font-weight: 700; color: #1e293b; margin-top: 2px; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        thead { background: #f1f5f9; }
        th { padding: 10px 12px; text-align: left; font-size: 11px; text-transform: uppercase; letter-spacing: .5px; color: #64748b; font-weight: 700; }
        .summary-bar { display: flex; justify-content: space-between; align-items: center; background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 10px; padding: 12px 16px; margin-top: 16px; }
        .obs { margin-top: 16px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 16px; }
        .footer { margin-top: 32px; padding-top: 16px; border-top: 1px solid #e5e7eb; display: flex; justify-content: space-between; font-size: 11px; color: #94a3b8; }
        .sign-line { margin-top: 48px; display: flex; gap: 64px; }
        .sign-line div { flex: 1; border-top: 1px solid #94a3b8; padding-top: 6px; font-size: 12px; color: #64748b; text-align: center; }
      </style>
    </head>
    <body>
      <div class="header">
        <div>
          <div class="logo">Sistema IBV <span>Gestión de Vehículos</span></div>
        </div>
        <div style="text-align:right;">
          <div style="font-size:18px;font-weight:800;">RESUMEN DE RECEPCIÓN</div>
          <div style="font-size:12px;color:#64748b;margin-top:2px;">${fecha} — ${hora}</div>
        </div>
      </div>

      <div class="info-grid">
        <div class="info-box">
          <div class="label">Contenedor</div>
          <div class="value" style="font-family:monospace;">${cont.codigo}</div>
        </div>
        <div class="info-box">
          <div class="label">Origen</div>
          <div class="value" style="font-size:13px;">${cont.origen}</div>
        </div>
        <div class="info-box">
          <div class="label">Transportista</div>
          <div class="value" style="font-size:13px;">${cont.transportista}</div>
        </div>
        <div class="info-box">
          <div class="label">Placa Camión</div>
          <div class="value" style="font-family:monospace;">${cont.placaCamion}</div>
        </div>
        <div class="info-box">
          <div class="label">Fecha Llegada</div>
          <div class="value">${cont.fechaLlegada}</div>
        </div>
        <div class="info-box">
          <div class="label">Hora Llegada</div>
          <div class="value">${cont.horaLlegada}</div>
        </div>
        <div class="info-box">
          <div class="label">Vehículos Esperados</div>
          <div class="value">${cont.vehiculosEsperados}</div>
        </div>
        <div class="info-box">
          <div class="label">Recibido Por</div>
          <div class="value" style="font-size:13px;">${cont.recibidoPor || authStore.user?.name || '—'}</div>
        </div>
      </div>

      <h3 style="font-size:14px;margin:0 0 8px;color:#334155;">Detalle de Vehículos</h3>
      <table>
        <thead>
          <tr><th>#</th><th>VIN</th><th>Vehículo</th><th>Año</th><th>Color</th><th>Código Impronta</th><th>Estado</th></tr>
        </thead>
        <tbody>${vehiculosHTML}</tbody>
      </table>

      <div class="summary-bar">
        <div>
          <strong>${resumenFinal.escaneados}</strong> de <strong>${resumenFinal.total}</strong> vehículos escaneados
        </div>
        <span class="badge" style="${resumenFinal.escaneados === resumenFinal.total ? 'background:#dcfce7;color:#15803d;' : 'background:#fef9c3;color:#a16207;'}">
          ${resumenFinal.escaneados === resumenFinal.total ? 'RECEPCIÓN COMPLETA' : 'RECEPCIÓN PARCIAL'}
        </span>
      </div>

      ${observaciones.value ? `<div class="obs"><strong style="font-size:12px;color:#92400e;">Observaciones:</strong><p style="margin:4px 0 0;font-size:13px;">${observaciones.value}</p></div>` : ''}

      <div class="sign-line">
        <div>Firma Recibidor</div>
        <div>Firma Transportista</div>
        <div>Firma Supervisor</div>
      </div>

      <div class="footer">
        <span>Sistema IBV — Documento generado automáticamente</span>
        <span>${fecha} ${hora}</span>
      </div>

      ${'<scr' + 'ipt>window.onload = function() { window.print(); }<' + '/script>'}
    </body>
    </html>
  `

  const win = window.open('', '_blank')
  if (win) {
    win.document.write(html)
    win.document.close()
  }
}
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
      <div class="flex items-center gap-3">
        <NuxtLink
          to="/recibidor"
          class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-xl transition"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </NuxtLink>
        <div>
          <h1 class="text-2xl sm:text-3xl font-bold text-gray-900">Recepción de Vehículos</h1>
          <p class="text-gray-500 mt-1">Escanea el contenedor y luego cada vehículo</p>
        </div>
      </div>
    </div>

    <!-- Progress Steps -->
    <div class="flex items-center gap-3 mb-8">
      <div class="flex items-center gap-2">
        <div
          :class="[
            'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all',
            paso >= 1
              ? 'bg-primary-600 text-white shadow-lg shadow-primary-500/30'
              : 'bg-gray-200 text-gray-500',
          ]"
        >
          1
        </div>
        <span
          class="text-sm font-semibold"
          :class="paso >= 1 ? 'text-primary-700' : 'text-gray-400'"
        >
          Contenedor
        </span>
      </div>
      <div class="flex-1 h-1 rounded-full" :class="paso >= 2 ? 'bg-primary-500' : 'bg-gray-200'" />
      <div class="flex items-center gap-2">
        <div
          :class="[
            'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all',
            paso >= 2
              ? 'bg-primary-600 text-white shadow-lg shadow-primary-500/30'
              : 'bg-gray-200 text-gray-500',
          ]"
        >
          2
        </div>
        <span
          class="text-sm font-semibold"
          :class="paso >= 2 ? 'text-primary-700' : 'text-gray-400'"
        >
          Vehículos
        </span>
      </div>
      <div class="flex-1 h-1 rounded-full" :class="paso >= 3 ? 'bg-success-500' : 'bg-gray-200'" />
      <div class="flex items-center gap-2">
        <div
          :class="[
            'w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all',
            paso >= 3
              ? 'bg-success-600 text-white shadow-lg shadow-success-500/30'
              : 'bg-gray-200 text-gray-500',
          ]"
        >
          <svg
            v-if="paso >= 3"
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 13l4 4L19 7"
            />
          </svg>
          <span v-else>3</span>
        </div>
        <span
          class="text-sm font-semibold"
          :class="paso >= 3 ? 'text-success-700' : 'text-gray-400'"
        >
          Completado
        </span>
      </div>
    </div>

    <!-- ========== PASO 1: Escanear Contenedor ========== -->
    <div v-if="paso === 1" class="max-w-2xl mx-auto">
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 sm:p-8">
        <div class="text-center mb-6">
          <div
            class="w-16 h-16 bg-primary-50 rounded-2xl flex items-center justify-center mx-auto mb-4"
          >
            <svg
              class="w-8 h-8 text-primary-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
              />
            </svg>
          </div>
          <h2 class="text-xl font-bold text-gray-900 mb-1">Escanear Código de Contenedor</h2>
          <p class="text-sm text-gray-500">
            Escanea el código QR o de barras del contenedor que trae los vehículos
          </p>
        </div>

        <QrScanner
          ref="scannerContenedor"
          placeholder="Código del contenedor (ej: CONT-2026-0001)"
          hide-result
          @scan="onScanContenedor"
        />

        <!-- Contenedores pendientes de hoy -->
        <div class="mt-8 pt-6 border-t border-gray-100">
          <h3 class="text-sm font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <svg
              class="w-4 h-4 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            Contenedores pendientes
          </h3>
          <div
            v-if="contenedoresPendientes.length === 0"
            class="text-sm text-gray-400 py-4 text-center bg-gray-50 rounded-xl"
          >
            No hay contenedores pendientes
          </div>
          <div class="space-y-2">
            <button
              v-for="cont in contenedoresPendientes"
              :key="cont.id"
              class="w-full flex items-center gap-4 p-4 rounded-xl text-left hover:bg-primary-50 border-2 border-transparent hover:border-primary-200 transition bg-gray-50"
              @click="seleccionarContenedor(cont)"
            >
              <div
                class="w-11 h-11 bg-primary-100 rounded-xl flex items-center justify-center shrink-0"
              >
                <svg
                  class="w-6 h-6 text-primary-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
                  />
                </svg>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-gray-900 font-mono">{{ cont.codigo }}</p>
                <p class="text-xs text-gray-500">{{ cont.origen }} · {{ cont.transportista }}</p>
              </div>
              <div class="text-right shrink-0">
                <p class="text-sm font-bold text-primary-600">{{ cont.vehiculosEsperados }} veh.</p>
                <p class="text-xs text-gray-400">{{ cont.horaLlegada }}</p>
              </div>
              <span
                :class="[
                  'text-xs font-semibold px-2.5 py-1 rounded-full shrink-0',
                  cont.estado === 'en_recepcion'
                    ? 'bg-amber-50 text-amber-700'
                    : 'bg-blue-50 text-blue-700',
                ]"
              >
                {{ cont.estado === 'en_recepcion' ? 'En recepción' : 'Pendiente' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ========== PASO 2: Escanear Vehículos ========== -->
    <div v-if="paso === 2 && contenedorActual" class="space-y-6">
      <!-- Info del contenedor -->
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
        <div class="flex flex-wrap items-center gap-5">
          <div
            class="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center shrink-0"
          >
            <svg
              class="w-6 h-6 text-primary-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"
              />
            </svg>
          </div>
          <div class="flex-1 grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Contenedor</p>
              <p class="text-sm font-bold text-gray-900 font-mono">{{ contenedorActual.codigo }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Origen</p>
              <p class="text-sm font-bold text-gray-900">{{ contenedorActual.origen }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Transportista</p>
              <p class="text-sm font-bold text-gray-900">{{ contenedorActual.transportista }}</p>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-semibold uppercase">Placa Camión</p>
              <p class="text-sm font-bold text-gray-900 font-mono">
                {{ contenedorActual.placaCamion }}
              </p>
            </div>
          </div>
          <button
            class="px-3 py-1.5 text-xs text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition font-semibold"
            @click="resetSeleccionContenedor"
          >
            Cambiar
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- Scanner de vehículos -->
        <div class="xl:col-span-2 space-y-6">
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
            <div class="flex items-center gap-3 mb-5">
              <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center">
                <svg
                  class="w-5 h-5 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"
                  />
                </svg>
              </div>
              <div>
                <h2 class="text-lg font-bold text-gray-900">Escanear Código de Impronta</h2>
                <p class="text-sm text-gray-500">
                  Escanea el código QR de cada vehículo del contenedor
                </p>
              </div>
            </div>

            <QrScanner
              ref="scannerVehiculo"
              placeholder="Código de impronta del vehículo (ej: IMP-VH-001)"
              hide-result
              @scan="onScanVehiculo"
            />
          </div>

          <!-- Lista de vehículos del contenedor -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 class="text-sm font-bold text-gray-900">Vehículos del Contenedor</h3>
              <span
                class="text-sm font-bold"
                :class="
                  vehiculosEscaneados === contenedorActual.vehiculosEsperados
                    ? 'text-success-600'
                    : 'text-primary-600'
                "
              >
                {{ vehiculosEscaneados }} / {{ contenedorActual.vehiculosEsperados }}
              </span>
            </div>

            <!-- Progress bar -->
            <div class="px-5 pt-3">
              <div class="w-full bg-gray-100 rounded-full h-2.5">
                <div
                  class="h-2.5 rounded-full transition-all duration-500"
                  :class="progresoVehiculos === 100 ? 'bg-success-500' : 'bg-primary-500'"
                  :style="{ width: progresoVehiculos + '%' }"
                />
              </div>
            </div>

            <div class="divide-y divide-gray-50">
              <div
                v-for="(veh, idx) in contenedorActual.vehiculos"
                :key="veh.vin"
                class="px-5 py-4 flex items-center gap-4 transition"
                :class="veh.escaneado ? 'bg-success-50/30' : ''"
              >
                <!-- Numero / Check -->
                <div
                  :class="[
                    'w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold shrink-0 transition-all',
                    veh.escaneado ? 'bg-success-500 text-white' : 'bg-gray-100 text-gray-500',
                  ]"
                >
                  <svg
                    v-if="veh.escaneado"
                    class="w-5 h-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                  <span v-else>{{ idx + 1 }}</span>
                </div>

                <!-- Info -->
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-semibold text-gray-900">
                    {{ veh.marca }} {{ veh.modelo }} {{ veh.anio }}
                  </p>
                  <p class="text-xs text-gray-500 font-mono">
                    VIN: {{ veh.vin.slice(-8) }} · {{ veh.color }}
                  </p>
                </div>

                <!-- Código -->
                <div class="text-right shrink-0">
                  <p class="text-xs text-gray-400 font-mono">{{ veh.codigoImpronta }}</p>
                </div>

                <!-- Estado -->
                <span
                  :class="[
                    'text-xs font-semibold px-2.5 py-1 rounded-full shrink-0',
                    veh.escaneado ? 'bg-success-50 text-success-700' : 'bg-gray-100 text-gray-500',
                  ]"
                >
                  {{ veh.escaneado ? 'Escaneado' : 'Pendiente' }}
                </span>

                <!-- Acción -->
                <NuxtLink
                  v-if="veh.escaneado && !veh.improntaId"
                  :to="`/recibidor/impronta?vin=${veh.vin}&marca=${veh.marca}&modelo=${veh.modelo}&anio=${veh.anio}&color=${veh.color}`"
                  class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-semibold text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-lg transition shrink-0"
                >
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 4v16m8-8H4"
                    />
                  </svg>
                  Impronta
                </NuxtLink>
                <span
                  v-if="veh.improntaId"
                  class="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-semibold text-success-700 bg-success-50 rounded-lg shrink-0"
                >
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  Impronta OK
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Panel lateral: Resumen -->
        <div class="space-y-6">
          <!-- Progreso -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h3 class="text-sm font-bold text-gray-900 mb-4">Progreso de Recepción</h3>
            <div class="flex items-center justify-center mb-4">
              <div class="relative w-28 h-28">
                <svg class="w-28 h-28 transform -rotate-90">
                  <circle cx="56" cy="56" r="48" stroke="#e5e7eb" stroke-width="8" fill="none" />
                  <circle
                    cx="56"
                    cy="56"
                    r="48"
                    :stroke="progresoVehiculos === 100 ? '#22c55e' : '#3b82f6'"
                    stroke-width="8"
                    fill="none"
                    stroke-linecap="round"
                    :stroke-dasharray="`${progresoVehiculos * 3.01} 301`"
                    class="transition-all duration-700"
                  />
                </svg>
                <div class="absolute inset-0 flex items-center justify-center">
                  <span
                    class="text-2xl font-bold"
                    :class="progresoVehiculos === 100 ? 'text-success-600' : 'text-primary-600'"
                  >
                    {{ progresoVehiculos }}%
                  </span>
                </div>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-3 text-center">
              <div class="bg-success-50 rounded-xl p-3">
                <p class="text-2xl font-bold text-success-600">{{ vehiculosEscaneados }}</p>
                <p class="text-xs text-success-600 font-semibold">Escaneados</p>
              </div>
              <div class="bg-gray-50 rounded-xl p-3">
                <p class="text-2xl font-bold text-gray-500">
                  {{ contenedorActual.vehiculosEsperados - vehiculosEscaneados }}
                </p>
                <p class="text-xs text-gray-500 font-semibold">Pendientes</p>
              </div>
            </div>
          </div>

          <!-- Observaciones -->
          <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <h3 class="text-sm font-bold text-gray-900 mb-3">Observaciones</h3>
            <textarea
              v-model="observaciones"
              rows="4"
              placeholder="Notas sobre la recepción..."
              class="w-full px-3 py-2.5 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 resize-none transition"
            />
          </div>

          <!-- Botones -->
          <div class="space-y-3">
            <button
              :disabled="vehiculosEscaneados === 0"
              class="w-full px-5 py-3 text-sm font-bold rounded-xl transition shadow-lg disabled:opacity-40 disabled:cursor-not-allowed disabled:shadow-none"
              :class="
                progresoVehiculos === 100
                  ? 'bg-success-600 text-white hover:bg-success-700 shadow-success-500/25'
                  : 'bg-primary-600 text-white hover:bg-primary-700 shadow-primary-500/25'
              "
              @click="finalizarRecepcion"
            >
              <span class="flex items-center justify-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
                {{ progresoVehiculos === 100 ? 'Completar Recepción' : 'Finalizar Parcialmente' }}
              </span>
            </button>
            <button
              class="w-full px-5 py-2.5 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition"
              @click="resetSeleccionContenedor"
            >
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ========== PASO 3: Completado ========== -->
    <div v-if="paso === 3" class="max-w-md mx-auto text-center">
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-8">
        <div
          class="w-20 h-20 bg-success-100 rounded-full flex items-center justify-center mx-auto mb-5"
        >
          <svg
            class="w-10 h-10 text-success-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-gray-900 mb-2">Recepción Completada</h2>
        <p class="text-gray-500 mb-2">
          Contenedor
          <span class="font-bold text-gray-700 font-mono">{{ resumenFinal.codigo }}</span>
        </p>
        <p class="text-sm text-gray-500 mb-6">
          Se escanearon
          <span class="font-bold text-success-600">{{ resumenFinal.escaneados }}</span>
          de {{ resumenFinal.total }} vehículos
        </p>
        <div class="space-y-3">
          <button
            class="w-full px-5 py-2.5 bg-gray-800 text-white text-sm font-semibold rounded-xl hover:bg-gray-900 transition shadow-lg flex items-center justify-center gap-2"
            @click="imprimirResumen"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"
              />
            </svg>
            Imprimir Resumen de Recepción
          </button>
          <div class="flex gap-3">
            <button
              class="flex-1 px-5 py-2.5 bg-primary-600 text-white text-sm font-semibold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25"
              @click="nuevaRecepcion"
            >
              Nueva Recepción
            </button>
            <NuxtLink
              to="/recibidor"
              class="flex-1 px-5 py-2.5 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition text-center"
            >
              Ir al Panel
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="translate-y-2 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transition duration-200 ease-in"
      leave-from-class="translate-y-0 opacity-100"
      leave-to-class="translate-y-2 opacity-0"
    >
      <div
        v-if="toast.show"
        class="fixed bottom-6 right-6 z-50 flex items-center gap-3 px-5 py-3 rounded-xl shadow-lg text-white font-medium"
        :class="
          toast.type === 'ok'
            ? 'bg-success-600'
            : toast.type === 'warn'
              ? 'bg-amber-500'
              : 'bg-danger-600'
        "
      >
        <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            v-if="toast.type === 'ok'"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5 13l4 4L19 7"
          />
          <path
            v-else-if="toast.type === 'warn'"
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
          />
          <path
            v-else
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
        {{ toast.msg }}
      </div>
    </Transition>

    <!-- ========== Modal: Registrar Contenedor ========== -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="showModalContenedor"
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      >
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
          <div class="px-6 py-5 border-b border-gray-100 flex items-center gap-3">
            <div class="w-10 h-10 bg-primary-100 rounded-xl flex items-center justify-center shrink-0">
              <svg class="w-5 h-5 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
              </svg>
            </div>
            <div>
              <h3 class="text-base font-bold text-gray-900">Registrar Llegada de Contenedor</h3>
              <p class="text-xs text-gray-500 font-mono mt-0.5">{{ codigoEscaneadoContenedor }}</p>
            </div>
          </div>

          <div class="px-6 py-5 space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Fecha llegada</label>
                <input
                  v-model="formContenedor.fechaLlegada"
                  type="date"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Hora llegada</label>
                <input
                  v-model="formContenedor.horaLlegada"
                  type="time"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>

            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Origen <span class="text-danger-500">*</span></label>
              <input
                v-model="formContenedor.origen"
                type="text"
                placeholder="Ej: Miami, FL"
                class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>

            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">Transportista <span class="text-danger-500">*</span></label>
              <input
                v-model="formContenedor.transportista"
                type="text"
                placeholder="Nombre de la empresa"
                class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Placa camión</label>
                <input
                  v-model="formContenedor.placaCamion"
                  type="text"
                  placeholder="ABC-123"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 font-mono"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Vehículos esperados</label>
                <input
                  v-model.number="formContenedor.vehiculosEsperados"
                  type="number"
                  min="0"
                  placeholder="0"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
          </div>

          <div class="px-6 py-4 bg-gray-50 border-t border-gray-100 flex gap-3">
            <button
              class="flex-1 px-4 py-2.5 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition"
              @click="showModalContenedor = false"
            >
              Cancelar
            </button>
            <button
              :disabled="cargandoContenedor"
              class="flex-1 px-4 py-2.5 bg-primary-600 text-white text-sm font-bold rounded-xl hover:bg-primary-700 transition shadow-lg shadow-primary-500/25 disabled:opacity-60 disabled:cursor-not-allowed"
              @click="confirmarCrearContenedor"
            >
              <span v-if="cargandoContenedor">Guardando...</span>
              <span v-else>Confirmar Llegada</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>

    <!-- ========== Modal: Agregar Vehículo ========== -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="showModalVehiculo"
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      >
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
          <div class="px-6 py-5 border-b border-gray-100 flex items-center gap-3">
            <div class="w-10 h-10 bg-blue-100 rounded-xl flex items-center justify-center shrink-0">
              <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
              </svg>
            </div>
            <div>
              <h3 class="text-base font-bold text-gray-900">Registrar Vehículo</h3>
              <p class="text-xs text-gray-500 font-mono mt-0.5">{{ formVehiculo.vin }}</p>
            </div>
          </div>

          <div class="px-6 py-5 space-y-4">
            <div>
              <label class="block text-xs font-semibold text-gray-600 mb-1.5">VIN / Código escaneado</label>
              <input
                v-model="formVehiculo.vin"
                type="text"
                class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm font-mono focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-gray-50"
              />
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Marca</label>
                <input
                  v-model="formVehiculo.marca"
                  type="text"
                  placeholder="Toyota"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Modelo</label>
                <input
                  v-model="formVehiculo.modelo"
                  type="text"
                  placeholder="Corolla"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Año</label>
                <input
                  v-model="formVehiculo.anio"
                  type="number"
                  min="2000"
                  max="2030"
                  placeholder="2024"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1.5">Color</label>
                <input
                  v-model="formVehiculo.color"
                  type="text"
                  placeholder="Blanco"
                  class="w-full px-3 py-2 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
          </div>

          <div class="px-6 py-4 bg-gray-50 border-t border-gray-100 flex gap-3">
            <button
              class="flex-1 px-4 py-2.5 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition"
              @click="showModalVehiculo = false"
            >
              Cancelar
            </button>
            <button
              :disabled="cargandoVehiculo"
              class="flex-1 px-4 py-2.5 bg-blue-600 text-white text-sm font-bold rounded-xl hover:bg-blue-700 transition shadow-lg shadow-blue-500/25 disabled:opacity-60 disabled:cursor-not-allowed"
              @click="confirmarAgregarVehiculo"
            >
              <span v-if="cargandoVehiculo">Guardando...</span>
              <span v-else>Registrar Vehículo</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

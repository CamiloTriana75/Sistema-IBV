<script setup lang="ts">
import { ref } from 'vue'

definePageMeta({
  layout: 'blank',
})

const form = ref({
  email: '',
  password: '',
  remember: false,
})

const showPassword = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')

// Recuperar contraseña
const showRecoverModal = ref(false)
const recoverEmail = ref('')
const isRecovering = ref(false)
const recoverSent = ref(false)

const handleLogin = async () => {
  errorMessage.value = ''
  isLoading.value = true

  try {
    // TODO: Conectar con API del backend
    await new Promise((resolve) => setTimeout(resolve, 1500))

    // Simular validación
    if (!form.value.email || !form.value.password) {
      throw new Error('Por favor completa todos los campos')
    }

    console.log('Login attempt:', form.value.email)
    navigateTo('/admin')
  } catch (error: any) {
    errorMessage.value =
      error.message || 'Credenciales incorrectas. Verifica tu email y contraseña.'
  } finally {
    isLoading.value = false
  }
}

const handleRecover = async () => {
  isRecovering.value = true
  try {
    // TODO: Conectar con API del backend
    await new Promise((resolve) => setTimeout(resolve, 1500))
    recoverSent.value = true
  } catch (error) {
    console.error('Error recovering password:', error)
  } finally {
    isRecovering.value = false
  }
}
</script>

<template>
  <div class="flex min-h-screen">
    <!-- Panel izquierdo: Branding -->
    <div
      class="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-primary-600 via-primary-700 to-primary-900 relative overflow-hidden"
    >
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-20 left-10 w-72 h-72 bg-white rounded-full blur-3xl" />
        <div class="absolute bottom-20 right-10 w-96 h-96 bg-primary-300 rounded-full blur-3xl" />
      </div>
      <div class="relative z-10 flex flex-col justify-center items-center w-full px-12 text-white">
        <div
          class="w-24 h-24 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center mb-8"
        >
          <svg class="w-14 h-14 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="1.5"
              d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
            />
          </svg>
        </div>
        <h1 class="text-4xl font-bold mb-4">Sistema IBV</h1>
        <p class="text-lg text-primary-100 text-center max-w-md leading-relaxed">
          Plataforma integral de gestión de inventario y despacho de vehículos en bodegas
        </p>
        <div class="mt-12 grid grid-cols-3 gap-8 text-center">
          <div>
            <div class="text-3xl font-bold">100+</div>
            <div class="text-sm text-primary-200 mt-1">Vehículos</div>
          </div>
          <div>
            <div class="text-3xl font-bold">24/7</div>
            <div class="text-sm text-primary-200 mt-1">Operación</div>
          </div>
          <div>
            <div class="text-3xl font-bold">5</div>
            <div class="text-sm text-primary-200 mt-1">Roles</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Panel derecho: Formulario de Login -->
    <div class="w-full lg:w-1/2 flex items-center justify-center p-6 sm:p-12 bg-gray-50">
      <div class="w-full max-w-md">
        <!-- Logo mobile -->
        <div class="lg:hidden text-center mb-8">
          <div
            class="w-16 h-16 bg-primary-600 rounded-2xl flex items-center justify-center mx-auto mb-4"
          >
            <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="1.5"
                d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
              />
            </svg>
          </div>
          <h1 class="text-2xl font-bold text-gray-800">Sistema IBV</h1>
        </div>

        <!-- Header -->
        <div class="mb-8">
          <h2 class="text-3xl font-bold text-gray-900">Iniciar Sesión</h2>
          <p class="text-gray-500 mt-2">Ingresa tus credenciales para acceder al sistema</p>
        </div>

        <!-- Alerta de error -->
        <div
          v-if="errorMessage"
          class="mb-6 p-4 bg-danger-500/10 border border-danger-500/20 rounded-xl flex items-start gap-3"
        >
          <svg
            class="w-5 h-5 text-danger-500 mt-0.5 shrink-0"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span class="text-sm text-danger-600">{{ errorMessage }}</span>
        </div>

        <!-- Formulario -->
        <form class="space-y-5" @submit.prevent="handleLogin">
          <!-- Email -->
          <div>
            <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
              Correo electrónico
            </label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg
                  class="w-5 h-5 text-gray-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"
                  />
                </svg>
              </div>
              <input
                id="email"
                v-model="form.email"
                type="email"
                required
                autocomplete="email"
                class="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all bg-white placeholder-gray-400"
                placeholder="nombre@empresa.com"
              />
            </div>
          </div>

          <!-- Contraseña -->
          <div>
            <label for="password" class="block text-sm font-semibold text-gray-700 mb-2">
              Contraseña
            </label>
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <svg
                  class="w-5 h-5 text-gray-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                  />
                </svg>
              </div>
              <input
                id="password"
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                required
                autocomplete="current-password"
                class="w-full pl-12 pr-12 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all bg-white placeholder-gray-400"
                placeholder="••••••••"
              />
              <button
                type="button"
                class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-400 hover:text-gray-600 transition"
                @click="showPassword = !showPassword"
              >
                <svg
                  v-if="!showPassword"
                  class="w-5 h-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                  />
                </svg>
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"
                  />
                </svg>
              </button>
            </div>
          </div>

          <!-- Recordar + Recuperar -->
          <div class="flex items-center justify-between">
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                v-model="form.remember"
                type="checkbox"
                class="w-4 h-4 rounded border-gray-300 text-primary-600 focus:ring-primary-500 transition"
              />
              <span class="text-sm text-gray-600">Recordarme</span>
            </label>
            <button
              type="button"
              class="text-sm font-semibold text-primary-600 hover:text-primary-700 transition"
              @click="showRecoverModal = true"
            >
              ¿Olvidaste tu contraseña?
            </button>
          </div>

          <!-- Botón Submit -->
          <button
            type="submit"
            :disabled="isLoading"
            class="w-full flex items-center justify-center gap-2 bg-primary-600 hover:bg-primary-700 active:bg-primary-800 text-white font-semibold py-3 px-4 rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-primary-500/25 hover:shadow-primary-500/40"
          >
            <svg v-if="isLoading" class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
              <circle
                class="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                stroke-width="4"
              />
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
            <span>{{ isLoading ? 'Ingresando...' : 'Iniciar Sesión' }}</span>
          </button>
        </form>

        <!-- Footer -->
        <p class="text-center text-sm text-gray-400 mt-8">
          ¿No tienes cuenta? Contacta al administrador del sistema
        </p>
      </div>
    </div>

    <!-- Modal Recuperar Contraseña -->
    <div
      v-if="showRecoverModal"
      class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4"
    >
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8 transform transition-all">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-gray-900">Recuperar Contraseña</h3>
          <button
            class="text-gray-400 hover:text-gray-600 transition"
            @click="showRecoverModal = false"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>

        <p class="text-sm text-gray-500 mb-6">
          Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu
          contraseña.
        </p>

        <!-- Mensaje de éxito -->
        <div
          v-if="recoverSent"
          class="mb-6 p-4 bg-success-500/10 border border-success-500/20 rounded-xl flex items-start gap-3"
        >
          <svg
            class="w-5 h-5 text-success-500 mt-0.5 shrink-0"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span class="text-sm text-success-600">
            Se han enviado las instrucciones a tu correo electrónico.
          </span>
        </div>

        <form v-else class="space-y-5" @submit.prevent="handleRecover">
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Correo electrónico</label>
            <input
              v-model="recoverEmail"
              type="email"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all placeholder-gray-400"
              placeholder="nombre@empresa.com"
            />
          </div>
          <div class="flex gap-3">
            <button
              type="submit"
              :disabled="isRecovering"
              class="flex-1 flex items-center justify-center gap-2 bg-primary-600 hover:bg-primary-700 text-white font-semibold py-3 px-4 rounded-xl transition-all disabled:opacity-50"
            >
              <svg v-if="isRecovering" class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                <circle
                  class="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  stroke-width="4"
                />
                <path
                  class="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                />
              </svg>
              Enviar instrucciones
            </button>
            <button
              type="button"
              class="px-4 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-xl transition-all"
              @click="showRecoverModal = false"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

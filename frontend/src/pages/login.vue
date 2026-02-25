<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '~/stores/auth'

definePageMeta({ layout: 'blank' })

const authStore = useAuthStore()
const router = useRouter()

const showPass = ref(false)
const loading = ref(false)
const error = ref('')
const form = ref({ email: '', password: '' })

const features = [
  {
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
    label: 'Registro de impronta con captura fotográfica',
  },
  {
    icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
    label: 'Checklist de inventario por categorías',
  },
  {
    icon: 'M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12v.01M12 4h.01M4 4h4v4H4V4zm12 0h4v4h-4V4zM4 16h4v4H4v-4z',
    label: 'Despacho por escaneo QR secuencial',
  },
]

const roles = ['Administrador', 'Recibidor', 'Inventario', 'Despachador', 'Portería']

const demoCredentials = [
  { email: 'admin1@ibv.com', label: 'Administrador' },
  { email: 'recibidor1@ibv.com', label: 'Recibidor' },
  { email: 'inventario1@ibv.com', label: 'Inventario' },
  { email: 'despacho1@ibv.com', label: 'Despachador' },
  { email: 'porteria1@ibv.com', label: 'Portería' },
]

const fillDemo = (demo: { email: string; label: string }) => {
  form.value.email = demo.email
  form.value.password = 'Test1234!'
  error.value = ''
}

const handleLogin = async () => {
  if (loading.value) return
  error.value = ''
  loading.value = true
  try {
    const redirect = await authStore.login(form.value.email, form.value.password)
    await router.push(redirect)
  } catch (e: unknown) {
    error.value = (e as Error).message || 'Credenciales inválidas'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen flex">
    <!-- Panel izquierdo — branding -->
    <div
      class="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-primary-600 via-primary-700 to-primary-900 relative overflow-hidden flex-col justify-between p-12"
    >
      <div class="absolute -top-24 -left-24 w-96 h-96 bg-white/5 rounded-full" />
      <div class="absolute -bottom-32 -right-32 w-[500px] h-[500px] bg-white/5 rounded-full" />
      <div class="absolute top-1/3 right-10 w-48 h-48 bg-white/5 rounded-full" />

      <!-- Logo -->
      <div class="relative">
        <div class="flex items-center gap-3">
          <div class="w-12 h-12 bg-white/20 rounded-2xl flex items-center justify-center">
            <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
              />
            </svg>
          </div>
          <div>
            <h1 class="text-2xl font-black text-white">Sistema IBV</h1>
            <p class="text-primary-200 text-sm">Bodega · Inventario · Despacho</p>
          </div>
        </div>
      </div>

      <div class="relative space-y-6">
        <h2 class="text-4xl font-black text-white leading-tight">
          Gestión inteligente
          <br />
          de vehículos
        </h2>
        <p class="text-primary-200 text-lg leading-relaxed">
          Controla todo el ciclo de vida de los vehículos desde la recepción hasta el despacho
          final.
        </p>
        <div class="space-y-4 pt-2">
          <div v-for="feat in features" :key="feat.label" class="flex items-center gap-3">
            <div class="w-9 h-9 bg-white/15 rounded-xl flex items-center justify-center shrink-0">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  :d="feat.icon"
                />
              </svg>
            </div>
            <span class="text-white font-medium">{{ feat.label }}</span>
          </div>
        </div>
      </div>

      <div class="relative">
        <p class="text-primary-300 text-xs font-semibold uppercase tracking-widest mb-3">
          Roles del sistema
        </p>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="rol in roles"
            :key="rol"
            class="px-3 py-1 bg-white/10 text-white text-xs font-semibold rounded-full border border-white/20"
          >
            {{ rol }}
          </span>
        </div>
      </div>
    </div>

    <!-- Panel derecho — formulario -->
    <div class="w-full lg:w-1/2 flex items-center justify-center p-6 sm:p-12 bg-gray-50">
      <div class="w-full max-w-md">
        <!-- Logo mobile -->
        <div class="flex items-center gap-3 mb-8 lg:hidden">
          <div class="w-10 h-10 bg-primary-600 rounded-xl flex items-center justify-center">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
              />
            </svg>
          </div>
          <span class="text-xl font-black text-gray-900">Sistema IBV</span>
        </div>

        <div
          class="bg-white rounded-3xl shadow-xl shadow-gray-200/60 p-8 sm:p-10 border border-gray-100"
        >
          <div class="mb-8">
            <h2 class="text-2xl font-black text-gray-900">Iniciar sesión</h2>
            <p class="text-gray-500 mt-1">Ingresa tus credenciales para continuar</p>
          </div>

          <!-- Error -->
          <div
            v-if="error"
            class="flex items-center gap-3 p-4 bg-red-50 border border-red-200 rounded-2xl mb-5 text-red-700 text-sm font-medium"
          >
            <svg class="w-5 h-5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
            {{ error }}
          </div>

          <form class="space-y-5" @submit.prevent="handleLogin">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
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
                  v-model="form.email"
                  type="email"
                  required
                  autocomplete="email"
                  placeholder="correo@ibv.com"
                  class="w-full pl-11 pr-4 py-3 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition bg-gray-50 focus:bg-white"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">Contraseña</label>
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
                  v-model="form.password"
                  :type="showPass ? 'text' : 'password'"
                  required
                  autocomplete="current-password"
                  placeholder="••••••••"
                  class="w-full pl-11 pr-12 py-3 border border-gray-200 rounded-xl text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition bg-gray-50 focus:bg-white"
                />
                <button
                  type="button"
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-400 hover:text-gray-600 transition"
                  @click="showPass = !showPass"
                >
                  <svg
                    v-if="!showPass"
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

            <button
              type="submit"
              :disabled="loading"
              class="w-full flex items-center justify-center gap-2 py-3.5 bg-primary-600 hover:bg-primary-700 text-white font-bold rounded-xl transition shadow-lg shadow-primary-500/30 disabled:opacity-60 disabled:cursor-not-allowed"
            >
              <svg v-if="loading" class="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
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
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                />
              </svg>
              {{ loading ? 'Iniciando sesión...' : 'Iniciar sesión' }}
            </button>
          </form>

          <!-- Credenciales demo -->
          <div class="mt-6 pt-6 border-t border-gray-100">
            <p
              class="text-xs text-gray-400 font-semibold uppercase tracking-wider mb-3 text-center"
            >
              Credenciales de prueba
            </p>
            <div class="grid grid-cols-1 gap-1.5">
              <button
                v-for="demo in demoCredentials"
                :key="demo.email"
                type="button"
                class="flex items-center justify-between px-3 py-2 text-xs rounded-xl border border-gray-100 hover:bg-gray-50 hover:border-primary-200 transition group"
                @click="fillDemo(demo)"
              >
                <span class="font-semibold text-gray-600 group-hover:text-primary-700">
                  {{ demo.email }}
                </span>
                <span class="text-gray-400 group-hover:text-primary-500 font-medium">
                  {{ demo.label }} →
                </span>
              </button>
            </div>
            <p class="text-center text-xs text-gray-400 mt-2">
              Contraseña:
              <span class="font-bold text-gray-600">Test1234!</span>
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

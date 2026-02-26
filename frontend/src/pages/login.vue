<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'
import { useAuthStore } from '~/stores/auth'
import { gsap } from 'gsap'

definePageMeta({ layout: 'blank' })

const authStore = useAuthStore()
const router = useRouter()
const rootRef = ref<HTMLElement | null>(null)
let ctx: gsap.Context | null = null

const showPass = ref(false)
const loading = ref(false)
const error = ref('')
const activeDemo = ref(-1)
const form = ref({ email: '', password: '' })

const features = [
  {
    tag: 'Recepción',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
    label: 'Registro de impronta con captura fotográfica',
    color: 'from-sky-500 to-blue-600',
  },
  {
    tag: 'Inventario',
    icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
    label: 'Checklist de inventario por categorías',
    color: 'from-emerald-500 to-green-600',
  },
  {
    tag: 'Despacho',
    icon: 'M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12v.01M12 4h.01M4 4h4v4H4V4zm12 0h4v4h-4V4zM4 16h4v4H4v-4z',
    label: 'Despacho por escaneo QR secuencial',
    color: 'from-violet-500 to-purple-600',
  },
]

const roles = ['Administrador', 'Recibidor', 'Inventario', 'Despachador', 'Portería']

const demoCredentials = [
  { email: 'admin1@ibv.com', label: 'Administrador', color: 'from-violet-500 to-purple-600' },
  { email: 'recibidor1@ibv.com', label: 'Recibidor', color: 'from-cyan-500 to-blue-600' },
  { email: 'inventario1@ibv.com', label: 'Inventario', color: 'from-emerald-500 to-green-600' },
  { email: 'despacho1@ibv.com', label: 'Despachador', color: 'from-amber-500 to-orange-600' },
  { email: 'porteria1@ibv.com', label: 'Portería', color: 'from-rose-500 to-red-600' },
]

const fillDemo = (demo: (typeof demoCredentials)[0], idx: number) => {
  activeDemo.value = idx
  form.value.email = demo.email
  form.value.password = 'ibv2024'
  error.value = ''

  gsap.fromTo(
    '.js-submit-btn',
    { scale: 1 },
    { scale: 1.04, duration: 0.15, yoyo: true, repeat: 1 },
  )
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
    gsap.fromTo(
      '.js-card-inner',
      { x: -8 },
      { x: 0, duration: 0.5, ease: 'elastic.out(1, 0.3)' },
    )
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  ctx = gsap.context(() => {
    // ─── Left panel timeline ───
    const main = gsap.timeline({ defaults: { ease: 'power4.out' } })
    main
      .fromTo('.js-hero', { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.6 })
      .fromTo('.js-title', { autoAlpha: 0, y: 30 }, { autoAlpha: 1, y: 0, duration: 0.7, clearProps: 'y' }, '-=0.3')
      .fromTo('.js-subtitle', { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.5 }, '-=0.3')
      .fromTo('.js-stat', { autoAlpha: 0, y: 20 }, { autoAlpha: 1, y: 0, stagger: 0.1, duration: 0.5, clearProps: 'y' }, '-=0.2')
      .fromTo('.js-feature', { autoAlpha: 0, x: -20 }, { autoAlpha: 1, x: 0, stagger: 0.1, duration: 0.5, clearProps: 'x' }, '-=0.3')
      .fromTo('.js-chip', { autoAlpha: 0, scale: 0.7 }, { autoAlpha: 1, scale: 1, stagger: 0.06, duration: 0.4, clearProps: 'scale' }, '-=0.3')

    // ─── Right panel timeline ───
    const card = gsap.timeline({ defaults: { ease: 'power3.out' }, delay: 0.2 })
    card
      .fromTo('.js-back', { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.4 })
      .fromTo('.js-mobile-logo', { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.4 }, '<')
      .fromTo('.js-card', { autoAlpha: 0, y: 40 }, { autoAlpha: 1, y: 0, duration: 0.8, clearProps: 'y' }, '-=0.2')
      .fromTo('.js-demo', { autoAlpha: 0, y: 16 }, { autoAlpha: 1, y: 0, duration: 0.5, clearProps: 'y' }, '-=0.4')

    // ─── Floating orbs ───
    gsap.utils.toArray<HTMLElement>('.js-orb').forEach((el, i) => {
      gsap.to(el, {
        y: `random(-14, 14)`,
        x: `random(-8, 8)`,
        duration: gsap.utils.random(3, 5),
        ease: 'sine.inOut',
        repeat: -1,
        yoyo: true,
        delay: i * 0.4,
      })
    })

    // ─── Shimmer ───
    gsap.to('.js-shimmer', {
      backgroundPosition: '200% center',
      duration: 3,
      ease: 'none',
      repeat: -1,
    })
  }, rootRef.value!)
})

onUnmounted(() => {
  ctx?.revert()
  ctx = null
})
</script>

<template>
  <div ref="rootRef" class="min-h-screen flex overflow-hidden">
    <!-- ════════ Panel izquierdo — branding ════════ -->
    <div
      class="js-hero hidden lg:flex lg:w-1/2 bg-[radial-gradient(120%_120%_at_0%_0%,#38bdf8_0%,#0ea5e9_35%,#0369a1_70%,#082f49_100%)] relative overflow-hidden flex-col justify-between p-12 xl:p-16"
    >
      <!-- Cuadrícula de fondo -->
      <div
        class="absolute inset-0 bg-[linear-gradient(90deg,rgba(255,255,255,0.08)_1px,transparent_1px),linear-gradient(180deg,rgba(255,255,255,0.08)_1px,transparent_1px)] bg-[size:36px_36px] opacity-30"
      />

      <!-- Orbs decorativos -->
      <div class="js-orb absolute -top-24 -left-24 w-96 h-96 bg-white/[0.07] rounded-full blur-xl" />
      <div class="js-orb absolute -bottom-10 right-10 w-[420px] h-[420px] bg-cyan-400/[0.08] rounded-full blur-2xl" />
      <div class="js-orb absolute top-1/3 left-1/3 w-56 h-56 bg-indigo-300/[0.06] rounded-full blur-xl" />
      <div class="js-orb absolute bottom-20 left-16 w-32 h-32 bg-sky-200/[0.08] rounded-full blur-lg" />

      <!-- Contenido superior -->
      <div class="relative z-10">
        <div
          class="inline-flex items-center gap-3 px-4 py-2.5 bg-white/[0.12] backdrop-blur-sm rounded-2xl border border-white/20 shadow-lg shadow-black/10 mb-8"
        >
          <div class="w-9 h-9 bg-white/20 rounded-xl flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
              />
            </svg>
          </div>
          <div>
            <span class="text-white font-bold text-lg tracking-tight">IBV</span>
            <span class="text-white/60 text-xs ml-1.5 font-medium tracking-wide"></span>
          </div>
        </div>

        <h1 class="js-title text-4xl xl:text-5xl font-extrabold text-white leading-[1.1] tracking-tight">
          Flujo total
          <br />
          <span class="bg-gradient-to-r from-cyan-200 to-sky-100 bg-clip-text text-transparent">
            del patio
          </span>
        </h1>
        <p class="js-subtitle mt-4 text-sky-100/90 text-lg max-w-md leading-relaxed">
          Opera recepción, inventario y despacho con trazabilidad fotográfica en tiempo real.
        </p>

        <!-- Stats -->
        <div class="flex gap-3 mt-8">
          <div class="js-stat flex-1 bg-white/[0.08] backdrop-blur-sm rounded-2xl py-3 border border-white/[0.15] hover:bg-white/[0.14] transition-colors cursor-default text-center">
            <p class="text-white text-xl font-bold leading-none">100%</p>
            <p class="text-sky-200/80 text-xs font-medium mt-1">Trazabilidad</p>
          </div>
          <div class="js-stat flex-1 bg-white/[0.08] backdrop-blur-sm rounded-2xl py-3 border border-white/[0.15] hover:bg-white/[0.14] transition-colors cursor-default text-center">
            <p class="text-white text-xl font-bold leading-none">24/7</p>
            <p class="text-sky-200/80 text-xs font-medium mt-1">Operativo</p>
          </div>
          <div class="js-stat flex-1 bg-white/[0.08] backdrop-blur-sm rounded-2xl py-3 border border-white/[0.15] hover:bg-white/[0.14] transition-colors cursor-default text-center">
            <p class="text-white text-xl font-bold leading-none">5</p>
            <p class="text-sky-200/80 text-xs font-medium mt-1">Módulos</p>
          </div>
        </div>
      </div>

      <!-- Features -->
      <div class="relative z-10 space-y-3">
        <div
          v-for="feat in features"
          :key="feat.label"
          class="js-feature group flex items-center gap-3 bg-white/[0.06] backdrop-blur-sm rounded-xl px-4 py-3 border border-white/[0.12] hover:bg-white/[0.12] transition-colors"
        >
          <div
            class="w-9 h-9 rounded-lg flex items-center justify-center shrink-0 bg-gradient-to-br shadow-sm"
            :class="feat.color"
          >
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="feat.icon" />
            </svg>
          </div>
          <div class="flex-1 min-w-0">
            <span class="text-white text-sm font-medium">{{ feat.label }}</span>
          </div>
          <span class="text-[10px] uppercase tracking-widest text-sky-300/70 font-semibold shrink-0 ml-auto pl-6">
            {{ feat.tag }}
          </span>
        </div>
      </div>

      <!-- Roles footer -->
      <div class="relative z-10">
        <p class="text-sky-300/60 text-[10px] uppercase tracking-[0.2em] font-semibold mb-2.5">
          Roles del sistema
        </p>
        <div class="flex flex-wrap gap-1.5">
          <span
            v-for="rol in roles"
            :key="rol"
            class="js-chip px-2.5 py-1 text-[11px] text-white/90 font-medium rounded-full border border-white/[0.15] bg-white/[0.08] backdrop-blur-sm hover:bg-white/[0.16] transition-colors cursor-default"
          >
            {{ rol }}
          </span>
        </div>
      </div>
    </div>

    <!-- ════════ Panel derecho — formulario ════════ -->
    <div
      class="w-full lg:w-1/2 flex flex-col items-center justify-center p-6 sm:p-10 xl:p-16 bg-gradient-to-bl from-slate-50 via-white to-sky-50/40 relative"
    >
      <div class="absolute top-0 right-0 w-96 h-96 bg-gradient-to-bl from-sky-400/[0.04] to-transparent rounded-full blur-3xl -translate-y-1/3 translate-x-1/3" />
      <div class="absolute bottom-0 left-0 w-72 h-72 bg-gradient-to-tr from-blue-500/[0.06] to-transparent rounded-full blur-3xl translate-y-1/3 -translate-x-1/4" />

      <div class="w-full max-w-[420px] mx-auto relative z-10">
        <!-- Botón volver -->
        <button
          class="js-back group inline-flex items-center gap-2 text-sm font-semibold text-gray-500 hover:text-primary-600 mb-8 px-3 py-1.5 rounded-xl border border-transparent hover:border-gray-200 hover:bg-white hover:shadow-sm transition-all duration-300"
          @click="router.push('/')"
        >
          <svg
            class="w-4 h-4 transition-transform duration-300 group-hover:-translate-x-0.5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Volver al inicio
        </button>

        <!-- Logo mobile -->
        <div class="js-mobile-logo flex items-center gap-3 mb-8 lg:hidden">
          <div class="w-11 h-11 bg-gradient-to-br from-primary-600 to-primary-700 rounded-xl flex items-center justify-center shadow-lg shadow-primary-500/25">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 17h.01M12 17h.01M16 17h.01M3.5 11l.5-2a2 2 0 011.9-1.4h12.2A2 2 0 0120 9l.5 2M4 17a2 2 0 01-2-2v-2h20v2a2 2 0 01-2 2H4z"
              />
            </svg>
          </div>
          <div>
            <span class="text-xl font-bold text-gray-900">Sistema IBV</span>
            <p class="text-xs text-gray-400 font-medium">Patio de vehículos</p>
          </div>
        </div>

        <!-- ─── Tarjeta principal ─── -->
        <div class="js-card">
          <div
            class="js-shimmer rounded-[28px] p-[1.5px] bg-[length:200%_auto] bg-gradient-to-r from-transparent via-sky-400/50 to-transparent"
          >
            <div class="js-card-inner bg-white/95 backdrop-blur-xl rounded-[27px] p-8 sm:p-10">
              <!-- Header -->
              <div class="flex items-center justify-between mb-8">
                <div>
                  <h2 class="text-2xl font-extrabold text-gray-900 tracking-tight">Bienvenido</h2>
                  <p class="text-gray-400 mt-1 text-sm">Inicia sesión en tu cuenta</p>
                </div>
                <div class="hidden sm:flex flex-col items-end">
                  <span class="text-xs font-bold text-primary-600">Patio</span>
                  <span class="text-[10px] uppercase tracking-[0.2em] text-gray-400">IBV</span>
                </div>
              </div>

              <!-- Error -->
              <Transition
                enter-active-class="transition duration-300 ease-out"
                enter-from-class="opacity-0 -translate-y-2"
                enter-to-class="opacity-100 translate-y-0"
                leave-active-class="transition duration-200 ease-in"
                leave-from-class="opacity-100"
                leave-to-class="opacity-0"
              >
                <div
                  v-if="error"
                  class="flex items-center gap-3 p-4 mb-6 bg-red-50 border border-red-200 rounded-2xl text-red-700 text-sm font-medium"
                >
                  <div class="w-8 h-8 rounded-full bg-red-100 flex items-center justify-center shrink-0">
                    <svg class="w-4 h-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                      />
                    </svg>
                  </div>
                  <span>{{ error }}</span>
                </div>
              </Transition>

              <!-- Formulario -->
              <form class="space-y-5" @submit.prevent="handleLogin">
                <!-- Email -->
                <div class="group">
                  <label class="block text-xs uppercase tracking-wider font-semibold text-gray-500 mb-2 group-focus-within:text-primary-600 transition-colors">
                    Correo electrónico
                  </label>
                  <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                      <svg class="w-5 h-5 text-gray-300 group-focus-within:text-primary-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                      </svg>
                    </div>
                    <input
                      v-model="form.email"
                      type="email"
                      required
                      autocomplete="email"
                      placeholder="correo@ibv.com"
                      class="w-full pl-12 pr-4 py-3.5 border-2 border-gray-100 rounded-2xl text-sm font-medium bg-gray-50/50 focus:bg-white focus:border-primary-500 focus:ring-0 transition-all duration-300 placeholder:text-gray-300 outline-none"
                    />
                  </div>
                </div>

                <!-- Password -->
                <div class="group">
                  <label class="block text-xs uppercase tracking-wider font-semibold text-gray-500 mb-2 group-focus-within:text-primary-600 transition-colors">
                    Contraseña
                  </label>
                  <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                      <svg class="w-5 h-5 text-gray-300 group-focus-within:text-primary-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                      </svg>
                    </div>
                    <input
                      v-model="form.password"
                      :type="showPass ? 'text' : 'password'"
                      required
                      autocomplete="current-password"
                      placeholder="••••••••"
                      class="w-full pl-12 pr-14 py-3.5 border-2 border-gray-100 rounded-2xl text-sm font-medium bg-gray-50/50 focus:bg-white focus:border-primary-500 focus:ring-0 transition-all duration-300 placeholder:text-gray-300 outline-none"
                    />
                    <button
                      type="button"
                      class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-300 hover:text-gray-500 transition-colors"
                      @click="showPass = !showPass"
                    >
                      <svg v-if="!showPass" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </svg>
                      <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- Submit -->
                <button
                  type="submit"
                  :disabled="loading"
                  class="js-submit-btn w-full flex items-center justify-center gap-2.5 py-3.5 bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-600 text-white font-bold rounded-2xl transition-all duration-300 shadow-lg shadow-primary-500/25 hover:shadow-xl hover:shadow-primary-500/40 active:scale-[0.98] text-sm tracking-wide disabled:opacity-60 disabled:cursor-not-allowed"
                >
                  <svg v-if="loading" class="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                  <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
                  </svg>
                  {{ loading ? 'Verificando...' : 'Iniciar sesión' }}
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- ─── Credenciales demo ─── -->
        <div class="js-demo mt-8">
          <p class="text-[10px] text-gray-400 font-semibold uppercase tracking-[0.2em] mb-3 text-center">
            Acceso rápido de prueba
          </p>
          <div class="grid grid-cols-1 gap-1.5">
            <button
              v-for="(demo, idx) in demoCredentials"
              :key="demo.email"
              type="button"
              class="flex items-center gap-3.5 px-3.5 py-2.5 rounded-xl border transition-all duration-300 group"
              :class="
                activeDemo === idx
                  ? 'border-primary-200 bg-primary-50/50 shadow-sm'
                  : 'border-gray-100 hover:bg-gray-50/80'
              "
              @click="fillDemo(demo, idx)"
            >
              <div
                class="w-7 h-7 rounded-lg bg-gradient-to-br flex items-center justify-center text-white text-[10px] font-bold shrink-0 shadow-sm"
                :class="demo.color"
              >
                {{ demo.label[0] }}
              </div>
              <div class="flex-1 text-left">
                <p class="text-xs font-semibold text-gray-700 group-hover:text-primary-700 transition-colors">
                  {{ demo.label }}
                </p>
                <p class="text-[10px] text-gray-400 font-medium">{{ demo.email }}</p>
              </div>
              <svg class="w-4 h-4 text-gray-300 group-hover:text-primary-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
          <p class="text-center text-[10px] text-gray-400 mt-3 font-medium">
            Contraseña:
            <code class="px-1.5 py-0.5 bg-gray-100 rounded text-[11px] text-gray-600 font-bold">Test1234!</code>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Estado inicial antes de que GSAP cargue — evita flash de contenido */
.js-hero,
.js-title,
.js-subtitle,
.js-stat,
.js-feature,
.js-chip,
.js-card,
.js-back,
.js-demo,
.js-mobile-logo {
  visibility: hidden;
  opacity: 0;
}
</style>

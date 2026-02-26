import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

interface AuthUser {
  id: string
  name: string
  email: string
  role: string
  status: string
}

export const useAuthStore = defineStore('auth', () => {
  const { $supabase } = useNuxtApp()
  const isClient = typeof window !== 'undefined'
  const user = ref<AuthUser | null>(
    isClient ? JSON.parse(localStorage.getItem('auth_user') || 'null') : null
  )
  const token = ref(isClient ? localStorage.getItem('auth_token') || '' : '')
  const isAuthenticated = computed(() => !!token.value)

  const login = async (email: string, password: string) => {
    if (!email || !password) {
      throw new Error('Credenciales requeridas')
    }
    const { data, error } = await $supabase.auth.signInWithPassword({ email, password })
    if (error) {
      throw new Error(error.message)
    }
    token.value = data.session?.access_token || ''
    if (typeof window !== 'undefined' && token.value) {
      localStorage.setItem('auth_token', token.value)
    }
    // Obtener el rol desde metadata de Supabase Auth
    const role =
      (data.user?.user_metadata?.role as string | undefined) ||
      (data.user?.app_metadata?.role as string | undefined) ||
      'cliente'
    user.value = {
      id: data.user?.id || '',
      name: (data.user?.user_metadata?.name as string | undefined) || data.user?.email?.split('@')[0] || 'Usuario',
      email: data.user?.email || '',
      role,
      status: 'active',
    }
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_user', JSON.stringify(user.value))
    }
    // Retornar la ruta según el rol para que login.vue haga la navegación
    if (role === 'admin') return '/admin'
    if (role === 'despachador') return '/despachador'
    if (role === 'inventario') return '/inventario'
    if (role === 'porteria') return '/porteria'
    if (role === 'recibidor') return '/recibidor'
    return '/'
  }

  const logout = async () => {
    await $supabase.auth.signOut()
    user.value = null
    token.value = ''
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth_token')
      localStorage.removeItem('auth_user')
    }
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    logout,
  }
})

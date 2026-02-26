import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const MOCK_USERS: Record<
  string,
  { name: string; role: string; roleLabel: string; redirect: string; avatar: string }
> = {
  'admin@ibv.com': {
    name: 'Carlos Administrador',
    role: 'admin',
    roleLabel: 'Administrador',
    redirect: '/admin',
    avatar: 'CA',
  },
  'recibidor@ibv.com': {
    name: 'María Recibidora',
    role: 'recibidor',
    roleLabel: 'Recibidor',
    redirect: '/recibidor',
    avatar: 'MR',
  },
  'inventario@ibv.com': {
    name: 'Juan Inventario',
    role: 'inventario',
    roleLabel: 'Inventario',
    redirect: '/inventario',
    avatar: 'JI',
  },
  'despachador@ibv.com': {
    name: 'Luis Despachador',
    role: 'despachador',
    roleLabel: 'Despachador',
    redirect: '/despachador',
    avatar: 'LD',
  },
  'porteria@ibv.com': {
    name: 'Ana Portería',
    role: 'porteria',
    roleLabel: 'Portería',
    redirect: '/porteria',
    avatar: 'AP',
  },
}

interface AuthUser {
  email: string
  name: string
  role: string
  roleLabel: string
  redirect: string
  avatar: string
}

export const useAuthStore = defineStore('auth', () => {
  const isClient = typeof window !== 'undefined'
  const user = ref<AuthUser | null>(
    isClient ? JSON.parse(localStorage.getItem('auth_user') || 'null') : null
  )
  const token = ref(isClient ? localStorage.getItem('auth_token') || '' : '')
  const isAuthenticated = computed(() => !!token.value)

  const login = async (email: string, password: string) => {
    const mockUser = MOCK_USERS[email.toLowerCase()]
    if (!mockUser || password.length < 4) {
      throw new Error('Credenciales inválidas')
    }
<<<<<<< HEAD
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      throw new Error(error.message)
    }
    token.value = data.session?.access_token || ''
    if (typeof window !== 'undefined' && token.value) {
      localStorage.setItem('auth_token', token.value)
    }
    // Obtener el rol real desde el backend
    let role = 'cliente'
    const config = useRuntimeConfig()
    const BACKEND_URL = `${config.public.apiBase || 'http://localhost:8000/api'}/users/`
    try {
      const res = await fetch(`${BACKEND_URL}?email=${encodeURIComponent(email)}`, {
        headers: {
          Authorization: 'Bearer ' + (data.session?.access_token || ''),
        },
      })
      if (res.ok) {
        const users = await res.json()
        if (Array.isArray(users) && users.length > 0) {
          role = users[0].role || 'cliente'
        }
      } else {
        const errorData = await res.text()
        console.error('Error backend:', errorData)
      }
    } catch (e) {
      console.error('Error obteniendo rol desde backend:', e)
    }
    user.value = {
      id: data.user?.id || '',
      name: data.user?.email?.split('@')[0] || 'Usuario',
      email: data.user?.email || '',
      role,
      status: 'active',
    }
    // Retornar la ruta según el rol para que login.vue haga la navegación
    if (role === 'admin') return '/admin'
    if (role === 'despachador') return '/despachador'
    if (role === 'inventario') return '/inventario'
    if (role === 'porteria') return '/porteria'
    if (role === 'recibidor') return '/recibidor'
    return '/'
  }

  const logout = () => {
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

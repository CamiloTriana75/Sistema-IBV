import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const MOCK_USERS: Record<string, { name: string; role: string; roleLabel: string; redirect: string; avatar: string }> = {
  'admin@ibv.com': { name: 'Carlos Administrador', role: 'admin', roleLabel: 'Administrador', redirect: '/admin', avatar: 'CA' },
  'recibidor@ibv.com': { name: 'María Recibidora', role: 'recibidor', roleLabel: 'Recibidor', redirect: '/recibidor', avatar: 'MR' },
  'inventario@ibv.com': { name: 'Juan Inventario', role: 'inventario', roleLabel: 'Inventario', redirect: '/inventario', avatar: 'JI' },
  'despachador@ibv.com': { name: 'Luis Despachador', role: 'despachador', roleLabel: 'Despachador', redirect: '/despachador', avatar: 'LD' },
  'porteria@ibv.com': { name: 'Ana Portería', role: 'porteria', roleLabel: 'Portería', redirect: '/porteria', avatar: 'AP' },
}

export const useAuthStore = defineStore('auth', () => {
  const isClient = typeof window !== 'undefined'
  const user = ref<any>(isClient ? JSON.parse(localStorage.getItem('auth_user') || 'null') : null)
  const token = ref(isClient ? (localStorage.getItem('auth_token') || '') : '')
  const isAuthenticated = computed(() => !!token.value)

  const login = async (email: string, password: string) => {
    const mockUser = MOCK_USERS[email.toLowerCase()]
    if (!mockUser || password.length < 4) {
      throw new Error('Credenciales inválidas')
    }
    const fakeToken = btoa(`${email}:${Date.now()}`)
    token.value = fakeToken
    user.value = { email, ...mockUser }
    localStorage.setItem('auth_token', fakeToken)
    localStorage.setItem('auth_user', JSON.stringify(user.value))
    return mockUser.redirect
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
    logout
  }
})

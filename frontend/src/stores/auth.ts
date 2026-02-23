import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '~/types/index'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref(process.client ? localStorage.getItem('auth_token') || '' : '')
  const isAuthenticated = computed(() => !!token.value)

  const login = async (email: string, password: string) => {
    try {
      if (!email || !password) {
        throw new Error('Credenciales requeridas')
      }

      const fakeToken = `dev-${Date.now()}`
      token.value = fakeToken
      if (process.client) {
        localStorage.setItem('auth_token', fakeToken)
      }

      user.value = {
        id: '0',
        name: email.split('@')[0] || 'Usuario',
        email,
        role: 'admin',
        status: 'active'
      }
    } catch (error) {
      console.error('Login error:', error)
      throw error
    }
  }

  const loadUser = async () => {
    return
  }

  const logout = async () => {
    user.value = null
    token.value = ''
    if (process.client) {
      localStorage.removeItem('auth_token')
    }
    return
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    logout,
    loadUser
  }
})

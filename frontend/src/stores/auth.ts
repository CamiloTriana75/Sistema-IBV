import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('auth_token') || '')
  const isAuthenticated = ref(!!token.value)

  const login = async (email: string, password: string) => {
    try {
      // TODO: Conectar con API del backend
      console.log('Login:', email, password)
      // const response = await apiClient.post('/auth/login', { email, password })
      // token.value = response.data.token
      // user.value = response.data.user
      // localStorage.setItem('auth_token', token.value)
      // isAuthenticated.value = true
    } catch (error) {
      console.error('Login error:', error)
      throw error
    }
  }

  const logout = () => {
    user.value = null
    token.value = ''
    isAuthenticated.value = false
    localStorage.removeItem('auth_token')
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    logout
  }
})

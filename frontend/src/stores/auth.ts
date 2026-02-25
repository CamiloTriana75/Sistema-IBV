
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '~/services/supabaseClient'
import type { User } from '~/types/index'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref(process.client ? localStorage.getItem('auth_token') || '' : '')
  const isAuthenticated = computed(() => !!token.value)

  const login = async (email: string, password: string) => {
    if (!email || !password) {
      throw new Error('Credenciales requeridas')
    }
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      throw new Error(error.message)
    }
    token.value = data.session?.access_token || ''
    if (process.client && token.value) {
      localStorage.setItem('auth_token', token.value)
    }
    // Obtener el rol real desde el backend
    let role = 'cliente'
    try {
      const res = await fetch('http://localhost:8000/api/users/?email=' + encodeURIComponent(email), {
        headers: {
          'Authorization': 'Bearer ' + (data.session?.access_token || '')
        }
      })
      if (res.ok) {
        const users = await res.json()
        if (Array.isArray(users) && users.length > 0) {
          role = users[0].role || 'cliente'
        }
      }
    } catch (e) { }
    user.value = {
      id: data.user?.id || '',
      name: data.user?.email?.split('@')[0] || 'Usuario',
      email: data.user?.email || '',
      role,
      status: 'active',
    }
    // Redirección según rol
    if (role === 'admin') {
      navigateTo('/admin')
    } else if (role === 'despachador') {
      navigateTo('/despachador')
    } else if (role === 'inventario') {
      navigateTo('/inventario')
    } else if (role === 'porteria') {
      navigateTo('/porteria')
    } else if (role === 'recibidor') {
      navigateTo('/recibidor')
    } else {
      navigateTo('/')
    }
  }

  const loadUser = async () => {
    return
  }

  const logout = async () => {
    await supabase.auth.signOut()
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
    loadUser,
  }
})

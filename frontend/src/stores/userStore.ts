import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '~/types/index'

export const useUserStore = defineStore('user', () => {
  const users = ref<User[]>([])
  const roles = ref([
    { id: '1', name: 'Administrador', code: 'admin' },
    { id: '2', name: 'Porteria', code: 'porteria' },
    { id: '3', name: 'Recibidor', code: 'recibidor' },
    { id: '4', name: 'Inventario', code: 'inventario' },
    { id: '5', name: 'Despachador', code: 'despachador' },
    { id: '6', name: 'Cliente', code: 'cliente' }
  ])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const userCount = computed(() => users.value.length)
  const activeUsers = computed(() => users.value.filter(u => u.status === 'active').length)

  const seedUsers = () => {
    if (users.value.length > 0) return
    users.value = [
      { id: '1', name: 'Carlos Admin', email: 'admin@ibv.com', role: 'admin', status: 'active', createdAt: '15/01/2026' },
      { id: '2', name: 'Maria Portero', email: 'maria@ibv.com', role: 'porteria', status: 'active', createdAt: '20/01/2026' },
      { id: '3', name: 'Juan Recibidor', email: 'juan@ibv.com', role: 'recibidor', status: 'active', createdAt: '22/01/2026' },
      { id: '4', name: 'Ana Inventario', email: 'ana@ibv.com', role: 'inventario', status: 'active', createdAt: '25/01/2026' },
      { id: '5', name: 'Pedro Despacho', email: 'pedro@ibv.com', role: 'despachador', status: 'active', createdAt: '28/01/2026' },
      { id: '6', name: 'Laura Cliente', email: 'laura@ibv.com', role: 'cliente', status: 'inactive', createdAt: '01/02/2026' }
    ]
  }

  const fetchUsers = async () => {
    loading.value = true
    error.value = null
    try {
      seedUsers()
    } catch (err) {
      error.value = 'Error al cargar usuarios'
      console.error(err)
    } finally {
      loading.value = false
    }
  }

  const fetchRoles = async () => {
    try {
      return
    } catch (err) {
      console.error('Error fetching roles:', err)
    }
  }

  const createUser = async (userData: Partial<User>) => {
    loading.value = true
    error.value = null
    try {
      const newUser: User = {
        id: String(Date.now()),
        name: userData.name || 'Nuevo Usuario',
        email: userData.email || 'nuevo@ibv.com',
        role: userData.role || 'cliente',
        status: userData.status || 'active',
        createdAt: new Date().toLocaleDateString('es-ES')
      }
      users.value.push(newUser)
      return newUser
    } catch (err) {
      error.value = 'Error al crear usuario'
      console.error(err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const updateUser = async (id: string, userData: Partial<User>) => {
    loading.value = true
    error.value = null
    try {
      const index = users.value.findIndex(u => u.id === id)
      if (index !== -1) {
        users.value[index] = { ...users.value[index], ...userData }
      }
      return users.value[index]
    } catch (err) {
      error.value = 'Error al actualizar usuario'
      console.error(err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const deleteUser = async (id: string) => {
    loading.value = true
    error.value = null
    try {
      users.value = users.value.filter(u => u.id !== id)
    } catch (err) {
      error.value = 'Error al eliminar usuario'
      console.error(err)
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    users,
    roles,
    loading,
    error,
    userCount,
    activeUsers,
    fetchUsers,
    fetchRoles,
    createUser,
    updateUser,
    deleteUser
  }
})

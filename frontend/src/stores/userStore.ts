import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { userService } from '~/services/userService'
import type { User } from '~/types/index'

export const useUserStore = defineStore('user', () => {
  const users = ref<User[]>([])
  const roles = ref([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const userCount = computed(() => users.value.length)
  const activeUsers = computed(() => users.value.filter((u) => u.status === 'active').length)

  const fetchUsers = async () => {
    loading.value = true
    error.value = null
    try {
      users.value = await userService.getUsers()
    } catch (err) {
      error.value = 'Error al cargar usuarios'
      console.error(err)
    } finally {
      loading.value = false
    }
  }

  const fetchRoles = async () => {
    try {
      roles.value = await userService.getRoles()
    } catch (err) {
      console.error('Error fetching roles:', err)
    }
  }

  const createUser = async (userData: Partial<User>) => {
    loading.value = true
    error.value = null
    try {
      const newUser = await userService.createUser(userData)
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
      const updatedUser = await userService.updateUser(id, userData)
      const index = users.value.findIndex((u) => u.id === id)
      if (index !== -1) {
        users.value[index] = updatedUser
      }
      return updatedUser
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
      await userService.deleteUser(id)
      users.value = users.value.filter((u) => u.id !== id)
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
    deleteUser,
  }
})

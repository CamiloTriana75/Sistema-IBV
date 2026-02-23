import apiClient from './api'
import type { User } from '~/types/index'

export const userService = {
  async getUsers(): Promise<User[]> {
    try {
      const response = await apiClient.get('/users/')
      return response.data
    } catch (error) {
      console.error('Error fetching users:', error)
      throw error
    }
  },

  async getUser(id: string): Promise<User> {
    try {
      const response = await apiClient.get(`/users/${id}`)
      return response.data
    } catch (error) {
      console.error('Error fetching user:', error)
      throw error
    }
  },

  async createUser(data: Partial<User>): Promise<User> {
    try {
      const response = await apiClient.post('/users/', data)
      return response.data
    } catch (error) {
      console.error('Error creating user:', error)
      throw error
    }
  },

  async updateUser(id: string, data: Partial<User>): Promise<User> {
    try {
      const response = await apiClient.put(`/users/${id}`, data)
      return response.data
    } catch (error) {
      console.error('Error updating user:', error)
      throw error
    }
  },

  async deleteUser(id: string): Promise<void> {
    try {
      await apiClient.delete(`/users/${id}`)
    } catch (error) {
      console.error('Error deleting user:', error)
      throw error
    }
  },

  async getRoles() {
    try {
      const response = await apiClient.get('/roles/')
      return response.data
    } catch (error) {
      console.error('Error fetching roles:', error)
      throw error
    }
  }
}

export default userService

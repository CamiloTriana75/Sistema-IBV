// API service para comunicarse con el backend
import axios from 'axios'

const config = useRuntimeConfig()

const apiClient = axios.create({
  baseURL: config.public.apiBase,
  timeout: 10000
})

// Agregar token a cada petición
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default apiClient

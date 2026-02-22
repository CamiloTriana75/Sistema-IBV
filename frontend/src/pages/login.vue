<template>
  <div class="flex items-center justify-center min-h-screen bg-gradient-to-br from-primary-500 to-primary-700">
    <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
      <h1 class="text-3xl font-bold text-center mb-8 text-gray-800">
        Sistema IBV
      </h1>

      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
            Email
          </label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            required
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            placeholder="correo@ejemplo.com"
          />
        </div>

        <div>
          <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
            Contraseña
          </label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            required
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            placeholder="••••••••"
          />
        </div>

        <button
          type="submit"
          class="w-full bg-primary-600 hover:bg-primary-700 text-white font-semibold py-2 px-4 rounded-lg transition"
        >
          Iniciar Sesión
        </button>
      </form>

      <p class="text-center text-sm text-gray-600 mt-6">
        Contacta al administrador si no tienes cuenta
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

definePageMeta({
  layout: 'blank'
})

const form = ref({
  email: '',
  password: ''
})

const handleLogin = async () => {
  // TODO: Implementar lógica de login con backend
  console.log('Login:', form.value)
  // await navigateTo('/dashboard')
}
</script>

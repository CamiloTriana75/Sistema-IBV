<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '~/services/supabaseClient'

const email = ref('')
const password = ref('')
const error = ref('')
const success = ref('')
const router = useRouter()

const register = async () => {
  error.value = ''
  success.value = ''
  const { data, error: registerError } = await supabase.auth.signUp({
    email: email.value,
    password: password.value
  })
  if (registerError) {
    error.value = registerError.message
  } else {
    // Llamada al backend para crear el usuario en la tabla usuarios
    await fetch('http://localhost:8000/api/users/', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: email.value,
        first_name: '',
        last_name: '',
        role: 'cliente',
        password: 'supabase-auth'
      })
    })
    success.value = '¡Registro exitoso! Revisa tu correo para confirmar.'
    setTimeout(() => router.push('/login'), 2000)
  }
}
</script>

<template>
  <div class="flex min-h-screen items-center justify-center bg-gray-50">
    <form @submit.prevent="register" class="w-full max-w-md bg-white p-8 rounded-xl shadow-lg space-y-6">
      <h2 class="text-3xl font-bold text-gray-900 mb-4">Crear cuenta</h2>
      <div>
        <label class="block text-sm font-semibold text-gray-700 mb-2">Correo electrónico</label>
        <input v-model="email" type="email" required class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all placeholder-gray-400" placeholder="nombre@empresa.com" />
      </div>
      <div>
        <label class="block text-sm font-semibold text-gray-700 mb-2">Contraseña</label>
        <input v-model="password" type="password" required class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-all placeholder-gray-400" placeholder="••••••••" />
      </div>
      <button type="submit" class="w-full bg-primary-600 hover:bg-primary-700 text-white font-semibold py-3 px-4 rounded-xl transition-all">Registrarse</button>
      <div v-if="error" class="text-red-600 text-sm">{{ error }}</div>
      <div v-if="success" class="text-green-600 text-sm">{{ success }}</div>
      <p class="text-center text-sm text-gray-400 mt-4">
        ¿Ya tienes cuenta? <NuxtLink to="/login" class="text-primary-600 hover:underline">Inicia sesión</NuxtLink>
      </p>
    </form>
  </div>
</template>

<template>
  <div>
    <form @submit.prevent="login">
      <input v-model="email" type="email" placeholder="Correo" required />
      <input v-model="password" type="password" placeholder="Contraseña" required />
      <button type="submit">Iniciar sesión</button>
      <div v-if="error">{{ error }}</div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '../services/supabaseClient'

const email = ref('')
const password = ref('')
const error = ref('')

async function login() {
  error.value = ''
  const { data, error: loginError } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value,
  })
  if (loginError) {
    error.value = loginError.message
  } else {
    // Aquí puedes redirigir según el rol, usando el JWT para consultar el backend
    // Ejemplo: this.$router.push('/dashboard')
  }
}
</script>

<template>
  <div>
    <form @submit.prevent="register">
      <input v-model="email" type="email" placeholder="Correo" required />
      <input v-model="password" type="password" placeholder="Contraseña" required />
      <button type="submit">Registrarse</button>
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

async function register() {
  error.value = ''
  const { data, error: regError } = await supabase.auth.signUp({
    email: email.value,
    password: password.value,
  })
  if (regError) {
    error.value = regError.message
  } else {
    // Puedes redirigir o mostrar mensaje de éxito
  }
}
</script>

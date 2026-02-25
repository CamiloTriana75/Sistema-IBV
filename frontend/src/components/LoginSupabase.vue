<template>
  <form @submit.prevent="login">
    <div>
      <label>Email</label>
      <input v-model="email" type="email" required />
    </div>
    <div>
      <label>Contraseña</label>
      <input v-model="password" type="password" required />
    </div>
    <button type="submit">Iniciar sesión</button>
    <div v-if="error" style="color:red">{{ error }}</div>
  </form>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '~/services/supabaseClient'

const email = ref('')
const password = ref('')
const error = ref('')

const login = async () => {
  error.value = ''
  const { data, error: loginError } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: password.value
  })
  if (loginError) {
    error.value = loginError.message
  } else {
    // Usuario autenticado, puedes redirigir o guardar el token
    // Por ejemplo:
    // navigateTo('/dashboard')
    alert('¡Login exitoso!')
  }
}
</script>

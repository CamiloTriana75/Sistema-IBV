<template>
  <form @submit.prevent="register">
    <div>
      <label>Email</label>
      <input v-model="email" type="email" required />
    </div>
    <div>
      <label>Contraseña</label>
      <input v-model="password" type="password" required />
    </div>
    <button type="submit">Registrarse</button>
    <div v-if="error" style="color:red">{{ error }}</div>
    <div v-if="success" style="color:green">{{ success }}</div>
  </form>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '~/services/supabaseClient'

const email = ref('')
const password = ref('')
const error = ref('')
const success = ref('')

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
    success.value = '¡Registro exitoso! Revisa tu correo para confirmar.'
  }
}
</script>

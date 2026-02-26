import { createClient } from '@supabase/supabase-js'

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  
  const supabaseUrl = config.public.supabaseUrl
  const supabaseAnonKey = config.public.supabaseAnonKey

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Supabase URL o ANON_KEY no están configurados')
    throw new Error('Configuración de Supabase incompleta')
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey)

  return {
    provide: {
      supabase
    }
  }
})

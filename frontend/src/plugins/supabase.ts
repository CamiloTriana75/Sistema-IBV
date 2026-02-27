import { createClient } from '@supabase/supabase-js'

let supabase: ReturnType<typeof createClient>

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()

  const supabaseUrl = config.public.supabaseUrl
  const supabaseAnonKey = config.public.supabaseAnonKey

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Supabase URL o ANON_KEY no están configurados')
    throw new Error('Configuración de Supabase incompleta')
  }

  supabase = createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
      storage: typeof window !== 'undefined' ? window.localStorage : undefined,
      storageKey: 'supabase.auth.token',
    },
  })

  return {
    provide: {
      supabase,
    },
  }
})

export { supabase }

import { createClient } from '@supabase/supabase-js'

let supabase: ReturnType<typeof createClient>

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig()
  
  const supabaseUrl = config.public.supabaseUrl
  const supabaseAnonKey = config.public.supabaseAnonKey

  if (!supabaseUrl || !supabaseAnonKey) {
    console.warn('[Supabase Plugin] URL o ANON_KEY no configurados. supabaseUrl:', !!supabaseUrl, 'anonKey:', !!supabaseAnonKey)
    // No lanzar error para no romper SSR — el cliente se inicializará después
    return
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
      supabase
    }
  }
})

export { supabase }

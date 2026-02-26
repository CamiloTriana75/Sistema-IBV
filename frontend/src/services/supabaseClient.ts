import { createClient } from '@supabase/supabase-js'

// En Nuxt 3, las variables públicas se acceden desde runtime config
const config = useRuntimeConfig()
const supabaseUrl = config.public.supabaseUrl as string
const supabaseAnonKey = config.public.supabaseAnonKey as string

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Supabase URL y ANON_KEY son requeridos. Verifica las variables de entorno.')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

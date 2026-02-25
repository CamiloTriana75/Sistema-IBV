import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://qocpopgcpleijmhuznyi.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3BvcGdjcGxlaWptaHV6bnlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5ODE4NzcsImV4cCI6MjA4NzU1Nzg3N30.JtooQww0FgHQCcPtGM9aXrHL6aYRy4MWVJMMSJCfd6A'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

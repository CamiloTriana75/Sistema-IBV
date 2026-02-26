# 🚀 Configuración de Deployment

## Variables de Entorno para Render

Ve a tu proyecto en Render Dashboard: https://sistema-ibv-backend.onrender.com
**Settings > Environment** y agrega estas variables:

```bash
# Django Core
SECRET_KEY=6mm4y8j_s#ik432=8xutszy^lnyh(z)+vs8ygbrqr+-)rkxtci
DEBUG=False
ALLOWED_HOSTS=sistema-ibv-backend.onrender.com

# Database (Supabase PostgreSQL)
DATABASE_URL=postgresql://postgres.qocpopgcpleijmhuznyi:Deicastillo321.@aws-0-us-west-2.pooler.supabase.com:6543/postgres

# CORS
CORS_ALLOW_ALL_ORIGINS=False
CORS_ALLOWED_ORIGINS=https://sistema-drindeyfs-camilos-projects-9cf6fda2.vercel.app

# Supabase
SUPABASE_URL=https://qocpopgcpleijmhuznyi.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3BvcGdjcGxlaWptaHV6bnlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5ODE4NzcsImV4cCI6MjA4NzU1Nzg3N30.JtooQww0FgHQCcPtGM9aXrHL6aYRy4MWVJMMSJCfd6A
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3BvcGdjcGxlaWptaHV6bnlpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTk4MTg3NywiZXhwIjoyMDg3NTU3ODc3fQ.tJydVDAkC_04HqnDT9FXlxpoMoE1DTm-y3OcPkeJQ3Y

# Timezone
TZ=America/Bogota
LOG_LEVEL=INFO
```

## Variables de Entorno para Vercel

Ve a tu proyecto en Vercel Dashboard:
**Settings > Environment Variables** y agrega:

```bash
# API Backend
NUXT_PUBLIC_API_BASE=https://sistema-ibv-backend.onrender.com/api

# Supabase (Frontend)
NUXT_PUBLIC_SUPABASE_URL=https://qocpopgcpleijmhuznyi.supabase.co
NUXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFvY3BvcGdjcGxlaWptaHV6bnlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5ODE4NzcsImV4cCI6MjA4NzU1Nzg3N30.JtooQww0FgHQCcPtGM9aXrHL6aYRy4MWVJMMSJCfd6A
```

**IMPORTANTE**: Aplica estas variables a:
- ✅ **Production** (obligatorio)
- ✅ **Preview** (recomendado)
- ⬜ Development (opcional)

## Verificación de Deployment

### Backend (Render)
```bash
# Prueba la API
curl https://sistema-ibv-backend.onrender.com/api/users/

# Verifica el admin
curl https://sistema-ibv-backend.onrender.com/admin/
```

### Frontend (Vercel)
Abre en navegador:
```
https://sistema-drindeyfs-camilos-projects-9cf6fda2.vercel.app
```

## Re-deploy después de configurar variables

### En Render:
1. Settings > Manual Deploy > "Deploy latest commit"
2. O hacer push a tu rama principal

### En Vercel:
1. Deployments > Latest > "Redeploy"
2. O simplemente espera (auto-redeploy al configurar variables)

## Comandos Git para deployment

```bash
# Agregar cambios
git add .

# Commit con mensaje descriptivo
git commit -m "feat: actualizar configuración de .env para producción"

# Push a GitHub (activa auto-deploy)
git push origin main
```

## Notas de Seguridad

⚠️ **NUNCA** commitear archivos .env al repositorio
✅ Los archivos .env ya están en .gitignore
✅ SECRET_KEY y SUPABASE_SERVICE_KEY son confidenciales
✅ Solo SUPABASE_ANON_KEY es segura para exponer públicamente

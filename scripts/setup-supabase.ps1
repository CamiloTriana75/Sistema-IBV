# Script de Verificación y Configuración de Supabase
# Sistema IBV - PostgreSQL Setup

# Colores para output
$ErrorActionPreference = "Continue"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️  $Message" "Cyan"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️  $Message" "Yellow"
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n▶️  $Message" "Magenta"
}

# Banner
Write-Host "`n" -NoNewline
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Blue"
Write-ColorOutput "   Sistema IBV - Configuración de Supabase PostgreSQL" "Blue"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Blue"
Write-Host "`n"

# 1. Verificar ubicación
Write-Step "Verificando ubicación del proyecto..."
$currentPath = Get-Location
if (-not (Test-Path ".\backend\manage.py")) {
    Write-Error "No se encontró manage.py en .\backend\"
    Write-Info "Por favor, ejecuta este script desde la raíz del proyecto (C:\Users\Deibyd\Sistema-IBV)"
    exit 1
}
Write-Success "Ubicación correcta: $currentPath"

# 2. Verificar Python
Write-Step "Verificando instalación de Python..."
try {
    $pythonVersion = python --version 2>&1
    Write-Success "Python encontrado: $pythonVersion"
} catch {
    Write-Error "Python no encontrado. Por favor instala Python 3.12+"
    exit 1
}

# 3. Verificar archivo .env
Write-Step "Verificando archivo .env..."
if (-not (Test-Path ".\.env")) {
    Write-Warning "Archivo .env no encontrado"
    Write-Info "Creando .env desde .env.example..."

    if (Test-Path ".\.env.example") {
        Copy-Item ".\.env.example" ".\.env"
        Write-Success "Archivo .env creado"
        Write-Warning "⚠️  IMPORTANTE: Edita .env con tus credenciales de Supabase"
        Write-Info "DATABASE_URL=postgresql://postgres.xxxxx:[PASSWORD]@..."
    } else {
        Write-Error ".env.example no encontrado"
        exit 1
    }
} else {
    Write-Success "Archivo .env encontrado"
}

# 4. Verificar DATABASE_URL
Write-Step "Verificando configuración de DATABASE_URL..."
if ($env:DATABASE_URL) {
    $dbUrl = $env:DATABASE_URL
    if ($dbUrl -like "*postgresql://*") {
        Write-Success "DATABASE_URL configurado para PostgreSQL"
        Write-Info "Host: $(($dbUrl -split '@')[1] -split ':' | Select-Object -First 1)"
    } elseif ($dbUrl -like "*sqlite*") {
        Write-Warning "DATABASE_URL apunta a SQLite"
        Write-Info "Cambia DATABASE_URL en .env para usar Supabase"
    }
} else {
    Write-Info "DATABASE_URL no encontrado en variables de entorno"
    Write-Info "Django lo leerá desde .env"
}

# 5. Verificar dependencias
Write-Step "Verificando dependencias de Python..."
$requiredPackages = @("django", "psycopg2", "djangorestframework", "python-decouple", "dj-database-url")
$missingPackages = @()

foreach ($package in $requiredPackages) {
    try {
        $result = python -c "import $($package.Replace('-', '_'))" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$package instalado"
        } else {
            $missingPackages += $package
            Write-Error "$package NO instalado"
        }
    } catch {
        $missingPackages += $package
        Write-Error "$package NO instalado"
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Warning "`nFaltan paquetes por instalar"
    Write-Info "Ejecuta: pip install -r requirements.txt"
}

# 6. Verificar conectividad a base de datos (si está configurado)
Write-Step "Verificando conectividad a base de datos..."
Set-Location ".\backend"
try {
    $checkDb = python manage.py check --database default 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Configuración de base de datos válida"
    } else {
        Write-Warning "Problemas con configuración de base de datos"
        Write-Info $checkDb
    }
} catch {
    Write-Warning "No se pudo verificar la base de datos"
}

# 7. Verificar migraciones
Write-Step "Verificando estado de migraciones..."
try {
    $migrations = python manage.py showmigrations --plan 2>&1
    if ($LASTEXITCODE -eq 0) {
        $unapplied = $migrations | Select-String "\[ \]"
        if ($unapplied) {
            Write-Warning "Hay migraciones pendientes"
            Write-Info "Ejecuta: python manage.py migrate"
        } else {
            Write-Success "Todas las migraciones aplicadas"
        }
    }
} catch {
    Write-Warning "No se pudo verificar migraciones"
}

# 8. Mostrar siguiente pasos
Write-Host "`n"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Blue"
Write-ColorOutput "   SIGUIENTES PASOS" "Blue"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Blue"
Write-Host "`n"

Write-Info "1. Configura tus credenciales de Supabase en .env"
Write-Info "   - DATABASE_URL"
Write-Info "   - SUPABASE_URL"
Write-Info "   - SUPABASE_ANON_KEY"
Write-Info "   - SUPABASE_SERVICE_KEY"
Write-Host ""

Write-Info "2. Instala dependencias (si falta alguna):"
Set-Location ".."
Write-ColorOutput "   pip install -r requirements.txt" "Yellow"
Write-Host ""

Write-Info "3. Ejecuta las migraciones:"
Write-ColorOutput "   cd backend" "Yellow"
Write-ColorOutput "   python manage.py migrate" "Yellow"
Write-Host ""

Write-Info "4. Crea un superusuario:"
Write-ColorOutput "   python manage.py createsuperuser" "Yellow"
Write-Host ""

Write-Info "5. Inicia el servidor:"
Write-ColorOutput "   python manage.py runserver" "Yellow"
Write-Host ""

Write-Info "6. Verifica el admin:"
Write-ColorOutput "   http://127.0.0.1:8000/admin/" "Yellow"
Write-Host "`n"

Write-ColorOutput "═══════════════════════════════════════════════════════════" "Blue"
Write-ColorOutput "   DOCUMENTACIÓN" "Blue"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Blue"
Write-Host "`n"

Write-Info "📚 Guía completa:"
Write-ColorOutput "   docs\SUPABASE_SETUP_GUIDE.md" "Yellow"
Write-Host ""

Write-Info "🚀 Inicio rápido:"
Write-ColorOutput "   docs\SUPABASE_QUICK_START.md" "Yellow"
Write-Host ""

Write-Info "🔒 Políticas RLS:"
Write-ColorOutput "   docs\SUPABASE_RLS_POLICIES.md" "Yellow"
Write-Host "`n"

Write-Success "¡Script de verificación completado!"
Write-Host "`n"

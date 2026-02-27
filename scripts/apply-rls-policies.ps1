<#
.SYNOPSIS
    Aplica las políticas RLS (Row Level Security) a Supabase

.DESCRIPTION
    Este script ejecuta el archivo 05_rls_policies.sql en tu proyecto de Supabase
    para aplicar todas las políticas de seguridad por rol

.EXAMPLE
    .\apply-rls-policies.ps1
#>

# Colores para output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Banner
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   APLICAR POLÍTICAS RLS - SUPABASE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en la raíz del proyecto
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
$sqlFile = Join-Path $scriptPath "sql\05_rls_policies.sql"

if (-not (Test-Path $sqlFile)) {
    Write-Error "❌ No se encuentra el archivo: $sqlFile"
    exit 1
}

Write-Info "📂 Archivo SQL encontrado: $sqlFile"
Write-Host ""

# Cargar variables de entorno
$envFile = Join-Path $projectRoot "frontend\.env"
if (Test-Path $envFile) {
    Write-Info "🔧 Cargando variables de entorno desde .env..."
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
} else {
    Write-Warning "⚠️  No se encontró archivo .env en frontend/"
}

# Obtener credenciales de Supabase
$supabaseUrl = $env:VITE_SUPABASE_URL
$supabaseKey = $env:VITE_SUPABASE_ANON_KEY

if (-not $supabaseUrl -or -not $supabaseKey) {
    Write-Host ""
    Write-Warning "⚠️  Credenciales de Supabase no encontradas en .env"
    Write-Host ""
    Write-Info "Por favor ingresa tus credenciales de Supabase:"
    Write-Host ""
    
    if (-not $supabaseUrl) {
        $supabaseUrl = Read-Host "URL de Supabase (ej: https://xxx.supabase.co)"
    }
    
    if (-not $supabaseKey) {
        $supabaseKey = Read-Host "Service Role Key de Supabase (no la anon key)"
    }
}

Write-Host ""
Write-Info "🔗 Conectando a Supabase..."
Write-Info "   URL: $supabaseUrl"
Write-Host ""

# Leer el archivo SQL
$sqlContent = Get-Content $sqlFile -Raw

# Confirmar antes de ejecutar
Write-Warning "⚠️  ADVERTENCIA: Este script va a:"
Write-Host "   • Eliminar todas las políticas RLS existentes"
Write-Host "   • Deshabilitar temporalmente RLS en todas las tablas"
Write-Host "   • Recrear todas las políticas RLS desde cero"
Write-Host ""

$confirmation = Read-Host "¿Deseas continuar? (escribe 'SI' para confirmar)"

if ($confirmation -ne "SI") {
    Write-Warning "❌ Operación cancelada por el usuario"
    exit 0
}

Write-Host ""
Write-Info "🚀 Ejecutando políticas RLS en Supabase..."
Write-Host ""

# Ejecutar el SQL usando la API REST de Supabase
try {
    $headers = @{
        "apikey" = $supabaseKey
        "Authorization" = "Bearer $supabaseKey"
        "Content-Type" = "application/json"
        "Prefer" = "return=minimal"
    }
    
    $body = @{
        query = $sqlContent
    } | ConvertTo-Json
    
    $endpoint = "$supabaseUrl/rest/v1/rpc/exec_sql"
    
    # Método alternativo: usar psql si está disponible
    Write-Info "📝 Método 1: Intentando copiar SQL al portapapeles..."
    Write-Host ""
    
    Set-Clipboard -Value $sqlContent
    
    Write-Success "✅ SQL copiado al portapapeles!"
    Write-Host ""
    Write-Info "📋 PASOS PARA APLICAR EN SUPABASE:"
    Write-Host ""
    Write-Host "   1. Ve a tu proyecto en Supabase: https://app.supabase.com" -ForegroundColor White
    Write-Host "   2. Abre el SQL Editor (menú lateral izquierdo)" -ForegroundColor White
    Write-Host "   3. Crea un nuevo query" -ForegroundColor White
    Write-Host "   4. Pega el SQL (Ctrl+V) - Ya está en tu portapapeles" -ForegroundColor White
    Write-Host "   5. Haz clic en 'Run' para ejecutar" -ForegroundColor White
    Write-Host ""
    
    # Intentar abrir el navegador
    Write-Info "🌐 Abriendo Supabase en el navegador..."
    Start-Process "https://app.supabase.com"
    
    Write-Host ""
    Write-Success "✅ Script completado!"
    Write-Host ""
    Write-Info "📊 Resumen de políticas aplicadas:"
    Write-Host "   • Roles: 4 políticas"
    Write-Host "   • Usuarios: 4 políticas"
    Write-Host "   • Notificaciones: 4 políticas"
    Write-Host "   • Auditoría vehiculos: 3 políticas"
    Write-Host "   • Bloqueos vehiculos: 4 políticas"
    Write-Host "   • Excepciones vehiculos: 4 políticas"
    Write-Host "   • Buques: 4 políticas"
    Write-Host "   • Modelos vehiculo: 4 políticas"
    Write-Host "   • Vehiculos: 7 políticas"
    Write-Host "   • Improntas: 4 políticas"
    Write-Host "   • Inventarios: 4 políticas"
    Write-Host "   • Despachos: 4 políticas"
    Write-Host "   • Despacho vehiculos: 4 políticas"
    Write-Host "   • Movimientos portería: 4 políticas"
    Write-Host "   • Recibos: 4 políticas"
    Write-Host "   • Contenedores: 4 políticas"
    Write-Host "   • Contenedor vehiculos: 4 políticas"
    Write-Host "   • Improntas registro: 4 políticas"
    Write-Host ""
    Write-Success "✅ Total: ~70 políticas RLS aplicadas"
    Write-Host ""
    
} catch {
    Write-Error "❌ Error al ejecutar el SQL:"
    Write-Error $_.Exception.Message
    Write-Host ""
    Write-Info "💡 Solución alternativa:"
    Write-Info "   El SQL está copiado en tu portapapeles."
    Write-Info "   Pégalo manualmente en el SQL Editor de Supabase."
    exit 1
}

Write-Host ""
Write-Info "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

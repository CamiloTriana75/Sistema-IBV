# Pre-commit Backend Verification Script
# Sistema IBV - Backend Quality Checks

Write-Host "Sistema IBV - Backend Pre-Commit Checks" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$WarningCount = 0

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "backend")) {
    Write-Host "ERROR: Este script debe ejecutarse desde la raiz del proyecto" -ForegroundColor Red
    exit 1
}

# Verificar que el entorno virtual está activado
if (-not $env:VIRTUAL_ENV) {
    Write-Host "ADVERTENCIA: El entorno virtual no esta activado" -ForegroundColor Yellow
    Write-Host "Ejecuta: .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
    Write-Host ""
    $WarningCount++
}

# 1. Verificar dependencias de desarrollo
Write-Host "1. Verificando dependencias de desarrollo..." -ForegroundColor Blue
try {
    python -c "import black, flake8, pytest, coverage" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   OK - Dependencias de desarrollo instaladas" -ForegroundColor Green
        Write-Host ""
    }
    else {
        Write-Host "   Instalando dependencias de desarrollo..." -ForegroundColor Yellow
        pip install -q -r requirements-dev.txt
        Write-Host "   OK - Dependencias instaladas" -ForegroundColor Green
        Write-Host ""
    }
}
catch {
    Write-Host "   ERROR instalando dependencias" -ForegroundColor Red
    Write-Host ""
    $ErrorCount++
}

# 2. Black - Formateo de código
Write-Host "2. Black - Verificando formato de codigo..." -ForegroundColor Blue
$blackOutput = python -m black --check backend/ 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Codigo correctamente formateado" -ForegroundColor Green
}
else {
    Write-Host "   ADVERTENCIA - Archivos que necesitan formateo" -ForegroundColor Yellow
    Write-Host "   Ejecuta: python -m black backend/" -ForegroundColor Cyan
    $WarningCount++
}
Write-Host ""

# 3. Flake8 - Linting
Write-Host "3. Flake8 - Analisis estatico de codigo..." -ForegroundColor Blue
$flake8Output = python -m flake8 backend/ --statistics 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Sin problemas de linting" -ForegroundColor Green
}
else {
    Write-Host "   ADVERTENCIA - Problemas encontrados:" -ForegroundColor Yellow
    Write-Host $flake8Output
    $WarningCount++
}
Write-Host ""

# 4. Verificar migraciones
Write-Host "4. Verificando migraciones de Django..." -ForegroundColor Blue
Push-Location backend
$env:SECRET_KEY = "test-key-for-checks"
$env:DEBUG = "False"
$env:DATABASE_URL = "sqlite:///db.sqlite3"

$migrationOutput = python manage.py makemigrations --check --dry-run --no-input 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - No hay migraciones pendientes" -ForegroundColor Green
}
else {
    Write-Host "   ADVERTENCIA - Hay migraciones pendientes" -ForegroundColor Yellow
    Write-Host "   Ejecuta: python manage.py makemigrations" -ForegroundColor Cyan
    $WarningCount++
}
Pop-Location
Write-Host ""

# 5. Tests
Write-Host "5. Ejecutando tests..." -ForegroundColor Blue
Push-Location backend
$testOutput = python manage.py test --no-input 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Todos los tests pasaron" -ForegroundColor Green
}
else {
    Write-Host "   ERROR - Algunos tests fallaron" -ForegroundColor Red
    Write-Host $testOutput
    $ErrorCount++
}
Pop-Location
Write-Host ""

# 6. Coverage
Write-Host "6. Generando reporte de cobertura..." -ForegroundColor Blue
Push-Location backend
python -m coverage run --source='.' manage.py test --no-input 2>&1 | Out-Null
$coverageOutput = python -m coverage report 2>&1
Write-Host $coverageOutput
Pop-Location
Write-Host ""

# Resumen
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resumen de verificaciones" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "OK - Todo perfecto! Puedes hacer commit con confianza." -ForegroundColor Green
    exit 0
}
elseif ($ErrorCount -eq 0) {
    Write-Host "ADVERTENCIA - $WarningCount advertencia(s) encontrada(s)" -ForegroundColor Yellow
    Write-Host "Revisa los problemas antes de hacer commit." -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "ERROR - $ErrorCount error(es) critico(s) encontrado(s)" -ForegroundColor Red
    Write-Host "Corrige los problemas antes de hacer commit." -ForegroundColor Red
    exit 1
}

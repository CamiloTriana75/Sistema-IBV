# Pre-commit Frontend Verification Script
# Sistema IBV - Frontend Quality Checks

Write-Host "Sistema IBV - Frontend Pre-Commit Checks" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$WarningCount = 0

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "frontend")) {
    Write-Host "ERROR: Este script debe ejecutarse desde la raiz del proyecto" -ForegroundColor Red
    exit 1
}

Push-Location frontend

# 1. Verificar que node_modules existe
Write-Host "1. Verificando dependencias de Node.js..." -ForegroundColor Blue
if (-not (Test-Path "node_modules")) {
    Write-Host "   Instalando dependencias..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ERROR - No se pudieron instalar las dependencias" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Write-Host "   OK - Dependencias instaladas" -ForegroundColor Green
} else {
    Write-Host "   OK - Dependencias ya instaladas" -ForegroundColor Green
}
Write-Host ""

# 2. ESLint
Write-Host "2. ESLint - Analisis estatico de codigo..." -ForegroundColor Blue
$eslintOutput = npm run lint 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Sin problemas de linting" -ForegroundColor Green
} else {
    Write-Host "   ADVERTENCIA - Problemas encontrados:" -ForegroundColor Yellow
    Write-Host $eslintOutput
    Write-Host "   Ejecuta: npm run lint:fix" -ForegroundColor Cyan
    $WarningCount++
}
Write-Host ""

# 3. Prettier
Write-Host "3. Prettier - Verificando formato de codigo..." -ForegroundColor Blue
$prettierOutput = npm run format:check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Codigo correctamente formateado" -ForegroundColor Green
} else {
    Write-Host "   ADVERTENCIA - Archivos que necesitan formateo" -ForegroundColor Yellow
    Write-Host "   Ejecuta: npm run format" -ForegroundColor Cyan
    $WarningCount++
}
Write-Host ""

# 4. Type Check
Write-Host "4. TypeScript - Verificando tipos..." -ForegroundColor Blue
$typeCheckOutput = npm run type-check 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Sin errores de tipos" -ForegroundColor Green
} else {
    Write-Host "   ERROR - Errores de TypeScript encontrados:" -ForegroundColor Red
    Write-Host $typeCheckOutput
    $ErrorCount++
}
Write-Host ""

# 5. Build
Write-Host "5. Build - Compilando proyecto..." -ForegroundColor Blue
$buildOutput = npm run build 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Build exitoso" -ForegroundColor Green
} else {
    Write-Host "   ERROR - El build fallo:" -ForegroundColor Red
    Write-Host $buildOutput
    $ErrorCount++
}
Write-Host ""

# 6. Tests (si existen)
Write-Host "6. Tests - Ejecutando pruebas..." -ForegroundColor Blue
$testOutput = npm run test --if-present 2>&1
if ($LASTEXITCODE -eq 0 -or $testOutput -match "missing script") {
    if ($testOutput -match "missing script") {
        Write-Host "   INFO - No hay tests configurados (opcional)" -ForegroundColor Gray
    } else {
        Write-Host "   OK - Todos los tests pasaron" -ForegroundColor Green
    }
} else {
    Write-Host "   ERROR - Algunos tests fallaron:" -ForegroundColor Red
    Write-Host $testOutput
    $ErrorCount++
}
Write-Host ""

Pop-Location

# Resumen
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resumen de verificaciones" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "OK - Todo perfecto! Puedes hacer commit con confianza." -ForegroundColor Green
    exit 0
} elseif ($ErrorCount -eq 0) {
    Write-Host "ADVERTENCIA - $WarningCount advertencia(s) encontrada(s)" -ForegroundColor Yellow
    Write-Host "Revisa los problemas antes de hacer commit." -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "ERROR - $ErrorCount error(es) critico(s) encontrado(s)" -ForegroundColor Red
    Write-Host "Corrige los problemas antes de hacer commit." -ForegroundColor Red
    exit 1
}

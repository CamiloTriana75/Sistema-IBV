# Script para hacer commit de Sprint 0 sin depender del terminal corrupto
Set-Location "C:\Users\Johan Beltrán\Desktop\Sistema IBV"

# Limpiar merge state
$MERGE_HEAD = ".git\MERGE_HEAD"
if (Test-Path $MERGE_HEAD) {
    Remove-Item $MERGE_HEAD -Force -ErrorAction SilentlyContinue
    Remove-Item ".git\MERGE_MODE" -Force -ErrorAction SilentlyContinue
    Remove-Item ".git\MERGE_MSG" -Force -ErrorAction SilentlyContinue
    Write-Host "Merge state cleaned"
}

# Stage frontend changes
& git add frontend/

# Create commit
& git commit -m "feat: sprint 0 - inicialización frontend nuxt 3 + tailwindcss - completo y testeable"

# Show result
$status = & git status --short
Write-Host "Git Status:"
Write-Host $status
Write-Host ""
Write-Host "✅ Sprint 0 Commit Completed"

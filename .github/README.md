# Backend CI/CD Pipeline

Este directorio contiene la configuración del pipeline de CI/CD para el backend del Sistema IBV.

## 🚀 Workflow: Backend CI

El workflow `backend-ci.yml` se ejecuta automáticamente en los siguientes casos:

- **Push** a las ramas `develop` o `main` que modifiquen:
  - Archivos en `backend/`
  - `requirements.txt`
  - El propio workflow

- **Pull Requests** hacia `develop` o `main` con los mismos criterios

## 📋 Pasos del Pipeline

1. **Checkout del código**
2. **Configuración de Python** (3.12 y 3.13)
3. **Instalación de dependencias**
4. **Black** - Verificación de formato de código
5. **Flake8** - Análisis estático (linting)
6. **Verificación de migraciones** - Detecta migraciones pendientes
7. **Tests** - Ejecución de pruebas unitarias
8. **Coverage** - Generación de reporte de cobertura

## 🔧 Ejecutar verificaciones localmente

### Antes de hacer commit

```bash
# Activar entorno virtual
.\venv\Scripts\Activate.ps1

# Instalar dependencias de desarrollo
pip install -r requirements-dev.txt

# Formatear código con Black
black backend/

# Verificar con Flake8
flake8 backend/

# Verificar migraciones
cd backend
python manage.py makemigrations --check --dry-run

# Ejecutar tests
python manage.py test

# Ejecutar tests con coverage
coverage run --source='.' manage.py test
coverage report
```

### Script automatizado

Puedes usar el script de pre-commit para ejecutar todas las verificaciones:

```bash
.\scripts\pre-commit-backend.ps1
```

## 📊 Coverage

El pipeline genera reportes de cobertura de código y los sube a Codecov (opcional).

- **Mínimo recomendado:** 80% de cobertura
- Los reportes HTML se generan en `backend/htmlcov/`

## ⚙️ Configuración

### Black
Configurado en `pyproject.toml`:
- Longitud de línea: 88 caracteres
- Target: Python 3.12+

### Flake8
Configurado en `.flake8`:
- Longitud de línea: 88 (compatible con Black)
- Excluye migraciones y archivos generados
- Complejidad ciclomática máxima: 10

### Pytest
Configurado en `pyproject.toml`:
- Cobertura automática habilitada
- Reportes en terminal, HTML y XML

## 🔍 Troubleshooting

### Error: "Black would make changes"
```bash
# Ejecutar Black para formatear el código
black backend/
```

### Error: "Flake8 found issues"
```bash
# Ver detalles de los problemas
flake8 backend/ --show-source --statistics
```

### Error: "You have unapplied migrations"
```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

### Tests fallan localmente
```bash
# Verificar que las variables de entorno estén configuradas
# Asegurarse de que la BD de pruebas esté limpia
cd backend
python manage.py test --debug-mode
```

## 📚 Referencias

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Black Documentation](https://black.readthedocs.io/)
- [Flake8 Documentation](https://flake8.pycqa.org/)
- [Django Testing](https://docs.djangoproject.com/en/stable/topics/testing/)
- [Coverage.py](https://coverage.readthedocs.io/)

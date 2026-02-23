# Backend - Sistema IBV

API RESTful para el Sistema de Inventario y Despacho de Vehículos en Bodegas.

## Tecnologías

- **Django 5+** - Framework web
- **Django REST Framework (DRF)** - API RESTful
- **PostgreSQL (Supabase)** - Base de datos
- **JWT** - Autenticación
- **Python 3.12/3.13** - Lenguaje

## Estructura del proyecto

```
backend/
├── config/              # Configuración del proyecto Django
│   ├── settings.py     # Configuración principal
│   ├── urls.py         # URLs principales
│   ├── api_urls.py     # URLs de la API
│   └── wsgi.py         # WSGI para deployment
├── users/              # App de usuarios y autenticación
├── manage.py           # CLI de Django
└── db.sqlite3          # BD local (desarrollo)
```

## Instalación

### 1. Requisitos previos

- Python 3.12 o superior
- pip
- PostgreSQL (Supabase para producción)

### 2. Instalar dependencias

```bash
# Desde la raíz del proyecto
pip install -r requirements.txt

# Dependencias de desarrollo (linting, testing)
pip install -r requirements-dev.txt
```

### 3. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
# Django
SECRET_KEY=tu-secret-key-aqui
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database (Supabase)
DATABASE_URL=postgresql://user:password@host:5432/dbname

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8000
```

### 4. Ejecutar migraciones

```bash
cd backend
python manage.py migrate
```

### 5. Crear superusuario

```bash
python manage.py createsuperuser
```

### 6. Ejecutar servidor de desarrollo

```bash
python manage.py runserver
```

La API estará disponible en: http://localhost:8000/api/

## Desarrollo

### Herramientas de calidad de código

Este proyecto usa las siguientes herramientas:

- **Black** - Formateador de código
- **Flake8** - Linter
- **pytest** - Framework de testing
- **Coverage** - Cobertura de código

### Ejecutar herramientas localmente

```bash
# Formatear código con Black
black backend/

# Verificar formato sin modificar (útil para CI)
black --check backend/

# Linter con Flake8
flake8 backend/ --statistics

# Ejecutar tests
cd backend
python manage.py test

# Tests con pytest (alternativa)
pytest

# Generar reporte de cobertura
coverage run --source='.' manage.py test
coverage report
coverage html  # Genera reporte HTML en htmlcov/
```

### Script de pre-commit

Ejecuta todas las verificaciones antes de hacer commit:

```bash
.\scripts\pre-commit-backend.ps1
```

Este script ejecuta:
1. ✅ Instalación de dependencias
2. 🎨 Black (formato)
3. 🔎 Flake8 (linting)
4. 🗄️ Verificación de migraciones
5. 🧪 Tests
6. 📊 Cobertura de código

### Configuración en VS Code

El proyecto incluye configuración recomendada para VS Code:

- `.vscode/settings.json` - Formateo automático con Black
- `.vscode/extensions.json` - Extensiones recomendadas

Las extensiones recomendadas son:
- Python (ms-python.python)
- Black Formatter (ms-python.black-formatter)
- Flake8 (ms-python.flake8)
- Django (batisteo.vscode-django)

## Pipeline CI/CD

El proyecto tiene configurado GitHub Actions para CI/CD automático.

### Workflow: Backend CI

Se ejecuta en:
- Push a `develop` o `main`
- Pull Requests hacia `develop` o `main`

Verifica:
1. Instalación de dependencias
2. Formato de código (Black)
3. Linting (Flake8)
4. Migraciones pendientes
5. Tests unitarios
6. Cobertura de código

Ver documentación completa en: [.github/README.md](../.github/README.md)

## API Documentation

La documentación de la API se genera automáticamente con **drf-spectacular**.

### Endpoints de documentación

- **Swagger UI**: http://localhost:8000/api/schema/swagger-ui/
- **ReDoc**: http://localhost:8000/api/schema/redoc/
- **OpenAPI Schema**: http://localhost:8000/api/schema/

### Ejemplo de llamada a la API

```bash
# Obtener token JWT
curl -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

# Usar token en request
curl -X GET http://localhost:8000/api/vehicles/ \
  -H "Authorization: Bearer <tu-token-aqui>"
```

## Testing

### Estructura de tests

```
backend/
└── <app_name>/
    └── tests/
        ├── __init__.py
        ├── test_models.py
        ├── test_views.py
        └── test_serializers.py
```

### Ejemplo de test

```python
from django.test import TestCase
from rest_framework.test import APIClient

class VehicleAPITestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
    
    def test_list_vehicles(self):
        response = self.client.get('/api/vehicles/')
        self.assertEqual(response.status_code, 200)
```

### Ejecutar tests específicos

```bash
# Todos los tests de una app
python manage.py test users

# Test específico
python manage.py test users.tests.test_models.UserModelTestCase

# Con verbose
python manage.py test --verbosity=2
```

## Comandos útiles

```bash
# Crear una nueva app
python manage.py startapp nombre_app

# Crear migraciones
python manage.py makemigrations

# Ver SQL de migraciones
python manage.py sqlmigrate app_name migration_number

# Shell de Django
python manage.py shell

# Shell con iPython (recomendado)
python manage.py shell_plus  # Requiere django-extensions

# Limpiar BD de pruebas
python manage.py flush --no-input

# Generar schema OpenAPI
python manage.py spectacular --file schema.yml
```

## Troubleshooting

### Error: "No module named 'django'"

```bash
# Verifica que el entorno virtual esté activado
.\venv\Scripts\Activate.ps1

# Reinstala dependencias
pip install -r requirements.txt
```

### Error: "ERRORS: settings.DATABASE_URL"

```bash
# Verifica que el archivo .env existe y tiene DATABASE_URL
# Para desarrollo local, puedes usar SQLite:
DATABASE_URL=sqlite:///db.sqlite3
```

### Tests fallan con "Access denied"

```bash
# Verifica que la BD de pruebas se pueda crear
# Django crea una BD temporal automáticamente
# Asegúrate de tener permisos en PostgreSQL
```

### Black modifica archivos de migración

```bash
# Black está configurado para ignorar migraciones
# Verifica que .flake8 y pyproject.toml están en la raíz
```

## Recursos

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [drf-spectacular](https://drf-spectacular.readthedocs.io/)
- [Black](https://black.readthedocs.io/)
- [Flake8](https://flake8.pycqa.org/)
- [pytest-django](https://pytest-django.readthedocs.io/)

## Contribuir

1. Crea una rama desde `develop`
2. Desarrolla tu feature/fix
3. Ejecuta el script de pre-commit: `.\scripts\pre-commit-backend.ps1`
4. Haz commit con mensajes convencionales
5. Crea un Pull Request hacia `develop`

Ver guía completa de contribución en [README.md](../README.md)

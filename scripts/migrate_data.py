#!/usr/bin/env python
"""
Script de Migración de Datos SQLite a PostgreSQL
Sistema IBV - Database Migration Tool

PROPÓSITO:
    Migrar datos de SQLite local a PostgreSQL (Supabase)
    preservando relaciones e integridad de datos

CUÁNDO USAR:
    - Cuando tienes datos en db.sqlite3 que necesitas en producción
    - Para migración de desarrollo a staging/producción

PREREQUISITOS:
    - Base de datos SQLite con datos existentes
    - PostgreSQL configurado con migraciones aplicadas
    - Variables de entorno configuradas (.env)

USO:
    python scripts/migrate_data.py [opciones]

OPCIONES:
    --dry-run     Simular migración sin aplicar cambios
    --backup      Crear backup antes de migrar
    --verbose     Mostrar información detallada

EJEMPLO:
    # Migración con backup y modo verbose
    python scripts/migrate_data.py --backup --verbose

    # Simular migración (no aplica cambios)
    python scripts/migrate_data.py --dry-run

VERSIÓN: 1.0.0
FECHA: 2026-02-24
"""

import os
import sys
import argparse
import json
from datetime import datetime
from pathlib import Path

# Agregar path del backend para imports de Django
BACKEND_DIR = Path(__file__).resolve().parent.parent / 'backend'
sys.path.insert(0, str(BACKEND_DIR))

# Setup de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

try:
    import django
    django.setup()
except Exception as e:
    print(f"❌ Error configurando Django: {e}")
    sys.exit(1)

from django.core.management import call_command
from django.db import connection, connections
from django.conf import settings
from io import StringIO


class MigrationTool:
    """Herramienta para migración de datos"""

    def __init__(self, dry_run=False, verbose=False, backup=False):
        self.dry_run = dry_run
        self.verbose = verbose
        self.backup = backup
        self.backup_file = None

    def print_banner(self):
        """Mostrar banner inicial"""
        print()
        print("╔════════════════════════════════════════════════════════╗")
        print("║  MIGRACIÓN DE DATOS - SQLITE → POSTGRESQL              ║")
        print("╚════════════════════════════════════════════════════════╝")
        print()

        if self.dry_run:
            print("⚠️  MODO DRY-RUN: No se aplicarán cambios")
        if self.verbose:
            print("ℹ️  Modo verbose activado")
        print()

    def check_databases(self):
        """Verificar configuración de bases de datos"""
        print("▶ Verificando configuración de bases de datos...")

        # Verificar DB configurada
        db_engine = settings.DATABASES['default']['ENGINE']
        print(f"  Base de datos actual: {db_engine}")

        if 'sqlite' in db_engine:
            print("  ⚠️  Estás usando SQLite como base de datos principal")
            print("  ℹ️  Para migrar a PostgreSQL, configura DATABASE_URL en .env")
            return False
        elif 'postgresql' in db_engine:
            print("  ✅ PostgreSQL configurado")
            return True
        else:
            print(f"  ❌ Base de datos no soportada: {db_engine}")
            return False

    def check_sqlite_file(self):
        """Verificar existencia de archivo SQLite"""
        sqlite_path = BACKEND_DIR / 'db.sqlite3'

        if not sqlite_path.exists():
            print("  ⚠️  No se encontró db.sqlite3")
            print("  ℹ️  No hay datos para migrar")
            return False

        # Verificar tamaño
        size_mb = sqlite_path.stat().st_size / (1024 * 1024)
        print(f"  ✅ SQLite encontrado ({size_mb:.2f} MB)")
        return True

    def create_backup(self):
        """Crear backup de datos actuales"""
        if not self.backup:
            return True

        print("▶ Creando backup...")

        try:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            self.backup_file = BACKEND_DIR.parent / f'backup_data_{timestamp}.json'

            # Exportar datos
            output = StringIO()
            call_command(
                'dumpdata',
                natural_foreign=True,
                natural_primary=True,
                exclude=['contenttypes', 'auth.permission', 'sessions'],
                indent=2,
                stdout=output
            )

            # Guardar a archivo
            with open(self.backup_file, 'w', encoding='utf-8') as f:
                f.write(output.getvalue())

            size_mb = self.backup_file.stat().st_size / (1024 * 1024)
            print(f"  ✅ Backup creado: {self.backup_file.name} ({size_mb:.2f} MB)")
            return True

        except Exception as e:
            print(f"  ❌ Error creando backup: {e}")
            return False

    def export_from_sqlite(self):
        """Exportar datos desde SQLite"""
        print("▶ Exportando datos desde SQLite...")

        sqlite_path = BACKEND_DIR / 'db.sqlite3'
        if not sqlite_path.exists():
            print("  ⚠️  No hay archivo SQLite para exportar")
            return None

        try:
            # Temporalmente cambiar a SQLite
            original_db = settings.DATABASES['default'].copy()
            settings.DATABASES['default'] = {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': str(sqlite_path),
            }

            # Reconectar
            connections['default'].close()

            # Exportar datos
            output = StringIO()
            call_command(
                'dumpdata',
                natural_foreign=True,
                natural_primary=True,
                exclude=['contenttypes', 'auth.permission', 'sessions'],
                indent=2,
                stdout=output
            )

            data = output.getvalue()

            # Restaurar configuración original
            settings.DATABASES['default'] = original_db
            connections['default'].close()

            # Parsear JSON para contar objetos
            data_json = json.loads(data)
            print(f"  ✅ {len(data_json)} objetos exportados desde SQLite")

            return data

        except Exception as e:
            print(f"  ❌ Error exportando desde SQLite: {e}")
            return None

    def import_to_postgresql(self, data):
        """Importar datos a PostgreSQL"""
        print("▶ Importando datos a PostgreSQL...")

        if self.dry_run:
            print("  ℹ️  Modo dry-run: no se importarán datos")
            return True

        try:
            # Guardar datos temporalmente
            temp_file = BACKEND_DIR / 'temp_migration_data.json'
            with open(temp_file, 'w', encoding='utf-8') as f:
                f.write(data)

            # Importar
            call_command('loaddata', str(temp_file))

            # Limpiar archivo temporal
            temp_file.unlink()

            print("  ✅ Datos importados exitosamente")
            return True

        except Exception as e:
            print(f"  ❌ Error importando datos: {e}")
            if temp_file.exists():
                temp_file.unlink()
            return False

    def verify_migration(self):
        """Verificar que la migración fue exitosa"""
        print("▶ Verificando migración...")

        try:
            from django.contrib.auth import get_user_model
            User = get_user_model()

            user_count = User.objects.count()
            superuser_count = User.objects.filter(is_superuser=True).count()

            print(f"  ✅ Usuarios migrados: {user_count}")
            print(f"  ✅ Superusuarios: {superuser_count}")

            # Verificar integridad
            with connection.cursor() as cursor:
                cursor.execute("SELECT COUNT(*) FROM users_user")
                db_count = cursor.fetchone()[0]

                if db_count == user_count:
                    print("  ✅ Integridad verificada")
                else:
                    print(f"  ⚠️  Discrepancia: ORM={user_count}, DB={db_count}")

            return True

        except Exception as e:
            print(f"  ❌ Error en verificación: {e}")
            return False

    def run(self):
        """Ejecutar proceso completo de migración"""
        self.print_banner()

        # 1. Verificar configuración
        if not self.check_databases():
            print("\n❌ Migración cancelada: configurar DATABASE_URL en .env")
            return False

        # 2. Verificar SQLite
        if not self.check_sqlite_file():
            print("\n⚠️  No hay datos para migrar")
            return True

        # 3. Crear backup (opcional)
        if self.backup:
            if not self.create_backup():
                response = input("\n⚠️  Fallo el backup. ¿Continuar? (s/N): ")
                if response.lower() != 's':
                    print("Migración cancelada")
                    return False

        # 4. Exportar desde SQLite
        print()
        data = self.export_from_sqlite()
        if not data:
            print("\n❌ Migración cancelada: error en exportación")
            return False

        # 5. Confirmar antes de importar
        if not self.dry_run:
            print()
            print("⚠️  ADVERTENCIA: Los datos se importarán a PostgreSQL")
            response = input("¿Continuar? (s/N): ")
            if response.lower() != 's':
                print("Migración cancelada por el usuario")
                return False

        # 6. Importar a PostgreSQL
        print()
        if not self.import_to_postgresql(data):
            print("\n❌ Migración falló en la importación")
            return False

        # 7. Verificar
        print()
        if not self.verify_migration():
            print("\n⚠️  Migración completada pero con advertencias")
            return True

        # Éxito
        print()
        print("╔════════════════════════════════════════════════════════╗")
        print("║  ✅ MIGRACIÓN COMPLETADA EXITOSAMENTE                  ║")
        print("╚════════════════════════════════════════════════════════╝")
        print()

        if self.backup_file:
            print(f"📦 Backup guardado en: {self.backup_file}")

        print()
        print("📋 SIGUIENTES PASOS:")
        print("  1. Verificar datos en Supabase Dashboard")
        print("  2. Probar login en Django Admin")
        print("  3. Ejecutar tests: python manage.py test")
        print()

        return True


def main():
    """Función principal"""
    parser = argparse.ArgumentParser(
        description='Migrar datos de SQLite a PostgreSQL',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:

  # Migración normal
  python scripts/migrate_data.py

  # Con backup y modo verbose
  python scripts/migrate_data.py --backup --verbose

  # Simular migración (no aplica cambios)
  python scripts/migrate_data.py --dry-run

Para más información: docs/SUPABASE_SETUP_GUIDE.md
        """
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Simular migración sin aplicar cambios'
    )

    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Mostrar información detallada'
    )

    parser.add_argument(
        '--backup', '-b',
        action='store_true',
        help='Crear backup antes de migrar'
    )

    args = parser.parse_args()

    # Ejecutar migración
    tool = MigrationTool(
        dry_run=args.dry_run,
        verbose=args.verbose,
        backup=args.backup
    )

    success = tool.run()

    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()

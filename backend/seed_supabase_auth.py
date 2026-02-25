import os
from supabase import create_client, Client
from decouple import config
import django

# Configurar Django para acceder a los modelos si fuera necesario
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

url = config("SUPABASE_URL")
key = config(
    "SUPABASE_SERVICE_KEY"
)  # Usamos service_role para bypass de email confirmation
supabase: Client = create_client(url, key)

users_to_create = [
    {"email": "porteria1@ibv.com", "password": "Test1234!"},
    {"email": "recibidor1@ibv.com", "password": "Test1234!"},
]

print("🚀 Iniciando creación de usuarios en Supabase Auth...")

for user in users_to_create:
    email = user["email"]
    password = user["password"]

    try:
        # Intentamos crear el usuario usando la API de administración para evitar confirmación de email
        # Nota: Esto requiere que SUPABASE_SERVICE_KEY sea válida
        res = supabase.auth.admin.create_user(
            {"email": email, "password": password, "email_confirm": True}
        )
        print(f"✅ Usuario creado exitosamente: {email}")
    except Exception as e:
        if "already exists" in str(
            e
        ).lower() or "Email address already registered" in str(e):
            print(f"ℹ️ El usuario {email} ya existe en Supabase Auth.")
        else:
            print(f"❌ Error al crear {email}: {e}")
            print(
                "Intentando registro normal (podría requerir confirmación de email)..."
            )
            try:
                supabase.auth.sign_up({"email": email, "password": password})
                print(
                    f"⚠️ Registro normal enviado para {email}. Revisa el correo si no está auto-confirmado."
                )
            except Exception as e2:
                print(f"🔴 Error crítico en registro normal para {email}: {e2}")

print("\n--- Proceso de Supabase completado ---")

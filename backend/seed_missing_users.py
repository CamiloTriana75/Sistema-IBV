from django.contrib.auth import get_user_model
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

User = get_user_model()

missing_users = [
    {
        "email": "porteria1@ibv.com",
        "role": "porteria",
        "first_name": "Porteria",
        "last_name": "1",
    },
    {
        "email": "recibidor1@ibv.com",
        "role": "recibidor",
        "first_name": "Recibidor",
        "last_name": "1",
    },
]

for user_data in missing_users:
    email = user_data["email"]
    user, created = User.objects.get_or_create(
        email=email,
        defaults={
            "role": user_data["role"],
            "first_name": user_data["first_name"],
            "last_name": user_data["last_name"],
            "is_active": True,
        },
    )

    if created:
        # Aunque no se use para Auth de Supabase, ponemos password por consistencia
        user.set_password("Test1234!")
        user.save()
        print(f"✅ Usuario creado en Django: {email} (Rol: {user_data['role']})")
    else:
        # Actualizar rol por si acaso
        user.role = user_data["role"]
        user.save()
        print(f"ℹ️ Usuario {email} ya existía. Rol actualizado a: {user_data['role']}")

print("\n--- Proceso completado ---")

from supabase import create_client, Client
from decouple import config

# Cargar configuración
url = config("SUPABASE_URL")
key = config("SUPABASE_SERVICE_KEY")
supabase: Client = create_client(url, key)

bucket_name = "improntas"

print(f"🚀 Intentando crear bucket: {bucket_name}...")

try:
    # Intentar crear el bucket con configuración de privacidad y límite de tamaño
    # file_size_limit está en bytes (10MB = 10 * 1024 * 1024)
    res = supabase.storage.create_bucket(
        bucket_name,
        options={
            "public": False,
            "file_size_limit": 10485760,  # 10MB
            "allowed_mime_types": ["image/*"],  # Opcional: solo imágenes
        },
    )
    print(f"✅ Bucket '{bucket_name}' creado exitosamente.")
except Exception as e:
    if "already exists" in str(e).lower():
        print(
            f"ℹ️ El bucket '{bucket_name}' ya existe. Intentando actualizar configuración..."
        )
        try:
            supabase.storage.update_bucket(
                bucket_name, options={"public": False, "file_size_limit": 10485760}
            )
            print(f"✅ Configuración del bucket '{bucket_name}' actualizada.")
        except Exception as e2:
            print(f"❌ Error al actualizar bucket: {e2}")
    else:
        print(f"❌ Error al crear bucket: {e}")

print("\n--- Proceso de Almacenamiento completado ---")

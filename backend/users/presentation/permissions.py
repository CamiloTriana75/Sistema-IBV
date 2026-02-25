import requests
from rest_framework.authentication import BaseAuthentication
from rest_framework.permissions import BasePermission
from rest_framework.exceptions import AuthenticationFailed
from django.conf import settings

SUPABASE_URL = settings.SUPABASE_URL.rstrip("/")
SUPABASE_ANON_KEY = settings.SUPABASE_ANON_KEY
USER_ENDPOINT = f"{SUPABASE_URL}/auth/v1/user"


def _verify_supabase_token(token: str) -> dict:
    """
    Valida el token llamando al endpoint /auth/v1/user de Supabase.
    Devuelve el payload del usuario si es válido, lanza AuthenticationFailed si no.
    """
    resp = requests.get(
        USER_ENDPOINT,
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {token}",
        },
        timeout=5,
    )
    if resp.status_code != 200:
        raise AuthenticationFailed("Token de Supabase inválido o expirado.")
    return resp.json()


class _SupabaseUser:
    """Objeto usuario liviano inyectado en request.user tras validar Supabase JWT."""

    def __init__(self, data: dict):
        self.id = data.get("id") or data.get("sub")
        self.email = data.get("email", "")
        self.is_authenticated = True
        self.is_active = True
        self.is_staff = False
        self.is_superuser = False

    def __str__(self):
        return self.email


class SupabaseJWTAuthentication(BaseAuthentication):
    """
    Autenticador DRF que valida tokens JWT emitidos por Supabase
    consultando directamente el endpoint /auth/v1/user.
    """

    def authenticate(self, request):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return None
        token = auth_header.split(" ", 1)[1]
        try:
            user_data = _verify_supabase_token(token)
        except AuthenticationFailed:
            raise
        except Exception as exc:
            raise AuthenticationFailed(f"Error verificando token: {exc}")
        return (_SupabaseUser(user_data), token)

    def authenticate_header(self, request):
        return 'Bearer realm="Supabase JWT"'


# Permiso legacy — se conserva por compatibilidad
class SupabaseJWTAuthenticationPermission(BasePermission):
    def has_permission(self, request, view):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return False
        token = auth_header.split(" ", 1)[1]
        try:
            _verify_supabase_token(token)
            return True
        except Exception:
            return False

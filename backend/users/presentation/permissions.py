import requests
import jwt
from rest_framework.permissions import BasePermission
from django.conf import settings

SUPABASE_PROJECT_ID = settings.SUPABASE_URL.split('//')[1].split('.')[0]
JWKS_URL = f'https://{SUPABASE_PROJECT_ID}.supabase.co/auth/v1/keys'

class SupabaseJWTAuthenticationPermission(BasePermission):
    def has_permission(self, request, view):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return False
        token = auth_header.split(' ')[1]
        try:
            # Obtener las claves públicas de Supabase
            jwks = requests.get(JWKS_URL).json()['keys']
            # Decodificar el JWT usando las claves públicas
            unverified_header = jwt.get_unverified_header(token)
            for jwk in jwks:
                if jwk['kid'] == unverified_header['kid']:
                    public_key = jwt.algorithms.RSAAlgorithm.from_jwk(jwk)
                    jwt.decode(token, public_key, algorithms=[jwk['alg']], audience=None)
                    return True
        except Exception:
            return False
        return False

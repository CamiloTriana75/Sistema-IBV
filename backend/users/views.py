from django.shortcuts import render  # noqa: F401
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views import View
from django.conf import settings
import jwt
from jwt import PyJWKClient
import requests
import json
from users.models import User

SUPABASE_JWKS_URL = f"{settings.SUPABASE_URL}/auth/v1/.well-known/jwks.json"


@method_decorator(csrf_exempt, name="dispatch")
class UserByEmailView(View):
    def get_public_keys(self):

        jwks = requests.get(SUPABASE_JWKS_URL).json()
        public_keys = {}
        for jwk in jwks["keys"]:
            kid = jwk["kid"]
            # Supabase expone claves JWK en formato JSON; PyJWT espera un string JSON válido
            # y, para proyectos estándar de Supabase, las claves son de tipo RSA (RS256).
            public_keys[kid] = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(jwk))
        return public_keys, jwks

    def decode_token(self, token):
        """
        Decodifica el JWT emitido por Supabase usando su JWKS.
        PyJWKClient se encarga de resolver el tipo de clave (RSA, EC, etc.).
        """
        jwk_client = PyJWKClient(SUPABASE_JWKS_URL)
        signing_key = jwk_client.get_signing_key_from_jwt(token)
        decoded = jwt.decode(
            token,
            key=signing_key.key,
            algorithms=["RS256", "ES256", "EdDSA"],
            audience="authenticated",
            options={
                # Evita errores por ligeras desincronizaciones de hora en el claim "iat"
                "verify_iat": False,
            },
        )
        return decoded

    def get(self, request):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            print("JWT error: Authorization header no Bearer")
            return JsonResponse({"detail": "Unauthorized"}, status=401)
        token = auth_header.split(" ")[1]

        try:
            print("JWT recibido:", token)
            decoded = self.decode_token(token)
            print("JWT payload:", decoded)

            email = request.GET.get("email")
            print("Email recibido por GET:", email)
            if not email:
                print("JWT error: email no enviado por GET")
                return JsonResponse({"detail": "Email required"}, status=400)

            if decoded.get("email") != email:
                print(
                    f"JWT error: email mismatch. Claim: {decoded.get('email')} GET: {email}"
                )
                return JsonResponse({"detail": "Email mismatch"}, status=401)

            try:
                user = User.objects.get(email=email)
                return JsonResponse(
                    [
                        {
                            "email": user.email,
                            "role": user.role,
                            "first_name": user.first_name,
                            "last_name": user.last_name,
                            "is_active": user.is_active,
                        }
                    ],
                    safe=False,
                )
            except User.DoesNotExist:
                print(f"Usuario no encontrado: {email}")
                return JsonResponse([], safe=False)
        except Exception as e:
            print("JWT error: excepción general", str(e))
            return JsonResponse(
                {"detail": "Invalid token", "error": str(e)}, status=401
            )

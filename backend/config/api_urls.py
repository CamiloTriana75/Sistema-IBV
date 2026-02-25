from django.http import JsonResponse
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from rest_framework.routers import DefaultRouter

from users.presentation.views import AuthLogoutView, AuthMeView, RolesView, UserViewSet
from users.views import UserByEmailView

router = DefaultRouter()
router.register("users", UserViewSet, basename="users")

urlpatterns = [
    path("health/", lambda _request: JsonResponse({"status": "ok"})),
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
    path("docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
    path("auth/login/", TokenObtainPairView.as_view(), name="auth_login"),
    path("auth/logout/", AuthLogoutView.as_view(), name="auth_logout"),
    path("auth/me/", AuthMeView.as_view(), name="auth_me"),
    path("roles/", RolesView.as_view(), name="roles"),
    path("token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("token/verify/", TokenVerifyView.as_view(), name="token_verify"),
    path("users/", UserByEmailView.as_view()),
    path("", include(router.urls)),
]

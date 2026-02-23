from __future__ import annotations

from rest_framework import status, viewsets
from rest_framework.permissions import IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from users.application.services import UserService
from users.infrastructure.repositories import DjangoUserRepository
from users.models import ROLE_CHOICES
from users.presentation.serializers import (
    UserCreateSerializer,
    UserSerializer,
    UserUpdateSerializer,
)


class UserViewSet(viewsets.ViewSet):
    permission_classes = [IsAdminUser]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._service = UserService(DjangoUserRepository())

    def list(self, request):
        users = self._service.list_users()
        return Response(UserSerializer(users, many=True).data)

    def retrieve(self, request, pk=None):
        if pk is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        try:
            user_id = int(pk)
        except (TypeError, ValueError):
            return Response(status=status.HTTP_400_BAD_REQUEST)

        user = self._service.get_user(user_id)
        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        return Response(UserSerializer(user).data)

    def create(self, request):
        serializer = UserCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated = serializer.validated_data
        password = validated.pop("password", None)
        user = self._service.create_user(validated, password)
        return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)

    def update(self, request, pk=None):
        if pk is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        try:
            user_id = int(pk)
        except (TypeError, ValueError):
            return Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = UserUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        validated = serializer.validated_data
        password = validated.pop("password", None)
        user = self._service.update_user(user_id, validated, password)
        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        return Response(UserSerializer(user).data)

    def destroy(self, request, pk=None):
        if pk is None:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        try:
            user_id = int(pk)
        except (TypeError, ValueError):
            return Response(status=status.HTTP_400_BAD_REQUEST)

        deleted = self._service.delete_user(user_id)
        if not deleted:
            return Response(status=status.HTTP_404_NOT_FOUND)

        return Response(status=status.HTTP_204_NO_CONTENT)


class AuthMeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        service = UserService(DjangoUserRepository())
        user = service.get_user(request.user.id)
        if not user:
            return Response(status=status.HTTP_404_NOT_FOUND)

        return Response(UserSerializer(user).data)


class AuthLogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, _request):
        return Response(status=status.HTTP_204_NO_CONTENT)


class RolesView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, _request):
        roles = [
            {"id": index + 1, "name": label}
            for index, (_code, label) in enumerate(ROLE_CHOICES)
        ]
        return Response(roles)

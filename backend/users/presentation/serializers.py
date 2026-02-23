from __future__ import annotations

from rest_framework import serializers

from users.models import ROLE_CHOICES


class UserSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    email = serializers.EmailField()
    first_name = serializers.CharField(allow_blank=True, required=False)
    last_name = serializers.CharField(allow_blank=True, required=False)
    role = serializers.ChoiceField(choices=ROLE_CHOICES)
    is_active = serializers.BooleanField()
    date_joined = serializers.DateTimeField(required=False, allow_null=True)


class UserCreateSerializer(serializers.Serializer):
    email = serializers.EmailField()
    first_name = serializers.CharField(allow_blank=True, required=False)
    last_name = serializers.CharField(allow_blank=True, required=False)
    role = serializers.ChoiceField(
        choices=ROLE_CHOICES, required=False, default="cliente"
    )
    is_active = serializers.BooleanField(required=False, default=True)
    password = serializers.CharField(write_only=True, required=False)


class UserUpdateSerializer(serializers.Serializer):
    email = serializers.EmailField(required=False)
    first_name = serializers.CharField(allow_blank=True, required=False)
    last_name = serializers.CharField(allow_blank=True, required=False)
    role = serializers.ChoiceField(choices=ROLE_CHOICES, required=False)
    is_active = serializers.BooleanField(required=False)
    password = serializers.CharField(write_only=True, required=False)

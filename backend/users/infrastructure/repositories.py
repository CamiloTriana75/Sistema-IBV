from __future__ import annotations

from django.contrib.auth import get_user_model

from users.domain.entities import UserEntity
from users.domain.repositories import UserRepository

User = get_user_model()


def _to_entity(user) -> UserEntity:
    return UserEntity(
        id=user.id,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        role=getattr(user, "role", "cliente"),
        is_active=user.is_active,
        date_joined=getattr(user, "date_joined", None),
    )


class DjangoUserRepository(UserRepository):
    def list(self) -> list[UserEntity]:
        return [_to_entity(user) for user in User.objects.all().order_by("id")]

    def get(self, user_id: int) -> UserEntity | None:
        try:
            return _to_entity(User.objects.get(pk=user_id))
        except User.DoesNotExist:
            return None

    def create(self, data: dict, password: str | None) -> UserEntity:
        user = User.objects.create_user(password=password, **data)
        return _to_entity(user)

    def update(self, user_id: int, data: dict, password: str | None = None) -> UserEntity | None:
        try:
            user = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None

        for field, value in data.items():
            setattr(user, field, value)

        if password:
            user.set_password(password)

        update_fields = list(data.keys()) + (["password"] if password else [])
        if update_fields:
            user.save(update_fields=update_fields)
        else:
            user.save()
        return _to_entity(user)

    def delete(self, user_id: int) -> bool:
        deleted, _ = User.objects.filter(pk=user_id).delete()
        return deleted > 0

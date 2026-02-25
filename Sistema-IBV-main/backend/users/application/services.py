from __future__ import annotations

from users.domain.repositories import UserRepository


class UserService:
    def __init__(self, repository: UserRepository) -> None:
        self._repository = repository

    def list_users(self):
        return self._repository.list()

    def get_user(self, user_id: int):
        return self._repository.get(user_id)

    def create_user(self, data: dict, password: str | None):
        return self._repository.create(data, password)

    def update_user(self, user_id: int, data: dict, password: str | None = None):
        return self._repository.update(user_id, data, password)

    def delete_user(self, user_id: int) -> bool:
        return self._repository.delete(user_id)

from __future__ import annotations

from typing import Protocol

from .entities import UserEntity


class UserRepository(Protocol):
    def list(self) -> list[UserEntity]:
        ...

    def get(self, user_id: int) -> UserEntity | None:
        ...

    def create(self, data: dict, password: str | None) -> UserEntity:
        ...

    def update(self, user_id: int, data: dict, password: str | None = None) -> UserEntity | None:
        ...

    def delete(self, user_id: int) -> bool:
        ...

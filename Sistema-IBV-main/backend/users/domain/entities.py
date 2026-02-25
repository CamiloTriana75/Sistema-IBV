from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class UserEntity:
    id: int
    email: str
    first_name: str
    last_name: str
    role: str
    is_active: bool
    date_joined: datetime | None = None

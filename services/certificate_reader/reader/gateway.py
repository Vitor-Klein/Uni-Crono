"""What the reader needs from the account server and the file storage."""

from dataclasses import dataclass
from typing import Any, Protocol


@dataclass(frozen=True)
class Student:
    id: str
    institution: str


class Gateway(Protocol):
    def student_for(self, token: str) -> Student | None:
        """The student who owns [token], or None when it is not valid."""

    def download(self, path: str) -> bytes | None:
        """The stored file at [path], or None when there is none."""

    def delete(self, path: str) -> None: ...

    def insert_certificate(self, row: dict[str, Any]) -> bool:
        """Saves the certificate; False when the student already has it."""

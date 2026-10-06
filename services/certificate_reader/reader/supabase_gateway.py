"""The reader's access to Supabase, over its HTTP API. It runs with the
service key, which only exists in the server's environment."""

import os
from typing import Any
from urllib.parse import quote

import httpx2 as httpx

from .gateway import Student

BUCKET = "certificates"
TIMEOUT = httpx.Timeout(10.0)


class SupabaseGateway:
    def __init__(self, url: str, service_key: str, client: httpx.Client) -> None:
        self._url = url.rstrip("/")
        self._key = service_key
        self._client = client

    @classmethod
    def from_env(cls) -> "SupabaseGateway":
        url = os.environ.get("SUPABASE_URL", "")
        key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
        if not url or not key:
            raise RuntimeError(
                "SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are required"
            )
        return cls(url, key, httpx.Client(timeout=TIMEOUT))

    @property
    def _service_headers(self) -> dict[str, str]:
        return {"apikey": self._key, "Authorization": f"Bearer {self._key}"}

    def student_for(self, token: str) -> Student | None:
        """Asks the account server who owns [token]: it checks the signature
        and the expiry, so the reader never decodes tokens itself."""
        try:
            response = self._client.get(
                f"{self._url}/auth/v1/user",
                headers={"apikey": self._key, "Authorization": f"Bearer {token}"},
            )
        except httpx.HTTPError:
            return None
        if response.status_code != 200:
            return None
        user = response.json()
        metadata = user.get("user_metadata") or {}
        user_id = user.get("id")
        institution = metadata.get("institution_id")
        if not isinstance(user_id, str) or not isinstance(institution, str):
            return None
        return Student(id=user_id, institution=institution)

    def download(self, path: str) -> bytes | None:
        response = self._client.get(
            f"{self._url}/storage/v1/object/{BUCKET}/{quote(path)}",
            headers=self._service_headers,
        )
        if response.status_code != 200:
            return None
        return response.content

    def delete(self, path: str) -> None:
        self._client.request(
            "DELETE",
            f"{self._url}/storage/v1/object/{BUCKET}",
            headers=self._service_headers,
            json={"prefixes": [path]},
        )

    def insert_certificate(self, row: dict[str, Any]) -> bool:
        response = self._client.post(
            f"{self._url}/rest/v1/certificates",
            headers={**self._service_headers, "Prefer": "return=minimal"},
            json=row,
        )
        if response.status_code == 409:
            return False
        response.raise_for_status()
        return True

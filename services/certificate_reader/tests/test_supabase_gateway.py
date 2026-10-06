import json

import httpx2 as httpx
import pytest

from reader.gateway import Student
from reader.supabase_gateway import SupabaseGateway

URL = "https://projeto.supabase.co"
KEY = "service-key"
UID = "11111111-1111-4111-8111-111111111111"
PATH = f"{UID}/22222222-2222-4222-8222-222222222222.pdf"


def gateway_answering(handler) -> tuple[SupabaseGateway, list[httpx.Request]]:
    seen: list[httpx.Request] = []

    def record(request: httpx.Request) -> httpx.Response:
        seen.append(request)
        return handler(request)

    client = httpx.Client(transport=httpx.MockTransport(record))
    return SupabaseGateway(URL, KEY, client), seen


def test_ca12_a_valid_token_is_the_student_with_their_institution():
    gateway, seen = gateway_answering(
        lambda _: httpx.Response(
            200, json={"id": UID, "user_metadata": {"institution_id": "utfpr"}}
        )
    )

    assert gateway.student_for("token") == Student(id=UID, institution="utfpr")
    assert seen[0].url.path == "/auth/v1/user"
    assert seen[0].headers["authorization"] == "Bearer token"
    assert seen[0].headers["apikey"] == KEY


@pytest.mark.parametrize("status", [401, 403, 500])
def test_ca12_a_refused_token_is_no_student(status):
    gateway, _ = gateway_answering(lambda _: httpx.Response(status, json={}))

    assert gateway.student_for("token") is None


def test_ca12_an_unreachable_server_is_no_student():
    def fail(request):
        raise httpx.ConnectError("offline", request=request)

    gateway, _ = gateway_answering(fail)

    assert gateway.student_for("token") is None


def test_ca13_downloads_from_the_private_bucket_with_the_service_key():
    gateway, seen = gateway_answering(lambda _: httpx.Response(200, content=b"%PDF"))

    assert gateway.download(PATH) == b"%PDF"
    assert seen[0].url.path == f"/storage/v1/object/certificates/{PATH}"
    assert seen[0].headers["authorization"] == f"Bearer {KEY}"


def test_ca13_a_missing_file_downloads_as_none():
    gateway, _ = gateway_answering(lambda _: httpx.Response(400, json={}))

    assert gateway.download(PATH) is None


def test_ca13_deletes_the_file():
    gateway, seen = gateway_answering(lambda _: httpx.Response(200, json=[]))

    gateway.delete(PATH)

    assert seen[0].method == "DELETE"
    assert seen[0].url.path == "/storage/v1/object/certificates"
    assert json.loads(seen[0].content) == {"prefixes": [PATH]}


def test_ca13_inserts_the_certificate():
    gateway, seen = gateway_answering(lambda _: httpx.Response(201))

    assert gateway.insert_certificate({"user_id": UID, "hours": 10}) is True
    assert seen[0].url.path == "/rest/v1/certificates"
    assert json.loads(seen[0].content) == {"user_id": UID, "hours": 10}


def test_ca13_a_certificate_the_student_already_has_is_not_inserted():
    gateway, _ = gateway_answering(
        lambda _: httpx.Response(409, json={"code": "23505"})
    )

    assert gateway.insert_certificate({"user_id": UID}) is False


def test_ca13_any_other_insert_failure_raises():
    gateway, _ = gateway_answering(lambda _: httpx.Response(500, json={}))

    with pytest.raises(httpx.HTTPStatusError):
        gateway.insert_certificate({"user_id": UID})


def test_from_env_requires_both_settings(monkeypatch):
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("SUPABASE_SERVICE_ROLE_KEY", raising=False)

    with pytest.raises(RuntimeError):
        SupabaseGateway.from_env()

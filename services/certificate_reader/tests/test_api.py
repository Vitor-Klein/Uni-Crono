import hashlib

import pytest
from fastapi.testclient import TestClient

from reader.app import create_app
from reader.gateway import Student
from reader.pdf_text import extract_text
from tests.pdf_factory import make_pdf

ANA = Student(id="11111111-1111-4111-8111-111111111111", institution="utfpr")
TOKEN = "token-da-ana"
FILE = "22222222-2222-4222-8222-222222222222.pdf"
PATH = f"{ANA.id}/{FILE}"

READABLE = make_pdf(
    [
        "Certificamos que Ana Souza participou do evento",
        '"Semana Academica de Computacao", promovido pela UTFPR,',
        "com carga horaria de 20 horas.",
    ]
)
SCANNED = make_pdf([])


class FakeGateway:
    def __init__(self) -> None:
        self.files: dict[str, bytes] = {}
        self.rows: list[dict] = []
        self.deleted: list[str] = []

    def student_for(self, token: str) -> Student | None:
        return ANA if token == TOKEN else None

    def download(self, path: str) -> bytes | None:
        return self.files.get(path)

    def delete(self, path: str) -> None:
        self.deleted.append(path)
        self.files.pop(path, None)

    def insert_certificate(self, row: dict) -> bool:
        if any(
            r["user_id"] == row["user_id"] and r["file_sha256"] == row["file_sha256"]
            for r in self.rows
        ):
            return False
        self.rows.append(row)
        return True


@pytest.fixture
def gateway() -> FakeGateway:
    return FakeGateway()


@pytest.fixture
def client(gateway: FakeGateway) -> TestClient:
    return TestClient(create_app(lambda: gateway))


def read(client: TestClient, path: str = PATH, token: str | None = TOKEN):
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    return client.post(
        "/api/certificates/read",
        json={"path": path, "file_name": "certificado-semana.pdf"},
        headers=headers,
    )


def manual(client: TestClient, **overrides):
    body = {"path": PATH, "title": "Mutirão", "category": "extension", "hours": 12}
    body.update(overrides)
    return client.post(
        "/api/certificates/manual",
        json=body,
        headers={"Authorization": f"Bearer {TOKEN}"},
    )


def test_the_test_pdfs_have_and_lack_text():
    assert "carga horaria de 20 horas" in extract_text(READABLE)
    assert extract_text(SCANNED) == ""


@pytest.mark.parametrize("token", [None, "token-invalido"])
def test_ca12_refuses_without_a_valid_token(client, gateway, token):
    gateway.files[PATH] = READABLE

    response = read(client, token=token)

    assert response.status_code == 401
    assert response.json() == {"error": "unauthorized"}
    assert gateway.rows == []


@pytest.mark.parametrize(
    "path",
    [
        f"33333333-3333-4333-8333-333333333333/{FILE}",
        f"{ANA.id}/../{FILE}",
        f"{ANA.id}/certificado.pdf",
        FILE,
    ],
)
def test_ca12_refuses_a_path_outside_the_student_folder(client, gateway, path):
    gateway.files[path] = READABLE

    response = read(client, path=path)

    assert response.status_code == 403
    assert response.json() == {"error": "forbidden"}
    assert gateway.rows == []


def test_ca12_refuses_a_file_that_is_not_a_pdf_and_deletes_it(client, gateway):
    gateway.files[PATH] = b"PK\x03\x04 not a pdf"

    response = read(client)

    assert response.status_code == 415
    assert response.json() == {"error": "not_pdf"}
    assert gateway.deleted == [PATH]


def test_ca12_refuses_more_than_10_mb_and_deletes_it(client, gateway):
    gateway.files[PATH] = READABLE + b"0" * (10 * 1024 * 1024)

    response = read(client)

    assert response.status_code == 413
    assert response.json() == {"error": "too_large"}
    assert gateway.deleted == [PATH]


def test_ca12_a_missing_file_is_not_found(client):
    response = read(client)

    assert response.status_code == 404
    assert response.json() == {"error": "not_found"}


def test_ca13_reads_and_saves_the_certificate(client, gateway):
    gateway.files[PATH] = READABLE

    response = read(client)

    assert response.status_code == 201
    assert response.json() == {
        "title": "Semana Academica de Computacao",
        "issuer": "UTFPR",
        "category": "complementary",
        "hours": 20,
    }
    assert gateway.rows == [
        {
            "user_id": ANA.id,
            "title": "Semana Academica de Computacao",
            "issuer": "UTFPR",
            "category": "complementary",
            "hours": 20,
            "file_path": PATH,
            "file_sha256": hashlib.sha256(READABLE).hexdigest(),
            "source": "extracted",
        }
    ]


def test_ca13_the_same_pdf_again_is_a_duplicate(client, gateway):
    gateway.files[PATH] = READABLE
    read(client)
    again = f"{ANA.id}/33333333-3333-4333-8333-333333333333.pdf"
    gateway.files[again] = READABLE

    response = read(client, path=again)

    assert response.status_code == 409
    assert response.json() == {"error": "duplicate"}
    assert len(gateway.rows) == 1
    assert again in gateway.deleted


def test_ca13_a_pdf_without_text_is_refused_and_kept(client, gateway):
    gateway.files[PATH] = SCANNED

    response = read(client)

    assert response.status_code == 422
    assert response.json() == {"error": "no_text"}
    assert gateway.rows == []
    assert PATH in gateway.files


def test_ca13_a_pdf_without_hours_is_refused_and_kept(client, gateway):
    gateway.files[PATH] = make_pdf(["Certificado de participacao na palestra."])

    response = read(client)

    assert response.status_code == 422
    assert response.json() == {"error": "no_hours"}
    assert PATH in gateway.files


def test_ca14_launches_an_unreadable_pdf_by_hand(client, gateway):
    gateway.files[PATH] = SCANNED

    response = manual(client)

    assert response.status_code == 201
    assert response.json() == {
        "title": "Mutirão",
        "issuer": None,
        "category": "extension",
        "hours": 12,
    }
    assert gateway.rows[0]["source"] == "manual"
    assert gateway.rows[0]["hours"] == 12


def test_ca14_refuses_by_hand_a_pdf_the_reader_can_read(client, gateway):
    gateway.files[PATH] = READABLE

    response = manual(client, hours=999)

    assert response.status_code == 409
    assert response.json() == {"error": "readable"}
    assert gateway.rows == []


@pytest.mark.parametrize(
    "overrides",
    [{"hours": 0}, {"hours": 1000}, {"title": "   "}, {"category": "outra"}],
)
def test_ca14_refuses_invalid_data(client, gateway, overrides):
    gateway.files[PATH] = SCANNED

    response = manual(client, **overrides)

    assert response.status_code == 422
    assert response.json() == {"error": "invalid"}
    assert gateway.rows == []


def test_ca14_manual_also_needs_a_valid_token(client, gateway):
    gateway.files[PATH] = SCANNED

    response = client.post(
        "/api/certificates/manual",
        json={"path": PATH, "title": "x", "category": "extension", "hours": 1},
    )

    assert response.status_code == 401

from fastapi.testclient import TestClient


def test_the_vercel_entry_imports_without_settings(monkeypatch):
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("SUPABASE_SERVICE_ROLE_KEY", raising=False)

    from api.index import app

    response = TestClient(app).post(
        "/api/certificates/read", json={"path": "x", "file_name": "x.pdf"}
    )
    # No settings: the gateway cannot be built, and nothing leaks.
    assert response.status_code == 503
    assert response.json() == {"error": "unavailable"}

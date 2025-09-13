import json
from app import app

def test_health():
    client = app.test_client()
    rv = client.get("/health")
    assert rv.status_code == 200
    payload = json.loads(rv.data)
    assert payload["status"] == "ok"

def test_index():
    client = app.test_client()
    rv = client.get("/")
    assert rv.status_code == 200

from fastapi.testclient import TestClient
from app import app

client = TestClient(app)


# --- PRUEBAS VÁLIDAS ---
def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


# 🚨 DESCOMENTAR PARA HACER FALLAR LA ETAPA DE CI (STATUS CODE INCORRECTO)
# def test_failing_status_code():
#     """Esta prueba falla porque /health devuelve 200, no 400."""
#     response = client.get("/health")
#     assert response.status_code == 400


# 🚨 DESCOMENTAR PARA HACER FALLAR LA ETAPA DE CI (RESPUESTA JSON INCORRECTA)
# def test_failing_json_response():
#     """Esta prueba falla porque el mensaje no coincide."""
#     response = client.get("/")
#     assert response.json()["message"] == "Mensaje incorrecto para forzar fallo"

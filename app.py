import os
from fastapi import FastAPI

app = FastAPI(title="Cloud Run App TEST")

# 🚨 DESCOMENTAR PARA HACER FALLAR GITLEAKS (Detectará una API Key expuesta)
# GCP_API_KEY_EXPOSED = "AIzaSyD-FakeSecretKeyForTestingGitleaks12345"


@app.get("/")
def read_root():
    env = os.getenv("ENVIRONMENT", "local")
    version = os.getenv("APP_VERSION", "dev-local")
    return {
        "status": "ok",
        "environment": env,
        "version": version,
        "message": "Deploy exitoso",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}

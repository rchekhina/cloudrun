FROM python:3.13-alpine

# Corrige CVEs del SO base
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*

WORKDIR /app

# 1) Actualiza pip/setuptools/wheel ANTES de instalar requirements.txt
RUN pip install --no-cache-dir --upgrade \
        "pip>=24.0" \
        "setuptools>=78.1.1" \
        "wheel"

# 2) IMPORTANTE: la imagen base de Python trae un setuptools/pip "de repuesto"
#    empaquetado como .whl dentro de ensurepip (para crear venvs offline).
#    Ese wheel NUNCA se toca con "pip install --upgrade": sigue ahí con la
#    versión vieja (70.3.0) y es justo lo que Trivy sigue detectando.
#    Lo eliminamos porque no lo necesitamos en runtime.
RUN find / -type d -name "ensurepip" -exec rm -rf {} + 2>/dev/null; \
    pip cache purge

COPY requirements.txt .

# 3) Instala dependencias del proyecto (msgpack>=1.2.1 ya fijado ahí)
#    --force-reinstall evita que quede colgado un msgpack 1.1.2 de alguna
#    capa/caché anterior.
RUN pip install --no-cache-dir --force-reinstall -r requirements.txt

# Usuario no privilegiado (sintaxis Alpine)
RUN addgroup -g 10001 appgroup && \
    adduser -D -u 10001 -G appgroup appuser && \
    chown -R appuser:appgroup /app

USER appuser

COPY --chown=appuser:appgroup app.py .

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

EXPOSE 8080

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]

FROM python:3.13-alpine
 
# Corrige CVEs del SO base
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*
 
WORKDIR /app
 
COPY requirements.txt .
 
# Ninguna de estas dependencias necesita compilar C-extensions en Alpine:
# fastapi, uvicorn, pytest, pytest-cov y httpx son puro Python, y msgpack
# publica wheels musllinux precompilados. No hace falta build-base/gcc.
RUN pip install --no-cache-dir --upgrade pip wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --upgrade "setuptools>=78.1.1"
 
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


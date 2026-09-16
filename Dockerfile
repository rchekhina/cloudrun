FROM python:3.13-slim

# 1. Actualización de paquetes para corregir CVEs del sistema
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Instalar dependencias como ROOT (aprovecha la caché si no cambia requirements.txt)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --upgrade "setuptools>=78.1.1" "msgpack>=1.2.1"

# 3. Crear usuario no privilegiado y asignar permisos
RUN useradd -m -u 10001 appuser && \
    chown -R appuser:appuser /app

# 4. Cambiar al usuario sin privilegios ANTES de copiar el código fuente
USER appuser

# 5. Copiar el código fuente con el propietario correcto
COPY --chown=appuser:appuser app.py .

EXPOSE 8080

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]

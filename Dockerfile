FROM python:3.13-alpine

# Corrige CVEs del SO base
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*

WORKDIR /app

# 1) Actualiza pip/setuptools/wheel ANTES de instalar requirements.txt.
#    Esto es clave: si lo haces DESPUÉS, cualquier dependencia transitiva
#    que arrastre un setuptools/msgpack viejo puede pisar la versión buena.
#    Al fijarlo primero, nada puede downgradearlo luego.
RUN pip install --no-cache-dir --upgrade \
        "pip>=24.0" \
        "setuptools>=78.1.1" \
        "wheel"

COPY requirements.txt .

# 2) Instala dependencias del proyecto. msgpack>=1.2.1 ya viene fijado
#    en requirements.txt, así que no hace falta repetirlo aquí.
RUN pip install --no-cache-dir -r requirements.txt

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

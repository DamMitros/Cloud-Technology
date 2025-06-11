FROM python:3.8-slim

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir Flask
EXPOSE 5000
ENV NAME World

CMD ["python", "app.py"]

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

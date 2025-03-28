ARG PYTHON_VERSION=3.9

FROM python:${PYTHON_VERSION}-slim

WORKDIR /app
COPY myapp/ .
COPY myapp/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONUNBUFFERED=1
EXPOSE 5000

CMD ["python", "app.py"]
FROM python:3.9-slim

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r requirements.txt
ENV RABBITMQ_HOST=rabbitmq

CMD ["python", "consumer.py"]

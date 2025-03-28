FROM alpine:latest

ARG PYTHON_VERSION=3.9
ARG SERVER_PORT=5000

ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV SERVER_PORT=${SERVER_PORT}
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN mkdir -p /data

RUN apk update && \
    apk add --no-cache python3 py3-pip && \
    ln -sf python3 /usr/bin/python

COPY myapp/ .

VOLUME ["/data"]

EXPOSE ${SERVER_PORT}

CMD ["python", "app.py"]

# Build the Docker image

# docker build -t python-alpine-app --build-arg PYTHON_VERSION=3.10 --build-arg SERVER_PORT=8080 .

# Run the Docker container

# docker run -p 8080:8080 -v app_data:/data python-alpine-app

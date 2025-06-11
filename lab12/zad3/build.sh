docker buildx create --name multibuilder --use --bootstrap 2>/dev/null || docker buildx use multibuilder
docker buildx build --platform linux/amd64,linux/arm64 -t gollet/lab12-zad3:latest . --push
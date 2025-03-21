info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NODE_CONTAINER="node-server-container"
NGINX_CONTAINER="nginx-volume-container"
NODE_VOLUME="nodejs_data"
NGINX_VOLUME="nginx_data"
ALL_VOLUME="all_volumes"

docker rm -f $NODE_CONTAINER $NGINX_CONTAINER >/dev/null 2>&1

info "VOLUME" "Tworzenie woluminów Docker"
docker volume create $NODE_VOLUME >/dev/null 2>&1
docker volume create $NGINX_VOLUME >/dev/null 2>&1
docker volume create $ALL_VOLUME >/dev/null 2>&1

info "KONTENER NODE" "Uruchamianie kontenera Node.js z woluminem"
docker run -d --name $NODE_CONTAINER -v $NODE_VOLUME:/app node:16-alpine tail -f /dev/null

info "PLIKI NODE" "Kopiowanie plików do kontenera Node.js"
docker cp app/. $NODE_CONTAINER:/app/

info "KOPIOWANIE" "Przenoszenie plików z Node.js do $ALL_VOLUME"
docker run --rm -v $NODE_VOLUME:/app -v $ALL_VOLUME:/all alpine sh -c "mkdir -p /all/node && cp -r /app/* /all/node/"

info "KOPIOWANIE" "Przenoszenie plików z Nginx do $ALL_VOLUME"
docker run --rm -v $NGINX_VOLUME:/nginx-html -v $ALL_VOLUME:/all alpine sh -c "mkdir -p /all/nginx && cp -r /nginx-html/* /all/nginx/"

info "WERYFIKACJA" "Sprawdzanie zawartości woluminu $ALL_VOLUME"
docker run --rm -v $ALL_VOLUME:/all alpine sh -c "ls -la /all/node/ && ls -la /all/nginx/"
# docker run --rm -v $ALL_VOLUME:/all busybox:latest ls -R /all

info "SUKCES" "Wszystkie pliki zostały poprawnie skopiowane do $ALL_VOLUME"
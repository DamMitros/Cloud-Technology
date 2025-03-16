info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NETWORK_NAME="node-nginx-network"
NODE_APP_CONTAINER="node-app"
NGINX_CONTAINER="nginx-proxy"
NODE_PORT=3000
NGINX_PORT=80
NGINX_SSL_PORT=443

info "Sprzątanie" "Usuwanie kontenera i sieci Docker"
docker rm -f $NODE_APP_CONTAINER $NGINX_CONTAINER >/dev/null 2>&1
docker network rm $NETWORK_NAME >/dev/null 2>&1

info "KONFIGURACJA" "Przygotowanie katalogów"
rm -rf nginx/nginx.conf
mkdir -p nginx/ssl nginx/cache app

info "KONFIGURACJA" "Kopiowanie plików konfiguracyjnych"
cp -f server.js app/ 
cp -f package.json app/
cp -f nginx.conf nginx/

info "SIEĆ" "Tworzenie sieci Docker dla kontenerów"
docker network create $NETWORK_NAME >/dev/null 2>&1

info "KONTENER" "Tworzenie kontenera z aplikacją Node.js"
NODE_CONTAINER_ID=$(docker run -d --network $NETWORK_NAME --name $NODE_APP_CONTAINER \
  -v $(pwd)/app:/app -w /app node:14 npm start)

echo "Utworzono kontener o ID: $NODE_CONTAINER_ID"
NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NODE_APP_CONTAINER)
info "IP KONTENERA" "adres IP kontenera z aplikacją Node.js to $NODE_IP"

info "SSL" "Generowanie certyfikatu SSL"
if [ ! -f nginx/ssl/cert.pem ] || [ ! -f nginx/ssl/key.pem ]; then
  docker run --rm -v $(pwd)/nginx/ssl:/ssl alpine/openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /ssl/key.pem -out /ssl/cert.pem -subj '/CN=localhost'
fi

info "KONTENER" "Tworzenie kontenera z serwerem Nginx"
NGINX_CONTAINER_ID=$(docker run -d --name $NGINX_CONTAINER --network $NETWORK_NAME \
  -p $NGINX_PORT:80 -p $NGINX_SSL_PORT:443 \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/nginx/ssl:/etc/nginx/ssl:ro \
  -v $(pwd)/nginx/cache:/var/cache/nginx \
  nginx)

echo "Utworzono kontener o ID: $NGINX_CONTAINER_ID"

docker exec $NGINX_CONTAINER bash -c "apt-get update && apt-get install -y openssl curl && mkdir -p /var/cache/nginx && chown -R nginx:nginx /var/cache/nginx"
docker exec $NGINX_CONTAINER nginx -s reload

NGINX_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $NGINX_CONTAINER)
info "IP KONTENERA" "adres IP kontenera z serwerem Nginx to $NGINX_IP"

info "TEST 1" "Sprawdzenie konfiguracji Nginx"
if docker exec $NGINX_CONTAINER nginx -t >/dev/null 2>&1; then
  echo "Konfiguracja Nginx jest poprawna"
else
  echo "Konfiguracja Nginx jest niepoprawna"
  exit 1
fi

info "TEST 2" "Sprawdzenie czy aplikacja Node.js jest dostępna bezpośrednio"
sleep 2
if docker exec $NGINX_CONTAINER curl -s http://$NODE_APP_CONTAINER:$NODE_PORT | grep -q "Node.js działa"; then
  echo "Aplikacja Node.js działa poprawnie na porcie $NODE_PORT"
else
  echo "Aplikacja Node.js nie działa poprawnie"
  exit 1
fi

info "TEST 3" "Sprawdzenie przekierowania HTTP do HTTPS"
sleep 2
if curl -s -I http://localhost | grep -q "301 Moved Permanently"; then
  echo "Przekierowanie HTTP do HTTPS działa poprawnie"
else
  echo "Przekierowanie HTTP do HTTPS nie działa poprawnie"
  exit 1
fi

info "TEST 4" "Sprawdzenie dostępu przez HTTPS"
sleep 2
if curl -s -k https://localhost | grep -q "Node.js działa przez Nginx"; then
  echo "Dostęp przez HTTPS działa poprawnie"
else
  echo "Dostęp przez HTTPS nie działa poprawnie"
  exit 1
fi

info "TEST 5" "Sprawdzenie czy cache działa"
sleep 2
# Pierwszy request powinien ominąć cache
FIRST_RESPONSE=$(curl -s -k -I https://localhost | grep -i X-Cache-Status || echo "NONE")
echo "Status cache dla pierwszego żądania: $FIRST_RESPONSE"
sleep 1
# Drugi request powinien trafić w cache
SECOND_RESPONSE=$(curl -s -k -I https://localhost | grep -i X-Cache-Status || echo "NONE")
echo "Status cache dla drugiego żądania: $SECOND_RESPONSE"
if echo "$SECOND_RESPONSE" | grep -q "HIT"; then
  echo "Mechanizm cache działa poprawnie"
else
  echo "Mechanizm cache nie działa poprawnie"
  exit 1
fi

info "SUKCES" "Wszystkie testy zakończone powodzeniem"
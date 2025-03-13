info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

CONFIG_FILE="nginx2.conf"
CONTAINER_NAME="nginx2"
PORT=8082

info "SIEĆ" "Tworzenie sieci Docker dla kontenera"
docker network create nginx-network >/dev/null 2>&1

info "KONFIGURACJA" "użycie kontenera z serwerem Nginx"
CONTAINER_ID=$(docker run -d -p $PORT:81 --network nginx-network --name $CONTAINER_NAME -v $(pwd)/$CONFIG_FILE:/etc/nginx/nginx.conf:ro nginx)

echo "Utworzono kontener o ID: $CONTAINER_ID"

CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
info "IP KONTENERA" "adres IP kontenera to $CONTAINER_IP"

info "TEST 1" "Sprawdzenie czy Nginx działa"
sleep 2
if docker exec $CONTAINER_NAME nginx -t >/dev/null 2>&1; then
  echo "Nginx działa poprawnie"
else
  echo "Nginx nie działa poprawnie"
  exit 1
fi

info "TEST 2" "Sprawdzenie czy strona jest dostępna na porcie"
sleep 2 
if curl -s localhost:$PORT >/dev/null; then
  echo "Strona jest dostępna na porcie $PORT"
else
  echo "Strona nie jest dostępna na porcie $PORT"
  exit 1
fi

info "TEST 3" "Sprawdzenie czy niestandardowa konfiguracja Nginx działa"
sleep 2
docker exec $CONTAINER_NAME cat /etc/nginx/nginx.conf | grep "worker_processes 2" >/dev/null
if [ $? -eq 0 ]; then
  echo "Niestandardowa konfiguracja Nginx działa"
else
  echo "Niestandardowa konfiguracja Nginx nie działa"
  exit 1
fi

info "SUKCES" "Skrypt działa poprawnie"





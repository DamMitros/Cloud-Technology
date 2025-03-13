info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

update_page(){
  local html=$1
  echo "$html" > index.html

  info "AKTUALIZACJA" "aktualizacja strony"
  docker cp index.html $CONTAINER_NAME:/usr/share/nginx/html/index.html
  rm index.html
}
CONTAINER_NAME="nginx-container"

info "SIEĆ" "Tworzenie sieci Docker dla kontenera"
docker network create nginx-network >/dev/null 2>&1

info "KONFIGURACJA" "użycie kontenera z serwerem Nginx"
CONTAINER_ID=$(docker run -d -p 8080:80 --network nginx-network --name $CONTAINER_NAME nginx)

echo "Utworzono kontener o ID: $CONTAINER_ID"

CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
info "IP KONTENERA" "adres IP kontenera to $CONTAINER_IP"

HTML="<html>
  <head>
    <title>Test</title>
  </head>
  <body>
    <h1>Strona Nginx przez kontener</h1>
    <p>Adres IP kontenera: $CONTAINER_IP</p>
    <p>Data: $(date)</p>
  </body>
</html>"

update_page "$HTML"

NEWHTML="<html>
  <head>
    <title>Test</title>
  </head>
  <body>
    <h1>Strona Nginx zaktualizowana przez kontener</h1>
    <p>Adres IP kontenera: $CONTAINER_IP</p>
    <p>Data: $(date)</p>
    <p>Nowe informacje</p>
    <p>Zawartość strony została zaktualizowana przez kontener</p>
  </body>
</html>"

info "TEST 1" "Sprawdzenie czy strona jest dostępna"
sleep 2 
if curl -s localhost:8080 | grep "Strona Nginx przez kontener"; then
  echo "Strona jest dostępna"
else
  echo "Strona nie jest dostępna"
  exit 1
fi


info "TEST 2" "Sprawdzanie czy strona została zaktualizowana"
sleep 5
update_page "$NEWHTML"
sleep 2

if docker run --rm --network nginx-network alpine:latest wget -qO- $CONTAINER_IP:80 | grep "Strona Nginx zaktualizowana przez kontener"; then
  echo "Strona została zaktualizowana"
else
  echo "Strona nie została zaktualizowana"
  exit 1
fi

info "SUKCES" "Testy zakończone powodzeniem"

docker rm -f $CONTAINER_NAME >/dev/null 2>&1
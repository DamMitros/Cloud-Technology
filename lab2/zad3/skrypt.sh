info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NODE_VERSION="16"

info "KONFIGURACJA" "UZYWAMY NODE.js w wersji $NODE_VERSION"

docker rm -f mongo-container >/dev/null 2>&1
docker rm -f node-server-container-db >/dev/null 2>&1

info "SIEC" "tworze siec dockerową łączącą kontenery"
docker network create app-network >/dev/null 2>&1

info "KONTENER" "tworze i uruchamiam kontener z bazą danych MongoDB"
DB_CONTAINER_ID=$(docker run -d -p 27017:27017 --network app-network --name mongo-container -it mongo:latest)

echo "Utworzono kontener z bazą danych o ID: $DB_CONTAINER_ID"

info "KONTENER" "tworze i uruchamiam kontener z node.js i aplikacją Express.js"
CONTAINER_ID=$(docker run -d -p 8080:8080 --network app-network --name node-server-container-db -it node:$NODE_VERSION-alpine sh -c "mkdir -p /app && tail -f /dev/null")

echo "Utworzono kontener z app.js o ID: $CONTAINER_ID"

info "KOPIOWANIE"
docker cp package.json $CONTAINER_ID:/app/
docker cp app.js $CONTAINER_ID:/app/

info "ZALEZNOSCI"
docker exec -w /app $CONTAINER_ID npm install

info "URUCHOMIENIE"
docker exec -d -w /app $CONTAINER_ID node app.js
echo "Serwer uruchomiony na porcie 8080"

info "TEST POŁĄCZENIA Z BAZĄ DANYCH"
sleep 5

mongo_status=$(docker exec -it $DB_CONTAINER_ID mongosh --eval "db.stats()" | grep "ok" || echo "error")
if [ "$mongo_status" == "error" ]; then
  echo "Błąd połączenia z bazą danych"
  exit 1
else
  echo "Połączenie z bazą danych OK"
fi

info "TESTY"
sleep 5
echo "Test dodania danych do bazy"
info "DODAWANIE DANYCH" 
# docker exec -it $DB_CONTAINER_ID mongosh --eval 'db.users.insertMany([
#   {"name": "Ewelina Lisowska", "email": "lisek122@gmail.com"},
#   {"name": "Krzysztof Krawczyk", "email": "krawiec123@gmail.com"},
#   {"name": "Marek Grechuta", "email": "gruszka124@gmail.com"}
# ])'

curl -s -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Ewelina Lisowska", "email": "lisek122@gmail.com"}' && \
curl -s -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Krzysztof Krawczyk", "email": "krawiec123@gmail.com"}' && \
curl -s -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Marek Grechuta", "email": "gruszka124@gmail.com"}'

sleep 5

echo "Test pobrania danych z bazy"
info "POBIERANIE DANYCH"
response=$(curl -s http://localhost:8080/users)

echo "Odpowiedź z serwera: $response"

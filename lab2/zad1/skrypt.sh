info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NODE_VERSION="12"

info "KONFIGURACJA" "UZYWAMY NODE.js w wersji $NODE_VERSION"

docker rm -f node-demo-container >/dev/null 2>&1

info "KONTENER" "tworze i uruchmamiam kontener z node.js"

CONTAINER_ID=$(docker run -d -p:8080:8080 --name node-demo-container -it node:$NODE_VERSION-alpine sh -c "mkdir -p /app && tail -f /dev/null")

echo "Utworzono kontener o ID: $CONTAINER_ID"

info "KOPIOWANIE" 

docker cp package.json $CONTAINER_ID:/app/
docker cp app.js $CONTAINER_ID:/app/

info "ZALEZNOSCI"

docker exec -w /app $CONTAINER_ID npm install

info "URUCHOMIENIE"

docker exec -w /app $CONTAINER_ID node app.js 


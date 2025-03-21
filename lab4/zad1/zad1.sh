info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

CONTAINER_NAME="nginx-container123"
VOLUME_NAME="nginx_data"

docker rm -f $CONTAINER_NAME 2>/dev/null

info "WOLUMIN" "Tworzenie woluminu Docker dla kontenera"
docker volume create nginx_data 

info "KONTENER" "użycie kontenera z serwerem Nginx"
docker run -d -p 8080:80 --name $CONTAINER_NAME -v nginx_data:/usr/share/nginx/html nginx

info "HTML" "Zmiana zawartości strony html"
docker exec -i $CONTAINER_NAME /bin/bash -c "cat > /usr/share/nginx/html/index.html" < index.html

info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONFIGURACJA" "Budowanie i start aplikacji w kontenerze Docker"
docker-compose up --build -d

echo "Aplikacja uruchomiona, dostępna pod adresem http://localhost:8080"
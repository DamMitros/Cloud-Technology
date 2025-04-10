info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONFIGURACJA" "Przygotowanie środowiska"

info "CZYSZCZENIE" "Zatrzymanie istniejących kontenerów"
docker-compose down 2>/dev/null

info "URUCHOMIENIE" "Uruchomienie kontenerów"
docker-compose up -d --build 

info "STATUS" "Sprawdzenie statusu kontenerów"
docker-compose ps

info "BAZA DANYCH" "Poczekanie na start bazy MongoDB"
sleep 10

info "DODAWANIE DANYCH" "Dodawanie danych do bazy MongoDB"
docker exec -it db mongo test --eval 'db.users.insertOne({
  "name": "user", 
  "last_name": "kowalski"
  })'

info "TEST" "Sprawdzenie dostępu do API"
echo "API dostępne pod adresem: http://localhost:3003/users"
echo "Odpowiedz z serwera:"
sleep 2 
curl -s http://localhost:3003/users

info "KONIEC" "Zatrzymanie kontenerów"
docker-compose down
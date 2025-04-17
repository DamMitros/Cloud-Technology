info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "PRZYGOTOWANIE" "Budowanie i uruchamianie aplikacji"

info "CZYSZCZENIE" "Zatrzymanie istniejących kontenerów"
docker-compose down 2>/dev/null

info "BUDOWANIE" "Budowanie obrazów Docker"
docker-compose build

info "URUCHOMIENIE" "Uruchamianie kontenerów"
docker-compose up -d

info "STATUS" "Sprawdzenie statusu kontenerów"
docker-compose ps

info "INFORMACJE" "Aplikacja dostępna pod adresem:"
echo "- http://localhost (przez Nginx)"
echo ""
echo "Dostępne endpointy:"
echo "- GET /messages/:key - Pobierz wiadomość o podanym kluczu"
echo "- POST /messages - Dodaj nową wiadomość (format: {\"key\": \"nazwa\", \"message\": \"treść\"})"
echo "- GET /users - Pobierz listę użytkowników"
echo "- POST /users - Dodaj nowego użytkownika (format: {\"username\": \"nazwa\", \"email\": \"adres\"})"

info "TESTOWANIE" "Dodawanie przykładowych danych"
sleep 5 
echo "1. Dodawanie wiadomości do Redis:"
curl -X POST http://localhost/messages \
  -H "Content-Type: application/json" \
  -d '{"key":"greeting", "message":"Hello from Docker!"}'
echo ""

echo "2. Pobieranie wiadomości z Redis:"
curl http://localhost/messages/greeting
echo ""

echo "3. Dodawanie użytkownika do PostgreSQL:"
curl -X POST http://localhost/users \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser", "email":"test@example.com"}'
echo ""

echo "4. Pobieranie listy użytkowników z PostgreSQL:"
curl http://localhost/users
echo ""

info "ZAKOŃCZONO" "Aplikacja uruchomiona pomyślnie!"
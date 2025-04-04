info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KONFIGURACJA" "Przygotowywanie środowiska mikroserwisów"

info "CZYSZCZENIE" "Zatrzymywanie istniejących kontenerów"
docker-compose down 2>/dev/null

info "URUCHAMIANIE" "Budowanie i uruchamianie usług"
docker-compose up -d --build

info "STATUS" "Sprawdzanie statusu usług"
docker-compose ps

sleep 10

info "TESTY POŁĄCZEŃ" "Sprawdzanie połączeń między serwisami"

info "Test 1" "Sprawdzanie łączności między frontendem a backendem"
if docker-compose exec frontend curl -sf http://backend:3000/api/health; then
    echo "✅ Frontend może komunikować się z backendem"
else
    echo "❌ Frontend nie może komunikować się z backendem"
fi

info "Test 2" "Sprawdzanie połączenia z bazą danych z backendu"
if docker-compose exec backend curl -sf http://backend:3000/api/data | grep -q "testuser"; then
    echo "✅ Backend może połączyć się z bazą danych i odczytać dane"
else
    echo "❌ Backend nie może połączyć się z bazą danych lub odczytać danych"
fi

info "Test 3" "Sprawdzanie izolacji sieci - frontend nie powinien mieć dostępu do bazy danych"
if docker-compose exec frontend ping -c 1 database 2>/dev/null; then
    echo "❌ Frontend może dotrzeć do bazy danych - to narusza izolację sieci!"
else
    echo "✅ Frontend nie może dotrzeć do bazy danych - izolacja sieci działa poprawnie"
fi

info "TESTY ZAKOŃCZONE" "Sprawdzanie łączności zakończone"
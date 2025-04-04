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

info "SIEĆ" "Informacje o sieci"
docker network inspect zad2_my_network

info "DOSTĘP" "Usługa webowa jest dostępna pod adresem http://localhost:8080"
echo "Poczekaj kilka sekund, aż baza danych się zainicjalizuje przed dostępem."
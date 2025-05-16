info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "KUBERNETES CLEANUP" "Usuwanie wszystkich istniejących zasobów"
# kubectl delete deployment mikroserwis-a-deployment --ignore-not-found
# kubectl delete deployment mikroserwis-b-deployment --ignore-not-found
# kubectl delete service mikroserwis-a-service --ignore-not-found
# kubectl delete service mikroserwis-b-service --ignore-not-found
# kubectl delete deployment mongo-deployment --ignore-not-found
# kubectl delete service mongo-service --ignore-not-found
# kubectl delete pvc mongo-pvc --ignore-not-found
# kubectl delete pv mongo-pv --ignore-not-found
# kubectl delete secret mongo-secret --ignore-not-found
# kubectl delete configmap mongo-config --ignore-not-found

info "DOCKER BUILD (1/2)" "Tworzenie obrazu Docker dla mikroserwisu A"
docker build -t mikroserwis-a:latest ./mikroserwis_a
if [ $? -ne 0 ]; then
  info "DOCKER BUILD" "Błąd podczas budowania obrazu mikroserwisu A"
  exit 1
fi

info "DOCKER BUILD (2/2)" "Tworzenie obrazu Docker dla mikroserwisu B"
docker build -t mikroserwis-b:latest ./mikroserwis_b
if [ $? -ne 0 ]; then
  info "DOCKER BUILD" "Błąd podczas budowania obrazu mikroserwisu B"
  exit 1
fi

if minikube status > /dev/null 2>&1; then
  info "MINIKUBE" "Wczytanie obrazów do Minikube"
  minikube image load mikroserwis-b:latest
  minikube image load mikroserwis-a:latest
fi

info "KUBERNETES APPLY (1/4)" "Zastosowanie PV(Persistent Volume) i PVC(PersistentVolumeClaim)"
kubectl apply -f database_serwis/mongo-pv.yaml
kubectl apply -f database_serwis/mongo-pvc.yaml

info "KUBERNETES APPLY (SECRET| 1.5/4)" "Zastosowanie MongoDB Secret"
kubectl apply -f database_serwis/mongo-secret.yaml

info "KUBERNETES APPLY (CONFIGMAP| 1.75/4)" "Zastosowanie MongoDB ConfigMap"
kubectl apply -f database_serwis/mongo-config.yaml

info "KUBERNETES APPLY (2/4)" "Zastosowanie MongoDB"
kubectl apply -f database_serwis/mongo-deployment.yaml
kubectl apply -f database_serwis/mongo-service.yaml

info "KUBERNETES APPLY (3/4)" "Zastosowanie mikroserwisu A"
kubectl apply -f mikroserwis_a/deployment.yaml 
kubectl apply -f mikroserwis_a/service.yaml   

info "KUBERNETES APPLY (4/4)" "Zastosowanie mikroserwisu B"
kubectl apply -f mikroserwis_b/deployment.yaml 
kubectl apply -f mikroserwis_b/service.yaml   

info "KUBERNETES STATUS (1/3)" "Sprawdzenie statusu zasobów"
sleep 15
kubectl get pods
kubectl get services

info "KUBERNETES PORT-FORWARD" "Uruchamianie port-forward dla mikroserwis-a-service (localhost:8080 -> service_port:80)"
kubectl port-forward service/mikroserwis-a-service 8080:80 > pf_a.log 2>&1 &
PF_PID_A=$!
info "PORT-FORWARD" "PID procesu port-forward: $PF_PID_A. Logi w pliku pf_a.log."
sleep 10

info "KUBERNETES STATUS (2/3)" "Przetestowanie wymagań zadania1: Komunikacja mikroserwis_a -> mikroserwis_b"
echo "Testowanie endpointu /call-ping w mikroserwis_a (który wywołuje /ping w mikroserwis_b):"
curl -s http://localhost:8080/call-ping

info "KUBERNETES STATUS (3/3)" "Przetestowanie wymagań zadania2: Interakcja z bazą danych przez mikroserwisy"
echo "Testowanie POST /items przez mikroserwis_a do mikroserwis_b (zapis do MongoDB):"
ITEM_PAYLOAD='{"name":"test-item-k8s","value":"'$(date +%s)'"}'
curl -s -X POST -H "Content-Type: application/json" -d "$ITEM_PAYLOAD" http://localhost:8080/items
echo -e "\n\n"
sleep 2
echo "Testowanie GET /items przez mikroserwis_a z mikroserwis_b (odczyt z MongoDB):"
curl -s http://localhost:8080/items
echo -e "\n\n"

trap - SIGINT SIGTERM EXIT
info "KUBERNETES CLEANUP" "Zatrzymywanie port-forward..."
kill $PF_PID_A
wait $PF_PID_A 2>/dev/null 
rm -f pf_a.log
echo "Port-forward zatrzymany."

info "KUBERNETES CLEANUP" "Usuwanie wszystkich istniejących zasobów"
kubectl delete deployment mikroserwis-a-deployment --ignore-not-found
kubectl delete deployment mikroserwis-b-deployment --ignore-not-found
kubectl delete service mikroserwis-a-service --ignore-not-found
kubectl delete service mikroserwis-b-service --ignore-not-found
kubectl delete deployment mongo-deployment --ignore-not-found
kubectl delete service mongo-service --ignore-not-found
kubectl delete pvc mongo-pvc --ignore-not-found
kubectl delete pv mongo-pv --ignore-not-found
kubectl delete secret mongo-secret --ignore-not-found
kubectl delete configmap mongo-config --ignore-not-found
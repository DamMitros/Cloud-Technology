# Lab 10 - Cloud Technology

## Zadanie 1
- Stworzenie i skonfigurowanie dwóch mikroserwisów (`mikroserwis_a` i `mikroserwis_b`) w klastrze Kubernetes.
- `mikroserwis_a` odpytuje API `mikroserwis_b`.
- `mikroserwis_a` jest dostępny lokalnie poprzez Service typu LoadBalancer.
- Komunikacja między mikroserwisami odbywa się poprzez usługi klastra.

## Zadanie 2
- Skonfigurowanie aplikacji składającej się z trzech serwisów: `mikroserwis_a`, `mikroserwis_b` i bazy danych (MongoDB).
- Każdy serwis działa jako oddzielny pod w klastrze.
- `mikroserwis_a` skalowany do trzech replik.
- `mikroserwis_b` i baza danych działają jako pojedyncze instancje.
- Skonfigurowanie PersistentVolume dla bazy danych.
- `mikroserwis_b` komunikuje się z bazą danych.
- `mikroserwis_a` jest dostępny z zewnątrz poprzez usługę typu LoadBalancer.

## Zadanie 3
- Ograniczenie zasobów (pamięć i CPU) dla każdego z podów:
    - `mikroserwis_a`: max 500Mi pamięci, 0.5 vCPU.
    - `mikroserwis_b`: max 1Gi pamięci, 1 vCPU.
    - Baza danych: max 2Gi pamięci, 2 vCPU.
- Cała konfiguracja zdefiniowana za pomocą plików YAML i aplikowana za pomocą `kubectl`.

### Wszystkie wymagania z 3 zadań spełnione są w jednym projekcie w katalogu `lab10`.
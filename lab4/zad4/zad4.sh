info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

SOURCE_VOLUME="source_data"
BACKUP_VOLUME="encrypted_backup"
RECOVERY_VOLUME="recovery_data"
PASSWORD="bezpieczne_haslo"
ENCRYPTED_FILE="volume_backup.tar.gz.gpg"

info "Przygotowanie" "Tworzenie woluminów Docker"
docker volume create $SOURCE_VOLUME
docker volume create $BACKUP_VOLUME
docker volume create $RECOVERY_VOLUME

info "Przygotowanie danych" "Dodawanie przykładowych danych do woluminu źródłowego"
docker run --rm -v $SOURCE_VOLUME:/data alpine sh -c "echo 'To jest przykładowy plik' > /data/test.txt && echo 'Sekretne dane' > /data/poufne.txt"

info "Zabezpieczanie woluminu" "Archiwizacja i szyfrowanie woluminu $SOURCE_VOLUME"
docker run --rm -v $SOURCE_VOLUME:/source:ro -v $BACKUP_VOLUME:/backup \
  alpine sh -c "apk update && apk add --no-cache gnupg && tar -czf - -C /source . | gpg --symmetric --cipher-algo AES256 --batch --passphrase $PASSWORD -o /backup/$ENCRYPTED_FILE"

info "Weryfikacja" "Sprawdzenie czy plik szyfrowy został utworzony"
if ! docker run --rm -v $BACKUP_VOLUME:/backup alpine sh -c "[ -f /backup/$ENCRYPTED_FILE ] && echo 'Plik istnieje' || echo 'Plik nie istnieje'"; then
  echo "Błąd: Plik szyfrowy nie został utworzony"
  exit 1
fi

info "Odszyfrowywanie woluminu" "Odszyfrowywanie zabezpieczonego woluminu do $RECOVERY_VOLUME"
docker run --rm -v $BACKUP_VOLUME:/backup:ro -v $RECOVERY_VOLUME:/recovery \
  alpine sh -c "apk update && apk add --no-cache gnupg && mkdir -p /recovery && gpg --decrypt --batch --passphrase $PASSWORD /backup/$ENCRYPTED_FILE | tar -xz -C /recovery"

info "Weryfikacja" "Sprawdzenie zawartości odzyskanego woluminu"
docker run --rm -v $RECOVERY_VOLUME:/recovery alpine sh -c "ls -la /recovery && cat /recovery/test.txt && cat /recovery/poufne.txt"

info "Zakończono" "Proces zabezpieczania i odszyfrowywania woluminów zakończony"

#Cyszczenei
docker volume rm $SOURCE_VOLUME $BACKUP_VOLUME $RECOVERY_VOLUME
info() {
  echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "WOLUMINY" "Sprawdzanie zużycia przestrzeni dyskowej woluminów Docker"

volumes=$(docker volume ls -q)
total_size=0
declare -A volume_sizes

echo "Obliczanie rozmiaru woluminów..."
for volume in $volumes; do
  size=$(docker run --rm -v $volume:/vol alpine sh -c "du -sk -b  /vol" | awk '{print $1}')
  volume_sizes[$volume]=$size
  total_size=$((total_size + size))
done

if [ $total_size -eq 0 ]; then
  total_size=1
fi

echo "+------------------------+------------+------------+"
echo "| Nazwa woluminu         | Rozmiar    | Użycie %   |"
echo "+------------------------+------------+------------+"

for volume in $volumes; do
  size=${volume_sizes[$volume]}

  if [ $size -ge 1048576 ]; then
    size_readable="$(echo "$size/1048576" | bc) GB"
  elif [ $size -ge 1024 ]; then
    size_readable="$(echo "$size/1024" | bc) MB"
  else
    size_readable="${size} KB"
  fi
  
  percent=$(echo "$size * 100 / $total_size" | bc)
  
  printf "| %-22s | %-10s | %-9.2f%% |\n" "$volume" "$size_readable" "$percent"
done

echo "+------------------------+------------+------------+"

info "ZAKOŃCZONO" "Sprawdzanie zużycia przestrzeni dyskowej"
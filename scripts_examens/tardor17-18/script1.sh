failed_services=$(systemctl --failed --no-legend --plain | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')

if [ -n "$failed_services" ]; then
    count=$(echo "$failed_services" | tr -cd ',' | wc -c)
    count=$((count + 1))
    echo "Hi ha $count serveis fallits:"
    echo "$failed_services"
else
    echo "Felicitats, tots els serveis estan correctes"
fi


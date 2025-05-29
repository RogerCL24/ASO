#!/bin/bash

# Primer paràmetre: llindar mínim
LIMIT=$1
shift  # Desplaça els arguments; ara "$@" conté només els usuaris

echo "Els usuaris:"

for user in "$@"; do
    count=$(find /home -user "$user" 2>/dev/null | wc -l)
    if [ "$count" -gt "$LIMIT" ]; then
        echo "$user"
    fi
done

echo "Tenen més de $LIMIT fitxers"


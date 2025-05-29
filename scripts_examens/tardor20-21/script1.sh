#!/bin/bash

for user in "$@"; do
    count=$(find /home -user "$user" 2>/dev/null | wc -l)
    echo "L’usuari $user té $count fitxers"
done


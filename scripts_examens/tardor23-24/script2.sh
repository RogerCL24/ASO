#!/bin/bash

# Comprova si s'ha passat el flag -l i un valor
if [[ "$1" == "-l" && -n "$2" ]]; then
    LIMIT=$2

    # Mostra tots els processos que superin el límit especificat
    ps -eo %mem,comm --sort=-%mem | awk -v lim="$LIMIT" 'NR > 1 && $1 + 0 > lim {print $1, $2}'
else
    # Comportament per defecte: mostra el procés que més memòria consumeix
    ps -eo %mem,comm --sort=-%mem | awk 'NR==2 {print $1, $2}'
fi


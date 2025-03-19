#!/bin/bash

p=0   # Flag para la opción -p (usuarios con procesos)
t=""  # Variable para la opción -t (usuarios inactivos)

# Función de ayuda
function print_help {
    echo "Usage: $0 [options]"
    echo "Possible options:"
    echo "  -p    Validate users with running processes"
    echo "  -t X  Detect inactive users (X can be 2d, 4m, etc.)"
}

# Validación de argumentos
if [ $# -gt 2 ]; then
    print_help
    exit 1
fi

# Procesar opciones
while [ $# -gt 0 ]; do
    case $1 in
        "-p") p=1 shift ;;
        "-t") shift; t=$1 ;;  # Guardar el valor del tiempo
        *) echo "Error: not valid option: $1"; exit 1 ;;
    esac
    shift
done

# Recorrer usuarios del sistema
for user in $(cut -d: -f1 /etc/passwd); do
    home=$(grep "^$user:" /etc/passwd | cut -d: -f6)

    if [ -d "$home" ]; then
        num_fich=$(find "$home" -type f -user "$user" 2>/dev/null | wc -l)
    else
        num_fich=0
    fi

    if [ $num_fich -eq 0 ]; then
        if [ $p -eq 1 ]; then
            user_proc=$(pgrep -u "$user" | wc -l)
            if [ $user_proc -eq 0 ]; then
                echo "The user $user has no processes"
            fi
        else
            echo "The user $user has no files in $home"
        fi
    fi

    # 🔹 DETECCIÓN DE USUARIOS INACTIVOS (-t)
    if [ -n "$t" ]; then            # Si $t no es de longitud 0 (es decir, se ha escrito -t al ejecutar)
        user_proc=$(pgrep -u "$user" | wc -l)   

        if [ $user_proc -eq 0 ]; then  # No tiene procesos activos
            last_login=$(lastlog -u "$user" | awk 'NR==2 {print $4, $5, $6}')  # Obtener última fecha de login

            # Extraer número y unidad (días o meses)
            num="${t//[!0-9]/}"  
            unit="${t//[0-9]/}"  

            # Convertir meses a días 
            if [ "$unit" == "m" ]; then
                num=$((num * 30))
            fi

            # Verificar archivos sin modificar en X días
            num_old_files=$(find "$home" -type f -user "$user" -mtime +"$num" 2>/dev/null | wc -l)

            if [ "$num_old_files" -gt 0 ]; then
                echo "The user $user has $num_old_files files"
            fi
        fi
    fi
done

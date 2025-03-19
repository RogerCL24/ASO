#!/bin/bash 

# Variables
group_mode=0
group_name=""
space_limit=""

# Funcion de ayuda 
function usage() {
    echo "Usage: $0 [-g group] <space_limit>"
    echo " -g group: Check disk usage for a specific group"
    echo " space_limit Disk usage limit (e.g., 600M, 500K)"
    exit 1
}

# Validar argumentos
if [[ $# -lt 1 || $# -gt 3 ]]; then 
    usage 
fi

# Leemos las opciones y sus argumentos 
while [[ $# -gt 0 ]]; do
    case "$1" in 
        -g) 
            group_mode=1          # flag -g activo
            group_name="$2"      
            shift 2
            ;;
        *)
            space_limit="$1" 
            shift
            ;;
    esac 
done 

# Validar <space_limit>
if [[ -z "$space_limit" ]]; then  # si <space_limit> mide 0, usage
    usage
fi 

# Para comparar el limite y lo que ocupan los users ponemos la misma medida, KB

limit=$(echo "$space_limit" | sed 's/M/*1024/' | sed 's/K/*1/   ' | bc) # sed multiplica por 1024 si es M o por 1 si es K, bc lo convierte en 
                                                                    # en un formato numerico compatible para hacer comparaciones

# Obtenemos los usuarios
if [[ "$group_mode" -eq 1 ]]; then 
    group_users=$(getent group "$group_name" | cut -d: -f4 | tr ',' ' ') # getent grop name, obtiene los users del grupo name
                                                                         # -f4 es la lista de users de ese grupo (la columna 4)
                                                                         # tr reemplaza las , por espacios, asi podemos iterar 
    # Obtenemos el propietario del grupo 
    group_owner=$(getent group "$group_name" | cut -d: -f1)

    # Agregamos el propietario del grupo a la lista de usuarios
    group_users="$group_users $group_owner"

    if [[ -z "$group_users" ]]; then                                     # No hay users en ese grupo o no existe el grupo
        echo "Error: Group '$group_name' not found"
        exit 1
    fi
else 
    group_users=$(ls /home)                                               # Opcion sin -g, en home estan todos los users, hacemos un ls y
                                                                          # pa dentro
fi
                                                            
# Calculamos el uso de disco de cada user
total_group_usage=0
for user in $group_users; do
    home_dir="/home/$user"

    # Si no tiene directorio lo ignoramos
    if [[ ! -d "$home_dir" ]]; then 
        continue
    fi

    size_used_human=$(du -sh "$home_dir" 2>/dev/null | awk '{print $1}')  # Ej: 500K, 1.2G
    size_used_kb=$(du -sk "$home_dir" 2>/dev/null | awk '{print $1}')  # Tamaño en KB

    if [[ -z "$size_used_kb" ]]; then                                      # si no devuelve size, lo ignoramos 
        continue
    fi

    echo "$user $size_used_human"

    # Verificamos si supera el limite 
    if [[ "$size_used_kb" -gt "$limit" ]]; then 
        msg="\n # WARNING: You are using too much disk space!\n# Please delete files.\n# To remove this message, run "

        # Solo lo agregamos en .bash_profile si no esta 
        if ! grep -q "WARNING" "$home_dir/.bash_profile" 2>/dev/null; then # -q significa que no imprime output (esta quiet)
            echo -e "$msg" >> "$home_dir/.bash_profile"
        fi
    fi

    # Sumamos el total si esta -g
    if [[ "$group_mode" -eq 1 ]]; then 
        total_group_usage=$((total_group_usage + size_used_kb))
    fi
done

if [[ "$group_mode" -eq 1 ]]; then 
    echo "Total group usage: $((total_group_usage)) KB"
fi
#!/bin/bash

# Si s’ha passat un paràmetre, el fem servir. Sinó, per defecte: 10
NUM=${1:-10}

# Mostra la capçalera i els N processos amb més temps de CPU acumulat
ps -eo pid,user,time,comm --sort=-time | head -n $((NUM + 1))


#!/bin/bash

# Obtén el procés que utilitza més memòria (ordenat pel %MEM)
ps -eo %mem,comm --sort=-%mem | awk 'NR==2 {print $1, $2}'


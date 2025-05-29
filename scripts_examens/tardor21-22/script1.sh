#!/bin/bash

# Desa temporalment el contingut en text de la web
w3m -dump https://www.ac.upc.edu/ca/nosaltres/serveis-tic/blog | grep -i "Actualització"


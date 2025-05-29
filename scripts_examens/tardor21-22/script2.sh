#!/bin/bash

latest=$(curl -s https://www.kernel.org/ | grep -m1 "mainline" | grep -oP '>[0-9]+\.[^<]+' | tr -d '>')
echo "The latest mainline kernel version is $latest"
echo "$latest" | sudo tee /var/lib/last.kernel > /dev/null


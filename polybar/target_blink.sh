#!/bin/bash

# Color Rojo Alerta de tu config
RED="#ff0000"

while true; do
    # Lee el archivo target
    IP=$(cat ~/.config/polybar/target 2>/dev/null)
    
    if [ -z "$IP" ] || [ "$IP" == "NONE" ]; then
        echo "NONE"
    else
        # %{F#ff0000} cambia el color a Rojo, %{F-} lo devuelve al original
        echo "%{F$RED}$IP%{F-}"
        sleep 0.7
        echo " "  # Espacio vacío para el parpadeo
        sleep 0.4
    fi
done

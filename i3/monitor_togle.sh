#!/bin/bash
# Nombres exactos según tu xrandr
INTERNAL="eDP"
EXTERNAL="HDMI-A-0"

# Si el monitor externo está activo (tiene resolución)
if xrandr | grep "$EXTERNAL connected" | grep -q "[0-9]x[0-9]"; then
    xrandr --output "$EXTERNAL" --off
    notify-send "Monitor Pared" "DESACTIVADO"
else
    # Lo activamos ARRIBA de la laptop
    xrandr --output "$EXTERNAL" --mode 1920x1080 --rate 60.00 --above "$INTERNAL"
    
    # IMPORTANTE: Cambia esta ruta por una real o dejará la pantalla negra
    feh --bg-fill /usr/share/backgrounds/desktop-background.jpg || echo "Fondo no encontrado"
    
    # Lanzamos Polybar en el nuevo monitor
    MONITOR=$EXTERNAL polybar --reload top &
    notify-send "Monitor Pared" "ACTIVADO"
fi

#!/bin/bash

# Opciones (Asegúrate de que coincidan exactamente con lo que eliges)
lock="󰌾 Lock"
logout="󰍃 Logout"
reboot="󰜉 Reboot"
shutdown="󰐥 Shutdown"

# Mostrar menú
selected=$(echo -e "$lock\n$logout\n$reboot\n$shutdown" | rofi -dmenu -p " SYSTEM CONTROL:" -theme ~/.config/rofi/soviet.rasi)

# Acciones
case "$selected" in
    "$lock")
        betterlockscreen -l blur
        ;;
    "$logout")
        notify-send "GHOST-HYDRA" "Disconnecting terminal..." -u critical
        
        # Efecto de fundido rápido
        for i in $(seq 100 -10 0); do
            picom-trans -a $i
            sleep 0.01
        done

        # Salida nuclear
        i3-msg exit || bspc quit || openbox --exit
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac

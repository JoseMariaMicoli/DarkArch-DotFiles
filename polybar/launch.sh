#!/usr/bin/env bash

# cargar entorno del usuario (arregla rofi, pactl, etc)
export $(dbus-launch)
export XDG_RUNTIME_DIR=/run/user/$(id -u)

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# barra superior
polybar top &

sleep 0.4

# barra inferior flotante
polybar bottom &

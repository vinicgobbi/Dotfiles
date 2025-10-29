#!/bin/bash
# Script: alterna entre perfis do Power Profiles Daemon

current=$(powerprofilesctl get)

case "$current" in
    power-saver)
        next="balanced"
        ;;
    balanced)
        next="performance"
        ;;
    performance)
        next="power-saver"
        ;;
    *)
        next="balanced"
        ;;
esac

powerprofilesctl set "$next"
notify-send "Modo de energia" "Perfil alterado para: $next" -i power-profile

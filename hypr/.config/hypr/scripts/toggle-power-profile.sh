#!/usr/bin/env bash
# toggle-power-profile.sh — Cicla los 3 perfiles del daemon.
#
# Ciclo: performance → balanced → power-saver → performance → ...

current=$(powerprofilesctl get)

case "$current" in
    performance)
        next="balanced"
        icon="󰌪"
        label="Balanced"
        ;;
    balanced)
        next="power-saver"
        icon="󰁾"
        label="Power Saver"
        ;;
    power-saver|*)
        next="performance"
        icon="󱓞"
        label="Performance"
        ;;
esac

powerprofilesctl set "$next"
notify-send -u low -t 2000 "${icon} Power Profile" "Cambiado a ${label}"
# Refresh inmediato del módulo custom/power-profile en waybar.
pkill -RTMIN+10 waybar 2>/dev/null || true

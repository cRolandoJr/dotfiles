#!/usr/bin/env bash
# toggle-dnd.sh — Activa/desactiva modo Do-Not-Disturb en mako.

makoctl mode -t do-not-disturb

# Leer el estado actual DESPUÉS del toggle para el mensaje correcto.
if makoctl mode | grep -q "do-not-disturb"; then
    notify-send -u low -t 2000 "󰂛 DND activado" "Las notificaciones están silenciadas"
else
    notify-send -u low -t 2000 "󰂚 DND desactivado" "Las notificaciones están habilitadas"
fi

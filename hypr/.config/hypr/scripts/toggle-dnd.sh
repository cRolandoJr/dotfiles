#!/usr/bin/env bash
# toggle-dnd.sh — Activa/desactiva modo Do-Not-Disturb en mako.
#
# Usa `makoctl mode -t do-not-disturb`:
#   - Si el modo NO está activo, lo agrega → mako invisible.
#   - Si el modo SÍ está activo, lo quita → mako vuelve a normal.
#
# Luego envía una notificación de feedback con el nuevo estado.
# notify-send usa urgency=low para que se vea brevemente y desaparezca sola.

makoctl mode -t do-not-disturb

# Leer el estado actual DESPUÉS del toggle para el mensaje correcto.
if makoctl mode | grep -q "do-not-disturb"; then
    notify-send -u low -t 2000 "󰂛 DND activado" "Las notificaciones están silenciadas"
else
    notify-send -u low -t 2000 "󰂚 DND desactivado" "Las notificaciones están habilitadas"
fi

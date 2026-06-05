#!/usr/bin/env bash
# keybinds-viewer.sh — visor de keybinds Hyprland (estilo cheatsheet rápido).
#
# Lee ~/.config/hypr/configs/binds.conf, agrupa por sección (comentarios
# "# --- SECTION ---" del archivo) y los muestra en rofi -dmenu con search
# fuzzy. Esc para cerrar; Enter no ejecuta nada (visualización pura).

set -euo pipefail

BINDS_FILE="$HOME/.config/hypr/configs/binds.conf"
THEME="$HOME/.config/rofi/keybinds/style.rasi"

awk '
BEGIN { section = "GENERAL" }

# Detectar sección: comentarios con guiones (# --- TEXT --- o variantes).
/^# --- .+/ {
    s = $0
    sub(/^#[[:space:]]*-+[[:space:]]*/, "", s)
    sub(/[[:space:]]*-+[[:space:]]*$/, "", s)
    # Limpiar paréntesis al final ej "(Submap)" → quitar
    sub(/[[:space:]]*\([^)]*\)[[:space:]]*$/, "", s)
    section = s
    next
}

/^#/ || /^[[:space:]]*$/ { next }

# Parser bind: "bind*" = MOD, KEY, dispatcher, args
/^bind[ldemu]*[[:space:]]*=/ {
    line = $0
    sub(/^bind[ldemu]*[[:space:]]*=[[:space:]]*/, "", line)
    n = split(line, parts, ",")
    if (n < 3) next

    mod = parts[1]; key = parts[2]
    action = parts[3]
    for (i=4; i<=n; i++) action = action "," parts[i]

    gsub(/^[[:space:]]+|[[:space:]]+$/, "", mod)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", action)

    combo = (mod == "" ? key : mod " + " key)
    # Acortar paths típicos para que entren en pantalla
    gsub(/\/home\/[^\/]+\/\.config\/hypr\/scripts\//, "~/scripts/", action)
    gsub(/[[:space:]]+/, " ", action)

    printf "[%s]  %-26s  →  %s\n", section, combo, action
}
' "$BINDS_FILE" | rofi -dmenu -i \
    -p "Keybinds" \
    -theme "$THEME" \
    -no-custom \
    -mesg "Buscá por sección, tecla o acción. Esc para cerrar."

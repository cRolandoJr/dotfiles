#!/usr/bin/env bash
# keybinds-viewer.sh — visor de keybinds Hyprland (estilo cheatsheet rápido).
#
# Lee los binds de `hyprctl binds`, o sea los que Hyprland tiene REALMENTE
# cargados, no lo que dice el archivo de config. Eso resuelve solo el loop de
# workspaces y los submaps, y sobrevive cambios de formato de la config.
#
# Agrupa por submap; los binds globales van bajo [GLOBAL]. Si el bind tiene
# description (los `bindd` de antes), se muestra esa en vez del dispatcher.
# rofi -dmenu con search fuzzy. Esc para cerrar; Enter no ejecuta nada.
#
# NOTA: no usar `hyprctl binds -j`. En 0.56 el JSON sale con las claves y los
# valores corridos un lugar y encima inválido; la salida de texto está bien.

set -euo pipefail

THEME="$HOME/.config/rofi/keybinds/style.rasi"

hyprctl binds | awk '
# Decodifica el modmask (bitmask de xkb) a nombres, en el orden en que se
# escriben los binds: SUPER, CTRL, ALT, SHIFT.
function mods(m,   s) {
    s = ""
    if (int(m / 64) % 2) s = s "SUPER + "
    if (int(m /  4) % 2) s = s "CTRL + "
    if (int(m /  8) % 2) s = s "ALT + "
    if (int(m /  1) % 2) s = s "SHIFT + "
    return s
}

function emit() {
    if (key == "") return
    group  = (submap == "" ? "GLOBAL" : toupper(submap))
    combo  = mods(modmask) key
    action = (desc != "" ? desc : dispatcher (arg != "" ? " " arg : ""))
    # Acortar paths típicos para que entren en pantalla
    gsub(/\/home\/[^\/]+\/\.config\/hypr\/scripts\//, "~/scripts/", action)
    gsub(/~\/\.config\/hypr\/scripts\//, "~/scripts/", action)
    gsub(/[[:space:]]+/, " ", action)
    printf "%-10s  %-26s  →  %s\n", "[" group "]", combo, action
}

# Un bloque nuevo empieza con el tipo de bind sin indentar (bind/binde/bindd/...)
/^bind/ {
    emit()
    modmask = 0; submap = ""; key = ""; desc = ""; dispatcher = ""; arg = ""
    next
}

# Campos: "\tclave: valor"
{
    line = $0
    sub(/^[[:space:]]+/, "", line)
    i = index(line, ":")
    if (i == 0) next
    k = substr(line, 1, i - 1)
    v = substr(line, i + 1)
    sub(/^[[:space:]]+/, "", v)

    if      (k == "modmask")     modmask    = v
    else if (k == "submap")      submap     = v
    else if (k == "key")         key        = v
    else if (k == "description") desc       = v
    else if (k == "dispatcher")  dispatcher = v
    else if (k == "arg")         arg        = v
}

END { emit() }
' | sort | rofi -dmenu -i \
    -p "Keybinds" \
    -theme "$THEME" \
    -no-custom \
    -mesg "Buscá por grupo, tecla o acción. Esc para cerrar."

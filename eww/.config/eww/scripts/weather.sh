#!/usr/bin/env bash
# Weather widget data source para el hub eww.
# Fetch Open-Meteo (gratis, sin API key); ubicación detectada por IP (cacheada).
# Salida: JSON con {temp, code, desc, icon, city}
#
# Llamado desde eww.yuck con defpoll cada 30m.

set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/eww"
location_cache="$cache_dir/location.json"
mkdir -p "$cache_dir"

# ─── Ubicación: usa cache si existe, si no fetch de ipinfo.io ────────────────
if [ ! -f "$location_cache" ] || [ ! -s "$location_cache" ]; then
    # ipinfo.io devuelve "loc": "lat,lon"
    if ! curl -sf --max-time 4 https://ipinfo.io/json > "$location_cache.tmp"; then
        # Fallback: si no hay red, devuelve placeholder vacío para no romper eww.
        echo '{"temp":"--","code":0,"desc":"Sin red","icon":"󰖑","city":""}'
        rm -f "$location_cache.tmp"
        exit 0
    fi
    mv "$location_cache.tmp" "$location_cache"
fi

lat=$(jq -r '.loc | split(",") | .[0]' "$location_cache")
lon=$(jq -r '.loc | split(",") | .[1]' "$location_cache")
city=$(jq -r '.city // ""' "$location_cache")

# ─── Open-Meteo current_weather ──────────────────────────────────────────────
url="https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true"
if ! resp=$(curl -sf --max-time 5 "$url"); then
    echo "{\"temp\":\"--\",\"code\":0,\"desc\":\"API caída\",\"icon\":\"󰖑\",\"city\":\"$city\"}"
    exit 0
fi

temp=$(echo "$resp" | jq -r '.current_weather.temperature | round')
code=$(echo "$resp" | jq -r '.current_weather.weathercode')

# ─── Mapeo WMO weathercode → descripción + icono Nerd Font ───────────────────
# Códigos según https://open-meteo.com/en/docs (WMO Weather interpretation codes)
case "$code" in
    0)              desc="Despejado";          icon="󰖙" ;;
    1|2)            desc="Mayormente claro";   icon="󰖕" ;;
    3)              desc="Nublado";            icon="󰖐" ;;
    45|48)          desc="Niebla";             icon="󰖑" ;;
    51|53|55)       desc="Llovizna";           icon="󰖗" ;;
    56|57)          desc="Llovizna helada";    icon="󰙿" ;;
    61|63|65)       desc="Lluvia";             icon="󰖎" ;;
    66|67)          desc="Lluvia helada";      icon="󰙿" ;;
    71|73|75|77)    desc="Nieve";              icon="󰖘" ;;
    80|81|82)       desc="Chubascos";          icon="󰖖" ;;
    85|86)          desc="Nevadas";            icon="󰖘" ;;
    95)             desc="Tormenta";           icon="󰼶" ;;
    96|99)          desc="Tormenta granizo";   icon="󰼶" ;;
    *)              desc="?";                  icon="󰖑" ;;
esac

jq -n \
    --arg temp "$temp" \
    --argjson code "$code" \
    --arg desc "$desc" \
    --arg icon "$icon" \
    --arg city "$city" \
    '{temp: $temp, code: $code, desc: $desc, icon: $icon, city: $city}'

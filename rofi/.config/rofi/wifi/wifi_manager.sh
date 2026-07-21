#!/usr/bin/env bash
set -euo pipefail

# Themes
LIST_THEME="$HOME/.config/rofi/wifi/list.rasi"
ENABLE_THEME="$HOME/.config/rofi/wifi/enable.rasi"
SSID_THEME="$HOME/.config/rofi/wifi/ssid.rasi"
PASSWORD_THEME="$HOME/.config/rofi/wifi/password.rasi"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 127; }; }
need nmcli
need rofi
need awk
need sort
need sed

notify() { notify-send -t 3000 -i network-wireless "$@"; }

theme_arg() {
  local f="$1"
  if [[ -n "$f" && -f "$f" ]]; then
    printf -- "-theme %s" "$f"
  else
    printf ''
  fi
}

enable_wifi_menu() {
  local ta; ta=$(theme_arg "$ENABLE_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -p "Wi‑Fi is off" $ta
}

list_wifi_menu() {
  local ta; ta=$(theme_arg "$LIST_THEME")
  {
    printf "%s\n" "   Disable Wi‑Fi"
    printf "%s\n" "   Manual Setup"
    printf "%s\n" "󰚃   Forget network"
    [[ -n "${connection_status:-}" ]] && printf "%s\n" "$connection_status"
    printf "%s\n" "────────── Redes ──────────"
    printf "%s\n" "${wifi_list}"
  } | (
    # -display-columns 1: la col 2 (SSID crudo tras tab) viaja oculta para el parseo.
    # shellcheck disable=SC2086
    rofi -markup-rows -dmenu -display-columns 1 -display-column-separator "$(printf '\t')" $ta
  )
}

prompt_ssid() {
  local ta; ta=$(theme_arg "$SSID_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -p "SSID" $ta
}

prompt_password() {
  local ta; ta=$(theme_arg "$PASSWORD_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -password -p "Password" $ta
}

forget_menu() {
  local ta; ta=$(theme_arg "$LIST_THEME")
  # shellcheck disable=SC2086
  printf '%s\n' "$@" | rofi -dmenu -p "Forget" $ta
}

# --- Saved connections ---
# SAVED[ssid]=perfil, cargado UNA sola vez y en paralelo (-P8): la consulta
# secuencial por perfil costaba ~25ms × perfil. Separador tab (SSIDs con ':').
declare -A SAVED=()
# shellcheck disable=SC2016  # $1 debe expandir dentro del sh -c, no acá
while IFS=$'\t' read -r prof_ssid name; do
  [[ -n "$prof_ssid" && -n "$name" ]] && SAVED["$prof_ssid"]="$name"
done < <(
  nmcli -t -f NAME,TYPE connection show \
  | awk -F: '$2=="802-11-wireless"{print $1}' \
  | xargs -r -P8 -I{} sh -c 'printf "%s\t%s\n" "$(nmcli -g 802-11-wireless.ssid connection show "$1" 2>/dev/null)" "$1"' _ {}
)

connect_without_prompt() {
  local ssid="$1"

  # 1) Preferir levantar el perfil guardado (si existe)
  if [[ -n "${SAVED[$ssid]:-}" ]]; then
    nmcli -w 12 connection up "${SAVED[$ssid]}" && return 0
    # si falla, seguimos a intentar directo por SSID
  fi

  # 2) Intentar conectar por SSID sin password (open o secrets ya guardados)
  out="$(nmcli -w 12 device wifi connect "$ssid" 2>&1)" && return 0

  # 3) Detectar caso "necesita clave"
  if grep -qiE "secrets were required|need.*secrets|password.*required|No secrets|not provided" <<<"$out"; then
    return 10
  fi

  return 1
}

# MAIN
wifi_status="$(nmcli -t -f WIFI general | tail -n1 | tr -d '\r\n' || true)"

if [[ "$wifi_status" == "disabled" ]]; then
  choice=$(enable_wifi_menu) || exit 0
  [[ -z "$choice" ]] && exit 0
  nmcli radio wifi on
  sleep 1
fi

# Rescan async: refresca la caché de NM para la PRÓXIMA apertura. Los listados
# van con --rescan no: el default "auto" bloquea 2-5s esperando el scan cuando
# NM considera vieja la caché (la lentitud intermitente del menú venía de ahí).
nmcli device wifi rescan >/dev/null 2>&1 || true

connected_ssid="$(nmcli -t -f active,ssid dev wifi list --rescan no | awk -F: '$1=="yes"{print $2; exit}' || true)"
if [[ -n "$connected_ssid" ]]; then
  connection_status="   Connected to ${connected_ssid}"
else
  connection_status=""
fi

# Build wifi list (marca 󰌾 los SSID con perfil guardado, vía SAVED)
wifi_list=$(
  nmcli -t -f SIGNAL,BARS,SSID,SECURITY dev wifi list --rescan no 2>/dev/null \
  | sort -rn \
  | awk -F: '
  {
    sig=$1; bars=$2; ssid=$3; sec=$4;

    if (ssid == "" || seen[ssid]++) next;

    lock = (sec ~ /WPA|WEP|802\.1X/) ? "" : "";
    printf "%s  %s  %s\t%s\n", bars, lock, ssid, ssid
  }' \
  | while IFS= read -r line; do
      ssid="${line##*$'\t'}"
      if [[ -n "${SAVED[$ssid]:-}" ]]; then
        printf "󰌾  %s\n" "$line"
      else
        printf "   %s\n" "$line"
      fi
    done
)

choice="$(list_wifi_menu)" || exit 0

# Trim
choice="${choice#"${choice%%[![:space:]]*}"}"
choice="${choice%"${choice##*[![:space:]]}"}"
[[ -z "$choice" ]] && exit 0

case "$choice" in
  *"Disable Wi‑Fi"*|"*Disable Wi-Fi"*)
    nmcli radio wifi off
    notify "Wi‑Fi disabled"
    ;;
  *"Manual Setup"*)
    ssid=$(prompt_ssid) || ssid=""
    [[ -z "$ssid" ]] && exit 0
    password=$(prompt_password) || password=""
    if [[ -n "$password" ]]; then
      nmcli dev wifi connect "$ssid" password "$password"
    else
      nmcli dev wifi connect "$ssid" hidden yes
    fi
    ;;
  *"Forget network"*)
    [[ ${#SAVED[@]} -eq 0 ]] && { notify "Wi‑Fi" "No saved networks"; exit 0; }
    sel="$(forget_menu "${!SAVED[@]}")" || exit 0
    [[ -z "$sel" || -z "${SAVED[$sel]:-}" ]] && exit 0
    nmcli connection delete "${SAVED[$sel]}"
    notify "Forgotten" "$sel"
    ;;
  *"Connected to "* )
    conn_name="$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="802-11-wireless"{print $1; exit}' || true)"
    if [[ -n "$conn_name" ]]; then
      if command -v foot >/dev/null 2>&1; then
        foot sh -c "nmcli connection show \"$conn_name\"; echo; read -p 'Press Return to close...'"
      else
        nmcli connection show "$conn_name" | less
      fi
    else
      notify "No active Wi‑Fi connection found"
    fi
    ;;
  *)
    if [[ "$choice" == *$'\t'* ]]; then
      ssid="${choice##*$'\t'}"
    else
      ssid="$(echo "$choice" | sed -E 's/^[^[:alnum:]]+//')"
    fi
    [[ -z "$ssid" ]] && exit 0

    # OJO: no usar `if fn; then…fi` + `rc=$?` — un if fallido sin else deja $?=0
    # y el return 10 ("necesita clave") se perdía: red nueva protegida nunca
    # llegaba al prompt de password.
    rc=0
    connect_without_prompt "$ssid" || rc=$?
    if [[ $rc -eq 0 ]]; then
      notify "Connected" "$ssid"
      exit 0
    fi
    if [[ $rc -ne 10 ]]; then
      notify "Wi‑Fi error" "Failed to connect to $ssid"
      exit 1
    fi

    # Need secrets: ask password once, then connect
    password=$(prompt_password) || password=""
    [[ -z "$password" ]] && exit 0
    nmcli -w 12 device wifi connect "$ssid" password "$password"
    notify "Connected" "$ssid"
    ;;
esac

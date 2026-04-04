#!/usr/bin/env bash
set -euo pipefail
export PS4='+ ${LINENO}: '
LOG=/tmp/wifi-run.log
CHOICE_LOG=/tmp/rofi-wifi-choice
: >"$LOG"
: >"$CHOICE_LOG"

log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG"; }

# Paths to Rofi themes (ajusta si hace falta)
LIST_THEME="$HOME/.config/rofi/wifi/list.rasi"
ENABLE_THEME="${HOME}/.config/rofi/wifi/enable.rasi"
SSID_THEME="$HOME/.config/rofi/wifi/ssid.rasi"
PASSWORD_THEME="${HOME}/.config/rofi/wifi/password.rasi"

log "Starting wifi script"
log "ENV: XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-<unset>}"
log "ENV: WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-<unset>}"
log "ENV: DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-<unset>}"

notify() { notify-send -t 3000 -i network-wireless "$@"; }

log "Notify test (non-fatal)"
if ! timeout 2 notify-send "Wi‑Fi script starting"; then
  log "notify-send failed or timed out (ignored)"
fi

# helper to build theme arg only if file exists
theme_arg() {
  local f="$1"
  if [[ -n "$f" && -f "$f" ]]; then
    printf -- "-theme %s" "$f"
  else
    printf ''
  fi
}

# Menu functions (use theme_arg to avoid passing missing theme)
enable_wifi_menu() {
  local ta
  ta=$(theme_arg "$ENABLE_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -p "Wi‑Fi is off" $ta
}

# list menu: build content then pipe to rofi; log rc and output
list_wifi_menu() {
  local ta
  ta=$(theme_arg "$LIST_THEME")
  {
    printf "%s\n" "   Disable Wi‑Fi"
    printf "%s\n" "   Manual Setup"
    printf "%s\n" "────────── Redes ──────────"
    printf "%s\n" "${wifi_list}"
  } | ( # shellcheck disable=SC2086
       rofi -markup-rows -dmenu $ta
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

get_security_for_ssid() {
  local ssid="$1"
  nmcli -t -f SSID,SECURITY device wifi list | awk -F: -v s="$ssid" '$1==s {print $2; exit}'
}

# MAIN
wifi_status="$(nmcli -t -f WIFI general | tail -n1 | tr -d '\r\n' || true)"
log "wifi_status='$wifi_status'"

if [[ "$wifi_status" == "disabled" ]]; then
  log "Wi‑Fi disabled, asking to enable..."
  choice=$(enable_wifi_menu) || choice=""
  log "enable menu returned rc=$? choice='$choice'"
  if [[ -n "$choice" ]]; then
    nmcli radio wifi on
    sleep 1
  else
    log "User cancelled enable menu, exiting"
    exit 0
  fi
fi

nmcli device wifi rescan >/dev/null 2>&1 || log "nmcli rescan failed"
sleep 0.6

connected_ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2; exit}' || true)
if [[ -n "$connected_ssid" ]]; then
  connection_status="   Connected to ${connected_ssid}"
else
  connection_status=""
fi

wifi_list=$(nmcli -t -f SIGNAL,BARS,SSID,SECURITY dev wifi list 2>/dev/null | sort -rn | awk -F: '
{
  sig=$1; bars=$2; ssid=$3; sec=$4;
  
  # Evitamos SSIDs vacíos o repetidos (nos quedamos con el de mejor señal gracias al sort previo)
  if (ssid == "" || seen[ssid]++) next;
  
  # Definimos el icono según seguridad
  icon = (sec ~ /WPA|WEP|802\.1X/) ? "" : "";
  
  # Formateamos la línea para Rofi: [Barras] Icono SSID :::SSID
  # El :::SSID al final es el "truco" para que el script sepa qué conectar después
  printf "%s  %s  %s :::%s\n", bars, icon, ssid, ssid
}')

log "Prepared wifi_list (first 20 lines):"
printf '%s\n' "$wifi_list" | sed -n '1,20p' | tee -a "$LOG"

# run menu and capture rc + output
choice="$(list_wifi_menu)"
rofi_rc=$?
printf '%s\n' "choice='$choice'" > "$CHOICE_LOG"
printf '%s\n' "rofi_rc=$rofi_rc" >> "$CHOICE_LOG"
log "Rofi rc=$rofi_rc choice='${choice}' (also saved to $CHOICE_LOG)"

if [[ $rofi_rc -ne 0 ]]; then
  log "Rofi cancelled or failed (rc=$rofi_rc); exiting"
  exit 0
fi

# Trim spaces
choice="${choice#"${choice%%[![:space:]]*}"}"
choice="${choice%"${choice##*[![:space:]]}"}"

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
  *"Connected to "* )
    conn_name=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="wifi"{print $1; exit}')
    if [[ -n "$conn_name" ]]; then
      kitty -e sh -c "nmcli connection show \"$conn_name\"; echo; read -p 'Press Return to close...'"
    else
      notify "No active Wi‑Fi connection found"
    fi
    ;;
  *)
    if [[ "$choice" == *":::"* ]]; then
      ssid="${choice##*:::}"
    else
      ssid="$(echo "$choice" | sed -E 's/^[^[:alnum:]]+//')"
    fi
    [[ -z "$ssid" ]] && exit 0
    sec=$(get_security_for_ssid "$ssid" || true)
    if [[ -z "$sec" || "$sec" == "--" ]]; then
      nmcli device wifi connect "$ssid"
    else
      password=$(prompt_password) || password=""
      [[ -z "$password" ]] && exit 0
      nmcli device wifi connect "$ssid" password "$password"
    fi
    ;;
esac

log "Done."

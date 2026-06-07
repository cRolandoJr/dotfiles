#!/usr/bin/env bash
# wifi.sh — LEGACY; usar wifi_manager.sh (más robusto con saved-connections y logging).

set -euo pipefail

notify-send -t 3000 -i info "   Checking for Wi-Fi..."

LIST_THEME="$HOME/.config/rofi/wifi/list.rasi"
ENABLE_THEME="$HOME/.config/rofi/wifi/enable.rasi"
SSID_THEME="$HOME/.config/rofi/wifi/ssid.rasi"
PASSWORD_THEME="$HOME/.config/rofi/wifi/password.rasi"

enable_wifi_menu() {
    echo -e "Enable Wi-Fi" | rofi -dmenu -theme "$ENABLE_THEME"
}

wifi_status=$(nmcli -t -f WIFI general | tail -n1)

if [[ "$wifi_status" == "disabled" ]]; then
    choice=$(enable_wifi_menu)
    nmcli radio wifi on
fi

connected_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2-)

wifi_list=$(nmcli -t -f ssid,security dev wifi | awk -F: '
{
    icon = ($2 ~ /WPA|WEP|802\.1X/) ? "" : "";
    if ($1 != "") {
        printf "%s   %s\n", icon, $1
    }
}' | sort -u)

if [[ -n "$connected_ssid" ]]; then
    connection_status="   Connected to $connected_ssid\n"
else
    connection_status=""
fi

list_wifi_menu() {
    echo -e "   Disable Wi-Fi\n${connection_status}   Manual Setup\n${wifi_list}" | rofi -markup-rows -dmenu -theme "$LIST_THEME"
}

prompt_ssid() {
    rofi -dmenu -p "SSID" -theme "$SSID_THEME"
}

prompt_password() {
    rofi -dmenu -p "Password" -theme "$PASSWORD_THEME"
}

if [[ "$wifi_status" == "enabled" ]]; then
    choice=$(list_wifi_menu)
else
    choice=$(enable_wifi_menu)
    nmcli radio wifi on
fi

choice=$(echo "$choice" | sed -E 's/^[^a-zA-Z0-9]+//')
echo $choice

case "$choice" in
    "Enable Wi-Fi")
        nmcli radio wifi on
        ;;

    "Disable Wi-Fi")
        nmcli radio wifi off
        ;;

    "Manual Setup")
        ssid=$(prompt_ssid)
        [[ -z "$ssid" ]] && exit 0
        password=$(prompt_password)
        nmcli dev wifi connect "$ssid" hidden yes password "$password"
        ;;

    "Connected to"*)
        kitty -e sh -c "nmcli dev wifi show-password; read -p 'Press Return to close...'"
        ;;

    "")
        exit 0
        ;;

    *)
        password=$(prompt_password)
        nmcli dev wifi connect "$choice" password "$password"
        ;;
esac

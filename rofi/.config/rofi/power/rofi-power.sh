#!/usr/bin/env bash

chosen=$(printf "⏻\n󰑓\n󰒲\n󰌾\n󰗼" | rofi \
  -dmenu \
  -p "Power" \
  -no-custom \
  -theme ~/.config/rofi/power/style-power.rasi \
  -width 35)"

[[ -z "$chosen" ]] && exit 0

case "$chosen" in
  "⏻" systemctl poweroff ;;
  "󰑓" systemctl reboot ;;
  "󰒲" systemctl suspend ;;
  "󰌾" hyprlock ;;
  "󰗼" hyprctl dispatch exit ;;
esac

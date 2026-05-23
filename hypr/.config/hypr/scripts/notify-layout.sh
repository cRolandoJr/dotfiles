#!/usr/bin/env bash
layout=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send "Layout" "$layout"

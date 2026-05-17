#!/usr/bin/env bash
set -euo pipefail

# Select an item from clipboard history
sel="$(cliphist list | fuzzel --prompt="Clipboard> " --dmenu)" || exit 0

# Decode and copy to clipboard
cliphist decode <<<"$sel" | wl-copy

#!/usr/bin/env bash

# This script handles DPMS commands for Hyprland.

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        cat <<'EOF'
Usage: dpms_handler.sh ACTION
Turn monitors on or off for the current window manager.

Arguments:
    on                  Turn monitors on
    off                 Turn monitors off
    -h, --help          Show this help message
EOF
        exit 0
fi

WM=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

if [ "$WM" = "hyprland" ]; then
    hyprctl eval "hl.dispatch(hl.dsp.dpms({ action = \"$1\" }))"
fi
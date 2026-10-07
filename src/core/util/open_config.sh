#!/usr/bin/env bash
set -euo pipefail

# This script opens Tobimune and Hyprland configuration files in VS Code.

# Check dependency
if ! command -v code &> /dev/null; then
    echo "VS Code (code) is not installed. Please install it to use this script." >&2
    exit 1
fi

paths=(
    "$HOME/.config/waybar"
    "$HOME/.config/rofi"
    "$HOME/.config/swaync"
    "$HOME/.config/kitty"
    "$HOME/.config/fastfetch"
    "$HOME/.zshrc"
)

# Add Hyprland configs only if running.
if [[ $XDG_CURRENT_DESKTOP == "Hyprland" ]]; then
    paths+=("$HOME/.config/hypr")
fi

# Keep only existing paths
existing=()
for p in "${paths[@]}"; do
    [[ -e "$p" ]] && existing+=("$p")
done

if [[ ${#existing[@]} -eq 0 ]]; then
    echo "No config paths found to open." >&2
    exit 1
fi

# Open all existing config paths in the editor
exec code -n "${existing[@]}"
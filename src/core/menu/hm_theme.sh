#!/usr/bin/env bash

spawn() { ( "$@" & ) >/dev/null 2>&1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tobimune_theme.sh"

if [[ $# -eq 0 ]]; then
    # Random Wallpaper
    WALL_STATUS=$(cat "/tmp/random_wallpaper_status" 2>/dev/null || echo "0")
    WALL_TEXT="OFF"
    [[ "$WALL_STATUS" == "1" ]] && WALL_TEXT="ON"

    # Tobimune Shell
    TOBIMUNE_SHELL_STATUS=$(cat "$STATE_DIR/tobimune_shell_state" 2>/dev/null || echo "0")
    TOBIMUNE_SHELL_TEXT="OFF"
    [[ "$TOBIMUNE_SHELL_STATUS" == "1" ]] && TOBIMUNE_SHELL_TEXT="ON"

    # Taskbar
    TASKBAR_STATUS=$(cat "$STATE_DIR/taskbar_manual_state" 2>/dev/null || echo "0")
    TASKBAR_TEXT="OFF"
    [[ "$TASKBAR_STATUS" == "1" ]] && TASKBAR_TEXT="ON"

    # Waybar
    WAYBAR_STATUS=$(cat "$STATE_DIR/waybar_manual_state" 2>/dev/null || echo "0")
    WAYBAR_TEXT="OFF"
    [[ "$WAYBAR_STATUS" == "1" ]] && WAYBAR_TEXT="ON"

    # Desktop Icons
    DESKTOP_ICONS_STATUS=$(cat "$STATE_DIR/desktop_icons_state" 2>/dev/null || echo "0")
    DESKTOP_ICONS_TEXT="OFF"
    [[ "$DESKTOP_ICONS_STATUS" == "1" ]] && DESKTOP_ICONS_TEXT="ON"

    # Rounded Screen
    ROUNDED_SCREEN_STATUS=$(cat "$STATE_DIR/rounded_screen_state" 2>/dev/null || echo "0")
    ROUNDED_SCREEN_TEXT="OFF"
    [[ "$ROUNDED_SCREEN_STATUS" == "1" ]] && ROUNDED_SCREEN_TEXT="ON"

    # Edge Trigger
    EDGE_TRIGGER_STATUS=$(cat "$STATE_DIR/edge_trigger_state" 2>/dev/null || echo "0")
    EDGE_TRIGGER_TEXT="OFF"
    [[ "$EDGE_TRIGGER_STATUS" == "1" ]] && EDGE_TRIGGER_TEXT="ON"

    # Opaque Theme
    OPAQUE_STATUS=$(cat "$STATE_DIR/opaque_theme_state" 2>/dev/null || echo "0")
    IS_OPAQUE=""
    [[ "$OPAQUE_STATUS" == "1" ]] && IS_OPAQUE="(ON)" || IS_OPAQUE="(OFF)"

    cat <<EOF
  Change Theme
󰆧  Tobimune Shell ($TOBIMUNE_SHELL_TEXT)
  Desktop ($DESKTOP_ICONS_TEXT)
󰅹  Waybar ($WAYBAR_TEXT)
󰐃  Taskbar ($TASKBAR_TEXT)
  Rounded Screen ($ROUNDED_SCREEN_TEXT)
  Edge Trigger ($EDGE_TRIGGER_TEXT)
  Opaque Theme Mode $IS_OPAQUE
  Auto Random Wallpaper ($WALL_TEXT)
󰏜  Change Wallpaper
󱛹  Kill Lively Wallpaper
EOF
    exit 0
fi

chosen="$*"
case "$chosen" in
    *"Change Theme"*) spawn $HOME/.local/bin/change_theme.sh ;;
    *"Tobimune Shell"*) spawn $HOME/.local/bin/tobimune_shell_mode.sh --toggle ;;
    *"Desktop"*) spawn $HOME/.local/bin/desktop_icons_manager.sh --toggle ;;
    *"Waybar"*) spawn $HOME/.local/bin/waybar_manager.sh --toggle ;;
    *"Taskbar"*) spawn $HOME/.local/bin/taskbar_manager.sh --toggle ;;
    *"Rounded Screen"*) spawn $HOME/.local/bin/rounded_screen_manager.sh --toggle ;;
    *"Edge Trigger"*) spawn $HOME/.local/bin/edge_trigger_manager.sh --toggle ;;
    *"Opaque Theme Mode"*) spawn $HOME/.local/bin/opaque_theme.sh --toggle ;;
    *"Auto Random Wallpaper"*) spawn $HOME/.local/bin/random_wallpaper.sh --toggle ;;
    *"Change Wallpaper"*) spawn $HOME/.local/bin/wallpaper_select.sh ;;
    *"Kill Lively Wallpaper"*) spawn $HOME/.local/bin/wallpaper_select.sh --exit ;;
esac

exit 0
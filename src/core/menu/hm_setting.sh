#!/usr/bin/env bash

spawn() { ( "$@" & ) >/dev/null 2>&1; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tobimune_theme.sh"

if [[ $# -eq 0 ]]; then
    DOCK_APP_NAME="OFF"
    if grep -qE '"format":\s*"\{icon\} \{name\}"' $HOME/.local/state/tobimune/taskbar-theme 2>/dev/null; then
        DOCK_APP_NAME="ON"
    fi

    DOCK_ICON_SIZE=$(grep -oP '"icon-size":\s*\K\d+' $HOME/.local/state/tobimune/taskbar-theme 2>/dev/null)
    DOCK_ICON_SIZE_TEXT="$DOCK_ICON_SIZE"
    DOCK_ICON_SIZE_TEXT+="px"

    DYNAMIC_STATUS=$(cat "$STATE_DIR/rounded_screen_dynamic_state" 2>/dev/null || echo "1")
    IS_DYNAMIC=""
    [[ "$DYNAMIC_STATUS" == "1" ]] && IS_DYNAMIC="(ON)" || IS_DYNAMIC="(OFF)"

    cat <<INNEREOF
󱂩  Taskbar App Name ($DOCK_APP_NAME)
󱂩  Taskbar Icon Size Change ($DOCK_ICON_SIZE_TEXT)
󰍹  Rounded Screen Dynamic Exclusive $IS_DYNAMIC
󱁤  Settings Folder
󱁤  TobimuneMenu General Tab
󰖩  Wifi
󰂯  Bluetooth
󰋊  Disk Manager
󰃢  Storage Manager
  Audio Control
INNEREOF
    exit 0
fi

chosen="$*"
case "$chosen" in
    *"Taskbar App Name"*) spawn $HOME/.local/bin/taskbar_manager.sh --app-name ;;
    *"Taskbar Icon Size Change"*) spawn $HOME/.local/bin/taskbar_manager.sh --icon-size ;;
    *"Rounded Screen Dynamic Exclusive"*) spawn $HOME/.local/bin/rounded_screen_manager.sh --toggle-dynamic ;;
    *"Settings Folder"*) spawn xdg-open "$HOME/suzaku" ;;
    *"TobimuneMenu General Tab"*) spawn code $HOME/suzaku/general-menu.sh ;;
    *"Wifi"*) spawn nm-connection-editor ;;
    *"Bluetooth"*) spawn blueman-manager ;;
    *"Disk Manager"*) spawn gparted ;;
    *"Storage Manager"*) spawn kitty --class ncdu -e sudo ncdu / ;;
    *"Audio Control"*) spawn pavucontrol ;;
esac

exit 0

#!/usr/bin/env bash

# Include Font Size Settings
[ -f "$HOME/suzaku/setting.sh" ] && source "$HOME/suzaku/setting.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        cat <<'EOF'
Usage: tobimune.sh [OPTION]
Open or clear the Tobimune desktop widgets.

Options:
    --clear             Close all Tobimune windows
    --do-not-exit       Do not exit after opening windows (useful for debugging)
    -h, --help          Show this help message
EOF
        exit 0
fi

need() { command -v "$1" >/dev/null 2>&1 || { echo "$1 is required"; exit 1; }; }

# Check dependencies
need kitty
need tty-clock
need lavat
need jq

# Main
TOBIMUNE_CLOCK_FONT_SIZE=${TOBIMUNE_CLOCK_FONT_SIZE:-10}
TOBIMUNE_GENERAL_FONT_SIZE=${TOBIMUNE_GENERAL_FONT_SIZE:-11}
TOBIMUNE_TERMINAL_FONT_SIZE=${TOBIMUNE_TERMINAL_FONT_SIZE:-14}

spawn() { ( setsid "$@" & ) >/dev/null 2>&1; }

clear() {
    PIDS=$(pgrep -f "seylavat|seyclock|seycmd")

    for pid in $PIDS; do
        echo "Killing window with PID: $pid"
        kill -9 "$pid"
    done
}

lavat() {
    spawn kitty --title "tobimunelavat" --class "seylavat" -o font_size=$TOBIMUNE_GENERAL_FONT_SIZE sh -c "lavat -c white -k white -r1"
    sleep 0.2
}

clock() {
    spawn kitty --title "tobimuneclock" --class "seyclock" -o font_size=$TOBIMUNE_CLOCK_FONT_SIZE sh -c "tty-clock -c -C 7 -r -b"
    sleep 0.2
}

cmd() {
    spawn kitty --title "tobimunecmd" --class "seycmd" -o font_size=$TOBIMUNE_TERMINAL_FONT_SIZE --hold fastfetch
    sleep 0.2
}


if [[ $1 == "--clear" ]]; then
    clear
    exit 0
fi

# Main

# Exec for Hyprland
if [[ $XDG_CURRENT_DESKTOP == "Hyprland" ]]; then
    MY_INFO=$(hyprctl activewindow -j)
    MY_ADDR=$(echo "$MY_INFO" | jq -r '.pid')
    LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')
    
    clear
    sleep 0.1

        
    hyprctl eval "hl.dispatch(hl.dsp.window.float({ window = 'pid:${MY_ADDR}' }))"
    hyprctl eval "hl.dispatch(hl.dsp.window.resize({ x = 600, y = 300, window = 'pid:${MY_ADDR}' }))"

    if [[ $LAYOUT == "scrolling" ]]; then
        cmd
        clock
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seyclock" }))'
        lavat
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seyclock" }))'
        hyprctl eval 'hl.dispatch(hl.dsp.layout("consume"))'
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seycmd" }))'
    elif [[ $LAYOUT == "dwindle" ]]; then
        clock
        cmd
        hyprctl eval 'hl.dispatch(hl.dsp.window.move({ direction = "left", window = "class:seycmd" }))'
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seyclock" }))'
        lavat
        hyprctl eval 'hl.dispatch(hl.dsp.window.move({ direction = "right", window = "class:seylavat" }))'
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seylavat" }))'
        hyprctl eval 'hl.dispatch(hl.dsp.window.move({ direction = "up", window = "class:seylavat" }))'
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seycmd" }))'
    elif [[ $LAYOUT == "master" ]]; then
        lavat
        clock
        cmd
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = "class:seycmd" }))'
    fi

    hyprctl eval "hl.dsp.exec_cmd('hyprctl keyword input:follow_mouse 1')"
    
    if [[ $1 != "--do-not-exit" ]]; then
        kill -9 $PPID
    fi

    exit 0
fi

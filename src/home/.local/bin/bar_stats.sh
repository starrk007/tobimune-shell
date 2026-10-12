#!/usr/bin/env bash

# CPU y RAM
cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}')
ram=$(free -m | awk '/Mem:/ {printf "%.1fG", $3/1024}')

# Volumen
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2*100)}')

# Batería
bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo "100")
bat_status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo "Discharging")
charging="false"
[[ "$bat_status" == "Charging" ]] && charging="true"

# Red (Ethernet vs Wi-Fi)
dev=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+')
if [[ "$dev" == eth* || "$dev" == enp* ]]; then
    net="󰈀"
else
    net="󰤨"
fi

# Bluetooth
bt="false"
bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && bt="true"

# Formato JSON de salida
printf '{"cpu":"%s%%","ram":"%s","vol":"%s%%","bat":"%s%%","charging":%s,"net":"%s","bt":%s}\n' \
    "$cpu" "$ram" "${vol:-0}" "$bat" "$charging" "$net" "$bt"

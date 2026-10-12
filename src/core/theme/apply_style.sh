#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tobimune_theme.sh"

# Apply GTK font (best-effort)
if command -v gsettings >/dev/null 2>&1; then
    if [[ -n "${FONT_FAMILY:-}" && -n "${FONT_SIZE:-}" ]]; then
        gtk_font="${FONT_FAMILY} ${FONT_SIZE}"
        gsettings set org.gnome.desktop.interface font-name "$gtk_font" || true
        gsettings set org.gnome.desktop.interface monospace-font-name "$gtk_font" || true
    fi
fi

# Reload apps
"$HOME/.local/bin/reload_config.sh" >/dev/null 2>&1 || true

if [[ -f "$HOME/.local/bin/desktop_icons_manager.sh" ]]; then
    "$HOME/.local/bin/desktop_icons_manager.sh" --reload >/dev/null 2>&1 || true
fi

# ... (resto de apply_style.sh) ...

# Extraer el color actual para inyectarlo en Kitty
ACCENT_COLOR=$(grep '@define-color accent_color' "$HOME/.local/state/tobimune/theme/colors.css" | awk '{print $3}' | tr -d ';')

for s in /tmp/kitty-*; do
    [[ -S "$s" ]] || continue
    kitty @ --to "unix:$s" load-config >/dev/null 2>&1 || true
    kitty @ --to "unix:$s" set-colors -a \
        "foreground=$ACCENT_COLOR" \
        "cursor=$ACCENT_COLOR" \
        "color1=$ACCENT_COLOR" \
        "color2=$ACCENT_COLOR" \
        "color3=$ACCENT_COLOR" \
        "color4=$ACCENT_COLOR" \
        "color5=$ACCENT_COLOR" \
        "color6=$ACCENT_COLOR" >/dev/null 2>&1 || true
done

# Quickshell
pkill -x quickshell 2>/dev/null || true
sleep 0.5
export QML_XHR_ALLOW_FILE_READ=1
quickshell -p "$HOME/.config/tobimune/shell.qml" >/dev/null 2>&1 &
disown

# Refrescar CAVA si está abierto
pkill -USR2 cava >/dev/null 2>&1 || true


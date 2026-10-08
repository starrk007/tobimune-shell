#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:-$HOME/.config/swaync/avatar.jpg}"
OUTPUT_DIR="$HOME/.local/state/tobimune/swaync"
OUTPUT="$OUTPUT_DIR/avatar.png"
SIZE=176
RADIUS=28

if ! command -v magick >/dev/null 2>&1; then
    echo "ImageMagick (magick) is required to generate the SwayNC avatar." >&2
    exit 1
fi

if [[ ! -f "$SOURCE" ]]; then
    echo "Avatar source image not found: $SOURCE" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

magick "$SOURCE" \
    -auto-orient \
    -thumbnail "${SIZE}x${SIZE}^" \
    -gravity center \
    -extent "${SIZE}x${SIZE}" \
    \( -size "${SIZE}x${SIZE}" xc:none \
        -fill white \
        -draw "roundrectangle 0,0 $((SIZE - 1)),$((SIZE - 1)) $RADIUS,$RADIUS" \
    \) \
    -alpha off \
    -compose CopyOpacity \
    -composite \
    "$OUTPUT"

printf 'Generated SwayNC avatar: %s\n' "$OUTPUT"

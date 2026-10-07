#!/usr/bin/env bash

# ==============================================================================
# TOBIMUNE SHELL - Configuración de Variables Globales y Rutas del Sistema
# ==============================================================================

# Directorio base del repositorio principal
TOBIMUNE_DIR="${TOBIMUNE_DIR:-$HOME/tobimune-shell}"
SOURCE_DIR="$TOBIMUNE_DIR/src"
HOME_SRC_DIR="$SOURCE_DIR/home"
ASSETS_DIR="$TOBIMUNE_DIR/assets"

# Directorio de respaldo con marca de tiempo
BACKUP_TS="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$HOME/.backup/Backup_$BACKUP_TS"

# Lista de paquetes base (Exclusivo Hyprland)
PKG_SERVICE="$SOURCE_DIR/packages/pkg-service.txt"
PKG_CORE="$SOURCE_DIR/packages/pkg-core.txt"
PKG_OPTIONAL="$SOURCE_DIR/packages/pkg-optional.txt"
PKG_HYPRLAND="$SOURCE_DIR/packages/pkg-hyprland.txt"

# Directorio de configuración personalizada del usuario (SUZAKU)
SUZAKU_CUSTOM_DIR="$HOME_SRC_DIR/suzaku"
DEST_CUSTOM_DIR="$HOME/suzaku"

# Directorios de configuración (.config)
SOURCE_CONFIG="$HOME_SRC_DIR/.config"
DEST_CONFIG="$HOME/.config"

# Configuraciones que se despliegan una sola vez (update.sh no las sobrescribirá)
ONCE_CONFIGS=(
    "$SOURCE_CONFIG/Thunar"
    "$SOURCE_CONFIG/xfce4"
    "$SOURCE_CONFIG/mpv"
    "$SOURCE_CONFIG/btop"
    "$SOURCE_CONFIG/cava"
    "$SOURCE_CONFIG/mimeapps.list"
)

# Configuraciones que se omiten del despliegue general (.config)
SKIP_CONFIGS=(
    "$SOURCE_CONFIG/hypr"
    "$SOURCE_CONFIG/gtk-3.0"
)

# Directorio de scripts del sistema
SOURCE_CORE="$SOURCE_DIR/core"
DEST_BIN="$HOME/.local/bin"
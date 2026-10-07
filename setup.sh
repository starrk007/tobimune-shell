#!/usr/bin/env bash
set -u

TOBIMUNE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ASSETS_DIR="$TOBIMUNE_DIR/assets"
ICON_DIR="$HOME/.icons"
THEME_DIR="$HOME/.themes"
tela_dir=""
midnight_dir=""

cleanup() {
    [[ -n "$tela_dir" ]] && rm -rf "$tela_dir"
    [[ -n "$midnight_dir" ]] && rm -rf "$midnight_dir"
}
trap cleanup EXIT

mkdir -p "$ICON_DIR" "$THEME_DIR"

echo ""
echo "Cursor Setup:"
read -p ">>> Do you want to install Bibata Cursor Theme? (y/n): " install_bibata
if [[ "$install_bibata" =~ ^[Yy]$ ]]; then
    if [[ ! -f "$ASSETS_DIR/Bibata-Modern-Ice.tar.gz" ]]; then
        echo "[!] Bibata archive not found: $ASSETS_DIR/Bibata-Modern-Ice.tar.gz"
        exit 1
    fi
    echo ":: Extracting Bibata Cursor Theme to ~/.icons/..."
    tar -xzf "$ASSETS_DIR/Bibata-Modern-Ice.tar.gz" -C "$ICON_DIR"
fi

echo ""
echo "Icons Setup:"
read -p ">>> Do you want to install Tela Icon Theme? (y/n): " install_tela
if [[ "$install_tela" =~ ^[Yy]$ ]]; then
    if ! command -v git >/dev/null 2>&1; then
        echo "[!] git is required to install Tela Icon Theme."
        exit 1
    fi
    echo ":: Installing Tela Icon Theme..."
    tela_dir="$(mktemp -d)"
    if ! git clone --depth 1 https://github.com/vinceliuice/Tela-icon-theme "$tela_dir/Tela-icon-theme"; then
        echo "[!] Failed to download Tela Icon Theme."
        exit 1
    fi
    if ! "$tela_dir/Tela-icon-theme/install.sh" -d "$ICON_DIR" -c "black"; then
        echo "[!] Failed to install Tela Icon Theme."
        exit 1
    fi
fi

echo ""
echo "Theme (Widget) Setup:"
read -p ">>> Do you want to install Midnight Gray Theme? (y/n): " install_midnight
if [[ "$install_midnight" =~ ^[Yy]$ ]]; then
    if ! command -v git >/dev/null 2>&1; then
        echo "[!] git is required to install Midnight Theme."
        exit 1
    fi
    echo ":: Installing Midnight Gray Theme..."
    echo ":: Copying Midnight Gray Theme to ~/.themes/..."
    midnight_dir="$(mktemp -d)"
    if ! git clone --depth 1 https://github.com/i-mint/midnight "$midnight_dir/midnight"; then
        echo "[!] Failed to download Midnight Theme."
        exit 1
    fi
    if ! cp -r "$midnight_dir/midnight/Midnight-Gray" "$THEME_DIR/"; then
        echo "[!] Failed to install Midnight Gray Theme."
        exit 1
    fi
fi

echo ""
echo "Setup completed."
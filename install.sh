#!/usr/bin/env bash
set -u

TOBIMUNE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

source "$TOBIMUNE_DIR/scripts/variables.sh"
source "$TOBIMUNE_DIR/scripts/functions.sh"

# ======================================================================================
# MAIN FLOW
# ======================================================================================

print_header ">>> TOBIMUNE SHELL INSTALLER <<<" "Press CTRL+C to cancel at any time."

select_deploy_mode

# ============================================================================
# BLOCK 1: CHECK AND INSTALL DEPENDENCIES
# ============================================================================
step_title "1 - CHECK AND INSTALL DEPENDENCIES (yay, git, curl)"

# Check if pacman is available (Arch Linux / CachyOS)
if command -v pacman >/dev/null 2>&1; then
    if command -v yay >/dev/null 2>&1; then
        log_ok "yay is installed."
    else
        if ask_yes_no "===> Do you want to install yay now?"; then
            git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
            (cd /tmp/yay && makepkg -si --noconfirm)
            cd "$HOME" || exit 1
            rm -rf /tmp/yay
            log_ok "yay has been installed successfully."
        else
            log_warn "You need yay to proceed with package installation automatically."
        fi
    fi
else
    log_error "You're not on an Arch-based distro."
    log_error "Please install the required packages manually."
fi

if ! command -v yay >/dev/null 2>&1; then
    log_error "yay is not installed. Please install yay first to run step 2."
fi

DEPENDENCIES=("git" "curl")
for pkg in "${DEPENDENCIES[@]}"; do
    if command -v "$pkg" >/dev/null 2>&1; then
        log_ok "$pkg exists."
    else
        log_warn "$pkg not found."
        if ask_yes_no "===> Install $pkg by yay now?"; then
            yay -S --noconfirm "$pkg"
        else
            log_warn "You need $pkg for full installer flow."
        fi
    fi
done

echo ""
print_divider
echo -e "${C_GREEN}--- Everything is ready to install Tobimune Shell! ---${C_RESET}"

# ============================================================================
# BLOCK 2: INSTALL PACKAGES
# ============================================================================
step_title "2 - INSTALL PACKAGES FROM LIST"

PKG_LABELS=()
PKG_FILES=()

log_info "Required: pkg-core.txt & pkg-hyprland.txt"
log_info "CTRL+C to cancel. Edit lists in ~/tobimune-shell/src/packages/"

if command -v yay >/dev/null 2>&1; then
    PKG_LABELS=("HYPRLAND" "CORE" "SERVICE" "OPTIONAL")
    PKG_FILES=("$PKG_HYPRLAND" "$PKG_CORE" "$PKG_SERVICE" "$PKG_OPTIONAL")

    INSTALL_FLAGS=()
    for i in "${!PKG_LABELS[@]}"; do
        INSTALL_FLAGS+=(0)
    done

    echo ":: Package lists:"
    for i in "${!PKG_LABELS[@]}"; do
        echo "   [$i] ${PKG_LABELS[$i]} : from $(shorten_path "${PKG_FILES[$i]}")"
    done
    echo ""

    for i in "${!PKG_LABELS[@]}"; do
        if ask_yes_no "===> Mark ${PKG_LABELS[$i]} for installation?"; then
            INSTALL_FLAGS[$i]=1
        else
            INSTALL_FLAGS[$i]=0
        fi
    done

    echo ""
    echo ":: Install plan (1=install, 0=skip): [${INSTALL_FLAGS[*]}]"
    echo ""

    selected_count=0
    for i in "${!PKG_LABELS[@]}"; do
        if [[ "${INSTALL_FLAGS[$i]}" -eq 1 ]]; then
            ((selected_count++))
        fi
    done

    if [[ "$selected_count" -eq 0 ]]; then
        log_skip "No package group selected. Skipping Block 2."
    else
        for i in "${!PKG_LABELS[@]}"; do
            if [[ "${INSTALL_FLAGS[$i]}" -eq 1 ]]; then
                install_pkg_file "${PKG_LABELS[$i]}" "${PKG_FILES[$i]}"
            else
                log_skip "[${PKG_LABELS[$i]}] Not selected."
            fi
        done
        log_ok "Block 2 package processing finished."
    fi
else
    log_error "yay is not installed. Please install yay first to run this step."
    log_error "Install yay on Arch/CachyOS before continuing."
fi

# ============================================================================
# BLOCK 3: CREATE NECESSARY DIRECTORIES
# ============================================================================
step_title "3 - CREATE NECESSARY DIRECTORIES"

FOLDERS=(
    "$HOME/.config"
    "$HOME/.icons"
    "$HOME/.themes"
    "$HOME/Pictures/Wallpapers"
    "$HOME/Pictures/Screenshots"
)

for folder in "${FOLDERS[@]}"; do
    ensure_dir "$folder"
done

log_ok "All necessary directories have been created."

# ============================================================================
# BLOCK 4: BACKUP AND COPY CONFIG
# ============================================================================
step_title "4 - SETUP TOBIMUNE CONFIG"

log_info "Deploying configs to ~/.config"

if ask_yes_no "===> Do you want to setup tobimune config now?"; then

    echo ">>> Deploying configs..."
    for item in "$SOURCE_CONFIG"/*; do
        [[ -e "$item" ]] || continue
        item_name="$(basename "$item")"
        
        is_skipped=0
        for once in "${ONCE_CONFIGS[@]}"; do
            [[ "$once" == "$item" ]] && { is_skipped=1; break; }
        done
        for skip in "${SKIP_CONFIGS[@]}"; do
            [[ "$skip" == "$item" ]] && { is_skipped=1; break; }
        done
        [[ $is_skipped -eq 1 ]] && continue

        deploy_config_item "$item" "$DEST_CONFIG/$item_name"
    done
    
    deploy_config_item "$SOURCE_CONFIG/hypr/hypridle.conf" "$DEST_CONFIG/hypr/hypridle.conf"
    deploy_config_item "$SOURCE_CONFIG/hypr/hyprlock.conf" "$DEST_CONFIG/hypr/hyprlock.conf"
    deploy_config_item "$SOURCE_CONFIG/hypr/hyprlock_tiny.conf" "$DEST_CONFIG/hypr/hyprlock_tiny.conf"

    echo ">>> Deploying Once configs..."
    for item in "${ONCE_CONFIGS[@]}"; do
        [[ -e "$item" ]] || continue
        item_name="$(basename "$item")"
        if [[ -d "$item" ]]; then
            copy_dir_content "$item" "$DEST_CONFIG/$item_name"
        else
            copy_file "$item" "$DEST_CONFIG/$item_name"
        fi
    done

    echo ">>> Deploying Hyprland configs..."
    deploy_config_item "$SOURCE_CONFIG/hypr/config" "$DEST_CONFIG/hypr/config"
    deploy_config_item "$SOURCE_CONFIG/hypr/hyprland.lua" "$DEST_CONFIG/hypr/hyprland.lua"

    echo ">>> Deploying Thunar gtk.css theme..."
    deploy_config_item "$SOURCE_CONFIG/gtk-3.0/gtk.css" "$DEST_CONFIG/gtk-3.0/gtk.css"

    echo ">>> Deploying starship.toml..."
    deploy_config_item "$SOURCE_CONFIG/starship.toml" "$DEST_CONFIG/starship.toml"

    echo ">>> Deploying .nanorc..."
    deploy_config_item "$HOME_SRC_DIR/.nanorc" "$HOME/.nanorc"

    log_ok "Configurations deployed finished."
else
    log_skip "Skipping config deployment."
fi

# ============================================================================
# BLOCK 5: SETUP TOBIMUNE SCRIPTS
# ============================================================================
step_title "5 - SETUP TOBIMUNE SCRIPTS"

log_info "Deploying Tobimune scripts to ~/.local/bin"

if ask_yes_no "===> Do you want to setup tobimune scripts now?"; then
    if deploy_tobimune_scripts; then
        log_ok "Tobimune script deployment completed."
    else
        log_error "Tobimune script deployment failed."
    fi
else
    log_skip "Skipping Tobimune script deployment."
fi

# ============================================================================
# BLOCK 6: INSTALL LOCAL ASSETS
# ============================================================================
step_title "6 - INSTALL LOCAL ASSETS"

log_info "Install cursor, icons and theme from local assets"

if ask_yes_no "===> Do you want to setup tobimune assets: Cursor, Icons and Theme?"; then
    if bash "$TOBIMUNE_DIR/setup.sh"; then
        log_ok "Local assets setup completed."
    else
        log_error "Local assets setup failed."
    fi
else
    log_skip "Skipping local assets setup."
fi

# ============================================================================
# BLOCK 7: FINAL SETUP
# ============================================================================
step_title "7 - FINAL SETUP: MAKE SOMETHING WORK"

check_state_dir

if [[ ! -f "$HOME/.local/state/tobimune/state/state.env" ]]; then
    "$HOME/.local/bin/gen_style.sh" --font "JetBrainsMono Nerd Font"
    log_ok "Executed gen_style.sh"
else
    log_skip "Skipping gen_style.sh execution."
fi

if [[ ! -f "$HOME/.local/state/tobimune/opaque_theme_state" ]]; then
    "$HOME/.local/bin/opaque_theme.sh" off >/dev/null 2>&1
    log_ok "Executed opaque_theme.sh"
else
    log_skip "Skipping opaque_theme.sh execution."
fi

# Change default shell to fish
echo ""
if command -v fish >/dev/null 2>&1; then
    FISH_PATH="$(command -v fish)"
    
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    
    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        chsh -s "$FISH_PATH" "$USER"
        log_ok "Changed default shell to fish ($FISH_PATH)."
    else
        log_skip "Fish is already your default shell."
    fi
else
    log_warn "Fish shell is not installed. Skipping shell change."
fi

# Init Suzaku Control
echo ""
check_control_dir

# Set GNOME color scheme to dark
echo ""
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    log_ok "Set GNOME color scheme to dark."
fi

# Set Thunar as default file manager if installed
echo ""
if command -v thunar >/dev/null 2>&1; then
    xdg-mime default thunar.desktop inode/directory
    log_ok "Set Thunar as default file manager."
fi

echo ""
print_divider
echo -e "${C_BOLD}${C_GREEN}  All done! Please restart your pc to apply changes!${C_RESET}"
echo -e "${C_MAGENTA}  Backup folder for this run: $BACKUP_DIR${C_RESET}"
print_divider
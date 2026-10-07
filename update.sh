#!/usr/bin/env bash
set -u



TOBIMUNE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

source "$TOBIMUNE_DIR/scripts/variables.sh"
source "$TOBIMUNE_DIR/scripts/functions.sh"

# ======================================================================================
# MAIN FLOW
# ======================================================================================

print_header ">>> CONFIG UPDATER <<<"

# ============================================================================
# BLOCK 0: UPDATE REPOSITORY (LATEST vs STABLE)
# ============================================================================
step_title "0 - UPDATE DOTFILES REPOSITORY"

SCRIPT_NAME=$(basename "$0")
BACKUP_SCRIPT="/tmp/${SCRIPT_NAME}.bak"

cp "$0" "$BACKUP_SCRIPT"

echo "Select update mode:"
echo -e "${C_BOLD}[1]${C_RESET} LATEST (Pull from main branch - Try the lastest changes)"
echo -e "${C_BOLD}[2]${C_RESET} STABLE (Checkout latest release tag - Recommended for stability)"
echo -e "${C_BOLD}[0]${C_RESET} SKIP (Do not update repository)"
echo ""
read -r -p ">>> Choose mode (1/2/0): " update_mode

REPO_CHANGED=0

if [[ "$update_mode" == "1" ]]; then
    log_info "Switching to main branch and pulling latest changes..."
    git -C "$TOBIMUNE_DIR" checkout main
    git -C "$TOBIMUNE_DIR" pull origin main
    log_ok "Repository updated to LATEST."
    REPO_CHANGED=1
elif [[ "$update_mode" == "2" ]]; then
    log_info "Fetching tags from remote..."
    git -C "$TOBIMUNE_DIR" fetch --tags
    LATEST_TAG=$(git -C "$TOBIMUNE_DIR" describe --tags $(git -C "$TOBIMUNE_DIR" rev-list --tags --max-count=1) 2>/dev/null)
    if [[ -z "$LATEST_TAG" ]]; then
        log_warn "No tags found in repository. Falling back to main branch."
        git -C "$TOBIMUNE_DIR" checkout main
        git -C "$TOBIMUNE_DIR" pull origin main
    else
        log_info "Latest stable tag found: $LATEST_TAG"
        git -C "$TOBIMUNE_DIR" checkout "$LATEST_TAG"
        log_ok "Repository updated to STABLE ($LATEST_TAG)."
    fi
    REPO_CHANGED=1
elif [[ "$update_mode" == "0" ]]; then
    log_skip "Skipping repository update."
else
    log_error "Invalid choice. Skipping repository update."
fi

if [[ "$REPO_CHANGED" -eq 1 && -f "$BACKUP_SCRIPT" ]]; then
    if ! cmp -s "$BACKUP_SCRIPT" "$0"; then
        echo ""
        log_warn "Detecting that '$SCRIPT_NAME' has new updates in repository!"
        log_info "Re-executing script with updated logic..."
        rm -f "$BACKUP_SCRIPT"
        exec "$0" "$@"
    fi
    rm -f "$BACKUP_SCRIPT"
fi

# ============================================================================
# BLOCK 1: UPDATE PACKAGES
# ============================================================================
step_title "1 - UPDATE PACKAGES FROM LISTS"

PKG_LABELS=()
PKG_FILES=()

if command -v yay >/dev/null 2>&1; then
    PKG_LABELS=("HYPRLAND" "CORE" "SERVICE")
    PKG_FILES=("$PKG_HYPRLAND" "$PKG_CORE" "$PKG_SERVICE")

    echo ">>> Package lists to be updated automatically:"
    for i in "${!PKG_LABELS[@]}"; do
        echo "  - ${PKG_LABELS[$i]}: from $(shorten_path "${PKG_FILES[$i]}")"
    done
    echo ""

    if ask_yes_no "===> Do you want to install/update ALL packages now?"; then
        for i in "${!PKG_LABELS[@]}"; do
            label="${PKG_LABELS[$i]}"
            file="${PKG_FILES[$i]}"
            install_pkg_file "$label" "$file"
        done
        log_ok "All package installations/updates completed."
    else
        log_skip "Skipping package installation/update."
    fi
else
    log_error "yay is not installed. Please install yay first to run this step."
    log_error "Install yay on Arch/CachyOS before continuing."
fi

# ============================================================================
# BLOCK 2: BACKUP AND COPY CONFIG
# ============================================================================
step_title "2 - BACKUP AND UPDATE CONFIG IN ~/.config"

if ask_yes_no "===> Do you want to update tobimune configs now?"; then

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

    echo ">>> Deploying Hyprland configs..."
    deploy_config_item "$SOURCE_CONFIG/hypr/config" "$DEST_CONFIG/hypr/config"
    deploy_config_item "$SOURCE_CONFIG/hypr/hyprland.lua" "$DEST_CONFIG/hypr/hyprland.lua"

    echo ">>> Deploying Thunar gtk.css theme..."
    deploy_config_item "$SOURCE_CONFIG/gtk-3.0/gtk.css" "$DEST_CONFIG/gtk-3.0/gtk.css"

    echo ">>> Deploying starship.toml (starship configuration)..."
    deploy_config_item "$SOURCE_CONFIG/starship.toml" "$DEST_CONFIG/starship.toml"

    echo ">>> Deploying .nanorc (nano configuration)..."
    deploy_config_item "$HOME_SRC_DIR/.nanorc" "$HOME/.nanorc"

    log_ok "Configurations deployed finished."
else
    log_skip "Skipping config deployment."
fi

# ============================================================================
# BLOCK 3: BACKUP AND COPY LOCAL BIN
# ============================================================================
step_title "3 - BACKUP AND UPDATE TOBIMUNE SCRIPTS"

if ask_yes_no "===> Do you want to update tobimune scripts now?"; then
    if deploy_tobimune_scripts; then
        log_ok "Tobimune Shell script update completed."
    else
        log_warn "Tobimune Shell script update failed."
    fi
else
    log_skip "Skipping Tobimune Shell script update."
fi

# ============================================================================
# BLOCK 4: FINALIZE UPDATE AND RELOAD
# ============================================================================
step_title "4 - FINALIZE UPDATE AND RELOAD"

# Check if local/state/tobimune exists, if not, deploy it
check_state_dir

# Init Tobimune Shell Control
check_control_dir

# Generate style if the Tobimune state is not initialized.
if [[ ! -f "$HOME/.local/state/tobimune/state/state.env" ]]; then
    "$HOME/.local/bin/gen_style.sh" --font "JetBrainsMono Nerd Font"
    log_ok "Executed gen_style.sh"
else
    log_skip "Skipping gen_style.sh execution as ~/.local/state/tobimune/state/state.env already exists."
fi

# Generate the opaque theme state if it does not exist.
if [[ ! -f "$HOME/.local/state/tobimune/opaque_theme_state" ]]; then
    "$HOME/.local/bin/opaque_theme.sh" off >/dev/null 2>&1
    log_ok "Executed opaque_theme.sh"
else
    log_skip "Skipping opaque_theme.sh execution as ~/.local/state/tobimune/opaque_theme_state already exists."
fi

# Reload Waybar
if [[ -x "$HOME/.local/bin/waybar_manager.sh" ]]; then
    sleep 1
    "$HOME/.local/bin/waybar_manager.sh" --reload >/dev/null 2>&1
    log_ok "Waybar reloaded."
else
    log_skip "Skipping Waybar reload."
fi

# Final message
echo ""
print_divider
echo -e "${C_BOLD}${C_GREEN}  Update complete! Restart session or reload WM to apply!${C_RESET}"
echo -e "${C_MAGENTA}  Backup folder for this update: $BACKUP_DIR${C_RESET}"
print_divider
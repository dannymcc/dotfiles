#!/bin/bash

# Omarchy Config Installer
# Symlinks dotfiles from this repo to their proper locations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

backup_and_link() {
    local src="$1"
    local dest="$2"
    local dest_dir="$(dirname "$dest")"

    # Create destination directory if it doesn't exist
    if [[ ! -d "$dest_dir" ]]; then
        info "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi

    # Handle existing file/symlink
    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -L "$dest" ]]; then
            local current_target="$(readlink "$dest")"
            if [[ "$current_target" == "$src" ]]; then
                info "Already linked: $dest"
                return 0
            fi
            warn "Removing existing symlink: $dest -> $current_target"
            rm "$dest"
        else
            local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing file: $dest -> $backup"
            mv "$dest" "$backup"
        fi
    fi

    info "Linking: $dest -> $src"
    ln -s "$src" "$dest"
}

echo "================================"
echo "  Omarchy Config Installer"
echo "================================"
echo

# Install required packages
info "Checking required packages..."
PACKAGES="blueberry python-rich python-requests python-textual wl-clipboard"
MISSING=""
for pkg in $PACKAGES; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        MISSING="$MISSING $pkg"
    fi
done
if [[ -n "$MISSING" ]]; then
    info "Installing missing packages:$MISSING"
    yay -S --noconfirm $MISSING
fi

# Bash
info "Installing bash config..."
backup_and_link "$SCRIPT_DIR/bash/.bashrc" "$HOME/.bashrc"

# Git
info "Installing git config..."
backup_and_link "$SCRIPT_DIR/git/.config/git/config" "$HOME/.config/git/config"

# Hyprland
info "Installing hyprland configs..."
backup_and_link "$SCRIPT_DIR/hypr/.config/hypr/bindings.conf" "$HOME/.config/hypr/bindings.conf"
backup_and_link "$SCRIPT_DIR/hypr/.config/hypr/input.conf" "$HOME/.config/hypr/input.conf"

# Hyprland app-specific configs
info "Installing hyprland app configs..."
mkdir -p "$HOME/.config/hypr/apps"
for appconf in "$SCRIPT_DIR/hypr/.config/hypr/apps"/*.conf; do
    [[ -f "$appconf" ]] || continue
    backup_and_link "$appconf" "$HOME/.config/hypr/apps/$(basename "$appconf")"
done

# Add source line for custom apps if not already present
HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"
if [[ -f "$HYPRLAND_CONF" ]] && ! grep -q "source.*apps/archnote.conf" "$HYPRLAND_CONF"; then
    info "Adding archnote config to hyprland.conf..."
    echo "" >> "$HYPRLAND_CONF"
    echo "# Custom app window rules" >> "$HYPRLAND_CONF"
    echo "source = ~/.config/hypr/apps/archnote.conf" >> "$HYPRLAND_CONF"
fi

# Custom scripts
info "Installing custom scripts..."
backup_and_link "$SCRIPT_DIR/scripts/.local/share/omarchy/bin/omarchy-hyprland-window-center" "$HOME/.local/share/omarchy/bin/omarchy-hyprland-window-center"

# Claude Code
info "Installing claude config..."
backup_and_link "$SCRIPT_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# Tmux
info "Installing tmux config..."
backup_and_link "$SCRIPT_DIR/tmux/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Waybar
info "Installing waybar config..."
backup_and_link "$SCRIPT_DIR/waybar/.config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
backup_and_link "$SCRIPT_DIR/waybar/.config/waybar/style.css" "$HOME/.config/waybar/style.css"

# Elephant (Walker websearch)
info "Installing elephant config..."
mkdir -p "$HOME/.config/elephant" "$HOME/.local/share/icons"
sed "s|/home/[^/]*/|$HOME/|g" "$SCRIPT_DIR/elephant/.config/elephant/websearch.toml" > "$HOME/.config/elephant/websearch.toml"
cp -n "$SCRIPT_DIR/elephant/.local/share/icons/provet.png" "$HOME/.local/share/icons/" 2>/dev/null || true

# Web apps
info "Installing web apps..."
APPS_SRC="$SCRIPT_DIR/applications/.local/share/applications"
APPS_DEST="$HOME/.local/share/applications"
mkdir -p "$APPS_DEST/icons"
for desktop in "$APPS_SRC"/*.desktop; do
    [[ -f "$desktop" ]] || continue
    name=$(basename "$desktop")
    # Copy and fix paths for this system
    sed "s|/home/[^/]*/|$HOME/|g" "$desktop" > "$APPS_DEST/$name"
    info "Installed web app: $name"
done
# Copy icons
cp -n "$APPS_SRC/icons/"*.png "$APPS_DEST/icons/" 2>/dev/null || true

# HiBob Search
info "Installing hibob-search..."
mkdir -p "$HOME/.local/bin"
backup_and_link "$SCRIPT_DIR/scripts/hibob-search/hibob-search" "$HOME/.local/bin/hibob-search"
if [[ ! -f "$HOME/.config/hibob/credentials" ]]; then
    mkdir -p "$HOME/.config/hibob"
    cp "$SCRIPT_DIR/scripts/hibob-search/credentials.example" "$HOME/.config/hibob/credentials"
    chmod 600 "$HOME/.config/hibob/credentials"
    warn "Created ~/.config/hibob/credentials - please add your API credentials"
fi

# Nord wallpapers
info "Installing nord wallpapers..."
NORD_BG_DIR="$HOME/.local/share/omarchy/themes/nord/backgrounds"
if [[ -d "$NORD_BG_DIR" ]]; then
    for img in "$SCRIPT_DIR/wallpapers/nord"/*.{png,jpg,jpeg}; do
        [[ -f "$img" ]] && backup_and_link "$img" "$NORD_BG_DIR/$(basename "$img")"
    done
else
    warn "Nord theme not found, skipping wallpapers"
fi

echo
info "Installation complete!"
echo
echo "Note: You may need to:"
echo "  - Restart your shell or run: source ~/.bashrc"
echo "  - Reload hyprland: hyprctl reload"
echo "  - Restart elephant: systemctl --user restart elephant"
echo "  - Configure HiBob credentials: nano ~/.config/hibob/credentials"

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

# Custom scripts
info "Installing custom scripts..."
backup_and_link "$SCRIPT_DIR/scripts/.local/share/omarchy/bin/omarchy-hyprland-window-center" "$HOME/.local/share/omarchy/bin/omarchy-hyprland-window-center"

echo
info "Installation complete!"
echo
echo "Note: You may need to:"
echo "  - Restart your shell or run: source ~/.bashrc"
echo "  - Reload hyprland: hyprctl reload"

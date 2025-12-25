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
PACKAGES="blueberry python-rich python-requests python-textual wl-clipboard hibob-tui hunspell-en_gb"
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

# British English locale
info "Configuring British English locale..."
if ! grep -q "^en_GB.UTF-8 UTF-8" /etc/locale.gen; then
    sudo sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
    sudo locale-gen
fi
if ! grep -q "LANG=en_GB.UTF-8" /etc/locale.conf 2>/dev/null; then
    sudo sh -c 'echo "LANG=en_GB.UTF-8" > /etc/locale.conf'
    warn "Locale changed to British English - reboot required for full effect"
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
for script in "$SCRIPT_DIR/scripts/.local/share/omarchy/bin"/omarchy-*; do
    [[ -f "$script" ]] || continue
    backup_and_link "$script" "$HOME/.local/share/omarchy/bin/$(basename "$script")"
done

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
backup_and_link "$SCRIPT_DIR/waybar/.config/waybar/vpn-override.css" "$HOME/.config/waybar/vpn-override.css"
mkdir -p "$HOME/.config/waybar/indicators"
backup_and_link "$SCRIPT_DIR/waybar/.config/waybar/indicators/wireguard-status.sh" "$HOME/.config/waybar/indicators/wireguard-status.sh"

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

# HiBob Search credentials
if [[ ! -f "$HOME/.config/hibob/credentials" ]]; then
    info "Setting up hibob-tui credentials..."
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

# ThinkPad LED config (if on ThinkPad)
if [[ -d /sys/class/leds/tpacpi::lid_logo_dot ]]; then
    info "Installing ThinkPad LED config..."
    sudo cp "$SCRIPT_DIR/thinkpad/etc/udev/rules.d/99-thinkpad-led.rules" /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    echo "BAT0-charging" | sudo tee /sys/class/leds/tpacpi::lid_logo_dot/trigger > /dev/null
    info "ThinkPad lid LED set to: on when charging"
fi

echo
info "Installation complete!"
echo
echo "Note: You may need to:"
echo "  - Restart your shell or run: source ~/.bashrc"
echo "  - Reload hyprland: hyprctl reload"
echo "  - Restart elephant: systemctl --user restart elephant"
echo "  - Configure HiBob credentials: nano ~/.config/hibob/credentials"

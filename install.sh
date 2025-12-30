#!/bin/bash
# ============================================================================
# Omarchy Config Installer
# Symlinks dotfiles from this repo to their proper locations
# ============================================================================
# Part of Danny's omarchy-config dotfiles
# https://blog.dmcc.io/dotfiles/
# ============================================================================

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
# Core packages
PACKAGES="stow blueberry python-rich python-requests python-textual wl-clipboard hibob-tui hunspell-en_gb weechat omarchy-zsh"
# Modern CLI tools
PACKAGES="$PACKAGES lf zathura zathura-pdf-mupdf gitui zsh-autosuggestions ripgrep"
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

# Stow packages (simple symlinks)
info "Installing configs via stow..."
STOW_PACKAGES="bash zsh git hypr tmux waybar weechat claude ghostty starship lf"

# Clean up old manual symlinks that conflict with stow
cleanup_for_stow() {
    local pkg="$1"
    # Handle directory symlinks (e.g., weechat)
    find "$SCRIPT_DIR/$pkg" -type d | while read -r src; do
        local rel="${src#$SCRIPT_DIR/$pkg/}"
        [[ -z "$rel" ]] && continue
        local dest="$HOME/$rel"
        if [[ -L "$dest" ]]; then
            info "  Removing old directory symlink: $dest"
            rm "$dest"
        fi
    done
    # Handle file symlinks
    find "$SCRIPT_DIR/$pkg" -type f | while read -r src; do
        local rel="${src#$SCRIPT_DIR/$pkg/}"
        local dest="$HOME/$rel"
        if [[ -L "$dest" ]]; then
            info "  Removing old symlink: $dest"
            rm "$dest"
        elif [[ -e "$dest" ]]; then
            local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
            warn "  Backing up: $dest -> $backup"
            mv "$dest" "$backup"
        fi
    done
}

for pkg in $STOW_PACKAGES; do
    if [[ -d "$SCRIPT_DIR/$pkg" ]]; then
        cleanup_for_stow "$pkg"
        info "  Stowing $pkg..."
        stow -d "$SCRIPT_DIR" -t "$HOME" "$pkg"
    fi
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
    # Skip empty files (0 bytes)
    [[ -s "$desktop" ]] || { warn "Skipping empty file: $desktop"; continue; }
    name=$(basename "$desktop")
    # Copy and fix paths for this system
    sed "s|/home/[^/]*/|$HOME/|g" "$desktop" > "$APPS_DEST/$name"
    info "Installed web app: $name"
done
# Copy icons
cp -n "$APPS_SRC/icons/"*.png "$APPS_DEST/icons/" 2>/dev/null || true
cp -n "$APPS_SRC/icons/"*.svg "$APPS_DEST/icons/" 2>/dev/null || true

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

# Setup zsh as default shell
info "Setting up zsh..."
if command -v zsh &>/dev/null; then
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        info "Run 'omarchy-setup-zsh' to set zsh as your default shell"
    fi
fi

echo
info "Installation complete!"
echo
echo "Note: You may need to:"
echo "  - Restart your shell (zsh will auto-launch from bash)"
echo "  - Reload hyprland: hyprctl reload"
echo "  - Restart elephant: systemctl --user restart elephant"
echo "  - Configure HiBob credentials: nano ~/.config/hibob/credentials"

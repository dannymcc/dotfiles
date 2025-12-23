# Omarchy Config

Personal dotfiles and customizations for [Omarchy](https://omarchy.com).

## Installation

```bash
git clone git@github.com:dannymcc/omarchy-config.git ~/omarchy-config
cd ~/omarchy-config
./install.sh
```

The install script will:
1. Back up any existing files with a timestamp
2. Create symlinks from the repo to the correct locations
3. Install required packages via `yay`

After installation:
```bash
source ~/.bashrc
hyprctl reload
systemctl --user restart elephant
```

## Contents

### Shell

**bash/** - Shell aliases and configuration

| Command | Description |
|---------|-------------|
| `dotpush` | Commit and push dotfiles to GitHub |
| `dotpull` | Pull latest dotfiles from GitHub |
| `gpull` / `gpush` | Git pull/push shortcuts |
| `projects` | Quick cd to projects directory |
| `nano` | Aliased to `nvim` |

### Git

**git/** - Git configuration
- User name and email
- Useful aliases (`co`, `br`, `ci`, `st`)
- Sensible defaults (rebase on pull, auto-setup remote)
- GitHub credential helper via `gh auth`

### Hyprland

**hypr/** - Hyprland window manager config
- `bindings.conf` - Custom keybindings (see table below)
- `input.conf` - Caps Lock as Hyper modifier (MOD3), GB keyboard layout

**hypr/apps/** - Application-specific window rules
- `archnote.conf` - Floating window, 320x380
- `plexamp.conf` - Floating window, 420x549, positioned top-right

### Custom Scripts

**scripts/** - Custom Omarchy scripts

| Script | Description |
|--------|-------------|
| `omarchy-hyprland-window-center` | Center window at specified percentage of screen |
| `omarchy-vpn-toggle` | Toggle Wireguard VPN on/off |
| `omarchy-vpn-connect` | Connect to Wireguard VPN |
| `omarchy-vpn-disconnect` | Disconnect from VPN |
| `omarchy-vpn-status` | Show VPN connection status |
| `omarchy-menu-vpn` | Walker menu for VPN management |
| `omarchy-caffeinate` | Prevent system sleep/suspend |
| `omarchy-decaffeinate` | Restore normal sleep behavior |

**scripts/hibob-search/** - Credentials template for hibob-tui

### VPN Integration

The VPN scripts provide Wireguard management with visual feedback:
- Waybar background turns dark red when VPN is connected
- Click the VPN indicator to toggle, right-click for menu
- Requires Wireguard config in `/etc/wireguard/`

### Sleep Prevention

Caffeinate/decaffeinate prevent the system from sleeping:
- Stops `hypridle` and inhibits sleep via `systemd-inhibit`
- Useful for long downloads or presentations
- Available as desktop apps or command line

### Terminal

**tmux/** - Tmux terminal multiplexer config
- Nord-themed status bar and panes
- Prefix: `Ctrl+A`
- Vim-style pane navigation (`h`/`j`/`k`/`l`)
- Split with `|` (vertical) and `-` (horizontal)
- Resize with `H`/`J`/`K`/`L`

### Status Bar

**waybar/** - Waybar status bar config
- Floating bar style with rounded corners
- 24-hour clock format with calendar tooltip
- VPN status indicator (green when connected)
- Modules: workspaces, clock, mpris, network, bluetooth, audio, battery
- Requires: `blueberry`

### Walker

**elephant/** - Walker launcher websearch configuration
- `pv <id>` - Open Provet Cloud environment by ID

### HiBob Search

[hibob-tui](https://github.com/dannymcc/hibob-tui) - Employee search TUI for [HiBob](https://hibob.com)
- Installed via AUR package `hibob-tui`
- Interactive two-panel interface with vim-style navigation
- Requires API credentials in `~/.config/hibob/credentials`

```bash
hibob-tui                # Interactive TUI mode
hibob-tui john           # Quick search from command line
```

### Applications

**applications/** - Desktop application shortcuts

| App | Description |
|-----|-------------|
| ChatGPT | OpenAI ChatGPT web app |
| Discord | Discord web app |
| GitHub | GitHub web app |
| YouTube | YouTube web app |
| Caffeinate | Prevent system sleep |
| Decaffeinate | Restore sleep behavior |
| Wireguard VPN | Connect to VPN |
| HiBob Search | Employee directory TUI (hibob-tui) |

### Wallpapers

**wallpapers/** - Theme wallpapers
- `nord/` - 91 Nord-themed backgrounds from [ChrisTitusTech/nord-background](https://github.com/ChrisTitusTech/nord-background)

### Claude Code

**.claude/** - Claude Code configuration
- `CLAUDE.md` - Global Claude Code preferences

### ThinkPad

**thinkpad/** - ThinkPad-specific configuration
- `99-thinkpad-led.rules` - Lid logo LED lights up when charging
- Only installed on ThinkPad hardware

## Custom Keybindings

| Keybind | Action |
|---------|--------|
| Super + B | Launch browser |
| Super + Shift + B | Launch browser (new window) |
| Super + Shift + Alt + B | Launch browser (private) |
| Super + Shift + A | ChatGPT |
| Super + Shift + Y | YouTube |
| Super + Shift + G | Signal |
| Super + Shift + D | Docker |
| Caps Lock + C | Center window at 60% of screen |

## Usage

| Scenario | Command |
|----------|---------|
| Fresh install | `./install.sh` |
| Update symlinks | `./install.sh` |
| Push local changes to GitHub | `dotpush` |
| Pull changes from GitHub | `dotpull` |

Symlinks mean changes are automatically reflected—no need to re-run install after pulling.

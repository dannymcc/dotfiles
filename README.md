# Omarchy Config

Personal dotfiles and customizations for [Omarchy](https://omarchy.com).

## Installation

```bash
git clone git@github.com:dannymcc/omarchy-config.git ~/omarchy-config
cd ~/omarchy-config
./install.sh
```

The install script will:
1. Install required packages via `yay` (including GNU Stow)
2. Use GNU Stow to symlink dotfile packages to `$HOME`
3. Handle special cases (path substitution, file copying, system config)

### Structure

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) for dotfile management. Each package directory mirrors the target structure relative to `$HOME`:

```
omarchy-config/
├── bash/.bashrc          → ~/.bashrc
├── zsh/.zshrc            → ~/.zshrc
├── git/.config/git/      → ~/.config/git/
├── hypr/.config/hypr/    → ~/.config/hypr/
├── tmux/.config/tmux/    → ~/.config/tmux/
├── waybar/.config/waybar/→ ~/.config/waybar/
├── weechat/.config/weechat/ → ~/.config/weechat/
└── claude/.claude/       → ~/.claude/
```

To manually stow a single package: `stow -t ~ <package>`

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
- `ostt.conf` - Speech-to-text overlay, bottom-center

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
| `omarchy-secure-irc` | Launch weechat IRC client |

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

### IRC

**weechat/** - IRC client configuration via ZNC bouncer

The setup uses a ZNC bouncer for persistent connections:
- ZNC handles staying connected 24/7 and buffering messages
- Local weechat connects to ZNC, not directly to IRC networks
- Passwords stored in weechat's encrypted `sec.conf` (not in git)

Networks: Libera (#archlinux, #archlinux-offtopic, #linux), OFTC (#tor), AAChat (#a&a)

| Shortcut | Action |
|----------|--------|
| `Ctrl+x` | Switch between servers |
| `Alt+<num>` | Switch to buffer/channel by number |
| `Alt+z` | Toggle sidebars (for clean text copying) |

Mouse support enabled - click buffers/nicks, scroll with wheel. Hold `Shift` for terminal text selection.

To manage channels, use ZNC's web admin or `/msg *controlpanel` in weechat.

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

**claude/** - Claude Code configuration (stow package)
- `.claude/CLAUDE.md` - Global Claude Code preferences

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
| Super + R | Speech-to-text (ostt) |
| Caps Lock + C | Center window at 60% of screen |

## Usage

| Scenario | Command |
|----------|---------|
| Fresh install | `./install.sh` |
| Update symlinks | `./install.sh` |
| Push local changes to GitHub | `dotpush` |
| Pull changes from GitHub | `dotpull` |

Symlinks mean changes are automatically reflected—no need to re-run install after pulling.

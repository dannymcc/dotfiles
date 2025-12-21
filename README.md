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
3. Install any required packages via `yay`

After installation:
```bash
source ~/.bashrc
hyprctl reload
systemctl --user restart elephant
```

## Contents

### Shell

**bash/** - Shell aliases and configuration
- `dotpush`, `dotpull` - Sync dotfiles with GitHub
- `gpull`, `gpush` - Git shortcuts
- `projects` - Quick cd to projects directory
- `nano` aliased to `nvim`

### Git

**git/** - Git configuration
- User name and email
- Useful aliases (`co`, `br`, `ci`, `st`)
- Sensible defaults (rebase on pull, auto-setup remote)

### Hyprland

**hypr/** - Hyprland window manager config
- `bindings.conf` - Custom keybindings
- `input.conf` - Caps Lock as Hyper modifier (MOD3)

**scripts/** - Custom Omarchy scripts
- `omarchy-hyprland-window-center` - Center window at specified percentage of screen

### Terminal

**tmux/** - Tmux terminal multiplexer config
- Nord-themed status bar and panes
- Vim-style pane navigation (`h`/`j`/`k`/`l`)
- Split with `|` and `-`

### Status Bar

**waybar/** - Waybar status bar config
- Floating bar style with rounded corners
- Based on [Adsovetzky's Waybar](https://github.com/cazador11/Adsovetzky-Omarchy-s-Waybar)
- Modules: workspaces, clock, mpris, network, bluetooth, audio, battery
- Requires: `blueberry`

### Walker

**elephant/** - Walker launcher websearch configuration
- `pv <id>` - Open Provet Cloud environment by ID

### HiBob Search

**scripts/hibob-search/** - Employee search TUI for [HiBob](https://hibob.com)
- Search employees by name
- Displays: name, email, title, department, tenure, manager, direct reports
- Requires API credentials in `~/.config/hibob/credentials` (not tracked in git)

```bash
hibob-search john        # Search from command line
hibob-search             # Interactive mode
```

### Applications

**applications/** - Web app shortcuts
- ChatGPT, Discord, GitHub, YouTube

### Wallpapers

**wallpapers/** - Theme wallpapers
- `nord/` - 91 Nord-themed backgrounds from [ChrisTitusTech/nord-background](https://github.com/ChrisTitusTech/nord-background)

### Claude Code

**.claude/** - Claude Code configuration
- `CLAUDE.md` - Global Claude Code preferences

## Custom Keybindings

| Keybind | Action |
|---------|--------|
| Caps Lock + C | Center window at 60% of screen |

## Usage

| Scenario | Command |
|----------|---------|
| Fresh install | `./install.sh` |
| Update symlinks | `./install.sh` |
| Push local changes to GitHub | `dotpush` |
| Pull changes from GitHub | `dotpull` |

Symlinks mean changes are automatically reflected—no need to re-run install after pulling.

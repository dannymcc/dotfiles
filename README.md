# Omarchy Config

Personal dotfiles and customizations for [Omarchy](https://omarchy.com).

## Contents

- **bash/** - Shell aliases and configuration
  - `dotpush`, `dotpull` - Sync dotfiles with GitHub
  - `gpull`, `gpush` - Git shortcuts
  - `projects` - Quick cd to projects directory
  - `nano` aliased to `nvim`

- **git/** - Git configuration
  - User name and email
  - Useful aliases (co, br, ci, st)
  - Sensible defaults (rebase on pull, auto-setup remote, etc.)

- **hypr/** - Hyprland window manager config
  - `bindings.conf` - Custom keybindings
  - `input.conf` - Caps Lock as Hyper modifier (MOD3)

- **scripts/** - Custom Omarchy scripts
  - `omarchy-hyprland-window-center` - Center window at specified percentage of screen

- **.claude/** - Claude Code configuration
  - `CLAUDE.md` - Global Claude Code preferences

- **tmux/** - Tmux terminal multiplexer config
  - Nord-themed status bar and panes
  - Vim-style pane navigation (h/j/k/l)
  - Split with `|` and `-`

- **waybar/** - Waybar status bar config
  - Floating bar style with rounded corners
  - Based on [Adsovetzky's Waybar](https://github.com/cazador11/Adsovetzky-Omarchy-s-Waybar/tree/main/waybar-1.3c.2)
  - Modules: workspaces, clock, mpris, weather, network, bluetooth, audio, cpu, battery
  - Requires: `wttrbar`, `blueberry`

- **applications/** - Web app shortcuts
  - ChatGPT, Discord, GitHub, YouTube

- **wallpapers/** - Theme wallpapers
  - `nord/` - 91 Nord-themed backgrounds from [ChrisTitusTech/nord-background](https://github.com/ChrisTitusTech/nord-background)

## Custom Keybindings

| Keybind | Action |
|---------|--------|
| Caps Lock + C | Center window at 60% of screen |

## Installation

```bash
git clone git@github.com:dannymcc/omarchy-config.git ~/omarchy-config
cd ~/omarchy-config
./install.sh
```

The install script will:
1. Back up any existing files (with timestamp)
2. Create symlinks from the repo to the correct locations
3. Preserve the repo as the source of truth

After installation, reload your environment:
```bash
source ~/.bashrc
hyprctl reload
```

## Usage

| Scenario | Command |
|----------|---------|
| Fresh install | `./install.sh` |
| Update symlinks | `./install.sh` |
| Push local changes to GitHub | `dotpush` |
| Pull changes from GitHub | `dotpull` |

Symlinks mean changes are automatically reflected - no need to re-run install after pulling.

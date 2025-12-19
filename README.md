# Omarchy Config

Personal dotfiles and customizations for [Omarchy](https://omarchy.com).

## Contents

- **bash/** - Shell aliases and configuration
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

## Updating

After making changes locally, commit and push:
```bash
cd ~/omarchy-config
git add -A
git commit -m "Update config"
git push
```

On other machines, pull the latest:
```bash
cd ~/omarchy-config
git pull
```

Symlinks mean changes are automatically reflected - no need to re-run install.

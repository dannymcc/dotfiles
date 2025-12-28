# Omarchy Config

Personal dotfiles and system configuration for Arch Linux running Omarchy (Hyprland-based).

## Architecture Overview

This repo uses **GNU Stow** for dotfile management. Each top-level directory is a "stow package" that mirrors the target structure relative to `$HOME`. Running `stow -t ~ <package>` creates symlinks from the package contents to their proper home directory locations.

### Stow Packages

| Package | Target | Purpose |
|---------|--------|---------|
| `bash/` | `~/.bashrc` | Bash config (mostly launches zsh) |
| `zsh/` | `~/.zshrc` | Main shell config with aliases and functions |
| `git/` | `~/.config/git/` | Git configuration |
| `hypr/` | `~/.config/hypr/` | Hyprland window manager config |
| `tmux/` | `~/.config/tmux/` | Tmux terminal multiplexer |
| `waybar/` | `~/.config/waybar/` | Status bar config |
| `weechat/` | `~/.config/weechat/` | IRC client config |
| `claude/` | `~/.claude/` | Claude Code global config |

### Non-Stow Directories

These require special handling (path substitution, copying, system locations):

| Directory | Purpose |
|-----------|---------|
| `applications/` | Desktop app shortcuts (copied with path substitution) |
| `elephant/` | Walker launcher websearch config (copied with path substitution) |
| `scripts/` | Custom omarchy scripts (symlinked individually) |
| `wallpapers/` | Nord theme backgrounds (symlinked to theme dir) |
| `thinkpad/` | ThinkPad-specific udev rules (copied to /etc, ThinkPad only) |

## Installation

```bash
./install.sh
```

The install script:
1. Installs required packages via `yay`
2. Cleans up any conflicting manual symlinks
3. Runs `stow` for each stow package
4. Handles special cases (path substitution, system config)
5. Sets up British English locale

To manually stow a single package: `stow -t ~ <package>`

## IRC Setup

IRC uses a **ZNC bouncer** with local **Weechat** client.

### ZNC

- Module: `chansaver` saves joined channels

To edit ZNC config, either:
- Use web admin or `/msg *controlpanel` from weechat
- SSH to ZNC server and edit config (stop ZNC first)

### Weechat (Local)

- Config stored in `weechat/.config/weechat/`
- Connects to ZNC via `znc-*` server entries (e.g., `znc-libera`, `znc-oftc`)
- Password stored in `sec.conf` (encrypted, not in git)
- Channel autojoins handled by ZNC, not weechat

**Important**: Weechat config files are warnings about not editing while running. Use `/set` commands in weechat, then `/save`.

#### Weechat Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+x` | Switch between servers |
| `Alt+<num>` | Switch to buffer/channel by number |
| `Alt+↑/↓` | Navigate buffer list |
| `Alt+z` | Toggle sidebars (for clean text copying) |
| `F5/F6` | Previous/next buffer |

#### Weechat Settings

Mouse support and custom keybinds (run in weechat):
```
/mouse enable
/set weechat.look.mouse on
/key bind meta-z /bar toggle buflist;/bar toggle nicklist
/save
```

- Mouse: Click buffers, nicks, scroll. Hold `Shift` for terminal selection.
- Highlights: `notify_send.py` and `highmon.pl` scripts installed for notifications.

### Current IRC Networks

| Network | Server | Channels |
|---------|--------|----------|
| Libera | irc.libera.chat | #archlinux, #archlinux-offtopic, #linux |
| OFTC | irc.oftc.net | #tor |
| AAChat | irc.aachat.net | #a&a |

## Custom Scripts

Located in `scripts/.local/share/omarchy/bin/`:

| Script | Description |
|--------|-------------|
| `omarchy-hyprland-window-center` | Center window at specified % of screen |
| `omarchy-vpn-toggle` | Toggle Wireguard VPN |
| `omarchy-vpn-connect` | Connect to VPN |
| `omarchy-vpn-disconnect` | Disconnect from VPN |
| `omarchy-vpn-status` | Show VPN status |
| `omarchy-menu-vpn` | Walker menu for VPN |
| `omarchy-caffeinate` | Prevent system sleep |
| `omarchy-decaffeinate` | Restore sleep behavior |
| `omarchy-secure-irc` | Launch weechat IRC client |

## Hyprland Configuration

Config split into modular files in `hypr/.config/hypr/`:

| File | Purpose |
|------|---------|
| `bindings.conf` | Custom keybindings |
| `input.conf` | Keyboard/mouse settings (GB layout, Caps as Hyper) |
| `monitors.conf` | Display configuration |
| `hypridle.conf` | Idle behavior (screen off, lock, suspend) |
| `hyprlock.conf` | Lock screen appearance |
| `apps/*.conf` | Per-application window rules |

### Key Bindings

| Keybind | Action |
|---------|--------|
| Super + Return | Terminal |
| Super + B | Browser |
| Super + Shift + B | Browser (new window) |
| Super + Shift + Alt + B | Browser (private) |
| Super + Shift + A | ChatGPT |
| Super + Shift + Y | YouTube |
| Super + Shift + G | Signal |
| Super + Shift + D | Docker (lazydocker) |
| Super + R | Speech-to-text (ostt) |
| Caps + C | Center window at 60% |

## Shell Functions

Defined in `zsh/.zshrc`:

| Function | Description |
|----------|-------------|
| `dotpush` | Commit and push dotfiles changes |
| `dotpull` | Pull latest dotfiles |
| `gpull` / `gpush` | Git pull/push shortcuts |
| `projects` | cd to ~/projects |

## Making Changes

1. **Stow packages**: Edit files directly in the package directory. Changes are immediate via symlinks.

2. **Non-stow items**: Edit in repo, then run `./install.sh` to copy/update.

3. **After changes**:
   - Shell: `source ~/.zshrc` or open new terminal
   - Hyprland: `hyprctl reload`
   - Waybar: `killall waybar && waybar &`
   - ZNC: Use web admin or `/msg *controlpanel`
   - Weechat: `/save` after `/set` commands

4. **Sync to GitHub**: `dotpush`

## Files NOT in Git

- `weechat/.config/weechat/sec.conf` - Contains encrypted passwords
- `scripts/hibob-search/credentials` - API credentials (template only)
- Any `*.backup.*` files

## ThinkPad-Specific

The `thinkpad/` directory contains:
- `99-thinkpad-led.rules` - Makes lid logo LED light up when charging

Only installed when ThinkPad hardware is detected.

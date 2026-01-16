# ============================================================================
# Zsh Configuration
# ============================================================================
# Part of Danny's omarchy-config dotfiles
# https://blog.dmcc.io/dotfiles/
# ============================================================================

# Exit early if not running interactively
[[ $- != *i* ]] && return

# ----------------------------------------------------------------------------
# SSH Tmux Auto-Attach
# ----------------------------------------------------------------------------
# Automatically attach to (or create) a tmux session when connecting via SSH

if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]] && command -v tmux &>/dev/null; then
    tmux attach-session -t ssh 2>/dev/null || tmux new-session -s ssh
fi

# ----------------------------------------------------------------------------
# Omarchy Base Configuration
# ----------------------------------------------------------------------------
# Load the base omarchy-zsh configuration (provides completions, keybindings,
# history settings, and core functionality)

if [[ -d /usr/share/omarchy-zsh/conf.d ]]; then
    for config in /usr/share/omarchy-zsh/conf.d/*.zsh; do
        [[ -f "$config" ]] && source "$config"
    done
fi

if [[ -d /usr/share/omarchy-zsh/functions ]]; then
    for func in /usr/share/omarchy-zsh/functions/*.zsh; do
        [[ -f "$func" ]] && source "$func"
    done
fi

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------

export PATH="$HOME/.local/bin:$HOME/.local/share/omarchy/bin:$HOME/.bun/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# ----------------------------------------------------------------------------
# History Settings
# ----------------------------------------------------------------------------
# Enhanced history with deduplication and sharing across sessions
# Note: HISTFILE is set by omarchy-zsh to ~/.zsh_history

HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries
setopt HIST_IGNORE_SPACE       # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS      # Remove superfluous blanks
setopt HIST_VERIFY             # Show command before executing from history
setopt SHARE_HISTORY           # Share history across sessions
setopt EXTENDED_HISTORY        # Save timestamp with history
setopt INC_APPEND_HISTORY      # Add commands immediately to history

# ----------------------------------------------------------------------------
# FZF Integration
# ----------------------------------------------------------------------------
# Fuzzy finding for files, history, and directories

if command -v fzf &>/dev/null; then
    # Use ripgrep for fzf if available
    if command -v rg &>/dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    fi

    export FZF_DEFAULT_OPTS='
        --height 60%
        --layout=reverse
        --border
        --info=inline
        --color=fg:#e5e9f0,bg:#2e3440,hl:#81a1c1
        --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
        --color=info:#eacb8a,prompt:#bf6069,pointer:#b48ead
        --color=marker:#a3be8b,spinner:#b48ead,header:#a3be8b'

    # Load fzf keybindings and completion
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

fi

# ----------------------------------------------------------------------------
# Zsh Autosuggestions
# ----------------------------------------------------------------------------
# Fish-like suggestions as you type

if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# ----------------------------------------------------------------------------
# Modern CLI Aliases
# ----------------------------------------------------------------------------
# Replace traditional tools with modern alternatives

# eza (modern ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --icons --level=2'
    alias tree='eza --tree --icons'
fi

# bat (modern cat)
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias catp='bat'  # Full bat with paging
fi

# btop (modern top)
if command -v btop &>/dev/null; then
    alias top='btop'
    alias htop='btop'
fi

# ----------------------------------------------------------------------------
# General Aliases
# ----------------------------------------------------------------------------

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias 0='cd ~/0'
alias projects='cd ~/projects'

# Editor
alias nano='nvim'
alias vim='nvim'
alias v='nvim'

# Clipboard (macOS compatibility)
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gpull='git pull'
alias gpush='git push'
alias glog='git log --oneline --graph --decorate -20'

# Safety nets
alias rm='rm -I'
alias mv='mv -i'
alias cp='cp -i'

# Misc
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# ----------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------

# Dotfiles sync - push local changes to GitHub
function dotpush {
    (
        builtin cd ~/omarchy-config || exit 1
        if [[ -z $(git status --porcelain) ]]; then
            echo "Dotfiles already in sync"
        else
            local changed=$(git status --porcelain | wc -l)
            git add -A && git commit -m "Update dotfiles" > /dev/null && git push -q
            echo "Pushed $changed file(s) to GitHub"
        fi
    )
}

# Dotfiles sync - pull remote changes from GitHub
function dotpull {
    (
        builtin cd ~/omarchy-config || exit 1
        git fetch -q
        local behind=$(git rev-list HEAD..@{u} --count 2>/dev/null)
        if [[ "$behind" -eq 0 ]]; then
            echo "Dotfiles already in sync"
        else
            git pull -q
            echo "Pulled $behind commit(s) from GitHub"
        fi
    )
}

# Create directory and cd into it
function mkcd {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
function extract {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1"    ;;
            *.tar.gz)  tar xzf "$1"    ;;
            *.tar.xz)  tar xJf "$1"    ;;
            *.bz2)     bunzip2 "$1"    ;;
            *.rar)     unrar x "$1"    ;;
            *.gz)      gunzip "$1"     ;;
            *.tar)     tar xf "$1"     ;;
            *.tbz2)    tar xjf "$1"    ;;
            *.tgz)     tar xzf "$1"    ;;
            *.zip)     unzip "$1"      ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1"       ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick HTTP server in current directory
function serve {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# ----------------------------------------------------------------------------
# Terminal Greeting
# ----------------------------------------------------------------------------

# Logo + quote side by side
if [[ -f ~/.config/fastfetch/logo.txt ]] && command -v fortune &>/dev/null; then
    local logo_file=~/.config/fastfetch/logo.txt
    local logo_lines=$(wc -l < "$logo_file")
    local quote=$(fortune -s linux | fold -s -w 40)
    local quote_lines=$(echo "$quote" | wc -l)
    local pad_top=$(( (logo_lines - quote_lines) / 2 ))

    paste -d' ' \
        <(cat "$logo_file" | sed 's/$/    /') \
        <(printf '%0.s\n' $(seq 1 $pad_top) 2>/dev/null; echo "$quote") \
        2>/dev/null
    echo
elif [[ -f ~/.config/fastfetch/logo.txt ]]; then
    cat ~/.config/fastfetch/logo.txt
    echo
fi

# ----------------------------------------------------------------------------
# Tool Integrations
# ----------------------------------------------------------------------------

# mise (runtime version manager)
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi

# Starship prompt (must be last)
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ----------------------------------------------------------------------------
# SSH Tmux Auto-Attach
# ----------------------------------------------------------------------------
# Automatically attach to (or create) a tmux session when connecting via SSH

if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]] && command -v tmux &>/dev/null; then
    tmux attach-session -t ssh 2>/dev/null || tmux new-session -s ssh
fi

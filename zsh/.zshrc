# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load omarchy-zsh configuration
if [[ -d /usr/share/omarchy-zsh/conf.d ]]; then
  for config in /usr/share/omarchy-zsh/conf.d/*.zsh; do
    [[ -f "$config" ]] && source "$config"
  done
fi

# Load omarchy-zsh functions and aliases
if [[ -d /usr/share/omarchy-zsh/functions ]]; then
  for func in /usr/share/omarchy-zsh/functions/*.zsh; do
    [[ -f "$func" ]] && source "$func"
  done
fi

# Add your own customizations below

# PATH entries
export PATH="$HOME/.local/bin:$HOME/.local/share/omarchy/bin:$HOME/.bun/bin:$PATH"

# Directory shortcuts
alias projects='cd ~/projects'

# nvim > nano
alias nano='nvim'

# Git aliases
alias gpull='git pull'
alias gpush='git push'

# Clipboard (macOS compatibility)
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'

# Dotfiles sync functions
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

# Load mise (if installed)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

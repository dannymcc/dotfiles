# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# PATH entries
export PATH="$HOME/.local/bin:$HOME/.local/share/omarchy/bin:$PATH"

# Directory shortcuts
alias projects='cd /home/danny/projects'

# nvim > nano
alias nano='nvim'

# Git aliases
alias gpull='git pull'
alias gpush='git push'

# Dotfiles sync functions
dotpush() {
    cd ~/omarchy-config || return 1
    if [[ -z $(git status --porcelain) ]]; then
        echo "Dotfiles already in sync"
    else
        local changed=$(git status --porcelain | wc -l)
        git add -A && git commit -m "Update dotfiles" > /dev/null && git push -q
        echo "Pushed $changed file(s) to GitHub"
    fi
    cd - > /dev/null
}

dotpull() {
    cd ~/omarchy-config || return 1
    git fetch -q
    local behind=$(git rev-list HEAD..@{u} --count 2>/dev/null)
    if [[ "$behind" -eq 0 ]]; then
        echo "Dotfiles already in sync"
    else
        git pull -q
        echo "Pulled $behind commit(s) from GitHub"
    fi
    cd - > /dev/null
}

. "$HOME/.local/share/../bin/env"

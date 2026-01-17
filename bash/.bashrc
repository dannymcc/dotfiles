# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Auto-launch zsh shell if available
if command -v zsh &> /dev/null; then
  if [[ $(ps --no-header --pid=$PPID --format=comm) != "zsh" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
  then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec zsh $LOGIN_OPTION
  fi
fi

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Fallback aliases (if zsh not available)
# PATH entries
export PATH="$HOME/.local/bin:$HOME/.local/share/omarchy/bin:$PATH"

# Directory shortcuts
alias projects='cd ~/projects'

# nvim > nano
alias nano='nvim'

# Git aliases
alias gpull='git pull'
alias gpush='git push'

# Dotfiles sync functions
function dotpush {
    (
        builtin cd ~/dotfiles || exit 1
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
        builtin cd ~/dotfiles || exit 1
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
    eval "$(mise activate bash)"
fi

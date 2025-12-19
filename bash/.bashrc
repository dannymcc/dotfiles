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
alias dotpush='cd ~/omarchy-config && git add -A && git commit -m "Update dotfiles" && git push; cd - > /dev/null'

. "$HOME/.local/share/../bin/env"

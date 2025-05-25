export TERM=xterm-256color
export EDITOR='vim'
export VISUAL='code'
export GPG_TTY=$(tty)
export LC_ALL=en_US.UTF-8

# Direnv hook (Q59.2)
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# TheFuck alias (Q59.9)
if command -v thefuck &> /dev/null; then
  eval "$(thefuck --alias)"
fi

# Settings for various CLIs I use
export PED_EDITOR='vim'
export KONCH_EDITOR='vim'
export FAM_SOURCE="$HOME/iCloud/fam"
export FAM_EDITOR="vim"
export AWS_CLI_AUTO_PROMPT=on-partial

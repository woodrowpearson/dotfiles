# Navigation (Q59.9)
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Clear shortcuts
alias cl="clear"
alias c="clear"

# Modern command replacements (Q59.9)
alias grep='rg --color=auto'
alias find='fd'
alias du='dust -r'
alias diff='delta'
alias sed='gsed'
alias tar='gtar'

# Git shortcuts (Q59.9)
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gco='git checkout'

# Safety (Q59.9)
alias rm='trash'  # move to Trash instead of delete

# Networking
alias wget='curl -O'

# Quick serve current dir (Q59.9)
alias serve='python3 -m http.server 8000'

# Clipboard helpers (Q59.9)
alias copypath='pwd | tr -d "\n" | pbcopy'

# Process management
alias pg='ps -ef | grep'
alias pkill!="pkill -9 -f "

# Development
alias reload!='. ~/.zshrc'
alias vi="vim"
alias v="vim"

# Utilities
alias resize="mogrify -resize"  # resize images
alias btm="btm --process_memory_as_value"
alias qr="qrtool encode -t terminal"  # QR codes

# Prepend ~/dotfiles/bin to PATH
export PATH=${PATH}:$ZSH/bin

# GNU Coreutils Path Shim (Q59.9)
# Ensure GNU coreutils precede BSD versions
if [[ -d "$(brew --prefix coreutils 2>/dev/null)/libexec/gnubin" ]]; then
  export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi

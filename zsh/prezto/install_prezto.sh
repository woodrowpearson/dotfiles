#!/bin/bash

set -x

# Start zsh
zsh

# clone prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# setup new zsh config by copying the zsh conf files provided
new_zsh () {
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
}

# try config setup func
new_zsh

ret_code=$?

# If it fails copy to 
if [ $ret_code -eq 0 ]; then
  echo "zsh config copy succeeded"
else
  echo "Some config files already exist causing error. Souring presto to .zshrc."
  echo "source "${ZDOTDIR:-$HOME}"/.zprezto/init.zsh" >> ~/.zshrc
fi

# Set zsh as default shell
chsh -s /bin/zsh

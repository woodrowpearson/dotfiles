#!/usr/bin/env bash

VIM_PLUGINS_DIR="${HOME}/.vim/plugged"
cd "$VIM_PLUGINS_DIR" || exit

# List of plugins from your .vimrc
plugins=$(find . -maxdepth 1 -type d -printf '%f\n')




# Loop through each plugin
for plugin in "${plugins[@]}"; do
  echo "### $plugin"
  echo "**Description:**"
  # Open Vim, access the plugin's documentation, and save it to a temporary file
  vim -c "help $plugin" -c "w! /tmp/plugin_help.txt" -c "q"

  # Extract the description (assuming it's in the first few lines)
  head -n 10 /tmp/plugin_help.txt | grep -E "$plugin.*\-" | sed "s/$plugin//"

  echo ""
  echo "**Key Mappings:**"
  # Extract lines that look like key mappings
  grep -E '^\s*\<.*\>' /tmp/plugin_help.txt
  echo "----------------------"
done

# Clean up
rm /tmp/plugin_help.txt

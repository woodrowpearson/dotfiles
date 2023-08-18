#!/usr/bin/env bash

# Ensure the script exits on any error
set -euo pipefail

# Function to display help
display_help() {
    echo "Usage: $0 [search_term]"
    echo
    echo "Automate the process of searching for homebrew formulae/casks, querying their info, and optionally installing them."
    echo
    echo "Arguments:"
    echo "  search_term    The term to search for in homebrew."
}

# Check if user requested help
if [[ "$#" -eq 1 && ("$1" == "-h" || "$1" == "--help") ]]; then
    display_help
    exit 0
fi

# Ensure we have the correct number of arguments
if [[ "$#" -ne 1 ]]; then
    echo "Error: Invalid number of arguments."
    display_help
    exit 1
fi

# Function to handle script exit
cleanup() {
    echo "Cleaning up..."
}

# Trap any exit or error signals
trap cleanup EXIT

# Search homebrew
search_term="$1"
results=$(brew search "$search_term")

# Extract formulae and casks into an array
items=($(echo "$results" | awk 'NR>2 && /^==>/ {exit} NR>2 {print $1}'))

# Initialize an array to store installed items
installed_items=()

# Loop over the items and query homebrew
for item in "${items[@]}"; do
    echo "Fetching info for $item..."
    brew info "$item"
    
    # Ask the user if they want to install
    read -p "Do you want to install $item? [y/N]: " choice
    case "$choice" in
        y|Y) 
            brew install "$item"
            installed_items+=("$item")
            ;;
        *) 
            echo "Skipping $item..."
            ;;
    esac
done

# Write installed items to a file
epoch_time=$(date +%s)
output_file="${HOME}/tmp/homebrew_install_${epoch_time}.txt"
echo "Installed items:" > "$output_file"
for item in "${installed_items[@]}"; do
    echo "$item" >> "$output_file"
done

echo "Script completed. Installed items written to $output_file"

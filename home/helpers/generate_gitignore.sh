#!/usr/bin/env bash

# Function to fetch and write .gitignore content
fetch_gitignore() {
  local types_encoded
  # Replace commas with encoded commas for the URL
  types_encoded=$(echo "$1" | tr ',' '%2C')

  # Fetch the .gitignore content for the specified types
  local content
  content=$(curl -sL --compressed "https://www.gitignore.io/api/$types_encoded")
  echo "$content"

  # Append the content to a .gitignore file
  echo "$content" >> .gitignore
}

# Main script execution
if [ "$#" -eq 0 ]; then
  # If no arguments are provided, fetch all available types
  types=$(curl -sL --compressed https://www.toptal.com/developers/gitignore/api/list?format=lines | tr '\n' ',')

  # Split the types into chunks of 50 (you can adjust this number if needed)
  chunks=$(echo "$types" | awk 'BEGIN{RS=",";ORS=","} NR%50==0{print "\n"} 1')

  # Fetch .gitignore content for each chunk
  echo "$chunks" | while IFS= read -r chunk; do
    fetch_gitignore "$chunk"
  done

  echo ".gitignore file has been created/updated!"
else
  # Use the provided types
  fetch_gitignore "$1"
  echo ".gitignore file has been created/updated for the provided types!"
fi
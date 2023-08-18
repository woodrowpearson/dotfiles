#!/usr/bin/env bash


# Check if OBSIDIAN_GIT_REPO environment variable exists
# Default is `obsidian-vault-backup``
if [ -z "$OBSIDIAN_GIT_REPO" ]; then
    echo "OBSIDIAN_GIT_REPO environment variable is not set."
    read -p "Please enter your Obsidian Git Repository: " OBSIDIAN_GIT_REPO
    echo "To set it globally, run: export OBSIDIAN_GIT_REPO=$OBSIDIAN_GIT_REPO"
fi

# Check if GITHUB_TOKEN environment variable exists
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN environment variable is not set."
    read -p "Please enter your GitHub Personal Access Token: " GITHUB_TOKEN
    echo "To set it globally, run: export GITHUB_TOKEN=$GITHUB_TOKEN"
fi

# Check if GITHUB_USER environment variable exists
if [ -z "$GITHUB_USER" ]; then
    echo "GITHUB_USER environment variable is not set."
    read -p "Please enter your GitHub Username: " GITHUB_USER
    echo "To set it globally, run: export GITHUB_USER=$GITHUB_USER"
fi

# Check if the repository exists and is private
REPO_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$OBSIDIAN_GIT_REPO")

if [[ $REPO_INFO == *"Not Found"* ]]; then
    # Create a new private repository
    curl -s -H "Authorization: token $GITHUB_TOKEN" -d "{\"name\":\"$OBSIDIAN_GIT_REPO\", \"private\":true}" "https://api.github.com/user/repos"
elif [[ $REPO_INFO != *"private\": true"* ]]; then
    echo "The repository exists but is not private!"
    exit 1
fi

# Navigate to the symlink directory
cd "${HOME}/code/${OBSIDIAN_GIT_REPO}"

# Check if the directory is a git repository
if [ ! -d ".git" ]; then
    git init
    git remote add origin "https://github.com/$USER/$OBSIDIAN_GIT_REPO.git"
fi

# Add, commit, and push changes every 5 minutes
while true; do
    git add .
    git commit -m "Automated backup commit"
    git push -u origin master
    sleep 300
done

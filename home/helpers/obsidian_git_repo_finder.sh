GITHUB_USER_ACCESS_TOKEN="YOUR_GITHUB_PERSONAL_ACCESS_TOKEN"
GITHUB_USERNANE="woodrowpearson"
GITHUB_OBSIDIAN_BACKUP_REPO_NAME="obsidian-vault-backup"

# Check if the repository exists and is private
REPO_INFO=$(curl -s -H "Authorization: token $GITHUB_USER_ACCESS_TOKEN" "https://api.github.com/repos/$GITHUB_USERNAME/$GITHUB_OBSIDIAN_BACKUP_REPO_NAME")

if [[ $REPO_INFO == *"Not Found"* ]]; then
    # Create a new private repository
    curl -s -H "Authorization: token $TOKEN" -d "{\"name\":\"$REPO_NAME\", \"private\":true}" "https://api.github.com/user/repos"
elif [[ $REPO_INFO != *"private\": true"* ]]; then
    echo "The repository exists but is not private!"
    exit 1
fi

# Navigate to the symlink directory
cd /Users/w/code/obsidian-backup/

# Check if the directory is a git repository
if [ ! -d ".git" ]; then
    git init
    git remote add origin "https://github.com/$USER/$REPO_NAME.git"
fi

# Add, commit, and push changes every 5 minutes
while true; do
    git add .
    git commit -m "Automated backup commit"
    git push -u origin master
    sleep 300
done
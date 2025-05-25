# 🎨 Customization Guide

Make this setup truly yours! This guide covers how to customize every aspect of the dotfiles to match your preferences and workflow.

## 🎯 Quick Customization

### Personal Information
Edit your details in `group_vars/local`:

```yaml
# Basic identity
user_name: "Your Name"
user_email: "your.email@example.com"
github_user: "yourusername"

# Git configuration
git_user_name: "Your Name"
git_user_email: "your.email@example.com"
```

### Application Preferences
Customize your app list in the same file:

```yaml
homebrew_packages:
  - your-favorite-cli-tool
  - another-useful-package

homebrew_cask_packages:
  - your-preferred-browser
  - development-tools
```

## 🎨 Terminal & Shell Customization

### ZSH Configuration
**Custom aliases** in `roles/zsh/aliases.zsh`:
```bash
# Add your personal shortcuts
alias myserver="ssh user@your-server.com"
alias myproject="cd ~/Code/important-project"
alias quickcommit="git add . && git commit -m 'Quick update'"
```

**Environment variables** in `roles/zsh/_env.zsh`:
```bash
export EDITOR="your-preferred-editor"
export BROWSER="your-preferred-browser"
export GITHUB_TOKEN="your-token-here"
```

### Prompt Customization
The Pure theme can be customized in your shell configuration:

```bash
# Prompt symbols
PURE_PROMPT_SYMBOL="❯"
PURE_PROMPT_VICMD_SYMBOL="❮"

# Colors (add to .zshrc after installation)
zstyle ':prompt:pure:prompt:success' color green
zstyle ':prompt:pure:git:branch' color blue
```

### Alacritty Themes
Create custom themes in `roles/terminal/files/`:

```yaml
# ~/.config/alacritty/themes/mytheme.yml
colors:
  primary:
    background: '#1e1e1e'
    foreground: '#d4d4d4'
  # ... your color scheme
```

Then reference it in your main Alacritty config.

## 🛠️ Development Environment

### Language Versions
**mise configuration** in `roles/mise/files/config.toml`:
```toml
[tools]
python = "3.11"      # Your preferred Python version
node = "20.0.0"      # Specific Node.js version
rust = "latest"      # Always latest Rust
```

**Global packages** for each language:
```yaml
# In group_vars/local
python_packages:
  - your-favorite-python-tool
  - development-package

npm_packages:
  - your-global-npm-package
  - useful-cli-tool
```

### VS Code Customization
**Settings override** in `roles/vscode/files/settings.json`:
```json
{
  "editor.fontSize": 14,
  "editor.fontFamily": "Your Preferred Font",
  "workbench.colorTheme": "Your Theme",
  "editor.rulers": [80, 120]
}
```

**Additional extensions**:
```yaml
# In group_vars/local
vscode_extensions:
  - ms-python.python
  - your.favorite.extension
  - another.useful.extension
```

## 🔧 Git Configuration

### Custom Git Aliases
Add to `roles/git/aliases.zsh`:
```bash
alias gst="git status"
alias gcm="git commit -m"
alias gpo="git push origin"
alias your-workflow="git add . && git commit --amend --no-edit && git push --force-with-lease"
```

### Git Configuration
**Signing setup** in `roles/git/templates/gitconfig.j2`:
```ini
[user]
    name = {{ git_user_name }}
    email = {{ git_user_email }}
    signingkey = {{ gpg_key_id }}

[commit]
    gpgsign = true

[your-section]
    your-setting = your-value
```

## 🐳 Docker & Kubernetes

### Custom Docker Commands
Add to `roles/docker/aliases.zsh`:
```bash
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dcleanup="docker system prune -a"
alias your-stack="docker-compose -f ~/your-project/docker-compose.yml"
```

### Kubernetes Shortcuts
**Custom K8s aliases** in `roles/kubernetes/aliases.zsh`:
```bash
alias kgp="kubectl get pods"
alias kdp="kubectl describe pod"
alias your-namespace="kubectl config set-context --current --namespace=your-ns"
```

## 📱 macOS Preferences

### System Settings
**Custom preferences** in `roles/macos/files/set-defaults.sh`:
```bash
# Your preferred dock size
defaults write com.apple.dock tilesize -int 48

# Your trackpad settings
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Your finder preferences
defaults write com.apple.finder ShowPathbar -bool true
```

### Application Settings
**BetterTouchTool** presets in `misc/bettertouchtool/`:
- Export your current setup
- Replace the preset file
- Import during setup

## 🎭 Themes & Appearance

### Terminal Color Schemes
**Create custom themes**:
1. Design your colors in Terminal.app
2. Export the theme
3. Place in `misc/terminal/your-theme.terminal`
4. Reference in the terminal role

### Vim Customization
**Custom vim settings** in `roles/vim/files/vimrc`:
```vim
" Your preferred settings
set number relativenumber
set tabstop=4
set shiftwidth=4
colorscheme your-preferred-scheme

" Your custom key mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
```

## 🚀 Project Templates

### Custom Project Types
**Add new templates** in `templates/`:
1. Create your framework directory
2. Add template files with variables
3. Update `bin/newproject` to recognize your type

```bash
# Example: Add Go project support
mkdir templates/go
# Add main.go, go.mod templates, etc.
```

### CI/CD Customization
**Modify workflows** in `templates/github/workflows/`:
- Adjust test commands
- Add deployment steps
- Include your preferred tools

## 🔐 Security & Secrets

### Ansible Vault Customization
**Add your secrets** to `ansible/vars/local_settings.yml`:
```yaml
# Encrypted with ansible-vault
api_keys:
  your_service: "your-api-key"
  another_service: "another-key"

ssh_keys:
  your_server: "path-to-private-key"
```

**Access in roles**:
```yaml
# In role vars
your_api_key: "{{ api_keys.your_service }}"
```

## 🔄 Custom Roles

### Creating New Roles
```bash
mkdir roles/your-tool
cd roles/your-tool

# Basic structure
mkdir {tasks,defaults,files,templates}
echo "---" > tasks/main.yml
echo "---" > defaults/main.yml
```

**Role template**:
```yaml
# tasks/main.yml
---
- name: Install your-tool
  homebrew:
    name: your-tool
    state: present

- name: Configure your-tool
  template:
    src: config.j2
    dest: "{{ ansible_env.HOME }}/.your-tool-config"
```

### Role Integration
**Add to playbooks**:
```yaml
# In local_env.yml
- role: your-tool
  tags: ['your-tool', 'custom']
```

## 🎪 Advanced Customization

### Custom Functions
**ZSH functions** in `roles/zsh/functions.zsh`:
```bash
# Weather for your city
weather() {
    curl "wttr.in/YourCity?format=3"
}

# Your workflow automation
deploy() {
    git push origin main
    ssh your-server 'cd /app && git pull && systemctl restart your-app'
}
```

### Conditional Configuration
**Environment-specific settings**:
```yaml
# In group_vars/local
when_at_work:
  - additional-work-tools
  - vpn-software

when_at_home:
  - personal-tools
  - gaming-software
```

### Integration Hooks
**Custom setup scripts** in `bin/`:
```bash
#!/bin/bash
# bin/your-custom-setup

echo "Running your custom setup..."
# Your automation here
```

Make it executable: `chmod +x bin/your-custom-setup`

## 🔧 Testing Your Changes

### Validate Configuration
```bash
# Test your changes
ansible-playbook -i hosts local_env.yml --check --diff

# Test specific roles
ansible-playbook -i hosts local_env.yml --tags your-role --check
```

### Backup Before Changes
```bash
# Backup current config
cp -r ~/.config ~/.config.backup
cp ~/.zshrc ~/.zshrc.backup
```

## 💡 Tips & Best Practices

### Version Control Your Changes
```bash
# Track your customizations
git add group_vars/local
git commit -m "Customize for my preferences"

# Create your branch for experiments
git checkout -b my-customizations
```

### Modular Approach
- Keep customizations in separate files when possible
- Use variables for values that might change
- Comment your custom additions
- Test changes incrementally

### Share Your Improvements
- Consider contributing useful additions back
- Document your customizations for future reference
- Share interesting configurations with the community

---

*Ready to make it yours? Start with the basics and gradually add more advanced customizations as you discover your workflow preferences!*
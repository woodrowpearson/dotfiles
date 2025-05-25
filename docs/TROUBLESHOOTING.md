# 🚨 Troubleshooting Guide

When things go sideways (and they sometimes do), this guide has your back. Here are solutions to common issues you might encounter.

## 🔧 Installation Issues

### Xcode Command Line Tools Problems

**Problem**: `xcode-select: error: tool 'clang' requires Xcode`
```bash
# Solution: Reinstall command line tools
sudo xcode-select --reset
xcode-select --install

# If that fails, install full Xcode then retry
```

**Problem**: License agreement not accepted
```bash
# Solution: Accept Xcode license
sudo xcodebuild -license accept
```

### Homebrew Installation Failures

**Problem**: Permission denied errors
```bash
# Solution: Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Problem**: `brew: command not found`
```bash
# Solution: Add Homebrew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Ansible Issues

**Problem**: `ansible-playbook: command not found`
```bash
# Solution: Install Ansible via pip
python3 -m pip install --user ansible
# Or via Homebrew
brew install ansible
```

**Problem**: Vault password prompt
```bash
# Solution: Set vault password file or use interactive mode
ansible-playbook -i hosts local_env.yml --ask-vault-pass
```

## 🔐 SSH & Git Problems

### SSH Key Issues

**Problem**: `Permission denied (publickey)`
```bash
# Solution: Generate and add SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub | pbcopy
# Add to GitHub: Settings > SSH Keys > New SSH Key
```

**Problem**: SSH key not being used
```bash
# Solution: Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add to ~/.ssh/config for persistence
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

### Git Configuration Issues

**Problem**: Commits not signed
```bash
# Solution: Set up GPG signing
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

**Problem**: Git push rejected due to email privacy
```bash
# Solution: Use GitHub noreply email
git config --global user.email "username@users.noreply.github.com"
```

## 🐚 Shell & Terminal Issues

### ZSH Problems

**Problem**: ZSH not default shell
```bash
# Solution: Change default shell
chsh -s $(which zsh)
# Restart terminal
```

**Problem**: Prezto not loading
```bash
# Solution: Re-link prezto configuration
cd ~/.dotfiles
ansible-playbook -i hosts local_env.yml --tags zsh
```

**Problem**: Command not found after installation
```bash
# Solution: Reload shell configuration
source ~/.zshrc
# Or restart terminal
```

### Alacritty Issues

**Problem**: Alacritty not finding configuration
```bash
# Solution: Check config location
ls -la ~/.config/alacritty/
# Re-run terminal role if missing
ansible-playbook -i hosts local_env.yml --tags terminal
```

**Problem**: Font rendering issues
```bash
# Solution: Install nerd fonts
brew tap homebrew/cask-fonts
brew install font-meslo-lg-nerd-font
# Update Alacritty config font family
```

## 🛠️ Development Tool Issues

### mise Problems

**Problem**: mise not managing versions
```bash
# Solution: Check mise installation and setup
mise --version
mise list
# Reinstall if needed
curl https://mise.run | sh
```

**Problem**: Python/Node version not switching
```bash
# Solution: Check .mise.toml file and reload
cd your-project
mise install
mise use python@3.11
```

### Docker Issues

**Problem**: Docker daemon not running
```bash
# Solution: Start Docker Desktop
open -a Docker
# Or start daemon manually if using Docker CLI only
sudo systemctl start docker  # Linux
```

**Problem**: Permission denied for Docker
```bash
# Solution: Add user to docker group (Linux) or check Docker Desktop (macOS)
sudo usermod -aG docker $USER
# Log out and back in
```

### VS Code Problems

**Problem**: Extensions not installing
```bash
# Solution: Install extensions manually
code --install-extension ms-python.python
# Or reinstall VS Code completely
```

**Problem**: Settings not applying
```bash
# Solution: Check settings.json location
ls -la ~/Library/Application\ Support/Code/User/
# Re-run VS Code role
ansible-playbook -i hosts local_env.yml --tags vscode
```

## 📱 macOS Specific Issues

### System Preferences

**Problem**: Defaults not applying
```bash
# Solution: Kill affected processes and retry
killall Dock
killall Finder
killall SystemUIServer
# Re-run macOS role
ansible-playbook -i hosts local_env.yml --tags macos
```

**Problem**: SIP (System Integrity Protection) blocking changes
```bash
# Solution: Some changes require SIP to be disabled temporarily
# Boot into Recovery Mode: ⌘+R during startup
# Terminal > csrutil disable
# After changes: csrutil enable
```

### Application Issues

**Problem**: Homebrew cask apps not launching
```bash
# Solution: Check quarantine attributes
xattr -d com.apple.quarantine /Applications/YourApp.app
# Or allow in System Preferences > Security & Privacy
```

## 🔄 Update & Maintenance Issues

### Git Pull Conflicts

**Problem**: Conflicts when updating dotfiles
```bash
# Solution: Stash local changes, pull, then reapply
git stash push -m "Local customizations"
git pull origin main
git stash pop
# Resolve any conflicts manually
```

### Ansible Role Failures

**Problem**: Role fails with "changed: false"
```bash
# Solution: Force reinstallation
ansible-playbook -i hosts local_env.yml --tags problematic-role -e force_reinstall=true
```

**Problem**: Outdated packages causing conflicts
```bash
# Solution: Update all packages first
brew update && brew upgrade
# Then re-run setup
```

## 🔍 Diagnostic Commands

### Health Check Script
```bash
#!/bin/bash
# Quick system health check

echo "=== Dotfiles Health Check ==="

# Check shell
echo "Shell: $SHELL"
echo "ZSH version: $(zsh --version)"

# Check key tools
commands=("git" "brew" "ansible" "mise" "eza" "bat" "rg")
for cmd in "${commands[@]}"; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "✅ $cmd: $(which $cmd)"
    else
        echo "❌ $cmd: Not found"
    fi
done

# Check configurations
configs=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.config/alacritty/alacritty.yml"
)

for config in "${configs[@]}"; do
    if [[ -f $config ]]; then
        echo "✅ Config exists: $config"
    else
        echo "❌ Missing config: $config"
    fi
done
```

### Environment Information
```bash
# System info
system_profiler SPSoftwareDataType
sw_vers

# Homebrew doctor
brew doctor

# Git configuration
git config --list --global

# Shell environment
env | grep -E "(PATH|SHELL|HOME)"
```

## 🆘 Emergency Recovery

### Full Reset
```bash
# If everything is broken, start fresh
cd ~/.dotfiles
git checkout main
git reset --hard HEAD
git clean -fd
./bin/dot-bootstrap
```

### Selective Recovery
```bash
# Restore just shell configuration
ansible-playbook -i hosts local_env.yml --tags zsh,git

# Restore just development environment
ansible-playbook -i hosts local_env.yml --tags mise,docker,vscode
```

### Backup Recovery
```bash
# If you made backups (you did, right?)
cp ~/.config.backup/* ~/.config/
cp ~/.zshrc.backup ~/.zshrc
source ~/.zshrc
```

## 💬 Getting Help

### Before Opening an Issue

1. **Check this troubleshooting guide**
2. **Run diagnostic commands** to gather information
3. **Try the emergency recovery** steps
4. **Search existing issues** on GitHub

### When Opening an Issue

Include this information:
```bash
# System information
sw_vers
echo "Shell: $SHELL"
ansible --version
brew --version

# Error output
# Paste the exact error message and command that failed

# Configuration
# Include relevant config files (sanitize any secrets!)
```

### Community Resources

- **GitHub Issues**: Report bugs and feature requests
- **Discussions**: Ask questions and share tips
- **Fork and PR**: Contribute improvements

## 🔧 Prevention Tips

### Best Practices

1. **Test in dry-run mode** before applying changes
   ```bash
   ansible-playbook -i hosts local_env.yml --check --diff
   ```

2. **Backup before major changes**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   cp -r ~/.config ~/.config.backup
   ```

3. **Keep configurations in version control**
   ```bash
   git add group_vars/local
   git commit -m "Update personal configuration"
   ```

4. **Regular maintenance**
   ```bash
   brew update && brew upgrade
   cd ~/.dotfiles && git pull origin main
   ./bin/dot-bootstrap
   ```

---

*Still stuck? The community is here to help! Open an issue with detailed information about your problem.*
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

## 🔗 Bootstrap Dependency Chain Issues

### Runtime Dependency Failures

**Problem**: `npm: command not found` during bootstrap
```bash
TASK [dev-environment : Install Mac-CLI via npm]
fatal: [localhost]: FAILED! => {"msg": "npm: command not found"}
```

**Root Cause**: `dev-environment` role running before `mise` role installs Node.js

**Solution**:
```bash
# Check role execution order
grep -A 20 "roles:" local_env.yml | head -10

# Verify mise comes before dev-environment
# Should see:
# - { role: mise, tags: ["mise"] }
# - { role: dev-environment, tags: ["dev-environment"] }

# Run dependency validation test
./bin/dot-test-bootstrap

# Fix manually if needed
mise install node
npm install -g mac-cli
```

**Problem**: `uv: No Python installation found` during Python tool setup
```bash
TASK [python : Install global Python tools via uv]
fatal: [localhost]: FAILED! => {"msg": "uv: No Python installation found"}
```

**Root Cause**: Python tools installed before Python runtime available

**Solution**:
```bash
# Ensure Python runtime is available
mise install python

# Check Python tools installation
uv tool list

# Reinstall tools if needed
for tool in pytest ruff black mypy poetry pyright jupyterlab; do
    uv tool install $tool
done
```

**Problem**: `externally-managed-environment` error during Python setup
```bash
error: externally-managed-environment
× This environment is externally managed
```

**Root Cause**: System Python restricted from global package installation (PEP 668)

**Solution**:
```bash
# Check if uv is installed
which uv || brew install uv

# Use isolated tool installation
uv tool install pytest
uv tool install ruff
# etc.

# Verify tools are available
uv tool list
export PATH="$HOME/.local/bin:$PATH"
```

### Tool Installation Conflicts

**Problem**: Multiple installations of CLI tools (eza, bat, ripgrep)
```bash
# Command exists but behaves unexpectedly
which eza  # Shows multiple paths
```

**Root Cause**: Tools installed via both Homebrew and dedicated roles

**Solution**:
```bash
# Check for duplicate installations
brew list | grep -E "^(eza|bat|ripgrep|fzf)$"
ls -la ~/.dotfiles/roles/{eza,bat,rg,fzf}/tasks/main.yml

# Remove Homebrew versions (roles provide configuration)
brew uninstall eza bat ripgrep fzf

# Reinstall via roles only
ansible-playbook -i hosts local_env.yml --tags eza,bat,rg,fzf

# Update PATH
source ~/.zshrc
```

**Problem**: `command not found` after successful installation
```bash
# Tool installed but not in PATH
eza --version  # command not found
```

**Root Cause**: PATH not updated or shell configuration not reloaded

**Solution**:
```bash
# Check if tool actually installed
find /opt/homebrew -name "eza" -type f
find ~/.local -name "eza" -type f

# Update PATH manually
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"

# Reload shell configuration
source ~/.zshrc

# Or restart terminal completely
```

### Fresh Installation Scenarios

**Problem**: Bootstrap fails immediately on brand new macOS system
```bash
❌ Ansible not found. Run ./bin/dot-install first.
```

**Root Cause**: Prerequisites not installed

**Solution**:
```bash
# Run prerequisite installation first
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash

# Then run bootstrap
cd ~/dotfiles
./bin/dot-bootstrap
```

**Problem**: Role execution order causing dependency failures
```bash
# Multiple "command not found" errors during bootstrap
```

**Root Cause**: Dependencies not installed in correct order

**Solution**:
```bash
# Test dependency order
./bin/dot-test-bootstrap

# Check role execution order in playbook
cat local_env.yml | grep -A 30 "roles:"

# Manually fix if needed
ansible-playbook -i hosts local_env.yml --tags mise
ansible-playbook -i hosts local_env.yml --tags dev-environment
```

## 💾 Backup & Recovery Issues

### Backup Checkpoint Failures

**Problem**: `backup-checkpoint: No such file or directory` during bootstrap
```bash
TASK [backup : Execute backup checkpoint creation]
fatal: [localhost]: FAILED! => {
  "msg": "non-zero return code", 
  "rc": 127, 
  "stderr": "/bin/sh: /Users/w/.local/bin/backup-checkpoint: No such file or directory"
}
```

**Root Cause**: Backup infrastructure not yet installed when checkpoint attempted

**Solution**: This is now handled gracefully - you should see:
```bash
⚠️  Backup infrastructure not yet available, skipping pre-ansible checkpoint
```

If you still see failures:
```bash
# Check if backup system installed
ls -la ~/.local/bin/backup-*

# Install backup system manually
ansible-playbook -i hosts local_env.yml --tags backup

# Create missing checkpoints
backup-checkpoint manual bootstrap-complete
```

**Problem**: Backup system not initializing on fresh install
```bash
# Bootstrap completes but no backup commands available
backup-create --help  # command not found
```

**Root Cause**: Backup role not executing or PATH not updated

**Solution**:
```bash
# Check if backup role executed
ansible-playbook -i hosts local_env.yml --tags backup -v

# Check PATH includes ~/.local/bin
echo $PATH | grep -o "$HOME/.local/bin"

# Add to PATH if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify backup system
backup-create --help
```

**Problem**: Network storage not available during bootstrap
```bash
# Backup operations fail or timeout
```

**Root Cause**: External backup drive or network storage not connected

**Solution**: This should now be handled gracefully:
```bash
# Check backup system status
backup-list

# Backup system works locally even without network storage
# Connect external storage later and sync:
backup-create --sync-external
```

### Bootstrap Process Failures

**Problem**: Bootstrap script fails mid-execution
```bash
# Solution: Use checkpoint rollback
backup-rollback bootstrap --phase pre-homebrew

# Or emergency recovery
backup-rollback emergency

# Resume from specific role
ansible-playbook -i hosts local_env.yml --tags git,zsh,python
```

**Problem**: Configuration got corrupted during setup
```bash
# Solution: Restore specific application configs
backup-restore --selective vscode latest
backup-restore --configs latest

# Or restore from specific checkpoint
backup-restore --from pre-setup_20240125_143022
```

**Problem**: Can't access backup commands after failed setup
```bash
# Solution: Manual recovery from Time Machine
# 1. Boot to Recovery Mode (⌘+R)
# 2. Restore from Time Machine backup
# 3. Re-run dotfiles setup

# Or restore manually
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
```

### Backup System Issues

**Problem**: Backup creation fails with permission errors
```bash
# Solution: Fix backup directory permissions
sudo chown -R $(whoami) ~/.dotfiles-backups
chmod 755 ~/.dotfiles-backups

# Reinitialize backup system
backup-create --initialize
```

**Problem**: External backup drive not detected
```bash
# Solution: Check drive mount and paths
mount | grep -i backup
ls -la /Volumes/

# Update backup configuration if needed
# Edit group_vars/local to match your drive path
```

**Problem**: GPG encryption keys missing
```bash
# Solution: Regenerate backup encryption key
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: Dotfiles Backup
Name-Email: backup@localhost
Expire-Date: 0
%no-protection
EOF
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

### Comprehensive Bootstrap Testing

**Use the built-in testing framework for thorough validation:**

```bash
# Run complete bootstrap validation
./bin/dot-test-bootstrap

# This tests:
# - Prerequisites (Xcode, Homebrew, Git, Python, Ansible)
# - Script functionality (dot-install, dot-bootstrap)
# - Ansible playbook syntax and inventory
# - Bootstrap role execution in check mode
# - Dependency order validation
# - Configuration file integrity
# - Role structure validation
# - Remote URL accessibility
```

**Understanding test results:**
- ✅ **Green checkmarks**: Tests passed successfully
- ⚠️ **Yellow warnings**: Non-critical issues (e.g., incomplete roles)
- ❌ **Red failures**: Critical issues requiring attention

**Test specific components:**
```bash
# Test only dependency chain
grep -A 20 "test_dependency_order" bin/dot-test-bootstrap

# Test only backup system
grep -A 20 "test_backup" bin/dot-test-bootstrap

# Test role execution manually
ansible-playbook -i hosts local_env.yml --tags mise --check
ansible-playbook -i hosts local_env.yml --tags dev-environment --check
```

### Health Check Script
```bash
#!/bin/bash
# Quick system health check

echo "=== Dotfiles Health Check ==="

# Run comprehensive bootstrap test first
echo "Running comprehensive test suite..."
./bin/dot-test-bootstrap

echo ""
echo "=== Quick Manual Checks ==="

# Check shell
echo "Shell: $SHELL"
echo "ZSH version: $(zsh --version)"

# Check key tools with version info
commands=("git" "brew" "ansible" "mise" "eza" "bat" "rg" "uv")
for cmd in "${commands[@]}"; do
    if command -v $cmd >/dev/null 2>&1; then
        version=$(eval "$cmd --version 2>/dev/null | head -1" || echo "unknown")
        echo "✅ $cmd: $(which $cmd) ($version)"
    else
        echo "❌ $cmd: Not found"
    fi
done

# Check mise-managed tools
echo ""
echo "=== Runtime Versions ==="
mise list 2>/dev/null || echo "❌ mise not configured"

# Check backup system
echo ""
echo "=== Backup System ==="
if [[ -f "$HOME/.local/bin/backup-list" ]]; then
    echo "✅ Backup system available"
    backup-list 2>/dev/null | head -5 || echo "ℹ️  No backups created yet"
else
    echo "❌ Backup system not installed"
fi

# Check configurations
echo ""
echo "=== Configuration Files ==="
configs=(
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.config/alacritty/alacritty.toml"
    "$HOME/.local/bin/backup-create"
)

for config in "${configs[@]}"; do
    if [[ -f $config ]]; then
        echo "✅ Config exists: $config"
    else
        echo "❌ Missing config: $config"
    fi
done

# Check PATH setup
echo ""
echo "=== PATH Configuration ==="
echo "PATH contains:"
echo "$PATH" | tr ':' '\n' | grep -E "(homebrew|local)" | sort | uniq
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
   # Quick backup using built-in system
   backup-create --config-only --name "before-changes"
   
   # Or manual backup for specific files
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
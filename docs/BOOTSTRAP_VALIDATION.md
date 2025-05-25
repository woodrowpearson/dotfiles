# Bootstrap Validation Checklist

This document provides a comprehensive checklist for validating the bootstrap process of the dotfiles repository.

## Quick Validation

Run the automated test suite:
```bash
./bin/dot-test-bootstrap
```

## Manual Validation Steps

### 1. Prerequisites Check
- [ ] Running on macOS
- [ ] Xcode Command Line Tools installed: `xcode-select -p`
- [ ] Homebrew installed: `brew --version`
- [ ] Git installed: `git --version`
- [ ] Python3 installed: `python3 --version`
- [ ] Ansible installed: `ansible --version`

### 2. Repository Structure
- [ ] Dotfiles cloned to `~/dotfiles`
- [ ] All bootstrap scripts exist:
  - [ ] `bin/dot-install`
  - [ ] `bin/dot-bootstrap`
  - [ ] `bin/dot-test-bootstrap`
- [ ] Configuration files exist:
  - [ ] `local_env.yml`
  - [ ] `remote_env.yml`
  - [ ] `hosts`
  - [ ] `group_vars/local`
  - [ ] `group_vars/remote`

### 3. Script Validation
- [ ] dot-install help works: `./bin/dot-install --help`
- [ ] dot-bootstrap syntax valid: `bash -n ./bin/dot-bootstrap`
- [ ] Ansible playbook syntax: `ansible-playbook --syntax-check local_env.yml`

### 4. Bootstrap Process Test
- [ ] Bootstrap check mode runs: `ansible-playbook -i hosts local_env.yml --tags bootstrap --check`
- [ ] Package manager role works: `ansible-playbook -i hosts local_env.yml --tags package_manager --check`
- [ ] ZSH role works: `ansible-playbook -i hosts local_env.yml --tags zsh --check`

### 5. Post-Bootstrap Validation
After running `./bin/dot-bootstrap`:
- [ ] Homebrew packages installed: `brew list`
- [ ] ZSH configuration applied: `echo $SHELL`
- [ ] Dotfiles sourced: `which eza bat rg`
- [ ] Backup system configured: `backup-list`

## Common Issues and Solutions

### Issue: Ansible Python Interpreter Warning
**Symptom:** Warning about Python interpreter discovery
**Solution:** 
```bash
export ANSIBLE_PYTHON_INTERPRETER=$(which python3)
```

### Issue: Bootstrap Fails on Fresh System
**Symptom:** Missing dependencies or permissions
**Solution:**
1. Run `./bin/dot-install` first
2. Ensure sudo password is available for `--ask-become-pass`
3. Check Xcode Command Line Tools: `xcode-select --install`

### Issue: ZSH Not Set as Default Shell
**Symptom:** Still using bash after bootstrap
**Solution:**
```bash
chsh -s $(which zsh)
```

### Issue: Homebrew Packages Not Found
**Symptom:** Commands like `eza`, `bat` not available
**Solution:**
1. Check PATH: `echo $PATH`
2. Source zsh config: `source ~/.zshrc`
3. Restart terminal

### Issue: Git Configuration Missing
**Symptom:** Git operations fail due to missing config
**Solution:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Emergency Recovery

### Restore from Backup
If bootstrap causes issues:
```bash
backup-restore
# or
backup-rollback
```

### Clean Slate Reset
To start over completely:
```bash
# Remove dotfiles
rm -rf ~/dotfiles

# Reset shell
chsh -s /bin/bash

# Remove homebrew (optional)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Start fresh
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
```

## Maintenance Commands

### Regular Updates
```bash
dot-update                    # Update all non-bootstrap components
dot-update git python        # Update specific roles
```

### Health Checks
```bash
./bin/dot-test-bootstrap     # Full validation
brew doctor                  # Homebrew health
ansible --version           # Ansible status
```

### Backup Management
```bash
backup-create               # Create new backup
backup-list                 # List all backups
backup-checkpoint          # Manage checkpoints
```

## Testing in CI/CD

For automated testing:
```yaml
# .github/workflows/test-bootstrap.yml
name: Test Bootstrap
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test bootstrap scripts
        run: ./bin/dot-test-bootstrap
```

## Troubleshooting Resources

- **Ansible Documentation:** https://docs.ansible.com/
- **Homebrew Issues:** https://github.com/Homebrew/brew/issues
- **macOS Development:** https://developer.apple.com/documentation/
- **Dotfiles Repository:** https://github.com/woodrowpearson/dotfiles/issues
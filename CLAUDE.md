# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based dotfiles repository that sets up a complete macOS development environment. The repository is structured around Ansible roles, each responsible for configuring specific tools and applications.

## Key Commands

### Setup Commands
- `curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash` - One-command fresh macOS setup
- `./bin/dot-bootstrap` - Initial setup of local environment (runs all roles)
- `./bin/dot-configure` - Interactive post-setup configuration (API keys, SSH, GPG)
- `dot-update` - Update local environment (skips bootstrap-tagged roles)
- `dot-update <role>` - Update specific role(s), e.g., `dot-update git python`

### Development Commands
- `newproject <language> <name>` - Create new project with templates (python, node, rust, go, web)
- `code ~/code/.env` - Edit global environment variables
- Various Mac-CLI aliases: `sysinfo`, `speedtest`, `gitlog`, `updateall`

### Backup Commands
- `backup-create` - Create new configuration backup with encryption support
- `backup-list` - List available backups and checkpoints with filtering options
- `backup-restore` - Restore from backups with integrity verification
- `backup-checkpoint` - Create bootstrap phase checkpoints for rollback capability
- `backup-verify` - Verify backup integrity and test restore procedures
- `backup-rollback` - Rollback to previous checkpoint or backup state
- `backup-monitor` - Monitor backup system health and status

### Advanced Commands
- `ansible-playbook -i hosts local_env.yml --tags <tag>` - Run specific tagged roles
- `ansible-playbook -i hosts remote_env.yml` - Set up remote environment

## Architecture

### Core Structure
- `local_env.yml` and `remote_env.yml` - Main playbooks defining role execution order
- `roles/` - Individual Ansible roles for each tool/application
- `group_vars/local` and `group_vars/remote` - Configuration variables
- `hosts` - Ansible inventory file

### Role System
Each role in `roles/` may contain:
- `*.zsh` files - Automatically loaded into zsh environment
- `bin/` directories - Contents added to `$PATH`
- Standard Ansible directories (tasks, files, templates, defaults, etc.)

### Key Roles
- `backup` - Comprehensive backup system with encrypted checkpoints and graceful failure handling
- `package_manager` - Homebrew setup and package installation
- `macos` - macOS system settings (Dock, Finder, trackpad, screenshots)
- `git` - Git configuration and aliases
- `zsh` - Shell configuration with Prezto, syntax highlighting, autosuggestions
- `starship` - Next-generation shell prompt with git integration, icons, and dynamic coloring
- `dev-environment` - ~/code directory with API key stubs
- `mise` - Multi-language runtime management (Node.js 20, Go)
- `python` - Python environment with uv and tools (pytest, ruff, black, mypy, poetry, pyright, jupyterlab)
- `rust` - Rust toolchain via rustup
- `alacritty` - Terminal emulator with custom theme and Hack Nerd Font
- `vscode` - VS Code configuration with Claude Code extension
- `vim` - Vim configuration with vim-plug

### Configuration Variables
Primary configuration in `group_vars/local`:
- `full_name`, `git_user`, `git_email` - Personal information (woodrow pearson, woodrowpearson@gmail.com)
- `mac_homebrew_packages` - Modern CLI tools (eza, bat, ripgrep, fzf, etc.)
- `mac_cask_packages` - Essential apps (Chrome, VS Code, Alacritty, Spotify, OrbStack, BetterTouchTool, Tailscale)
- `icloud_enabled: true` - Enable iCloud Drive symlink

### Custom Features
- **Comprehensive Backup System**: Encrypted backpoints, graceful failure handling, Time Machine integration
- **Bootstrap Checkpoints**: Automatic recovery points with rollback capability during setup
- **Project Scaffolding**: `newproject python my-api` creates fully configured projects with CI/CD
- **Interactive Setup**: Guided configuration of API keys, SSH, and GPG with `dot-configure`
- **One-Command Install**: From fresh macOS to fully configured in minutes with backup safety
- **Modern CLI Tools**: 15+ replacements with intuitive aliases (ls→eza, cat→bat, grep→rg)
- **Custom Terminal**: Alacritty with pastel theme, Hack Nerd Font, Starship prompt with git integration and icons
- **Smart Secrets**: Global .env template, per-project configurations, direnv integration
- **Enhanced VS Code**: Language-specific settings, recommended extensions, integrated terminal
- **CI/CD Templates**: GitHub Actions workflows for Python, Node.js, Rust
- **Pre-commit Hooks**: Automated code quality checks
- **Mac-CLI Integration**: System management shortcuts and developer utilities

## Development Notes

### Workflow Patterns
- **Zero-to-Productive**: Complete setup from fresh macOS in under 30 minutes
- **Project Creation**: `newproject` provides language-specific scaffolding with CI/CD
- **Secrets Management**: Global defaults, per-project overrides, secure configuration
- **Code Quality**: Pre-commit hooks, formatters, linters configured by default

### Repository Structure
- All roles are tagged for selective execution
- Bootstrap-tagged roles only run during initial setup
- Templates directory provides CI/CD and configuration templates
- Scripts in `bin/` are automatically added to PATH
- Remote setup supports server configurations

### Best Practices Alignment
- Self-documenting with comprehensive `CLAUDE.md`
- Modular, composable Ansible roles
- Safe defaults with easy customization
- Automated testing via GitHub Actions templates
- Security-conscious (SSH keys, GPG, API key management)
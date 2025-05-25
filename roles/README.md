# 🎭 Ansible Roles Documentation

**The workhorses of automation.** Each role handles a specific piece of your development environment setup.

## 🏗️ Architecture Overview

Each role follows Ansible best practices:
- **`tasks/`** - The actual work (install, configure, symlink)
- **`files/`** - Static files to copy 
- **`templates/`** - Dynamic configuration files
- **`defaults/`** - Default variables (customizable in `group_vars/local`)
- **`*.zsh`** - Shell integrations (automatically loaded)

## 🏠 Home Server & Automation Roles

### 🏠 `homeassistant/` - Complete Smart Home Ecosystem
**What it configures:**
- HomeAssistant core with PostgreSQL database
- MQTT broker (Eclipse Mosquitto) for device communication
- Zigbee2MQTT for Zigbee device integration
- HACS (Home Assistant Community Store) with popular integrations
- Google Home, Apple HomeKit, and Philips Hue integration
- Comprehensive configuration templates

**Why you'll love it:** Turn your Mac Mini into a professional smart home hub

---

### 📹 `frigate/` - AI-Powered Camera Monitoring
**What it configures:**
- Frigate NVR with real-time object detection
- AI-powered person, car, and animal detection
- 24/7 recording with motion-triggered clips
- HomeAssistant integration for notifications
- Multi-camera support (ONVIF, RTSP, USB)
- Hardware acceleration for optimal performance

**Why you'll love it:** Professional CCTV monitoring with intelligent alerts

---

### 📊 `monitoring/` - Comprehensive Analytics Stack
**What it configures:**
- Grafana dashboards for beautiful visualizations
- Prometheus for time-series metrics collection
- AlertManager for intelligent notification routing
- Node Exporter for system metrics
- cAdvisor for container monitoring
- Pre-configured dashboards for all services

**Why you'll love it:** Professional monitoring like the big companies use

---

### 🌐 `tailscale/` - Secure Mesh VPN
**What it configures:**
- Tailscale VPN with exit node capabilities
- Magic DNS for automatic service discovery
- Subnet routing for home network access
- SSH integration for secure remote access
- Service monitoring and health checks
- Firewall configuration for security

**Why you'll love it:** Access your home server securely from anywhere

---

### 🛡️ `adguard/` - Network-wide Ad Blocking
**What it configures:**
- AdGuard Home with comprehensive blocklists
- DNS-over-HTTPS for secure queries
- Network-wide ad and tracker blocking
- Custom DNS rules and filtering
- Web interface for management
- Performance-optimized configuration

**Why you'll love it:** Block ads and trackers for your entire home network

---

### 💾 `backup/` - Multi-Layer Backup & Recovery System
**What it configures:**
- Comprehensive backup strategy for safe development environment management
- Bootstrap safety checkpoints with automatic rollback capabilities
- Time Machine integration + selective configuration backups
- Encrypted security data backup (SSH keys, GPG keys, credentials)
- Non-networked backup drive support with local + external sync
- Mackup integration for application settings preservation
- Complete CLI toolkit: backup-create, backup-restore, backup-checkpoint, backup-list, backup-rollback

**Why you'll love it:** Never lose your carefully crafted development environment again

---

## 🎯 Core System Roles

### 🏠 `alacritty/` - Terminal That Doesn't Suck
**What it configures:**
- Modern terminal emulator with GPU acceleration
- Custom color scheme (pastel theme with contrasting background)
- Hack font integration
- Optimized for development workflow

**Why you'll love it:** Blazing fast, beautiful, and actually configurable

---

### 🎨 `macos/` - System Settings Automation  
**What it configures:**
- Dock position, size, and behavior
- Finder preferences (show hidden files, path bar)
- Screenshot settings (PNG format, custom location)
- Trackpad and keyboard preferences
- iCloud Drive symlink to `~/iCloud`

**Why you'll love it:** No more clicking through System Preferences for 20 minutes

---

### 🐚 `zsh/` - Shell That Makes You Productive
**What it configures:**
- Prezto framework with Pure theme
- Syntax highlighting and autosuggestions  
- Custom aliases for modern CLI tools
- Direnv integration for per-project environments
- TheFuck command correction

**Files managed:**
- `.zshrc` - Main shell configuration
- `.zpreztorc` - Prezto configuration
- `aliases.zsh` - Modern CLI tool aliases
- `functions.zsh` - Useful shell functions

**Why you'll love it:** Beautiful, fast, and makes the command line actually enjoyable

---

## 🛠️ Development Environment Roles

### 🐍 `python/` - Python Done Right
**What it installs:**
- `uv` - Modern Python package manager (faster than pip)
- Global Python tools: pytest, ruff, black, mypy, poetry, pyright, jupyterlab

**Why you'll love it:** Modern Python tooling that just works

---

### 📦 `mise/` - Multi-Language Runtime Management  
**What it manages:**
- Node.js 20 (with version switching capability)
- Go latest
- Language version switching per-project

**Why you'll love it:** Never deal with version conflicts again

---

### 🦀 `rust/` - Systems Programming Goodness
**What it installs:**
- Rust toolchain via rustup
- Cargo package manager
- Ready for systems programming

**Why you'll love it:** Rust development setup in seconds

---

### 🚀 `vscode/` - Editor Config + Extensions
**What it configures:**
- Comprehensive settings for all supported languages
- Language-specific formatters and linters
- Terminal integration with Alacritty
- File associations and exclusions
- Auto-save, format-on-save, organize imports

**Extensions installed:**
- Claude Code extension (obviously!)
- Language-specific extensions based on your setup

**Why you'll love it:** VS Code that's perfectly tuned for your workflow

---

### 🏠 `dev-environment/` - Development Workflow
**What it creates:**
- `~/code/` directory for projects
- Global `.env` template with API key stubs
- Mac-CLI installation and aliases
- Project-focused development structure

**Why you'll love it:** Organized development workflow from day one

---

## 🔧 Tool Enhancement Roles

### ⚡ Modern CLI Tool Roles
These roles install and configure modern replacements for ancient Unix tools:

- **`eza/`** - `ls` replacement with icons and git integration
- **`bat/`** - `cat` replacement with syntax highlighting  
- **`rg/`** - `grep` replacement that's stupid fast
- **`fzf/`** - Fuzzy finder for everything
- **`gsed/`** - GNU sed (because BSD sed is weird)

**Aliases configured:**
```bash
ls    → eza -alh --icons     # Beautiful file listings
cat   → bat --paging=never   # Syntax highlighted output  
grep  → rg --color=auto      # Fast, smart searching
find  → fd                   # Sensible find replacement
```

---

### 📝 `vim/` - Classic Editor Setup
**What it configures:**
- Vim with vim-plug plugin manager
- Language-specific snippets (Python, JavaScript, reStructuredText)
- Hybrid color scheme
- ctags integration for code navigation

**Why it's included:** Sometimes you just need vim

---

### 📦 `package_manager/` - Foundation Layer
**What it handles:**
- Homebrew installation and updates
- Core CLI tools installation
- Package management automation

**Why it's first:** Everything else builds on this foundation

---

## 🎯 Role Execution Order

Roles run in optimized order for dependency management:

1. **Bootstrap** - `package_manager`, `macos`
2. **Core Dev** - `git`, `zsh`, `dev-environment`  
3. **Languages** - `mise`, `python`, `rust`
4. **CLI Tools** - `rg`, `eza`, `bat`, `fzf`, `gsed`
5. **Applications** - `alacritty`, `vscode`, `vim`

## 🔧 Customization

### Adding Your Own Role
```bash
# Create the structure
mkdir -p roles/my-tool/{tasks,files,defaults}

# Add to local_env.yml
- { role: my-tool, tags: ["my-tool"] }

# Run it
dot-update my-tool
```

### Modifying Existing Roles
- **Package lists:** Edit `group_vars/local`
- **Configuration files:** Modify files in `roles/*/files/`
- **Default behavior:** Update `roles/*/defaults/main.yml`

### Selective Installation
```bash
# Run only specific roles
ansible-playbook -i hosts local_env.yml --tags "git,zsh,python"

# Skip roles you don't want
ansible-playbook -i hosts local_env.yml --skip-tags "vim,docker"
```

## 🚀 Best Practices

- **Idempotent by design** - Run roles multiple times safely
- **Tagged appropriately** - Use `dot-update <role>` for targeted updates
- **Well documented** - Each role has clear purpose and configuration
- **Modular** - Remove roles you don't need, add ones you do

---

**💡 Pro Tip:** Each role is designed to be independently useful. You can cherry-pick just the roles you want!

**🔍 Exploring Roles:** Each role directory contains its own configuration files and documentation. Dive into `roles/*/tasks/main.yml` to see exactly what each role does.

**[← Back to Main README](../README.md) • [🛠️ Scripts →](../bin/README.md) • [🏗️ Templates →](../templates/README.md)**
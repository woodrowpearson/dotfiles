# 📦 Installation Guide

Welcome to the installation guide for woodrow's dotfiles! This guide covers everything from fresh macOS setup to selective component installation.

## 🚀 Quick Start (Fresh macOS)

For a brand new Mac, use the one-command installer:

```bash
curl -fsSL https://raw.githubusercontent.com/wpearson/dotfiles/main/bin/dot-install | bash
```

This handles everything:
- Installs Xcode Command Line Tools
- Sets up SSH keys and GitHub access
- Clones the repository
- Runs the full setup process

## 🎯 Standard Installation

If you already have development tools and SSH configured:

```bash
git clone git@github.com:wpearson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bin/dot-bootstrap
```

## 🔧 Step-by-Step Installation

### Prerequisites

1. **macOS**: This setup is optimized for macOS (tested on Monterey+)
2. **Xcode Command Line Tools**: 
   ```bash
   xcode-select --install
   ```
3. **SSH Key**: Set up GitHub SSH access for private repositories

### Core Installation

1. **Clone the repository**:
   ```bash
   git clone git@github.com:wpearson/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Review configuration**:
   ```bash
   # Check what will be installed
   ansible-playbook -i hosts local_env.yml --check --diff
   ```

3. **Run the installation**:
   ```bash
   ./bin/dot-bootstrap
   ```

4. **Configure secrets and preferences**:
   ```bash
   ./bin/dot-configure
   ```

## 🎛️ Selective Installation

### Install Specific Roles

```bash
# Just shell configuration
ansible-playbook -i hosts local_env.yml --tags zsh,git

# Development tools only
ansible-playbook -i hosts local_env.yml --tags mise,docker,kubernetes

# macOS preferences
ansible-playbook -i hosts local_env.yml --tags macos
```

### Available Tags

| Tag | Description |
|-----|-------------|
| `shell` | ZSH, Prezto, themes, aliases |
| `git` | Git configuration and aliases |
| `dev` | Development tools (mise, Docker, K8s) |
| `cli` | Modern CLI replacements (eza, bat, rg) |
| `macos` | macOS system preferences |
| `vim` | Vim configuration and plugins |

## 🔐 Configuration Setup

After installation, run the interactive configuration:

```bash
./bin/dot-configure
```

This sets up:
- API keys and tokens
- SSH and GPG keys  
- VS Code preferences
- Git signing configuration

## 🎨 Terminal Setup

### Alacritty Configuration

The setup includes custom Alacritty themes. After installation:

1. Install Alacritty: `brew install --cask alacritty`
2. Configuration is automatically linked to `~/.config/alacritty/`
3. Themes available: Ayu, Night Owl, Custom

### Shell Enhancement

The ZSH configuration includes:
- **Prezto** framework with Pure theme
- **Modern CLI tools**: eza, bat, ripgrep, fzf
- **Smart aliases** and functions
- **Git integration** with status and shortcuts

## 🐳 Development Environment

### Language Support

Automatic setup for:
- **Python**: mise, pipx, common packages
- **Node.js**: npm, common global packages  
- **Rust**: rustup, cargo tools
- **Docker & Kubernetes**: CLI tools and aliases

### VS Code Integration

- Comprehensive settings for all languages
- Extensions auto-installed
- Workspace optimization
- Integrated terminal configuration

## 🚨 Troubleshooting

### Common Issues

**Homebrew Permission Errors**:
```bash
sudo chown -R $(whoami) /opt/homebrew
```

**SSH Key Issues**:
```bash
# Generate new key
ssh-keygen -t ed25519 -C "your_email@example.com"
# Add to GitHub
cat ~/.ssh/id_ed25519.pub | pbcopy
```

**Ansible Vault Errors**:
```bash
# Recreate vault file
./bin/dot-configure
```

For more issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## 🔄 Updates

Keep your setup fresh:

```bash
cd ~/.dotfiles
git pull origin main
./bin/dot-bootstrap
```

## 🎯 Verification

Test your installation:

```bash
# Check Ansible dry-run
ansible-playbook -i hosts local_env.yml --check

# Verify shell setup
echo $SHELL
which eza bat rg fzf

# Test aliases
ll
gst
```

## 📚 Next Steps

After installation:
1. **Customize**: See [CUSTOMIZATION.md](CUSTOMIZATION.md)
2. **Explore**: Review [FEATURES.md](FEATURES.md)  
3. **Create**: Use `newproject` for scaffolding
4. **Contribute**: Check [CONTRIBUTING.md](CONTRIBUTING.md)

---

*Having issues? Check the [troubleshooting guide](TROUBLESHOOTING.md) or open an issue.*
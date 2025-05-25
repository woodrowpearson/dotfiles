# 🏠 dotfiles

<div align="center">

```ascii
     ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
     ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
     ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
     ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
     ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
     ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

**From fresh macOS to productive development environment in < 30 minutes** ⚡

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](docs/CONTRIBUTING.md)

*Started as a [sloria](https://github.com/sloria/dotfiles) fork, grew into something more powerful. Because manual setup is so 2023.* 😏

</div>

## 🚀 TL;DR - Get Started Now

**One command. Seriously.**

```bash
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
```

*Then grab a coffee ☕ while your Mac transforms into a developer powerhouse.*

---

## ✨ What Makes This Special

| 🎯 **Feature** | 🔥 **Why You'll Love It** |
|----------------|---------------------------|
| **Zero-to-Hero Setup** | Fresh macOS → Fully configured dev environment in one command |
| **Smart Project Scaffolding** | `newproject python my-api` → Complete project with CI/CD ready |
| **Interactive Configuration** | Guided setup for API keys, SSH, GPG (no more googling!) |
| **Modern Everything** | Alacritty + ZSH + 15+ CLI tool upgrades with smart aliases |
| **Professional CI/CD** | GitHub Actions templates that actually work |
| **Secrets That Make Sense** | Global + per-project environment management done right |

## 🗂️ Repository Explorer

Click around and explore! Each 📁 links to detailed documentation.

```
dotfiles/
├── 📁 [bin/](bin/README.md)                    # 🛠️  Automation scripts that do the magic
│   ├── dot-install                           # 🚀 One-command fresh macOS setup  
│   ├── dot-bootstrap                         # ⚙️  Complete environment installation
│   ├── dot-configure                         # 🔧 Interactive post-setup wizard
│   ├── newproject                            # 📦 Smart project scaffolding
│   └── upgrades                              # 🔄 Keep everything fresh
├── 📁 [roles/](roles/README.md)                # 🎭 Ansible roles (the real workhorses)
│   ├── 🏠 alacritty/                         # Terminal that doesn't suck
│   ├── 🐍 python/                            # Python done right (uv + tools)
│   ├── 🦀 rust/                              # Systems programming goodness
│   ├── 🚀 vscode/                            # Editor config + extensions
│   ├── 🐚 zsh/                               # Shell that makes you productive
│   └── 🎨 macos/                             # System settings automation
├── 📁 [templates/](templates/README.md)        # 🏗️  CI/CD templates for new projects
│   ├── .github/workflows/                   # GitHub Actions that work
│   └── .pre-commit-config.yaml              # Code quality automation
├── 📁 [docs/](docs/)                          # 📚 Deep-dive documentation
│   ├── 📖 [INSTALLATION.md](docs/INSTALLATION.md)  # Detailed setup guide
│   ├── ⭐ [FEATURES.md](docs/FEATURES.md)           # Comprehensive feature list
│   ├── 🎨 [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) # Make it truly yours
│   └── 🔧 [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) # When things go sideways
├── ⚙️  [group_vars/local](group_vars/)         # Configuration that matters
├── 🎬 [CLAUDE.md](CLAUDE.md)                  # Claude Code integration guide
└── 📜 [CHANGELOG.md](CHANGELOG.md)            # What's new and noteworthy
```

## 🎮 Quick Demos

### **Fresh Mac Setup**
```bash
# Literally one command from App Store Mac to development powerhouse
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
cd ~/dotfiles && ./bin/dot-bootstrap && ./bin/dot-configure
```

### **Create a Project**
```bash
# Smart scaffolding with CI/CD, pre-commit hooks, and best practices
newproject python my-awesome-api
cd ~/code/my-awesome-api
code .  # Opens with all the right extensions
```

### **Modern CLI Tools**
```bash
# Your new superpowers (all included)
ls        # → eza (with icons!)
cat file  # → bat (syntax highlighting)
grep "x"  # → rg (ripgrep - stupid fast)
find      # → fd (sensible defaults)
```

## 🏗️ Architecture

**Built on battle-tested foundations:**
- **Ansible**: Declarative, idempotent, reliable automation
- **Homebrew**: Package management that doesn't fight you  
- **Modern CLI Tools**: Because life's too short for ancient Unix tools
- **Opinionated Defaults**: Sensible choices you can override

**Philosophy: Automate Everything Possible, Guide Through What Can't Be**

## 🤝 Community & Credits

### **Standing on the Shoulders of Giants**
Huge props to [Steven Loria](https://github.com/sloria) for the original dotfiles that inspired this. What started as a simple fork has evolved into something much more comprehensive, but the core philosophy remains: *make developer setup painless*.

### **Contributing**
Found a bug? Have an idea? Want to add your favorite tool? 

**[👥 Contributing Guide →](docs/CONTRIBUTING.md)**

### **Support**
- 🐛 **Issues**: [GitHub Issues](https://github.com/woodrowpearson/dotfiles/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/woodrowpearson/dotfiles/discussions)
- ⭐ **Star this repo** if it saved you time!

## 📊 Stats & Recognition

<!-- GitHub stats will be inserted here -->
<div align="center">

![GitHub stars](https://img.shields.io/github/stars/woodrowpearson/dotfiles?style=social)
![GitHub forks](https://img.shields.io/github/forks/woodrowpearson/dotfiles?style=social)
![GitHub issues](https://img.shields.io/github/issues/woodrowpearson/dotfiles)
![GitHub last commit](https://img.shields.io/github/last-commit/woodrowpearson/dotfiles)

</div>

---

<div align="center">

**Made with ❤️ and way too much coffee** ☕

*Your terminal will thank you. Your productivity will soar. Your coworkers will be jealous.* 😎

**[🚀 Get Started Now](#-tldr---get-started-now) • [📚 Read the Docs](docs/) • [🤝 Contribute](docs/CONTRIBUTING.md)**

</div>
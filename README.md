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

**From fresh macOS to productive dev environment + ultimate home server in < 30 minutes** ⚡

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![HomeAssistant](https://img.shields.io/badge/Home%20Assistant-41BDF5?style=for-the-badge&logo=home-assistant&logoColor=white)](https://home-assistant.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com/)
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
| **🏠 Ultimate Home Server** | Complete HomeAssistant + Frigate + monitoring stack |
| **Smart Project Scaffolding** | `newproject python my-api` → Complete project with CI/CD ready |
| **🌐 Mesh VPN Access** | Tailscale integration for secure remote access |
| **📊 Comprehensive Monitoring** | Grafana + Prometheus + real-time analytics |
| **🔒 Network-wide Ad Blocking** | AdGuard Home protecting all your devices |
| **Interactive Configuration** | Guided setup for API keys, SSH, GPG (no more googling!) |
| **Modern Everything** | Alacritty + ZSH + 15+ CLI tool upgrades with smart aliases |

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
│   ├── 🏠 homeassistant/                     # Complete smart home ecosystem
│   ├── 📹 frigate/                           # AI-powered camera monitoring
│   ├── 📊 monitoring/                        # Grafana + Prometheus stack
│   ├── 🌐 tailscale/                         # Mesh VPN networking
│   ├── 🛡️  adguard/                          # Network-wide ad blocking
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

## 🏠 Ultimate Mac Mini Home Server

**Transform your Mac Mini into a comprehensive smart home hub with one command:**

```bash
# Deploy the entire home automation stack
ansible-playbook -i hosts remote_env.yml
```

### 🏡 **What You Get**

| 📱 **Service** | 🔗 **Access** | 🎯 **Purpose** |
|-------------|------------|----------------|
| **HomeAssistant** | `:8123` | Complete smart home automation |
| **Frigate NVR** | `:5000` | AI-powered camera monitoring |
| **Grafana** | `:3000` | Beautiful monitoring dashboards |
| **AdGuard Home** | `:3001` | Network-wide ad blocking |
| **Tailscale VPN** | *mesh* | Secure remote access |

### 🌐 **Smart Home Integrations**
- ✨ **Zigbee + Matter + WiFi** device support
- 📹 **AI CCTV** with object detection (Frigate)
- 🏠 **Google Home + AirPlay** integration
- 💡 **Hue lights + smart switches**
- 📶 **LoRaWAN** for long-range IoT
- 🌍 **Remote access** via Tailscale mesh VPN

### 📈 **Monitoring & Analytics**
- Real-time system metrics and alerts
- Container health and resource usage
- Network traffic analysis
- Smart home device status tracking
- Performance dashboards and trends

---

## 🎮 Quick Demos

### **Fresh Mac Setup**
```bash
# Literally one command from App Store Mac to development powerhouse
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
cd ~/dotfiles && ./bin/dot-bootstrap && ./bin/dot-configure
```

### **Deploy Home Server**
```bash
# Complete smart home automation stack
ansible-playbook -i hosts remote_env.yml
# OR deploy specific layers:
ansible-playbook -i hosts remote_env.yml --tags homeautomation
ansible-playbook -i hosts remote_env.yml --tags monitoring
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
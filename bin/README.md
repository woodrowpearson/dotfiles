# 🛠️ Scripts Documentation

**The magic happens here.** These scripts turn a fresh Mac into a development powerhouse.

## 🚀 Setup & Installation Scripts

### `dot-install` - The Genesis Script
**What it does:** One-command setup from completely fresh macOS
```bash
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
```

**Behind the scenes:**
- ✅ Installs Xcode Command Line Tools (the foundation)
- ✅ Installs Homebrew (package manager extraordinaire) 
- ✅ Sets up Git, Python, Ansible (the automation trio)
- ✅ Authenticates with GitHub CLI (seamless integration)
- ✅ Clones this repository to `~/dotfiles`

**Perfect for:** Brand new Macs, fresh installs, lending your setup to friends

---

### `dot-bootstrap` - The Heavy Lifter
**What it does:** Installs everything using Ansible automation
```bash
./bin/dot-bootstrap
```

**Behind the scenes:**
- 🎭 Runs all Ansible roles in optimal order
- 📦 Installs 30+ CLI tools and applications
- ⚙️ Configures system settings (Dock, Finder, etc.)
- 🎨 Sets up terminal, shell, and development environment
- 🔧 Creates project directories and templates

**Perfect for:** After dot-install, major system updates, adding new roles

---

### `dot-configure` - The Personal Touch
**What it does:** Interactive setup for things that can't be automated
```bash
./bin/dot-configure
```

**Guides you through:**
- 🔐 SSH key generation and GitHub setup
- 🗝️ API key configuration (Anthropic, OpenAI, GitHub, etc.)
- ✍️ GPG commit signing setup
- 🧩 VS Code extensions installation
- 👤 Personal git configuration

**Perfect for:** After dot-bootstrap, setting up new API keys, onboarding team members

---

## 🔄 Maintenance Scripts

### `dot-update` - Stay Fresh
**What it does:** Updates your environment (skips bootstrap-only tasks)
```bash
dot-update           # Update everything
dot-update git zsh   # Update specific roles
```

**Perfect for:** Regular maintenance, pulling in new features, keeping tools current

---

### `upgrades` - Everything Current
**What it does:** Updates all the things (Homebrew, npm, pip, vim plugins)
```bash
upgrades
```

**Perfect for:** Monthly maintenance, before big projects, when feeling organized

---

## 🏗️ Development Scripts

### `newproject` - Smart Scaffolding
**What it does:** Creates complete projects with CI/CD, pre-commit hooks, best practices
```bash
newproject python my-api      # Python project with pytest, ruff, black
newproject node my-app        # Node.js with eslint, prettier
newproject rust my-tool       # Rust with cargo, clippy
newproject go my-service      # Go with modules, gofmt
newproject web my-site        # Static HTML/CSS/JS
```

**Creates for you:**
- 📁 Proper project structure
- 📋 Language-specific tooling configured
- 🔄 GitHub Actions CI/CD workflow
- 🪝 Pre-commit hooks for code quality
- 📝 README with project info
- 🔐 .env template with API key stubs
- 📦 Initial git commit

**Perfect for:** Starting new projects, rapid prototyping, ensuring consistency

---

## 🔧 Utility Scripts

### `git-find-commit` - Time Travel
**What it does:** Fuzzy search through git commits (requires fzf)
```bash
git-find-commit
```

**Perfect for:** Finding that commit from 3 months ago, code archaeology

---

### `dot-bootstrap-remote` - Server Setup
**What it does:** Sets up remote servers with appropriate roles
```bash
./bin/dot-bootstrap-remote
```

**Perfect for:** Cloud servers, Raspberry Pis, development VMs

---

## 🎯 Usage Patterns

### **Fresh Mac Setup (Recommended Flow)**
```bash
# 1. Genesis - get the basics
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash

# 2. Heavy lifting - install everything  
cd ~/dotfiles && ./bin/dot-bootstrap

# 3. Personal touch - configure secrets and preferences
./bin/dot-configure

# 4. Create your first project
newproject python my-awesome-project
```

### **Regular Maintenance**
```bash
# Weekly: Update environment
dot-update

# Monthly: Update all packages
upgrades

# As needed: New projects
newproject <language> <name>
```

### **Troubleshooting**
All scripts support `--help` for detailed usage information:
```bash
dot-install --help
dot-configure --help  
newproject --help
```

---

**💡 Pro Tip:** These scripts are designed to be idempotent - run them multiple times safely. They'll detect what's already installed and skip unnecessary work.

**🔍 Want to see what a script does before running it?** Most scripts support dry-run modes or you can read the source - they're designed to be clear and well-commented.

**[← Back to Main README](../README.md) • [📚 More Docs](../docs/) • [🎭 Ansible Roles →](../roles/README.md)**
# dotfiles

woodrow pearson's dotfiles, forked from [sloria's dotfiles](https://github.com/sloria/dotfiles-old) and rewritten as Ansible roles. Sets up a complete development environment with **automated setup and configuration.**

**As of 2025, this repo only supports macOS.** There's still remnants of Red Hat and Debian support, but they are not maintained.

## features

**🚀 Zero-to-Productive Development Environment:**
- **One-command setup**: Fresh macOS to fully configured in <30 minutes
- **Smart project scaffolding**: `newproject python my-api` → Complete project with CI/CD
- **Interactive configuration**: Guided setup of API keys, SSH, GPG
- **Modern toolchain**: Alacritty + ZSH + Prezto + Pure theme with pastel colors

**🛠️ Development Tools:**
- **Languages**: Python (uv), Node.js 20, Rust, Go via mise
- **Editors**: VS Code with Claude Code extension, comprehensive language support
- **CLI Tools**: 15+ modern replacements (eza, bat, ripgrep, fzf, etc.)
- **Git**: Extensive aliases and GitHub CLI integration

**⚡ Automation & Quality:**
- **CI/CD Templates**: GitHub Actions for Python, Node.js, Rust
- **Pre-commit hooks**: Automated code quality and formatting
- **Secrets management**: Global + per-project environment variables
- **macOS integration**: System settings, Dock, Finder, screenshots

## quick start

**🎯 One-Command Setup (Fresh macOS):**
```bash
curl -fsSL https://github.com/woodrowpearson/dotfiles/raw/main/bin/dot-install | bash
```
This installs prerequisites (Xcode tools, Homebrew, Ansible, Git, GitHub CLI) and clones the repository.

**🔧 Complete Installation:**
```bash
cd ~/dotfiles
./bin/dot-bootstrap    # Install everything
./bin/dot-configure    # Interactive setup (API keys, SSH, etc.)
```

**⚡ Create Your First Project:**
```bash
newproject python my-api  # Scaffolds complete project with CI/CD
cd ~/code/my-api
code .  # Opens in VS Code with all extensions
```

## manual installation

If you prefer manual setup:

1. **Prerequisites**: Homebrew, Git, Ansible
2. **Clone**: `git clone https://github.com/woodrowpearson/dotfiles.git ~/dotfiles`
3. **Configure**: Update personal info in `group_vars/local`
4. **Install**: `./bin/dot-bootstrap`
5. **Configure**: `./bin/dot-configure`

## authenticating with github

You won't be able to push to repos until you authenticate with GitHub.
You can use `gh` for this, which should have been installed by `dot-bootstrap` above.

```
gh auth login
```

## updating your local environment

Once you have the dotfiles installed you can run the following command to rerun the ansible playbook:

```bash
dot-update
```

You can optionally pass role names

```bash
dot-update git python
```

## updating your dotfiles repo

To keep your fork up to date with the original:

```bash
git remote add upstream https://github.com/woodrowpearson/dotfiles.git
git pull upstream main
```

## commands

**Setup & Configuration:**
- `dot-install`: One-command fresh macOS setup (prerequisites + clone)
- `dot-bootstrap`: Complete environment setup (all roles)
- `dot-configure`: Interactive configuration (API keys, SSH, GPG, VS Code)
- `dot-update`: Update environment (skip bootstrap roles)
- `dot-update <role>`: Update specific roles

**Development:**
- `newproject <language> <name>`: Create project with templates (python, node, rust, go, web)
- `code ~/code/.env`: Edit global environment variables

**System Management (Mac-CLI aliases):**
- `sysinfo`: System performance details
- `speedtest`: Internet speed test
- `gitlog`: Recent git commits
- `updateall`: Update macOS, Homebrew, npm, gems

## special files

All configuration is done in `~/dotfiles`. Each role may contain (in addition to the typical ansible directories and files) a number of special files

- **role/\*.zsh**: Any files ending in `.zsh` get loaded into your environment.
- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.

## notes

**vscode**

Use built-in Settings Sync to sync VSCode settings.

**macOS keyboard settings**

There are a few keyboard customizations that must be done manually:

- System Settings > Keyboard > Turn "Key repeat rate" and "Delay until repeat" to their highest settings.

![Keyboard settings](https://github.com/user-attachments/assets/0c0e9ed6-3e5b-4996-b1e0-4aa4e9de3725 "Key repeat settings")

- System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys > Change Caps Lock key to Control.

![Modifier keys](https://github.com/user-attachments/assets/79a883cd-9eec-472e-bdb6-0b4c2efeea9d)

**mac mini**

I also use this repo to configure my Mac Mini server which I have running in headless mode. My setup is documented in [docs/MAC_MINI.md](docs/MAC_MINI.md).

## what if I only want your vim?

First make sure you have a sane vim compiled. On macOS, the following will do:

```
brew install vim
```

The following commands will install vim-plug and download my `.vimrc`.

After backing up your `~/.vim` directory and `~/.vimrc`:

```
mkdir -p ~/.vim/autoload
curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo ~/.vimrc https://raw.githubusercontent.com/sloria/dotfiles/master/roles/vim/files/vimrc
```

You will now be able to open vim and run `:PlugInstall` to install all plugins.

## troubleshooting

If you get an error about Xcode command-line tools, you may need to run

```
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

[homebrew]: http://brew.sh/
[homebrew-cask]: https://github.com/caskroom/homebrew-cask
[mas]: https://github.com/mas-cli/mas

## license

[MIT Licensed](http://sloria.mit-license.org/).

#!/bin/bash

brews=(
      "ag"
      "airshare"
      "amass"
      "apparency"
      "awk"
      "awscli"
      "bandwhich"
      "bash-completion@2"
      "bash-git-prompt"
      "bat"
      "blueutil"
      "bottom"
      "broot"
      "brotli"
      "carthage"
      "ca-certificates"
      "cairo"
      "cgit"
      "choose"
      "click"
      "coreutils"
      "create-dmg"
      "ctags"
      "dex2jar"
      "d2"
      "direnv"
      "docker" # Software providing OS-level virtualization
      "docker-compose"
      "docutils"
      "dog"
      "dns2tcp"
      "dnslookup"
      "dua-cli"
      "duf"
      "dust"
      "exa"
      "faiss"
      "fbthrift"
      "fd"
      "ffmpeg" # Multimedia framework to decode encode transcode etc.
      "findutils"
      "flarectl"
      "fff"
      "git" # Distributed version control system
      "git-delta"
      "git-extras"
      "git-lfs"
      "git-tools"
      "gh"
      "glances"
      "go"
      "gping"
      "grip"
      "gum"
      "gawk"
      "gnu"
      "gnu-getopt"
      "gnu-indent"
      "gnu-sed"
      "gnu-tar"
      "hashpump"
      "has"
      "helm" # Kubernetes package manager
      "heroku-node"
      "highlight"
      "htmlq"
      "hopenpgp-tools"
      "htop"
      "hydra"
      "hyperfine"
      "iredis"
      "jc"
      "jq"
      "jsonlint"
      "just"
      "keychain"
      "knock"
      "kubernetes-cli" # Command line interface for running commands against Kubernetes clusters
      "lame"
      "lf"
      "libassuan"
      "libpq"
      "llm"
      "locateme"
      "lsd"
      "lua"
      "macvim" # Text editor for macOS
      "mackup"
      "mas"
      "mc"
      "mcfly"
      "mc"
      "mpg123"
      "nmap" # Utility for network discovery and security auditing
      "nnn"
      "node"
      "noti"
      "npm yarn"
      "onnxruntime"
      "openjdk" # Free and open-source implementation of the Java Platform
      "openssl"
      "openssl-osx-ca"
      "pandoc"
      "pc2"
      "perl"
      "pgcli"
      "pinentry"
      "pipx"
      "pcre2"
      "procs"
      "postgresql@15" # Object-relational database system
      "pulumi"
      "pyenv" # Python version management
      "pyenv-virtualenv"
      "python@3.11"
      "qlcolorcode"
      "qlimagesize"
      "qlmarkdown"
      "quicklook-json"
      "quicklookase"
      "qlstephen"
      "qlvideo"
      "readline"
      "redis" # In-memory data structure store
      "remake"
      "rich-cli"
      "ripgrep"
      "rm-improved"
      "ruby" # Dynamic open-source programming language
      "rust" # Systems programming language
      "screenresolution"
      "sd"
      "skhd"
      "sqlite" # C library that provides a lightweight disk-based database
      "subversion" # Version control system
      "suspicious-package"
      "task"
      "tcptrace"
      "telnet"
      "terraform" # Infrastructure as Code (IaC) tool
      "testssl"
      "tfvar"
      "thefuck"
      "tig"
      "tldr"
      "tidy-html5"
      "trailscraper"
      "terrafrom"
      "up"
      "unixodbc"
      "vale"
      "virtualenv" # Tool to create isolated Python environments
      "vs-code"
      "w3m"
      "watch"
      "watchman"
      "wget"
      "whatmask"
      "whalebrew"
      "wifi-password"
      "wireshark" # Network protocol analyzer
      "xh"
      "xray"
      "yank"
      "ykman"
      "ykpers"
      "youtube-dl" # Command-line program to download videos from YouTube
      "yq"
      "ytop"
      "zmap"
      "zoxide"
      "zx"
)

echo "brews = ["
for brew in "${brews[@]}"
do
  info=$(brew info $brew)

  # Format 1: description is in the second line
  description=$(echo "$info" | sed -n 2p | xargs)

  # Format 2: description follows "==> Description"
  if echo "$info" | grep -q "==> Description"; then
    description=$(echo "$info" | awk '/==> Description/ { getline; print }' | xargs)
  fi

  echo "  \"$brew\" # $description"
done
echo "];"

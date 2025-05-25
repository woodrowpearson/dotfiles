# 💾 Backup & Recovery Role

Comprehensive backup strategy for safe development environment management with multi-layered protection.

## 🎯 Strategy Overview

### Three-Phase Protection
1. **Pre-Setup**: Full system snapshot + selective exports
2. **During Setup**: Checkpoint system with rollback capabilities  
3. **Post-Setup**: Ongoing automated configuration preservation

### Backup Layers
- **Foundation**: Time Machine for full system backup
- **Configuration**: Selective application settings export
- **Development**: Git-based dotfiles and project versioning
- **Security**: SSH keys, certificates, and sensitive data
- **Checkpoints**: Bootstrap process safety points

## 🛡️ Backup Components

### Full System Backup
- **Time Machine**: Native macOS full system backup
- **Schedule**: Automatic hourly when drive connected
- **Purpose**: Complete system recovery and rollback safety net

### Application Configuration Backup
- **Settings Export**: Application preferences and configurations
- **Dotfiles Sync**: Version-controlled configuration files
- **Extension Lists**: VS Code, browser extensions, etc.
- **Custom Configs**: Terminal themes, vim settings, etc.

### Development Environment Backup
- **Project State**: Active development projects
- **Environment Variables**: API keys and tokens (encrypted)
- **SSH/GPG Keys**: Authentication credentials
- **Development Tools**: Language versions, package lists

### Checkpoint System
- **Pre-Role Snapshots**: Before each Ansible role execution
- **Rollback Capability**: Selective undo of specific changes
- **Progress Tracking**: What's been installed and configured
- **Failure Recovery**: Automatic cleanup on script failures

## 🚀 Quick Start

### Pre-Bootstrap Backup
```bash
# Create comprehensive pre-setup backup
./bin/backup-create --phase pre-setup --full

# Quick config-only backup
./bin/backup-create --config-only
```

### During Bootstrap (Automatic)
```bash
# Bootstrap with checkpoints (automatic)
./bin/dot-bootstrap --with-checkpoints

# Manual checkpoint creation
./bin/backup-checkpoint "after-homebrew-install"
```

### Recovery Operations
```bash
# List available backups
./bin/backup-list

# Restore specific application configs
./bin/backup-restore --app vscode --from 2024-01-15

# Rollback last role
./bin/backup-rollback --last-role

# Emergency full restore
./bin/backup-restore --full --from pre-setup
```

## 📋 What Gets Backed Up

### Application Settings
- **VS Code**: Settings, extensions, snippets, themes
- **Terminal**: Alacritty config, shell aliases, themes
- **Git**: Configuration, aliases, signing keys
- **SSH**: Keys, known hosts, config files
- **Browser**: Bookmarks, extensions (export lists)
- **Development Tools**: Homebrew packages, language versions

### System Preferences
- **macOS Settings**: Dock, Finder, keyboard, trackpad
- **Firewall Rules**: Custom network configurations
- **Login Items**: Startup applications and services
- **Fonts**: Custom installed fonts

### Development Environment
- **Projects**: Active development projects (optional)
- **Environments**: Virtual environments, containers
- **Databases**: Development database snapshots
- **API Keys**: Encrypted storage of sensitive credentials

## 🔄 Recovery Scenarios

### Scenario 1: Bootstrap Script Failure
**Problem**: Ansible role fails mid-execution
**Solution**: 
```bash
./bin/backup-rollback --role package_manager
./bin/dot-bootstrap --resume-from git
```

### Scenario 2: Bad Configuration Change
**Problem**: Application misconfigured, need previous settings
**Solution**:
```bash
./bin/backup-restore --app vscode --from yesterday
```

### Scenario 3: Complete System Failure
**Problem**: Need to restore entire development environment
**Solution**:
```bash
# 1. Fresh macOS install
# 2. Restore from Time Machine (or clean install)
# 3. Clone dotfiles
# 4. Restore configurations
./bin/backup-restore --config-full --from pre-setup
./bin/dot-bootstrap --skip-existing
```

## ⚙️ Configuration

### Backup Locations
```yaml
backup_config:
  local_drive: "/Volumes/Backup"  # USB drive path
  time_machine: true              # Use TM for full backups
  cloud_sync: false              # Optional cloud backup
  retention_days: 30              # How long to keep backups
  
backup_paths:
  applications: "~/Library/Application Support"
  preferences: "~/Library/Preferences"
  ssh_keys: "~/.ssh"
  development: "~/Code"           # Optional project backup
```

### Security
- **Encryption**: All sensitive data encrypted at rest
- **Key Management**: Secure storage of backup encryption keys
- **Access Control**: Limited permissions on backup files
- **Audit Trail**: Log of all backup and restore operations

## 🔧 Advanced Features

### Smart Backup
- **Change Detection**: Only backup modified configurations
- **Differential Backups**: Space-efficient incremental updates
- **Compression**: Reduce backup size and transfer time
- **Deduplication**: Avoid storing identical files multiple times

### Integration
- **Git Hooks**: Automatic backup before major changes
- **Cron Jobs**: Scheduled configuration backups
- **Monitoring**: Health checks and backup verification
- **Notifications**: Alerts for backup success/failure

## 📚 Best Practices

### Regular Maintenance
1. **Weekly**: Verify backup integrity
2. **Monthly**: Clean old backups, check space
3. **Quarterly**: Test full restore procedure
4. **Before Major Changes**: Create checkpoint backup

### Workflow Integration
- **Pre-commit**: Backup configs before major changes
- **Project Setup**: Include backup in project initialization
- **Environment Changes**: Checkpoint before system updates
- **Sharing Setups**: Export configs for team sharing
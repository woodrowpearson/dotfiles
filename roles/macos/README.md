# 🎨 macOS System Configuration Role

Automated macOS system preferences and dock configuration for optimal development environment setup.

## 🎯 What This Role Does

### System Preferences
- **Finder Enhancement**: Show hidden files, path bar, and Library folder
- **Screenshot Configuration**: PNG format, saved to iCloud Drive screenshots folder
- **Text Input**: Disable smart quotes and dashes (better for coding)
- **Trackpad Settings**: Disable tap-to-click for precise control
- **AirDrop**: Enable over all interfaces
- **VS Code Integration**: Enable key repeat for Vim mode

### Dock Configuration
- **Custom Application Layout**: Configurable list of dock applications
- **Optimized Settings**: Left positioning, 48px size, no autohide
- **Clean Experience**: Remove recent apps, disable space rearrangement
- **Smart Detection**: Graceful handling of missing applications

## 🚀 Usage

### Apply All macOS Settings
```bash
# Run the complete macOS role
ansible-playbook -i hosts local_env.yml --tags macos

# Apply only dock configuration
ansible-playbook -i hosts local_env.yml --tags macos -e dock_only=true
```

### Preview Changes
```bash
# Dry run to see what would change
ansible-playbook -i hosts local_env.yml --tags macos --check --diff
```

## ⚙️ Dock Configuration

### Default Applications
The dock is configured with these applications by default:
1. **Google Chrome** - Primary web browser
2. **Alacritty** - Modern GPU-accelerated terminal
3. **Terminal** - Built-in macOS terminal
4. **Visual Studio Code** - Primary code editor
5. **Messages** - iMessage and SMS
6. **Find My** - Device location and tracking
7. **Notes** - Quick note-taking
8. **System Settings** - macOS system preferences
9. **iPhone Mirroring** - Screen mirroring (macOS 15.0+)
10. **TextEdit** - Simple text editor

### Customizing Dock Applications

#### Method 1: Edit Role Defaults (Recommended)
Edit `roles/macos/defaults/main.yml`:

```yaml
dock_apps:
  - name: "Your App Name"
    path: "/Applications/Your App.app"
  - name: "App with Fallback"
    path: "/Applications/New App.app"
    fallback_path: "/Applications/Old App.app"  # Optional fallback
```

#### Method 2: Override in Group Variables
Edit `group_vars/local`:

```yaml
dock_apps:
  - name: "Firefox"
    path: "/Applications/Firefox.app"
  - name: "Slack"
    path: "/Applications/Slack.app"
  - name: "Spotify"
    path: "/Applications/Spotify.app"
```

#### Method 3: Per-Host Configuration
Create `host_vars/[hostname].yml`:

```yaml
dock_apps:
  - name: "Development Browser"
    path: "/Applications/Google Chrome Canary.app"
  - name: "Work Chat"
    path: "/Applications/Microsoft Teams.app"
```

### Application Path Examples
```yaml
dock_apps:
  # Standard Applications folder
  - name: "Chrome"
    path: "/Applications/Google Chrome.app"
  
  # Utilities subfolder
  - name: "Terminal"
    path: "/Applications/Utilities/Terminal.app"
  
  # System apps with version compatibility
  - name: "System Settings"
    path: "/Applications/System Settings.app"        # macOS 13+
    fallback_path: "/Applications/System Preferences.app"  # macOS 12-
  
  # Mac App Store apps
  - name: "Xcode"
    path: "/Applications/Xcode.app"
  
  # Homebrew Cask apps
  - name: "iTerm2"
    path: "/Applications/iTerm.app"
```

### Dock Behavior Settings
Customize dock behavior by editing `roles/macos/templates/configure-dock.sh.j2`:

```bash
# Dock size (16-128 pixels)
defaults write com.apple.dock tilesize -int 48

# Position: "left", "bottom", "right"
defaults write com.apple.dock orientation -string "left"

# Auto-hide dock
defaults write com.apple.dock autohide -bool false

# Show recent applications
defaults write com.apple.dock show-recents -bool false

# Minimize effect: "genie", "scale", "suck"
defaults write com.apple.dock mineffect -string "scale"
```

## 🔧 Advanced Configuration

### Conditional Applications
Include applications only when they exist:

```yaml
dock_apps:
  - name: "Xcode"
    path: "/Applications/Xcode.app"
    when: "{{ ansible_facts['os_family'] == 'Darwin' and xcode_installed | default(false) }}"
```

### Multiple Profiles
Create different dock configurations for different use cases:

```yaml
# Development profile
dock_apps_dev:
  - name: "VS Code"
    path: "/Applications/Visual Studio Code.app"
  - name: "Terminal"
    path: "/Applications/Utilities/Terminal.app"
  - name: "Chrome"
    path: "/Applications/Google Chrome.app"

# Design profile  
dock_apps_design:
  - name: "Figma"
    path: "/Applications/Figma.app"
  - name: "Adobe Photoshop"
    path: "/Applications/Adobe Photoshop 2024/Adobe Photoshop 2024.app"

# Use the appropriate profile
dock_apps: "{{ dock_apps_dev if profile == 'dev' else dock_apps_design }}"
```

### Environment-Specific Configuration
```yaml
# group_vars/local
dock_apps: "{{ dock_apps_work if work_environment | default(false) else dock_apps_personal }}"

dock_apps_work:
  - name: "Slack"
    path: "/Applications/Slack.app"
  - name: "Microsoft Teams"
    path: "/Applications/Microsoft Teams.app"

dock_apps_personal:
  - name: "Spotify"
    path: "/Applications/Spotify.app"
  - name: "Discord"
    path: "/Applications/Discord.app"
```

## 🏗️ File Structure

```
roles/macos/
├── README.md                    # This documentation
├── defaults/main.yml            # Default dock configuration
├── files/set-defaults.sh        # System preferences script
├── tasks/main.yml              # Main task orchestration
└── templates/
    └── configure-dock.sh.j2    # Dock configuration template
```

## 🔍 Troubleshooting

### Applications Not Appearing
1. **Check Application Path**: Verify the exact path in `/Applications`
2. **Case Sensitivity**: Ensure exact case matching for app names
3. **Application Bundle**: Make sure to include `.app` extension
4. **Permissions**: Ensure the application is not quarantined

```bash
# Find correct application path
ls -la "/Applications" | grep -i "app-name"

# Remove quarantine attribute if needed
xattr -r -d com.apple.quarantine "/Applications/YourApp.app"
```

### Dock Configuration Not Applied
1. **Kill Dock Process**: `killall Dock`
2. **Check Logs**: Look for errors in the Ansible output
3. **Manual Test**: Run the generated script directly

```bash
# Manually apply dock configuration
/tmp/configure-dock.sh

# Reset dock to defaults
defaults delete com.apple.dock; killall Dock
```

### System Settings vs System Preferences
The role automatically handles macOS version differences:
- **macOS 13+ (Ventura)**: Uses "System Settings"
- **macOS 12- (Monterey)**: Falls back to "System Preferences"

## 🎨 Examples

### Minimal Dock
```yaml
dock_apps:
  - name: "Chrome"
    path: "/Applications/Google Chrome.app"
  - name: "Terminal"
    path: "/Applications/Utilities/Terminal.app"
  - name: "VS Code"
    path: "/Applications/Visual Studio Code.app"
```

### Developer-Focused Dock
```yaml
dock_apps:
  - name: "Chrome"
    path: "/Applications/Google Chrome.app"
  - name: "Firefox Developer Edition"
    path: "/Applications/Firefox Developer Edition.app"
  - name: "Alacritty"
    path: "/Applications/Alacritty.app"
  - name: "VS Code"
    path: "/Applications/Visual Studio Code.app"
  - name: "Xcode"
    path: "/Applications/Xcode.app"
  - name: "Simulator"
    path: "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
  - name: "Docker Desktop"
    path: "/Applications/Docker.app"
  - name: "Postman"
    path: "/Applications/Postman.app"
```

### Creative Professional Dock
```yaml
dock_apps:
  - name: "Adobe Photoshop"
    path: "/Applications/Adobe Photoshop 2024/Adobe Photoshop 2024.app"
  - name: "Adobe Illustrator"
    path: "/Applications/Adobe Illustrator 2024/Adobe Illustrator 2024.app"
  - name: "Figma"
    path: "/Applications/Figma.app"
  - name: "Sketch"
    path: "/Applications/Sketch.app"
  - name: "Final Cut Pro"
    path: "/Applications/Final Cut Pro.app"
  - name: "Logic Pro"
    path: "/Applications/Logic Pro.app"
```

## 📋 Variables Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `dock_apps` | List | See defaults | List of applications to include in dock |
| `icloud_enabled` | Boolean | `true` | Enable iCloud Drive symlink |
| `mac_mas_packages` | List | `[]` | Mac App Store packages to install |

### Dock App Object Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | String | Yes | Display name for the application |
| `path` | String | Yes | Full path to the application bundle |
| `fallback_path` | String | No | Alternative path if primary path doesn't exist |
| `when` | String | No | Ansible condition for conditional inclusion |

## 🔗 Related Roles

- **[alacritty](../alacritty/)** - Terminal configuration that pairs with dock setup
- **[vscode](../vscode/)** - VS Code settings and extensions
- **[package_manager](../package_manager/)** - Homebrew apps that appear in dock

## 🤝 Contributing

To add new dock configurations or improve the role:

1. Test your changes with `--check --diff` first
2. Ensure compatibility across macOS versions
3. Update this README with new examples
4. Consider adding to the default configuration if broadly useful
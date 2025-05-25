# Terminal Configuration Documentation

## Overview

The dotfiles repository now includes a comprehensive terminal enhancement with Alacritty terminal emulator and Starship prompt, providing a modern, visually appealing, and highly functional development environment.

## Components

### Alacritty Terminal Emulator

**Configuration**: `roles/alacritty/files/alacritty.toml`

**Features**:
- GPU-accelerated terminal emulator
- Custom pastel color palette with contrasting black background
- Hack Nerd Font integration for icon support
- Optimized window settings with 95% opacity
- High-performance scrolling with 10,000 line history

**Color Palette**:
- Background: `#1a1a1a` (contrasting black)
- Foreground: `#e0e0e0` (light text)
- Red: `#ff6b6b` 
- Green: `#b3ffe1` (gradient light)
- Blue: `#4381df` (bright blue)
- Yellow: `#ffedb9` (cream yellow)
- Magenta: `#ffc4b4` (salmon pink)
- Cyan: `#87ceeb`

### Starship Prompt

**Configuration**: `roles/starship/files/starship.toml`

**Features**:
- Cross-shell compatibility
- Git integration with branch and status indicators
- Programming language detection with version display
- Custom icons using Nerd Font symbols
- Dynamic coloring matching Alacritty theme
- Execution time display for commands over 2 seconds

**Visual Elements**:

#### Git Status Indicators
- `📝` - Uncommitted changes detected
- `🗃️` - Staged changes ready for commit
- `📦` - Git stash contains saved work
- `🔄` - Files have been modified
- `✨` - New files are staged
- `🗑️` - Files have been deleted

#### Programming Language Context
- `🐍` - Python projects with version display
- `🦀` - Rust projects with toolchain version
- `⚡` - Node.js projects with version
- `🐹` - Go projects with version
- `💎` - Ruby projects with version

#### Additional Features
- Current directory path with home directory shortening
- User and hostname display when relevant
- Command execution time for performance awareness
- Clean visual separators and structured layout

## Font Configuration

### Hack Nerd Font Integration

The configuration has been updated across all relevant files to use "Hack Nerd Font" instead of plain "Hack":

**Updated Files**:
- `roles/alacritty/files/alacritty.toml` - Terminal font configuration
- `ansible/vars/local_settings.yml` - Font preference variable
- `CLAUDE.md` - Documentation references
- `roles/README.md` - Role descriptions

**Installation**: Automatically handled by the `starship` role, which installs:
- Starship binary via Homebrew
- Hack Nerd Font for icon support
- Starship configuration file

## Role Integration

### Starship Role (`roles/starship/`)

**Files**:
- `tasks/main.yml` - Installation and configuration tasks
- `files/starship.toml` - Comprehensive prompt configuration

**Integration**: Added to `local_env.yml` after the `zsh` role for proper shell integration.

## Terminal Workflow Enhancement

### Development Workflow
1. **Project Status**: Instantly see git branch, changes, and stash status
2. **Environment Context**: Automatically detect programming language and version
3. **Performance Awareness**: Execution time display for optimization feedback
4. **Visual Clarity**: Clean icons and colors for quick information parsing

### Git Integration
- Branch name with clean formatting
- Status indicators for staged/unstaged changes
- Stash detection for work-in-progress awareness
- Modified file indicators with appropriate icons

## Example Terminal Output

The enhanced terminal provides immediate visual feedback:

```
┌─ w@MacBook-Pro ~/dotfiles main 📝🗃️ 🐍3.12.0 ⚡20.12.0
└─ $ git status --short
 M CLAUDE.md
 M ansible/vars/local_settings.yml
 M local_env.yml
?? roles/starship/

┌─ w@MacBook-Pro ~/dotfiles main 📝🗃️ 🐍3.12.0 ⚡20.12.0 2.3s
└─ $ 
```

## Configuration Management

### Automated Deployment
- All font and terminal configurations are managed through Ansible roles
- Consistent deployment across fresh installations and updates
- Configuration files are version-controlled and reproducible

### Customization
- Color palette defined in Alacritty configuration
- Starship modules can be individually enabled/disabled
- Font preferences centrally managed in `local_settings.yml`

## Benefits

1. **Enhanced Productivity**: Immediate visual feedback on project state
2. **Beautiful Interface**: Modern design with consistent color theming
3. **Information Dense**: Multiple context indicators without clutter
4. **Performance Optimized**: GPU acceleration and efficient rendering
5. **Cross-Platform**: Starship works across multiple shells and systems

This configuration transforms the terminal from a basic command interface into a powerful, visually appealing development workspace that provides immediate context and status information for enhanced productivity.
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based dotfiles repository that sets up a complete macOS development environment. The repository is structured around Ansible roles, each responsible for configuring specific tools and applications.

## Key Commands

- `./bin/dot-bootstrap` - Initial setup of local environment (runs all roles in `local_env.yml`)
- `dot-update` - Update local environment (skips bootstrap-tagged roles)
- `dot-update <role>` - Update specific role(s), e.g., `dot-update git python`
- `ansible-playbook -i hosts local_env.yml --tags <tag>` - Run specific tagged roles
- `ansible-playbook -i hosts remote_env.yml` - Set up remote environment

## Architecture

### Core Structure
- `local_env.yml` and `remote_env.yml` - Main playbooks defining role execution order
- `roles/` - Individual Ansible roles for each tool/application
- `group_vars/local` and `group_vars/remote` - Configuration variables
- `hosts` - Ansible inventory file

### Role System
Each role in `roles/` may contain:
- `*.zsh` files - Automatically loaded into zsh environment
- `bin/` directories - Contents added to `$PATH`
- Standard Ansible directories (tasks, files, templates, defaults, etc.)

### Key Roles
- `package_manager` - Homebrew setup and package installation
- `zsh` - Shell configuration with Prezto
- `git` - Git configuration and aliases
- `python` - Python environment with uv
- `vim` - Vim configuration with vim-plug
- `macos` - macOS-specific settings and defaults

### Configuration Variables
Primary configuration in `group_vars/local`:
- `full_name`, `git_user`, `git_email` - Personal information
- `mac_homebrew_packages` - CLI tools to install
- `mac_cask_packages` - GUI applications to install
- `mac_mas_packages` - Mac App Store applications

## Development Notes

- All roles are tagged for selective execution
- Bootstrap-tagged roles only run during initial setup
- The repository supports both local and remote machine setup
- Remote setup includes additional roles like ollama, beszel-agent, and adguard
- macOS-specific functionality is conditionally executed based on `ansible_os_family`
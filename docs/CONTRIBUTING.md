# 🤝 Contributing Guide

Want to make this dotfiles setup even better? Awesome! Here's how you can contribute to the project.

## 🎯 Ways to Contribute

### 🐛 Bug Reports
Found something broken? Help us fix it!

### ✨ Feature Requests  
Got an idea for improvement? We'd love to hear it!

### 📝 Documentation
Help make the docs clearer and more helpful.

### 🔧 Code Contributions
Submit fixes, improvements, or new features.

### 💡 Share Your Setup
Show off your customizations to inspire others.

## 🚀 Getting Started

### Prerequisites
- macOS (primary target platform)
- Git and GitHub account
- Basic familiarity with shell scripting and Ansible

### Fork and Clone
```bash
# Fork the repository on GitHub, then:
git clone git@github.com:yourusername/dotfiles.git
cd dotfiles
git remote add upstream git@github.com:wpearson/dotfiles.git
```

### Development Setup
```bash
# Test your changes safely
ansible-playbook -i hosts local_env.yml --check --diff --tags your-role

# Use a test branch
git checkout -b feature/your-improvement
```

## 📋 Contribution Guidelines

### Code Style

**Shell Scripts**:
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Use clear variable names
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions should be documented
setup_environment() {
    # Brief description of what this does
    local config_file="$1"
    # Implementation
}
```

**Ansible Roles**:
```yaml
---
# Use descriptive task names
- name: Install development tools via Homebrew
  homebrew:
    name: "{{ item }}"
    state: present
  loop: "{{ dev_packages }}"
  tags: ['development', 'homebrew']

# Include appropriate tags and when conditions
- name: Configure Git signing key
  git_config:
    name: user.signingkey
    value: "{{ gpg_key_id }}"
  when: gpg_key_id is defined
```

**Documentation**:
- Use clear headings and sections
- Include code examples for complex procedures
- Test all documented commands
- Keep the tone friendly but professional

### Testing Your Changes

**Required Tests**:
```bash
# 1. Ansible syntax check
ansible-playbook -i hosts local_env.yml --syntax-check

# 2. Dry-run to check for issues
ansible-playbook -i hosts local_env.yml --check --diff

# 3. Test specific roles
ansible-playbook -i hosts local_env.yml --tags your-role --check

# 4. Full test run (on a test system/VM if possible)
./bin/dot-bootstrap
```

**Additional Validation**:
- Verify shell scripts with `shellcheck`
- Test documentation steps manually
- Ensure compatibility with latest macOS
- Check that customizations don't break core functionality

## 🔄 Development Workflow

### 1. Create a Branch
```bash
git checkout -b feature/descriptive-name
# or
git checkout -b fix/issue-description
```

### 2. Make Your Changes
- Keep changes focused and atomic
- Include appropriate documentation updates
- Add or update tests as needed

### 3. Test Thoroughly
```bash
# Test your specific changes
ansible-playbook -i hosts local_env.yml --tags your-role --check

# Test the full setup (preferably on a clean system)
./bin/dot-bootstrap
```

### 4. Commit Your Changes
```bash
# Use conventional commit format
git commit -m "feat: add support for new development tool"
git commit -m "fix: resolve homebrew permission issue"
git commit -m "docs: improve installation guide clarity"
```

### 5. Push and Create PR
```bash
git push origin feature/your-branch
# Create pull request on GitHub
```

## 📝 Pull Request Guidelines

### PR Title Format
Use conventional commits format:
- `feat:` New features
- `fix:` Bug fixes  
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Test improvements
- `chore:` Maintenance tasks

### PR Description Template
```markdown
## Description
Brief description of what this PR does and why.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (please describe)

## Testing
- [ ] Tested with `ansible-playbook --check`
- [ ] Manually tested on clean macOS system
- [ ] Updated documentation as needed
- [ ] Verified backwards compatibility

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

## 🎨 Types of Contributions

### New Tool/Role Addition
```yaml
# Example: Adding a new development tool
# 1. Create role structure
mkdir roles/your-tool/{tasks,defaults,files,templates}

# 2. Implement installation and configuration
# tasks/main.yml
- name: Install your-tool
  homebrew:
    name: your-tool
    state: present

# 3. Add to main playbook
# local_env.yml
- role: your-tool
  tags: ['your-tool', 'development']

# 4. Document in appropriate README
```

### Improving Existing Roles
- Add new configuration options
- Improve error handling
- Add conditional logic for different scenarios
- Enhance documentation

### Script Improvements
- Better error handling
- More user-friendly output
- Additional functionality
- Performance optimizations

### Documentation Enhancements
- Clearer explanations
- More examples
- Better organization
- Fix typos and errors

## 🧪 Advanced Testing

### Test on Different Systems
- Fresh macOS installation
- Existing development environment
- Different macOS versions (if possible)

### Performance Testing
```bash
# Time the full setup
time ./bin/dot-bootstrap

# Check for unnecessary operations
ansible-playbook -i hosts local_env.yml --check --diff | grep changed
```

### Security Review
- No hardcoded secrets in commits
- Proper file permissions
- Secure default configurations
- Validate external script sources

## 📚 Documentation Standards

### Code Comments
```bash
# Explain WHY, not just WHAT
# Good:
# Set stricter permissions to prevent accidental modification
chmod 600 "$config_file"

# Less helpful:
# Change file permissions
chmod 600 "$config_file"
```

### README Updates
When adding new features:
1. Update main README.md if it affects the overview
2. Update role-specific READMEs
3. Add to FEATURES.md if it's a user-facing feature
4. Update CUSTOMIZATION.md if it's configurable

### Variable Documentation
```yaml
# In defaults/main.yml, document complex variables
development_packages:
  # Core development tools for daily workflow
  - git
  - ansible
  
  # Modern CLI replacements for better UX
  - eza      # Enhanced 'ls' with icons and git status
  - bat      # 'cat' with syntax highlighting
```

## 🎉 Recognition

### Contributors
All contributors are recognized in:
- GitHub contributors list
- CHANGELOG.md for significant contributions
- Special thanks in release notes

### Types of Recognition
- **Code Contributors**: Direct code/configuration improvements
- **Documentation Contributors**: Help make the project accessible
- **Community Contributors**: Answer questions, provide support
- **Testers**: Help validate changes across different environments

## 🤔 Questions?

### Before Contributing
- Check existing issues and PRs
- Read through current documentation
- Test the current setup on your system

### During Development
- Open a draft PR early for feedback
- Ask questions in issues or discussions
- Test incrementally as you develop

### Communication
- Be respectful and constructive
- Provide detailed context for issues
- Help others when you can

## 🎯 Project Goals

Keep these in mind when contributing:

### Simplicity
- Easy to install and configure
- Minimal manual intervention required
- Clear and understandable automation

### Flexibility  
- Customizable for different workflows
- Modular design for selective adoption
- Support for various development environments

### Reliability
- Idempotent operations (safe to run multiple times)
- Graceful error handling
- Comprehensive testing

### Documentation
- Everything is documented
- Examples for common use cases
- Troubleshooting for common issues

---

*Thank you for contributing! Every improvement, no matter how small, makes this setup better for everyone.* 🙏
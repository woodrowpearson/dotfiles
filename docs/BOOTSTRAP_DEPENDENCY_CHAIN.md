# Bootstrap Dependency Chain Management

This document explains the critical dependency chain management system implemented in the dotfiles bootstrap process, including the problems it solves, scenarios where issues occur, and the technical solutions implemented.

## Overview

The bootstrap process involves installing and configuring multiple tools and languages that have complex interdependencies. Without proper ordering and dependency management, fresh installations can fail due to missing runtime dependencies.

## Critical Problem Scenarios

### 1. **Fresh macOS Installation Scenario**

**When it happens:**
- Brand new macOS system
- No development tools installed
- Running `./bin/dot-bootstrap` for the first time

**Original problem:**
```bash
TASK [dev-environment : Install Mac-CLI via npm] 
fatal: [localhost]: FAILED! => {"msg": "npm: command not found"}
```

**Root cause:** 
- `dev-environment` role executed before `mise` role
- npm command used before Node.js runtime installed
- Bootstrap failed completely

### 2. **Python Tools Installation Failure**

**When it happens:**
- Fresh system without Python development environment
- Python tools needed for development workflow

**Original problem:**
```bash
TASK [python : Install global Python tools]
fatal: [localhost]: FAILED! => {"msg": "uv: No Python installation found"}
```

**Root cause:**
- `uv tool install` commands ran without guaranteed Python runtime
- System Python may be insufficient or restricted (PEP 668)
- Tools failed to install, breaking development environment

### 3. **Tool Installation Duplication**

**When it happens:**
- Both Homebrew packages and dedicated roles install same tools
- Creates conflicts and confusion about tool sources

**Original problem:**
- CLI tools like `ripgrep`, `bat`, `eza` installed via both Homebrew AND dedicated roles
- Unclear which version/configuration takes precedence
- Potential path conflicts and inconsistent behavior

## Technical Solutions Implemented

### 1. **Role Execution Order Optimization**

**Change made:**
```yaml
# Before (BROKEN)
- { role: git, tags: ["git"] }
- { role: zsh, tags: ["zsh", "bootstrap"] }
- { role: dev-environment, tags: ["dev-environment"] }  # Uses npm
- { role: mise, tags: ["mise"] }                        # Installs Node.js

# After (FIXED)
- { role: git, tags: ["git"] }
- { role: zsh, tags: ["zsh", "bootstrap"] }
- { role: mise, tags: ["mise"] }                        # Installs Node.js FIRST
- { role: dev-environment, tags: ["dev-environment"] }  # Now npm available
```

**Logic:**
1. **Runtime Installation First**: `mise` role installs Node.js and Python before any role needs them
2. **Dependency Consumption Second**: Roles that use npm, pip, or other tools run after runtime installation
3. **Clear Separation**: Bootstrap roles vs. application roles vs. configuration roles

### 2. **Explicit Runtime Dependency Checks**

**Implementation in `dev-environment/tasks/main.yml`:**
```yaml
- name: Ensure Node.js is available via mise
  command: mise install node
  environment:
    PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
  failed_when: false

- name: Install Mac-CLI via npm
  npm:
    name: mac-cli
    global: yes
  environment:
    PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
  failed_when: false
  retries: 2
  delay: 5
```

**Logic flow:**
1. **Check Runtime Availability**: Ensure Node.js is installed via mise
2. **Path Management**: Include mise binary path for runtime access
3. **Graceful Failure**: Use `failed_when: false` to handle edge cases
4. **Retry Logic**: Attempt installation multiple times with delays
5. **Environment Isolation**: Proper PATH management for tool execution

**Implementation in `python/tasks/mac.yml`:**
```yaml
- name: Ensure Python is available via mise
  command: mise install python
  environment:
    PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
  failed_when: false

- name: Install global Python tools via uv
  command: uv tool install {{ item }}
  loop: [pytest, ruff, black, mypy, poetry, pyright, jupyterlab]
  environment:
    PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
  failed_when: false
  retries: 2
  delay: 5
```

**Logic flow:**
1. **Runtime Guarantee**: Ensure Python runtime available before tool installation
2. **Isolated Tool Installation**: Use `uv tool install` for proper isolation (PEP 668 compliance)
3. **Batch Processing**: Install multiple tools with consistent error handling
4. **Environment Consistency**: Maintain PATH across all operations

### 3. **mise Configuration Enhancement**

**Change made to `mise/files/config.toml`:**
```toml
[tools]
node = "20"
go = "latest"
python = "latest"  # Added Python runtime management

[settings]
idiomatic_version_file_enable_tools = ["node", "python"]  # Added Python
```

**Logic:**
1. **Centralized Runtime Management**: All language runtimes managed through mise
2. **Version Consistency**: Explicit version specifications for reproducibility
3. **Tool Integration**: Enable idiomatic version file support for project-specific versions

### 4. **Tool Duplication Elimination**

**Change made to `group_vars/local`:**
```yaml
# Removed duplicate CLI tools from Homebrew packages
mac_homebrew_packages:
  # Modern CLI replacements (others handled by dedicated roles)
  - fd  # find replacement
  - dust  # du replacement
  # Removed: eza, bat, ripgrep, fzf (now handled by dedicated roles only)
```

**Logic:**
1. **Single Source of Truth**: Each tool installed by exactly one method
2. **Role-Based Management**: Dedicated roles provide configuration and aliases
3. **Homebrew for System Tools**: Only system-level utilities via Homebrew
4. **Clear Separation**: Development tools vs. system utilities

## Error Handling and Recovery

### 1. **Graceful Degradation**

**When runtimes are missing:**
```yaml
failed_when: false  # Continue bootstrap even if specific tools fail
retries: 2          # Attempt multiple times before giving up
delay: 5            # Wait between retries for system stability
```

**Logic:**
- Bootstrap continues even if individual tools fail
- Critical path (system setup) vs. nice-to-have (specific tools)
- User can manually fix specific issues after bootstrap completes

### 2. **Environment Path Management**

**Implementation pattern:**
```yaml
environment:
  PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
```

**Logic:**
- Include mise binary directory in PATH for all tool operations
- Maintain existing PATH to avoid breaking system tools
- Consistent environment across all runtime-dependent tasks

### 3. **Prerequisite Validation**

**Enhanced `dot-bootstrap` script:**
```bash
# Check prerequisites before starting
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible not found. Run ./bin/dot-install first."
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Run ./bin/dot-install first."
    exit 1
fi
```

**Logic:**
1. **Early Failure Detection**: Catch missing prerequisites before Ansible execution
2. **Clear Error Messages**: Guide user to correct resolution steps
3. **Fast Feedback**: Avoid lengthy bootstrap process when prerequisites missing

## Testing and Validation

### 1. **Automated Dependency Testing**

**Test implementation in `bin/dot-test-bootstrap`:**
```bash
test_dependency_order() {
    # Check critical dependency order: mise before dev-environment
    local mise_line=$(echo "$role_order" | grep -n "mise" | cut -d: -f1)
    local dev_env_line=$(echo "$role_order" | grep -n "dev-environment" | cut -d: -f1)
    
    if [[ "$mise_line" -lt "$dev_env_line" ]]; then
        test_passed "mise role comes before dev-environment"
    else
        test_failed "mise role must come before dev-environment (Node.js dependency)"
    fi
}
```

**Logic:**
- Parse role execution order from playbook
- Validate critical dependencies are satisfied
- Automated detection of regression in role ordering

### 2. **Runtime Availability Validation**

**Test checks:**
```bash
# Check dev-environment has Node.js dependency check
if grep -q "mise install node" roles/dev-environment/tasks/main.yml; then
    test_passed "dev-environment checks Node.js availability"
else
    test_failed "dev-environment missing Node.js dependency check"
fi
```

**Logic:**
- Verify explicit runtime checks exist in dependent roles
- Ensure code follows established dependency patterns
- Catch missing dependency checks during development

## Performance Considerations

### 1. **Runtime Installation Caching**

**mise behavior:**
- Downloads and caches runtime binaries locally
- Subsequent installs use cached versions
- Shared cache across projects and bootstrap runs

**Impact:**
- First bootstrap: Longer due to runtime downloads
- Subsequent runs: Fast due to caching
- Network dependency: Initial install requires internet

### 2. **Parallel Tool Installation**

**Ansible behavior:**
- Roles execute sequentially for dependency management
- Within roles, tasks can leverage Ansible's parallelism
- Tool installation loops benefit from Ansible's efficiency

**Optimization opportunities:**
- Batch tool installations where possible
- Use Ansible's async capabilities for long-running installs
- Consider splitting large tool lists into parallel batches

## Security Considerations

### 1. **Runtime Source Verification**

**mise security model:**
- Downloads runtimes from official sources
- Verifies checksums for downloaded binaries
- Maintains trusted source registry

**Implications:**
- Trust mise's security model for runtime integrity
- Regular updates ensure latest security patches
- Alternative: Pin specific versions for security auditing

### 2. **Tool Installation Isolation**

**uv tool isolation:**
- Each Python tool installed in isolated environment
- Prevents dependency conflicts between tools
- Complies with PEP 668 externally-managed-environment restrictions

**Benefits:**
- Reduced security attack surface
- Improved stability and reproducibility
- System Python remains unmodified

### 3. **Path Security**

**Implementation:**
```yaml
environment:
  PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
```

**Security considerations:**
- Append to PATH rather than prepend to avoid hijacking system tools
- Use user-specific directories to avoid system-wide modifications
- Limit scope to specific tasks rather than global environment changes

## Future Maintenance

### 1. **Adding New Language Runtimes**

**Process:**
1. Add runtime to `mise/files/config.toml`
2. Create explicit dependency check in consuming roles
3. Update role execution order if needed
4. Add validation test to `dot-test-bootstrap`

**Example for Ruby:**
```toml
[tools]
ruby = "latest"
```

```yaml
- name: Ensure Ruby is available via mise
  command: mise install ruby
  environment:
    PATH: "{{ ansible_env.PATH }}:{{ ansible_env.HOME }}/.local/bin"
  failed_when: false
```

### 2. **Role Dependency Documentation**

**Maintain dependency graph:**
- Document which roles depend on which runtimes
- Update documentation when adding new dependencies
- Consider tooling to auto-generate dependency graphs

### 3. **Version Management Strategy**

**Current approach:**
- `node = "20"` - Specific stable version
- `python = "latest"` - Latest stable version
- `go = "latest"` - Latest stable version

**Considerations:**
- Pin specific versions for reproducibility
- Update strategy for security patches
- Testing across multiple runtime versions

## Troubleshooting Common Issues

### 1. **Bootstrap Fails with "command not found"**

**Symptoms:**
```
npm: command not found
python: command not found
```

**Diagnosis:**
- Check role execution order in `local_env.yml`
- Verify `mise` role runs before dependent roles
- Confirm PATH includes mise binary directory

**Resolution:**
```bash
# Run dependency order test
./bin/dot-test-bootstrap

# Manual verification
mise install node
mise install python
```

### 2. **Python Tools Fail with PEP 668 Error**

**Symptoms:**
```
error: externally-managed-environment
```

**Diagnosis:**
- System Python restricted from global package installation
- `uv tool install` not being used correctly

**Resolution:**
- Ensure `uv` is installed via Homebrew
- Use `uv tool install` instead of `pip install`
- Verify Python runtime available via mise

### 3. **Tool Version Conflicts**

**Symptoms:**
- Wrong tool versions being used
- Commands not found despite installation

**Diagnosis:**
- Multiple installation sources (Homebrew + roles)
- PATH ordering issues
- Tool duplication

**Resolution:**
- Check `group_vars/local` for duplicate entries
- Verify single source of truth for each tool
- Update shell configuration: `source ~/.zshrc`

## Related Documentation

- [BOOTSTRAP_VALIDATION.md](BOOTSTRAP_VALIDATION.md) - Testing and validation procedures
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting guide
- [FEATURES.md](FEATURES.md) - Overview of dotfiles features
- [mise documentation](https://mise.jdx.dev/) - Runtime management tool documentation
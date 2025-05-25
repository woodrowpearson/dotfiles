# Bootstrap Testing Framework

This document explains the comprehensive testing framework for validating the dotfiles bootstrap system, including test structure, interpretation of results, and extension guidelines.

## Overview

The `dot-test-bootstrap` script provides automated validation of the entire bootstrap system, from prerequisites to role execution to dependency chain management. It's designed to catch issues before they cause bootstrap failures.

## Quick Start

### Running Tests

```bash
# Run complete test suite
./bin/dot-test-bootstrap

# Show help and test categories
./bin/dot-test-bootstrap --help
```

### Understanding Results

**Test Status Indicators:**
- ✅ **Green checkmarks**: Tests passed successfully
- ⚠️ **Yellow warnings**: Non-critical issues that don't prevent bootstrap
- ❌ **Red failures**: Critical issues requiring immediate attention

**Exit Codes:**
- `0`: All tests passed
- `1`: One or more tests failed

## Test Categories

### 1. Prerequisites Testing (`test_prerequisites`)

**What it tests:**
- macOS operating system
- Xcode Command Line Tools installation
- Homebrew installation and functionality
- Git availability
- Python3 installation
- Ansible installation and version

**Sample output:**
```
🧪 Testing prerequisites...
✅ Running on macOS
✅ Xcode Command Line Tools installed
✅ Homebrew installed
✅ Git installed
✅ Python3 installed
✅ Ansible installed
```

**When tests fail:**
```bash
❌ Homebrew not installed
```

**Resolution:** Run `./bin/dot-install` to install missing prerequisites.

### 2. Script Functionality Testing (`test_dot_install`, `test_dot_bootstrap`)

**What it tests:**
- Script file existence
- Script syntax validation
- Help flag functionality
- Script permissions

**Sample validation:**
```bash
✅ dot-install script exists
✅ dot-install --help works
✅ dot-install syntax is valid
✅ dot-bootstrap script exists
✅ dot-bootstrap syntax is valid
```

**Implementation details:**
```bash
# Syntax validation
if bash -n "${DOTFILES_DIR}/bin/dot-install"; then
    test_passed "dot-install syntax is valid"
else
    test_failed "dot-install has syntax errors"
fi
```

### 3. Ansible Configuration Testing (`test_ansible_playbooks`)

**What it tests:**
- Playbook syntax validation (`local_env.yml`, `remote_env.yml`)
- Inventory file existence and parsing
- Ansible can parse configuration without errors

**Validation process:**
```bash
# Syntax checking
ansible-playbook --syntax-check local_env.yml

# Inventory validation
ansible-inventory -i hosts --list
```

**Common issues caught:**
- YAML syntax errors in playbooks
- Missing inventory hosts
- Invalid group_vars configuration

### 4. Bootstrap Role Execution Testing (`test_bootstrap_roles`)

**What it tests:**
- Bootstrap-tagged roles execute successfully in check mode
- Individual critical roles (package_manager, zsh) work correctly
- No fatal errors during role execution

**Sample execution:**
```bash
✅ Bootstrap roles check mode successful
✅ Role package_manager check mode successful
✅ Role zsh check mode successful
```

**Technical implementation:**
```bash
# Test bootstrap roles in check mode
ansible-playbook -i hosts local_env.yml --tags bootstrap --check --diff
```

**Benefits of check mode testing:**
- Validates logic without making changes
- Catches dependency issues early
- Tests ansible syntax and role structure

### 5. Dependency Order Validation (`test_dependency_order`)

**What it tests:**
- Critical role execution order (mise before dev-environment)
- CLI tool duplication prevention
- Runtime dependency management
- Backup checkpoint graceful handling

**Key validations:**

**Role execution order:**
```bash
# Extract and validate role order
local role_order=$(grep -A 50 "roles:" local_env.yml | grep "role:" | sed 's/.*role: \([^,]*\).*/\1/')
local mise_line=$(echo "$role_order" | grep -n "mise" | cut -d: -f1)
local dev_env_line=$(echo "$role_order" | grep -n "dev-environment" | cut -d: -f1)

if [[ "$mise_line" -lt "$dev_env_line" ]]; then
    test_passed "mise role comes before dev-environment"
else
    test_failed "mise role must come before dev-environment (Node.js dependency)"
fi
```

**CLI tool duplication check:**
```bash
# Check for duplicate CLI tools in Homebrew packages
local homebrew_tools=$(grep -A 30 "mac_homebrew_packages:" group_vars/local | grep -E "\s+- (eza|bat|ripgrep|fzf)" | wc -l)
if [[ "$homebrew_tools" -eq 0 ]]; then
    test_passed "No duplicate CLI tools in Homebrew packages"
else
    test_warning "Found CLI tools in Homebrew packages that have dedicated roles"
fi
```

**Runtime dependency checks:**
```bash
# Verify roles include dependency checks
if grep -q "mise install node" roles/dev-environment/tasks/main.yml; then
    test_passed "dev-environment checks Node.js availability"
else
    test_failed "dev-environment missing Node.js dependency check"
fi
```

### 6. Configuration File Validation (`test_config_files`)

**What it tests:**
- Group variables file existence
- YAML syntax validation via Ansible
- Configuration file accessibility

**Validation method:**
```bash
# Use Ansible inventory parsing to validate YAML
if ansible-inventory -i "${DOTFILES_DIR}/hosts" --list > /dev/null 2>&1; then
    test_passed "group_vars/local YAML syntax is valid (via ansible)"
else
    test_failed "group_vars/local has invalid YAML syntax"
fi
```

### 7. Role Structure Validation (`test_role_structure`)

**What it tests:**
- Role directory structure
- Required files existence (tasks/main.yml)
- Role task file syntax validation

**What it reports:**
- ✅ Valid roles with proper structure
- ⚠️ Roles missing tasks/main.yml (incomplete/placeholder roles)
- ⚠️ Roles with potential YAML syntax issues

**Implementation note:**
Many warnings are expected for incomplete roles (like service roles for home server setup). These don't affect bootstrap functionality.

### 8. Remote URL Accessibility (`test_remote_urls`)

**What it tests:**
- GitHub repository accessibility
- dot-install script raw URL availability
- Network connectivity for remote bootstrap

**Sample output:**
```bash
✅ GitHub repository is accessible
⚠️ dot-install raw URL may not be accessible
```

**Note:** URL warnings may indicate network issues or GitHub rate limiting, but don't prevent local bootstrap.

## Test Reports and Logging

### Automatic Report Generation

Each test run generates comprehensive reports:

**Test log location:**
```
artifacts/test-results/bootstrap_test_YYYYMMDD_HHMMSS.log
```

**Test report location:**
```
artifacts/test-results/bootstrap_test_report_YYYYMMDD_HHMMSS.md
```

### Report Contents

**Test report includes:**
- Date and system information
- Detailed test results
- System configuration snapshot
- Homebrew package lists
- Python package information
- Recommendations for issues found

**Sample report structure:**
```markdown
# Bootstrap Test Report

**Date:** 2024-01-25 14:30:22
**System:** Darwin MacBook-Pro.local 23.1.0
**Dotfiles Version:** 8552c1c

## Test Results
PASS: Running on macOS
PASS: Homebrew installed
PASS: mise role comes before dev-environment
...

## System Information
### Homebrew Packages
git
ansible
uv
...

## Recommendations
### Immediate Actions Required
- Check failed tests above
- Review Ansible warnings about Python interpreter
```

## Extending the Test Framework

### Adding New Test Functions

**Basic test function structure:**
```bash
test_new_functionality() {
    echo -e "${BLUE}Testing new functionality...${NC}"
    
    # Test implementation
    if [[ condition_check ]]; then
        test_passed "Test description"
    else
        test_failed "Test description"
    fi
    
    # Optional warning
    if [[ warning_condition ]]; then
        test_warning "Warning description"
    fi
}
```

**Add to main execution:**
```bash
local test_functions=(
    "test_prerequisites"
    "test_dot_install" 
    "test_dot_bootstrap"
    "test_ansible_playbooks"
    "test_bootstrap_roles"
    "test_dependency_order"
    "test_config_files"
    "test_role_structure"
    "test_remote_urls"
    "test_new_functionality"  # Add your new test
)
```

### Helper Functions Available

**Test result functions:**
```bash
test_passed "Description"    # Green checkmark
test_failed "Description"    # Red X (increments failure count)
test_warning "Description"   # Yellow warning (doesn't fail test)
```

**Logging functions:**
```bash
echo "INFO: message" >> "$TEST_LOG"
```

**Environment variables:**
```bash
DOTFILES_DIR          # Path to dotfiles directory
TEST_OUTPUT_DIR       # Test results directory
TEST_LOG             # Current test log file
TIMESTAMP            # Test run timestamp
```

### Testing New Roles

**Add role-specific tests:**
```bash
test_new_role() {
    echo -e "${BLUE}Testing new role functionality...${NC}"
    
    # Check role structure
    if [[ -f "${DOTFILES_DIR}/roles/new-role/tasks/main.yml" ]]; then
        test_passed "New role has main tasks file"
    else
        test_failed "New role missing main tasks file"
    fi
    
    # Test role execution in check mode
    if ansible-playbook -i hosts local_env.yml --tags new-role --check > /dev/null 2>&1; then
        test_passed "New role check mode successful"
    else
        test_failed "New role check mode failed"
    fi
    
    # Test role dependencies
    if grep -q "dependency_check" roles/new-role/tasks/main.yml; then
        test_passed "New role includes dependency checks"
    else
        test_warning "New role missing dependency checks"
    fi
}
```

### Performance Testing

**Add timing measurements:**
```bash
test_performance() {
    echo -e "${BLUE}Testing performance metrics...${NC}"
    
    local start_time=$(date +%s)
    
    # Run performance test
    ansible-playbook -i hosts local_env.yml --tags bootstrap --check > /dev/null 2>&1
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $duration -lt 60 ]]; then
        test_passed "Bootstrap check completes in ${duration}s (< 60s)"
    else
        test_warning "Bootstrap check takes ${duration}s (consider optimization)"
    fi
}
```

## Integration with CI/CD

### GitHub Actions Integration

**Example workflow file (`.github/workflows/test-bootstrap.yml`):**
```yaml
name: Test Bootstrap System
on: [push, pull_request]

jobs:
  test-bootstrap:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install prerequisites
        run: ./bin/dot-install
        
      - name: Run bootstrap tests
        run: ./bin/dot-test-bootstrap
        
      - name: Upload test reports
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-reports
          path: artifacts/test-results/
```

### Local Development Integration

**Pre-commit hook:**
```bash
#!/bin/bash
# .git/hooks/pre-commit
./bin/dot-test-bootstrap
if [[ $? -ne 0 ]]; then
    echo "Bootstrap tests failed. Fix issues before committing."
    exit 1
fi
```

**Development workflow:**
```bash
# Make changes
vim roles/python/tasks/main.yml

# Test changes
./bin/dot-test-bootstrap

# If tests pass, commit
git add roles/python/tasks/main.yml
git commit -m "fix: improve Python dependency management"
```

## Performance Considerations

### Test Execution Time

**Typical test durations:**
- Prerequisites testing: ~2 seconds
- Script validation: ~1 second  
- Ansible syntax checking: ~3 seconds
- Role check mode execution: ~10-30 seconds
- Total execution time: ~1-2 minutes

**Optimization strategies:**
- Tests run in parallel where possible
- Use check mode instead of actual execution
- Cache test results for unchanged components
- Skip network tests when offline

### Resource Usage

**System resources:**
- Minimal CPU usage (mostly I/O bound)
- Low memory footprint (~50MB)
- Network usage only for URL accessibility tests
- Disk space: ~1MB for test reports

## Security Considerations

### Test Data Safety

**What tests DON'T do:**
- Never execute actual bootstrap (only check mode)
- Never modify system configuration
- Never install or remove packages
- Never access sensitive data

**What tests DO verify:**
- Script syntax without execution
- Configuration file accessibility
- Dependency chain logic
- Role structure integrity

### Test Report Security

**Sensitive data handling:**
- Test reports exclude sensitive configuration
- No passwords or API keys in logs
- System information is safe to share
- Personal paths are visible (consider before sharing)

## Troubleshooting Test Framework

### Common Test Issues

**Problem**: Tests fail with "Permission denied"
```bash
# Fix test script permissions
chmod +x bin/dot-test-bootstrap
```

**Problem**: Ansible inventory warnings
```bash
# These are warnings, not failures
[WARNING]: No inventory was parsed, only implicit localhost is available
```

**Problem**: Network test failures
```bash
# Skip network tests if offline
export SKIP_NETWORK_TESTS=true
./bin/dot-test-bootstrap
```

**Problem**: False positives in role structure tests
```bash
# Many roles are incomplete/placeholders - warnings are expected
# Only failures (❌) require attention
```

### Debugging Test Failures

**Verbose test execution:**
```bash
# Enable debug mode
export DEBUG=true
./bin/dot-test-bootstrap

# Check specific test manually
ansible-playbook -i hosts local_env.yml --tags problematic-role --check -v
```

**Review test logs:**
```bash
# Find latest test log
ls -la artifacts/test-results/bootstrap_test_*.log | tail -1

# Review specific test results
grep -A 5 -B 5 "FAIL:" artifacts/test-results/bootstrap_test_*.log
```

## Related Documentation

- [BOOTSTRAP_DEPENDENCY_CHAIN.md](BOOTSTRAP_DEPENDENCY_CHAIN.md) - Dependency management details
- [BACKUP_SYSTEM_ARCHITECTURE.md](BACKUP_SYSTEM_ARCHITECTURE.md) - Backup system testing
- [BOOTSTRAP_VALIDATION.md](BOOTSTRAP_VALIDATION.md) - Manual validation procedures
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Issue resolution guide
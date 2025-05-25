# 🏗️ Templates Documentation

**Production-ready CI/CD and project templates.** Because starting projects shouldn't take hours of setup.

## 🎯 What's Included

When you run `newproject <language> <name>`, these templates create complete, professional project setups with modern tooling and best practices baked in.

## 🔄 GitHub Actions Workflows

### 🐍 `python.yml` - Python CI/CD
**Perfect for:** Python APIs, libraries, data science projects

**What it does:**
- ✅ **Multi-version testing** - Python 3.8, 3.9, 3.10, 3.11
- ✅ **Modern tooling** - Uses `uv` for lightning-fast dependency management
- ✅ **Code quality** - Runs ruff (linting + formatting), mypy (type checking)
- ✅ **Testing** - pytest with coverage reporting
- ✅ **Coverage** - Uploads to Codecov for tracking

**Triggered on:** Push to main/develop, PRs to main

```yaml
# Example workflow run
✓ Install uv and dependencies
✓ Lint with ruff  
✓ Format check with ruff
✓ Type check with mypy
✓ Test with pytest + coverage
✓ Upload coverage to Codecov
```

---

### 🟢 `node.yml` - Node.js CI/CD  
**Perfect for:** Web apps, APIs, React/Vue projects, npm packages

**What it does:**
- ✅ **Multi-version testing** - Node.js 18, 20, 21
- ✅ **Fast installs** - Uses npm cache for speed
- ✅ **Code quality** - ESLint, TypeScript checking, Prettier
- ✅ **Testing** - Your test framework of choice
- ✅ **Build verification** - Ensures production builds work

**Triggered on:** Push to main/develop, PRs to main

```yaml
# Example workflow run  
✓ Setup Node.js with cache
✓ Install dependencies (npm ci)
✓ Lint code (ESLint)
✓ Type check (if TypeScript)
✓ Run tests
✓ Build for production
```

---

### 🦀 `rust.yml` - Rust CI/CD
**Perfect for:** CLI tools, systems programming, WebAssembly projects

**What it does:**
- ✅ **Latest stable Rust** - Always uses current stable toolchain
- ✅ **Code quality** - cargo fmt, clippy (with strict warnings)
- ✅ **Smart caching** - Caches dependencies for faster builds
- ✅ **Testing** - cargo test with verbose output
- ✅ **Build verification** - Ensures release builds compile

**Triggered on:** Push to main/develop, PRs to main

```yaml
# Example workflow run
✓ Install Rust stable + components
✓ Cache cargo dependencies  
✓ Format check (cargo fmt)
✓ Lint (cargo clippy)
✓ Build project
✓ Run tests
```

---

## 🪝 Pre-commit Configuration

### `.pre-commit-config.yaml` - Automated Code Quality
**What it prevents:** Committing broken, poorly formatted, or problematic code

**Universal hooks:**
- ✅ **Whitespace cleanup** - Trailing whitespace, end-of-file fixes
- ✅ **File validation** - YAML, JSON syntax checking
- ✅ **Merge conflict detection** - Prevents accidental conflict commits
- ✅ **Large file prevention** - Stops accidentally committing huge files

**Language-specific hooks:**

**Python projects:**
- 🐍 **ruff** - Lightning-fast linting and formatting
- 🐍 **mypy** - Type checking for better code quality

**JavaScript/TypeScript projects:**
- 🟢 **ESLint** - Code linting and style enforcement
- 🟢 **Prettier** - Automatic code formatting

**Rust projects:**
- 🦀 **cargo fmt** - Automatic code formatting
- 🦀 **cargo clippy** - Advanced linting and suggestions

---

## 🚀 How Templates Are Used

### Project Creation Flow
```bash
newproject python my-awesome-api
```

**What happens behind the scenes:**
1. 📁 **Project structure** created in `~/code/my-awesome-api/`
2. 📄 **Language-specific files** - setup.py, pyproject.toml, README, etc.
3. 🔄 **CI/CD workflow** copied from `templates/.github/workflows/python.yml`
4. 🪝 **Pre-commit config** copied and customized for Python
5. 📝 **Git initialization** with proper .gitignore and initial commit
6. 🔐 **Environment setup** - .env template with API key stubs

### Result: Production-Ready Project
```
my-awesome-api/
├── .github/workflows/python.yml    # CI/CD ready to go
├── .pre-commit-config.yaml         # Code quality automation
├── src/                            # Proper Python structure
├── tests/                          # Testing framework setup
├── pyproject.toml                  # Modern Python configuration
├── .env                           # API key management
├── .gitignore                     # Sensible defaults
└── README.md                      # Project documentation
```

## 🎨 Customizing Templates

### Adding Your Own Workflow
```bash
# Create new workflow template
cp templates/.github/workflows/python.yml templates/.github/workflows/my-language.yml

# Edit for your language/framework
vim templates/.github/workflows/my-language.yml

# Update newproject script to use it
vim bin/newproject  # Add case for your language
```

### Modifying Existing Templates
```bash
# Templates are in templates/ directory
ls templates/
├── .github/workflows/
│   ├── python.yml     # ← Edit these
│   ├── node.yml       # ← Edit these  
│   └── rust.yml       # ← Edit these
└── .pre-commit-config.yaml  # ← Edit this
```

### Template Variables
Templates support basic variable substitution:
- `$PROJECT_NAME` - Replaced with your project name
- `$LANGUAGE` - Replaced with the project language
- Standard git variables (user.name, user.email)

## 🌟 Best Practices Baked In

### Security
- ✅ **Dependency scanning** - GitHub security advisories
- ✅ **No secrets in code** - .env templates with placeholders
- ✅ **Minimal permissions** - Workflows use least-privilege access

### Performance  
- ✅ **Smart caching** - Dependencies cached between runs
- ✅ **Parallel execution** - Matrix builds for multiple versions
- ✅ **Fast tooling** - uv, esbuild, cargo for speed

### Maintainability
- ✅ **Version pinning** - Specific action versions for reliability
- ✅ **Clear failure messages** - Know exactly what went wrong
- ✅ **Consistent structure** - Same patterns across languages

## 🔍 Template Philosophy

**"Start with production-quality, scale down if needed"**

These templates assume you want:
- ✅ **Professional CI/CD** from day one
- ✅ **Code quality enforcement** that prevents bugs
- ✅ **Modern tooling** that makes development enjoyable  
- ✅ **Security best practices** built in by default

**Not building the next unicorn?** That's fine! Remove what you don't need. But you'll often find these practices make even small projects better.

---

**💡 Pro Tip:** These templates evolve with best practices. Update your dotfiles regularly to get the latest improvements!

**🔧 Want to contribute?** Found a better way to do CI/CD for a language? PRs welcome for template improvements!

**[← Back to Main README](../README.md) • [🎭 Ansible Roles →](../roles/README.md) • [🛠️ Scripts →](../bin/README.md)**
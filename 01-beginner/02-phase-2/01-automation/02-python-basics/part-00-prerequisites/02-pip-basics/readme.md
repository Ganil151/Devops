# Pip Essentials
*The Package Installer for Python*

`pip` <font color="#ffc000">is the standard package manager for Python</font>. It allows you to install and manage additional libraries and dependencies that are not distributed as part of the standard library.

---
## 🎯 Learning Objectives
- Install packages using pip
- Manage package versions
- Use requirement files
- Understand basic pip commands

---
## 🛠️ Basic Pip Commands

### Installing Packages
```bash
# Install the latest version
pip install requests

# Install a specific version
pip install requests==2.31.0

# Install a version compatible with 2.31
pip install requests~=2.31.0
```
### Managing Packages
```bash
# List installed packages
pip list

# Show information about an installed package
pip show requests

# Uninstall a package
pip uninstall requests
```
### Requirements Files
Requirements files allow you to specify a list of packages to install. This is crucial for reproducing environments.
**requirements.txt**:
```text
requests==2.31.0
boto3>=1.26.0
pyyaml
```
**Install from file**:
```bash
pip install -r requirements.txt
```
**Freeze current environment to file**:
```bash
pip freeze > requirements.txt
```

---
## 🔍 Best Practices for DevOps
1. **Always use Virtual Environments**: Never install packages globally on your system Python to avoid conflicts.
2. **Pin Dependencies**: Use `==` in production `requirements.txt` to ensure the exact same code runs everywhere.
3. **Cache for CI/CD**: Use `--no-cache-dir` in Docker builds to save space, but leverage caching in CI/CD pipelines for speed.

---
**Next Step**: [Virtual Environments →](readme.md)

# Python Installation & Setup
*The First Step to Automation*

Before you can automate servers or cloud infrastructure, you need a robust Python environment. This guide covers how to install Python correctly on Windows, Linux, and macOS for DevOps work.

---
## 🎯 Learning Objectives
- Install the latest stable Python version
- Verify installation on different operating systems
- Understand the Python Launcher (Windows)
- Configure the PATH environment variable
- Run the REPL (Read-Eval-Print Loop)

---

## 🏗️ Installation Guide

### 1. Windows Installation
For DevOps on Windows, we recommend the official installer.

1. **Download**: Go to [python.org/downloads](https://www.python.org/downloads/) and get the latest stable release (e.g., 3.11.x or 3.12.x).
2. **Run Installer**: Double-click the `.exe`.
3. **⚠️ CRITICAL STEP**: Check the box **"Add Python to PATH"** at the bottom.
4. **Click "Install Now"**.

#### Verify (PowerShell/CMD):
```powershell
python --version
# Output: Python 3.12.1

pip --version
# Output: pip 23.2.1 from ...
```

> **Pro Tip**: Use `py` (Python Launcher) to manage multiple versions.
> `py -3.10` runs Python 3.10, `py -3.12` runs Python 3.12.

---

### 2. Linux Installation (Ubuntu/Debian)
Most Linux distros come with Python, but it might be old.

```bash
# Check current version
python3 --version

# Update package list
sudo apt update

# Install latest supported version
sudo apt install python3 python3-pip python3-venv

# Verify
python3 --version
pip3 --version
```

---

### 3. macOS Installation
macOS comes with a system Python that you **should not modify**. Install a separate version for development.

**Option A: Official Installer**
Download from [python.org/downloads](https://www.python.org/downloads/macos/).

**Option B: Homebrew (Recommended for DevOps)**
```bash
# Install Homebrew if you haven't
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python
brew install python

# Verify
python3 --version
```

---

## ⚙️ The PATH Variable
If typing `python` gives "Command not found":

1. **Windows**: Search "Edit the system environment variables" -> Environment Variables -> Path -> Edit -> Add path to python.exe (e.g., `C:\Users\Name\AppData\Local\Programs\Python\Python312\`).
2. **Linux/Mac**: Add to `~/.bashrc` or `~/.zshrc`:
   ```bash
   export PATH="/usr/local/bin:$PATH"
   ```

---
## 🐍 Interactive Shell (REPL)
Type `python` (or `python3`) to enter the interactive shell. Great for quick tests.

```python
Type "help", "copyright", "credits" or "license" for more information.
>>> print("Hello, DevOps!")
Hello, DevOps!
>>> 2 + 2
4
>>> exit()
```
(Press `Ctrl+Z` then `Enter` on Windows, or `Ctrl+D` on Linux/Mac to exit)

---

## 🛠️ Hands-On Challenges

### Challenge 1: Version Check Script
Write a one-liner to check your environment.
```bash
python -c "import sys; print(f'Running Python {sys.version}')"
```

### Challenge 2: Locate Interpreter
Find exactly where your Python is running from.
```bash
# Windows
where python

# Linux/Mac
which python3
```

---
**Next Step**: [Pip Essentials →](../00-Pip-Basics/README.md)

# Virtual Environments
*Isolating Dependencies for Stability*

A Virtual Environment is a self-contained directory tree that contains a Python installation for a particular version of Python, plus a number of additional packages.

---
## 🎯 Learning Objectives
- Understanding the need for isolation
- Creating a virtual environment (`venv`)
- Activating and Deactivating
- Managing dependencies within a venv

---
## 🚀 Why Virtual Environments?
Imagine you have **Project A** needing `Django==3.0` and **Project B** needing `Django==4.0`. If you install Django globally, you can only have one version. Virtual environments solve this by giving each project its own isolated sandbox.

---
## 🛠️ Usage Guide

### 1. Creating a Venv
In your project directory:
```bash
# Windows
python -m venv .venv

# Linux/Mac
python3 -m venv .venv
```
*Note: `.venv` is a common naming convention. Using `.` hides it in some file explorers.*

### 2. Activating
You must activate the environment to use it. Your terminal prompt will usually change to show `(.venv)`.

**Windows (CMD)**:
```cmd
.venv\Scripts\activate
```
**Windows (PowerShell)**:
```powershell
.venv\Scripts\Activate.ps1
```
**Linux / macOS**:
```bash
source .venv/bin/activate
```

### 3. Deactivating
To leave the virtual environment:
```bash
deactivate
```

---
## 📦 Working Inside a Venv
Once activated, `pip` and `python` point to the restricted environment.
```bash
# Check python path (should be inside .venv)
which python      # Linux/Mac
where python      # Windows

# Install a package (only goes into .venv directory)
pip install requests
```

---

## �🛑 Common Pitfalls
1. **Committing `.venv`**: NEVER commit your virtual environment to Git. Add `.venv/` to your `.gitignore`.
2. **Moving Venvs**: You cannot move a venv folder to a different location. It relies on absolute paths. If you move the project, delete and recreate the venv.
---
**Next Step**: [Python Fundamentals →](readme.md)

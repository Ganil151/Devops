# 🐍 Python Standard Library for DevOps
*Version 2.0 | The Senior SRE's Toolkit for System Automation*

---

## 🏛️ Executive Summary
While Python's external ecosystem (PyPI) is massive, a Senior DevOps engineer prioritizes the **Standard Library** to minimize dependencies and security risks. This manual covers the essential modules for OS interaction, file manipulation, and network communication.

---

## 🏗️ Core Architecture: The "Big Four" Modules

### 1. `os` & `os.path` / `pathlib`
**Purpose**: System-level operations and file path manipulation.
- **SRE Standard**: Use `pathlib` for modern, object-oriented path handling over `os.path`.
- **Snippet**: `path = pathlib.Path("/etc/config").exists()`

### 2. `subprocess`
**Purpose**: Spawning new processes and connecting to their input/output/error pipes.
- **Rule**: Always use `subprocess.run()` with `check=True` to catch non-zero exit status automatically.
- **Snippet**: `subprocess.run(["ls", "-l"], capture_output=True, text=True, check=True)`

### 3. `shutil`
**Purpose**: High-level file operations (Copying, Moving, Disk Usage).
- **Use Case**: Cleaning up log directories or backing up config files.
- **Snippet**: `shutil.disk_usage("/")` - Returns total, used, and free space.

### 4. `json` / `csv` / `configparser`
**Purpose**: Structured data serialization and configuration management.
- **SRE Standard**: Use `json.loads()` for API responses and `configparser` for legacy `.ini` configuration files.

---

## ⚙️ Advanced Data Handling

### `sys` module
- `sys.argv`: Access command-line arguments.
- `sys.exit(1)`: Gracefully exit a script with a failure code for CI/CD runners.
- `sys.stdin`: Reading piped data (e.g., `cat list.txt | python script.py`).

### `datetime`
**Requirement**: Time-stamping logs and managing TTLs (Time to Live) for backup files.
- **Snippet**: `datetime.now(timezone.utc).isoformat()`

---

## 🛡️ SRE Global Patterns: Dependency Minimalism
**The "Cloud-Init" Rule**: If your script needs to run in a raw cloud-init environment (before `pip` is available), stick **100%** to the standard library.

---

## 🧪 Real-World Troubleshooting
**Scenario**: "My script works manually but fails when launched via a Cron job or CI Runner."
- **Root Cause**: The **Environment Path**. Python might not find the same binaries.
- **Solution**: Use `shutil.which("binary_name")` to find the absolute path of a tool at runtime, or use absolute paths in `subprocess`.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between `subprocess.run()` and `os.system()`. Why is the latter deprecated?**
2. **What is a "Generator" and why is it preferred for reading 10GB log files using the `io` module?**
3. **Describe how `sys.path` impact module resolution and how a "Namespace Package" works.**
4. **Compare `json.dump` vs `json.dumps`. When would you use one over the other?**
5. **How does the `atexit` module help with idempotent resource cleanup?**

---
**Next Step**: [Python Automation Patterns →](./Python-Automation-Patterns-Ref.md)

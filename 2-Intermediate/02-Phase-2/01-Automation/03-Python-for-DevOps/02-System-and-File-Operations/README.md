# System and File Operations

System interaction is the bread and butter of DevOps. Python offers modern, object-oriented ways to handle paths and processes that are safer than OS shells.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `os_operations.py` (Pathlib, Subprocess).
- **[CHALLENGES](./CHALLENGES.md)**: Recursive walkers, log rotation.

---

## 🔑 Key Libraries

| Library | Use Case | Legacy Equivalent (Avoid) |
| :--- | :--- | :--- |
| **`pathlib`** | File/Folder manipulation | `os.path`, `glob` |
| **`subprocess`** | Running external commands | `os.system` |
| **`shutil`** | High-level file ops (mv, cp) | Manual `open()/write()` |
| **`os`** | Low-level (Env vars, Chown) | N/A |

---

## 🏗️ Modern Patterns

### 1. Robust Paths with `pathlib`
Stop concatenating strings with backslashes!

```python
from pathlib import Path

# Works on Windows AND Linux
config_path = Path("/etc") / "myapp" / "config.yaml"

if config_path.exists():
    text = config_path.read_text()
```

### 2. Safe Command Execution
Avoid "Shell Injection" by passing lists to `subprocess`.

```python
import subprocess

# BAD: Vulnerable to injection if 'user_input' has semi-colons
# os.system(f"grep {user_input} file.txt")

# GOOD: Arguments are strictly separated
subprocess.run(["grep", user_input, "file.txt"], check=True)
```

---

## 📖 Real-World Story: The "Fragile Shell" Migration

**Problem**: A 2,000-line Bash script for deploying apps used complex regex to parse YAML and `rm -rf` commands.
**Crisis**: A developer added a space in a directory name. The script parsed it as two arguments and deleted the wrong folder.
**Solution**: Rewrote in Python using `pathlib` and `PyYAML`. Python handles spaces in filenames natively without complex quoting.

---

## ❓ Interview Questions

1. **Why use `pathlib` over `os.path`?**
   - *Answer*: `pathlib` treats paths as objects, not strings. It is more readable (`p / "child"`) and handles cross-platform separators automatically.
2. **What does `subprocess.run(..., check=True)` do?**
   - *Answer*: It raises a `CalledProcessError` if the command returns a non-zero exit code, ensuring failures aren't ignored.
3. **How do you safely delete a directory tree?**
   - *Answer*: `shutil.rmtree(path)`.

---

[Next: Data Manipulation](../03-Working-with-Data-JSON-YAML/README.md)
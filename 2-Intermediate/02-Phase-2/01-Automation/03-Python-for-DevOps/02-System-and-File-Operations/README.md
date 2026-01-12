# System and File Operations

In DevOps, Python scripts often need to interact with the underlying operating system—managing files, checking environment variables, and executing shell commands.

## 🛠️ The `os` and `sys` Modules

These are the standard libraries for system-level interaction.

- **`os`**: Portable way of using operating system dependent functionality (file paths, env vars).
- **`sys`**: System-specific parameters and functions (command line arguments, script exit).

```python
import os
import sys

# Get Environment Variable
db_host = os.getenv("DB_HOST", "localhost")

# Get Command Line Arguments
# Usage: python script.py <filename>
if len(sys.argv) < 2:
    print("Usage: script.py <filename>")
    sys.exit(1)

filename = sys.argv[1]
```

## 📟 Running Shell Commands: `subprocess`

When Python doesn't have a native library for a task, you can run a shell command. Use `subprocess.run()` instead of the older `os.system()`.

```python
import subprocess

# Simple execution
subprocess.run(["ls", "-l"])

# Capture output
result = subprocess.run(["uname", "-a"], capture_output=True, text=True)
print(f"Server Info: {result.stdout.strip()}")
```

> [!CAUTION]
> Avoid `shell=True` whenever possible to prevent security vulnerabilities (Shell Injection). Pass commands as a list of strings instead.

## 📂 Modern Path Handling: `pathlib`

`pathlib` is the modern approach to file paths, replacing older `os.path` functions with object-oriented logic.

```python
from pathlib import Path

# Check if file exists
log_file = Path("/var/log/app.log")
if log_file.exists():
    print(f"Log size: {log_file.stat().st_size} bytes")

# Create directories recursively
new_dir = Path("backups/2025/jan")
new_dir.mkdir(parents=True, exist_ok=True)
```

---

## 📖 Stories from the Field: The "Infinite" Log Cleanup

**Scenario**: A sysadmin wrote a Python script to delete logs older than 30 days.
**Problem**: They used `os.system("rm -rf " + directory)` and passed a directory name provided by a user.
**Outcome**: A user accidentally (or maliciously) passed `"; rm -rf /"` as the directory name. Because `os.system` runs through a shell, it executed both commands, starting a root-level deletion.
**Resolution**: The script was refactored to use `pathlib` for file deletion or `subprocess.run()` with a list of arguments, which are not interpreted by a shell.
**Prevention**: **ALWAYS** treat external input as untrusted. Use `subprocess.run(["rm", "-rf", dir])` instead of shell strings.

---

## ❓ Interview Questions

1. **Why is `subprocess.run()` better than `os.system()`?**
   * *Answer*: It provides much better control over input/output/error streams and is safer against shell injection when used with a list of arguments instead of strings.
2. **What does `pathlib` offer over `os.path`?**
   * *Answer*: `pathlib` provides an object-oriented interface, making path manipulations more readable and cross-platform compatible without manual string concatenation.
3. **How do you read a large file in Python without loading it all into memory?**
   * *Answer*: Iterate through the file object: `with open('large.log') as f: for line in f: ...`. This reads the file line-by-line using a buffer.
4. **How do you check if a script is being run directly vs. being imported?**
   * *Answer*: Use `if __name__ == "__main__":`.
5. **How do you capture both standard output and standard error from a subprocess?**
   * *Answer*: Use `capture_output=True`. The results are then available in `result.stdout` and `result.stderr`.

---

## 🧠 Quiz

1. **Which module handles command-line arguments passed to a script?** `(sys)`
2. **Which function is recommended for executing external shell commands?** `(subprocess.run)`
3. **True/False: `pathlib` is only available on Linux.** `(False)`
4. **How do you access an environment variable in Python?** `(os.getenv('NAME'))`
5. **What does `exist_ok=True` do in `mkdir()`?** `(Prevents an error if the directory already exists)`
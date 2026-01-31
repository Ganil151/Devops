# 🐍 Reference: Core Python Automation Keywords

Python's strength in DevOps comes from its readable syntax and powerful Standard Library. Below are the core keywords and modules used for system-level automation.

---

## 🛠️ System & File Operations (os, pathlib)

### `pathlib.Path`
*   **Definition**: An object-oriented approach to filesystem paths.
*   **DevOps Why**: It handles OS-specific separators (Windows `\` vs Linux `/`) automatically and provides safe methods like `.exists()`, `.is_file()`, and `.mkdir(parents=True)`.
*   **Example**: `Path("/tmp/config.yml").read_text()` is cleaner than old `os.path` methods.

### `subprocess.run()`
*   **Definition**: The recommended way to run external shell commands from Python.
*   **Key Args**:
    *   `check=True`: Automatically raises an exception if the command fails (The Python equivalent of `set -e`).
    *   `capture_output=True`: Grabs `stdout` and `stderr` for processing.
    *   `text=True`: Returns strings instead of raw bytes.
*   **DevOps Why**: It allows Python to act as the "Glue" for legacy CLI tools while providing robust error handling.

### `sys.exit()`
*   **Definition**: Terminates the script with a specific status code.
*   **Standard**: Use `sys.exit(0)` for success and `sys.exit(1)` (or higher) for failures to notify CI/CD pipelines.

---

## 🛡️ Robust Coding Structures

### `try...except...finally`
*   **Definition**: The mechanism for catching and handling runtime errors.
*   **`finally` block**: Guaranteed to run regardless of whether an error occurred.
*   **DevOps Why**: Used to ensure database connections are closed or temp files are deleted (Python's internal `trap`).

### `with` (Context Managers)
*   **Definition**: Encapsulates common `try...finally` patterns.
*   **Example**: `with open('file.txt') as f:` ensures the file is closed automatically even if an error occurs.
*   **DevOps Why**: Prevents file handle leaks in long-running automation daemons.

### Type Hinting (`typing`)
*   **Definition**: Annotating variables and function returns with their expected types (e.g., `num: int`).
*   **DevOps Why**: Improves code clarity for team members and allows IDEs to catch bugs before the script even runs.

---

## 🎙️ Staff Interview context
*   **"Why use pathlib instead of the os module?"**
    *   *Answer*: `pathlib` treats paths as objects with methods rather than just strings. This reduces errors when joining paths and makes the code more readable and cross-platform compatible.
*   **"When should you use subprocess instead of a native Python library?"**
    *   *Answer*: Only as a last resort. Native libraries (like `boto3` or `requests`) provide better error handling and performance. Use `subprocess` only when interacting with a legacy CLI that has no Python SDK.

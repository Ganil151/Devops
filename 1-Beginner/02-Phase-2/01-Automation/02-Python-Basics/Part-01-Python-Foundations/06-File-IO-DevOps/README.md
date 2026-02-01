# 📂 File I/O: The Data Persistence Layer

> **"Infrastructure is code, and code is data. Mastering File I/O is how you bridge the gap between static YAML configs, dynamic JSON API responses, and the persistent audit logs that keep your systems accountable."**

![File I/O Architecture](../assets/file_io.png)

---

## 🧠 The Mental Model: File I/O as the Filing Cabinet

**The Junior Struggle**: "Why not just keep everything in memory?"

**The Engineer Solution**: Files provide **persistence**. Memory is temporary (lost on reboot), files are permanent. Just like a filing cabinet stores documents for later retrieval.

### 🏗️ The Infrastructure Analogy

Think of file I/O like a **filing cabinet** in an office:

| Concept | Filing Cabinet Analogy | File I/O Equivalent |
|:--------|:-----------------------|:--------------------|
| **Reading** | Taking a document out | `open("file.txt", "r")` |
| **Writing** | Creating a new document | `open("file.txt", "w")` |
| **Appending** | Adding to existing document | `open("file.txt", "a")` |
| **Context Manager** | Closing drawer when done | `with open(...)` |
| **Streaming** | Reading page by page | `for line in file:` |
| **Binary Mode** | Storing photos, not text | `open("file.bin", "rb")` |

**The Key Insight**: Just like you don't leave filing cabinet drawers open, you don't leave files open. Use context managers to ensure files are properly closed.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll just use `.read()` for everything"
- "I don't need to close files"
- "Memory is unlimited"

**After this module**, you'll understand:
- **Context managers (`with`) prevent resource leaks**
- **Streaming handles large files** without running out of memory
- **Different modes** for different operations (read, write, append)
- **Text vs binary** modes for different file types
- **Error handling** for missing files

**The Difference**: Your scripts will handle files safely, efficiently, and reliably.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Use Context Managers**: Always use `with` for file operations
- ✅ **Stream Large Files**: Process files line-by-line
- ✅ **Handle File Modes**: Read, write, append, binary
- ✅ **Parse Structured Data**: JSON and YAML files
- ✅ **Handle Errors Gracefully**: FileNotFoundError, PermissionError
- ✅ **Work with Paths**: Cross-platform file paths
- ✅ **Implement Atomic Writes**: Prevent corruption

---

## 🏗️ Part 1: The Context Manager Pattern

### 🧠 The Mental Model: The Auto-Closer

**The Problem**: Forgetting to close files causes resource leaks and file locks.

**The Solution**: Context managers (`with` statement) automatically close files.

### 🔧 The Wrong Way vs The Right Way

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ❌ WRONG: Manual file handling
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f = open("config.yaml", "r")
data = f.read()
f.close()  # ❌ Might never run if error occurs above

# Problems:
# 1. File stays open if exception occurs
# 2. File stays locked by the process
# 3. Resource leak in long-running scripts

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ✅ RIGHT: Context manager (with statement)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("config.yaml", "r") as f:
    data = f.read()
# ✅ File automatically closed here, even if exception occurs

# Benefits:
# 1. File always closed, even on error
# 2. No resource leaks
# 3. Cleaner, more Pythonic code
```

**💡 Pro Tip**: **ALWAYS** use `with` for file operations. It's the professional standard.

---

## 📖 Part 2: File Modes

### 🧠 The Mental Model: The Access Permission

**The Concept**: File modes determine what you can do with a file.

### 📊 File Mode Reference

| Mode | Name | Behavior | Use Case |
|:-----|:-----|:---------|:---------|
| **`r`** | Read | Read existing file | Reading configs, logs |
| **`w`** | Write | Create new or **overwrite** existing | Writing state files |
| **`a`** | Append | Add to end of existing file | Appending to logs |
| **`r+`** | Read/Write | Read and write existing file | Updating configs |
| **`rb`** | Read Binary | Read binary file | Reading images, PDFs |
| **`wb`** | Write Binary | Write binary file | Writing images, PDFs |

### 🔧 Mode Examples

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Read mode (r) - File must exist
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("config.yaml", "r") as f:
    content = f.read()
    print(content)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Write mode (w) - Creates new or OVERWRITES existing
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("output.txt", "w") as f:
    f.write("Deployment started\n")
    f.write("Deployment completed\n")

# ⚠️ WARNING: This DELETES all existing content!

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Append mode (a) - Adds to end of file
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("deployment.log", "a") as f:
    f.write("2026-01-31 21:00:00 - Deployment started\n")

# ✅ Preserves existing content, adds to end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Binary mode (rb/wb) - For non-text files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Reading a binary file
with open("image.png", "rb") as f:
    binary_data = f.read()

# Writing a binary file
with open("backup.tar.gz", "wb") as f:
    f.write(binary_data)
```

**💡 Pro Tip**: Use `a` (append) for logs, `w` (write) for state files, `r` (read) for configs.

---

## 🌊 Part 3: Streaming Large Files

### 🧠 The Mental Model: The Page-by-Page Reader

**The Problem**: Loading a 10GB log file into memory causes out-of-memory errors.

**The Solution**: Stream the file line-by-line, processing one line at a time.

### 🔧 Memory-Efficient File Reading

```python
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ❌ WRONG: Loading entire file into memory
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("huge_log.txt", "r") as f:
    lines = f.readlines()  # ❌ Loads entire file into RAM
    for line in lines:
        if "ERROR" in line:
            print(line)

# Problem: 10GB file = 10GB RAM usage = OOM crash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ✅ RIGHT: Streaming line-by-line
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("huge_log.txt", "r") as f:
    for line in f:  # ✅ Reads one line at a time
        if "ERROR" in line:
            print(line.strip())

# Benefit: Constant memory usage, regardless of file size
```

### 🚀 Professional Pattern: Log Parser

```python
from typing import Dict, List
from datetime import datetime

def parse_nginx_logs(log_file: str) -> Dict[str, int]:
    """
    Parse Nginx access logs and count status codes.
    
    Args:
        log_file: Path to Nginx access log
    
    Returns:
        Dictionary mapping status codes to counts
    
    Example:
        >>> counts = parse_nginx_logs("/var/log/nginx/access.log")
        >>> print(f"200 OK: {counts.get('200', 0)}")
    """
    status_counts: Dict[str, int] = {}
    error_lines: List[str] = []
    
    try:
        with open(log_file, "r") as f:
            for line_num, line in enumerate(f, start=1):
                try:
                    # Parse status code (simplified - real parsing would use regex)
                    parts = line.split()
                    if len(parts) >= 9:
                        status_code = parts[8]
                        status_counts[status_code] = status_counts.get(status_code, 0) + 1
                    
                except (IndexError, ValueError) as e:
                    error_lines.append(f"Line {line_num}: {str(e)}")
        
        # Report results
        print(f"✅ Parsed {sum(status_counts.values())} log entries")
        for status, count in sorted(status_counts.items()):
            print(f"  Status {status}: {count}")
        
        if error_lines:
            print(f"⚠️ {len(error_lines)} lines had parsing errors")
        
        return status_counts
    
    except FileNotFoundError:
        print(f"❌ Log file not found: {log_file}")
        return {}
    
    except PermissionError:
        print(f"❌ Permission denied: {log_file}")
        return {}


# 🎯 Usage
counts = parse_nginx_logs("/var/log/nginx/access.log")
```

**💡 Pro Tip**: Always stream large files. Use `for line in file:` instead of `.readlines()`.

---

## 📝 Part 4: Writing Files Safely

### 🧠 The Mental Model: The Atomic Write

**The Problem**: If a script crashes while writing, you get a corrupted file.

**The Solution**: Write to a temporary file, then rename it (atomic operation).

### 🔧 Basic Writing

```python
import json
from typing import Dict, Any

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Writing text files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("deployment.log", "w") as f:
    f.write("Deployment started\n")
    f.write("Deploying to production\n")
    f.write("Deployment completed\n")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Writing JSON files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

state: Dict[str, Any] = {
    "deployment_id": "deploy-12345",
    "status": "completed",
    "servers": ["web-01", "web-02", "web-03"],
    "timestamp": "2026-01-31T21:00:00Z"
}

with open("deployment_state.json", "w") as f:
    json.dump(state, f, indent=2)  # indent=2 for readability

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Appending to log files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import datetime

with open("audit.log", "a") as f:
    timestamp = datetime.datetime.now().isoformat()
    f.write(f"[{timestamp}] User deployed to production\n")
```

### 🚀 Professional Pattern: Atomic Write

```python
import os
import json
import tempfile
from typing import Dict, Any

def atomic_write_json(filepath: str, data: Dict[str, Any]) -> None:
    """
    Write JSON file atomically to prevent corruption.
    
    Args:
        filepath: Path to write to
        data: Data to write
    
    Example:
        >>> atomic_write_json("state.json", {"status": "deployed"})
    """
    # Get directory and filename
    directory = os.path.dirname(filepath) or "."
    
    # Create temporary file in same directory
    fd, temp_path = tempfile.mkstemp(
        dir=directory,
        prefix=".tmp_",
        suffix=".json"
    )
    
    try:
        # Write to temporary file
        with os.fdopen(fd, 'w') as f:
            json.dump(data, f, indent=2)
        
        # Atomic rename (replaces old file)
        os.replace(temp_path, filepath)
        
        print(f"✅ Successfully wrote {filepath}")
    
    except Exception as e:
        # Clean up temp file on error
        if os.path.exists(temp_path):
            os.remove(temp_path)
        raise e


# 🎯 Usage
state = {
    "deployment_id": "deploy-12345",
    "status": "completed",
    "timestamp": "2026-01-31T21:00:00Z"
}

atomic_write_json("deployment_state.json", state)
```

**💡 Pro Tip**: Use atomic writes for critical state files. Prevents corruption if script crashes.

---

## 📊 Part 5: Working with JSON and YAML

### 🧠 The Mental Model: The Format Converter

**The Use Case**: Read configs in one format, write in another.

### 🔧 JSON and YAML Operations

```python
import json
import yaml
from typing import Dict, Any, List

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Reading JSON
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("config.json", "r") as f:
    config: Dict[str, Any] = json.load(f)

print(f"Environment: {config.get('environment')}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Writing JSON
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

data = {
    "servers": ["web-01", "web-02"],
    "region": "us-east-1",
    "replicas": 3
}

with open("output.json", "w") as f:
    json.dump(data, f, indent=2)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Reading YAML
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

with open("deployment.yaml", "r") as f:
    deployment: Dict[str, Any] = yaml.safe_load(f)

print(f"Deployment name: {deployment.get('metadata', {}).get('name')}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Writing YAML
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

config = {
    "apiVersion": "v1",
    "kind": "ConfigMap",
    "metadata": {"name": "app-config"},
    "data": {"environment": "production"}
}

with open("configmap.yaml", "w") as f:
    yaml.dump(config, f, default_flow_style=False)
```

### 🚀 Professional Pattern: Config Normalizer

```python
import json
import yaml
from typing import List, Dict, Any

def normalize_inventory(
    input_file: str,
    output_file: str,
    filter_env: str = "production"
) -> None:
    """
    Read JSON inventory, filter by environment, write as YAML.
    
    Args:
        input_file: Input JSON file path
        output_file: Output YAML file path
        filter_env: Environment to filter for
    
    Example:
        >>> normalize_inventory("cloud.json", "inventory.yaml", "production")
    """
    try:
        # Read JSON input
        with open(input_file, "r") as f:
            raw_data: List[Dict[str, Any]] = json.load(f)
        
        # Filter for specified environment
        filtered_nodes = [
            node for node in raw_data
            if node.get("environment") == filter_env
        ]
        
        # Write YAML output
        with open(output_file, "w") as f:
            yaml.dump(filtered_nodes, f, default_flow_style=False)
        
        print(f"✅ Normalized {len(filtered_nodes)} {filter_env} nodes")
        print(f"   Input: {input_file}")
        print(f"   Output: {output_file}")
    
    except FileNotFoundError as e:
        print(f"❌ File not found: {e.filename}")
    
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON in {input_file}: {e}")
    
    except yaml.YAMLError as e:
        print(f"❌ YAML error: {e}")


# 🎯 Usage
normalize_inventory("cloud_discovery.json", "production_inventory.yaml")
```

**💡 Pro Tip**: Always use `yaml.safe_load()` instead of `yaml.load()` to prevent code execution.

---

## 🛡️ Part 6: Error Handling

### 🧠 The Mental Model: The Safety Net

**The Reality**: Files might not exist, permissions might be denied, disk might be full.

**The Solution**: Handle errors gracefully with try/except.

### 🔧 Common File Errors

```python
from typing import Optional

def safe_read_file(filepath: str) -> Optional[str]:
    """
    Safely read a file with comprehensive error handling.
    
    Args:
        filepath: Path to file
    
    Returns:
        File contents or None if error
    """
    try:
        with open(filepath, "r") as f:
            return f.read()
    
    except FileNotFoundError:
        print(f"❌ File not found: {filepath}")
        return None
    
    except PermissionError:
        print(f"❌ Permission denied: {filepath}")
        return None
    
    except IsADirectoryError:
        print(f"❌ Path is a directory, not a file: {filepath}")
        return None
    
    except UnicodeDecodeError:
        print(f"❌ File is not valid text (try binary mode): {filepath}")
        return None
    
    except Exception as e:
        print(f"❌ Unexpected error reading {filepath}: {e}")
        return None


# 🎯 Usage
content = safe_read_file("config.yaml")
if content:
    print("File read successfully")
else:
    print("Failed to read file")
```

**💡 Pro Tip**: Always handle `FileNotFoundError` and `PermissionError` at minimum.

---

## 🏆 Part 7: Real-World DevOps Story

### 📖 The Migration that Overwhelmed the RAM

**The Scenario**: A migration script needed to read a 12GB CSV of server metrics and calculate average uptime.

**The Code**:
```python
# ❌ The disaster
with open("metrics.csv", "r") as f:
    lines = f.readlines()  # Loads entire 12GB into RAM
    
# Process lines...
```

**The Problem**: The engineer used `.readlines()`, which loaded the entire 12GB file into the server's 8GB RAM. The OOM (Out of Memory) Killer terminated the script, corrupting the partial state file.

**The Solution**:
```python
# ✅ The fix
total_uptime = 0
count = 0

with open("metrics.csv", "r") as f:
    next(f)  # Skip header
    
    for line in f:  # Stream line-by-line
        parts = line.strip().split(",")
        uptime = float(parts[2])
        total_uptime += uptime
        count += 1

average_uptime = total_uptime / count if count > 0 else 0
print(f"Average uptime: {average_uptime:.2f}%")
```

**The Outcome**: Script completed in 2 minutes using only 50MB of RAM.

**The Lesson**: **Always stream large files**. Never use `.read()` or `.readlines()` on files of unknown size.

---

## ❓ Interview Preparation

### 🎯 Core Concepts

1. **Q: Why use context managers (`with`) for file operations?**
   - **A**: Context managers automatically close files, even if an exception occurs. This prevents resource leaks and file locks. It's the Pythonic way to handle files.

2. **Q: What's the difference between `w` and `a` modes?**
   - **A**: `w` (write) overwrites the entire file. `a` (append) adds to the end of the existing file. Use `a` for logs, `w` for state files.

3. **Q: How do you handle a file that might not exist?**
   - **A**: Wrap the operation in `try/except FileNotFoundError:`. This is the EAFP (Easier to Ask Forgiveness than Permission) approach preferred in Python.

4. **Q: Why use `yaml.safe_load()` instead of `yaml.load()`?**
   - **A**: `yaml.load()` can execute arbitrary Python code if the YAML is malicious. `safe_load()` restricts parsing to standard data types, making it the security standard.

5. **Q: How do you read a 100GB log file without running out of memory?**
   - **A**: Stream it line-by-line using `for line in file:`. This reads one line at a time, keeping memory usage constant regardless of file size.

### 🚀 Advanced Questions

6. **Q: What is an atomic write and why is it important?**
   - **A**: An atomic write writes to a temporary file, then renames it. The rename operation is atomic (all-or-nothing), preventing corruption if the script crashes mid-write.

7. **Q: What's the difference between text mode and binary mode?**
   - **A**: Text mode (`r`, `w`) handles encoding/decoding (UTF-8). Binary mode (`rb`, `wb`) reads/writes raw bytes. Use binary for images, archives, etc.

8. **Q: How do you handle different line endings (Windows vs Unix)?**
   - **A**: Python's text mode automatically handles `\r\n` (Windows) and `\n` (Unix). Use `open(file, newline='')` to preserve original line endings.

9. **Q: Why use `json.dump(indent=2)`?**
   - **A**: While machines don't care about whitespace, humans do. Indentation makes state files readable in terminals and easier to debug.

10. **Q: How do you safely delete a file?**
    - **A**: Use `os.remove(filepath)` wrapped in `try/except FileNotFoundError:` to handle the case where the file doesn't exist.

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **What happens if you open a file in 'w' mode that already exists?**
   - [ ] a) It appends to the end
   - [x] b) It deletes the old content and starts fresh
   - [ ] c) It raises FileExistsError
   - [ ] d) It creates a backup

2. **Which method is safest for reading a 20GB log file?**
   - [ ] a) `file.read()`
   - [ ] b) `file.readlines()`
   - [x] c) `for line in file:` (streaming)
   - [ ] d) `file.load()`

3. **In `with open(...) as f:`, what is `f`?**
   - [ ] a) The content of the file
   - [x] b) A file object (stream handler)
   - [ ] c) The file path
   - [ ] d) The file size

4. **True or False: Python can natively parse JSON without external libraries.**
   - [x] a) True (using `import json`)
   - [ ] b) False

### 🚀 Intermediate Level

5. **Which library is the standard for parsing YAML in Python?**
   - [ ] a) py-yaml
   - [x] b) PyYAML
   - [ ] c) yaml-parser
   - [ ] d) python-yaml

6. **What does `json.dump(data, f, indent=2)` do?**
   - [ ] a) Indents the file by 2 spaces
   - [x] b) Formats JSON with 2-space indentation for readability
   - [ ] c) Compresses the JSON
   - [ ] d) Validates the JSON

7. **Which mode should you use to append to a log file?**
   - [ ] a) `r`
   - [ ] b) `w`
   - [x] c) `a`
   - [ ] d) `r+`

8. **What error occurs if you try to open a non-existent file in read mode?**
   - [x] a) FileNotFoundError
   - [ ] b) IOError
   - [ ] c) ValueError
   - [ ] d) PermissionError

### 🏆 Advanced Level

9. **Why is atomic write important for state files?**
   - [ ] a) It's faster
   - [x] b) It prevents corruption if script crashes mid-write
   - [ ] c) It compresses the file
   - [ ] d) It validates the data

10. **What's the difference between `rb` and `r` mode?**
    - [ ] a) `rb` is faster
    - [x] b) `rb` reads raw bytes, `r` decodes to text
    - [ ] c) `rb` is for large files
    - [ ] d) No difference

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Files = Filing Cabinet**: Persistent storage for data
2. **Context Manager = Auto-Closer**: Always closes files
3. **Streaming = Page-by-Page**: Constant memory usage
4. **Atomic Write = Safety Net**: Prevents corruption

### 🛡️ Safety Patterns

1. **Always use `with`** for file operations
2. **Stream large files** line-by-line
3. **Handle FileNotFoundError** and PermissionError
4. **Use `yaml.safe_load()`** not `yaml.load()`
5. **Use atomic writes** for critical state files

### 🚀 Production Rules

1. **Use `a` mode** for logs (append)
2. **Use `w` mode** for state files (overwrite)
3. **Use `r` mode** for reading configs
4. **Stream files** of unknown size
5. **Add `indent=2`** to JSON for readability

---

## 🔗 Next Steps

Now that you can persist data to files, you're ready to learn about modularizing your code with functions.

**Proceed to**: [Functions and Modules →](../07-Functions-and-Modules/README.md)

---

## 📚 Additional Resources

- [Python File I/O Documentation](https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files)
- [Context Managers](https://docs.python.org/3/reference/compound_stmts.html#with)
- [JSON Module](https://docs.python.org/3/library/json.html)
- [PyYAML Documentation](https://pyyaml.org/wiki/PyYAMLDocumentation)
- [Atomic File Writes](https://stackoverflow.com/questions/2333872/how-to-make-file-creation-an-atomic-operation)

---

**🎓 Remember**: A newbie uses `.read()` and hopes for the best. An engineer uses context managers and streams large files. A senior engineer uses atomic writes and comprehensive error handling. Master file I/O, and you master data persistence.

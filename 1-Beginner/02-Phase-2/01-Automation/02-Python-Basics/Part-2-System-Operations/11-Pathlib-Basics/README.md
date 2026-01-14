# Pathlib Basics
*Modern Cross-Platform Path Handling*

Pathlib provides an object-oriented approach to file system paths, making code more readable and cross-platform compatible than the traditional `os.path` module. For DevOps automation, pathlib ensures your scripts work seamlessly across Windows, Linux, and macOS.

---

## 🎯 Learning Objectives

- Use Path objects for all file and directory operations
- Navigate directories programmatically with intuitive syntax
- Write cross-platform automation scripts that work everywhere
- Perform file operations (read, write, copy, delete) with pathlib
- Use glob patterns to find files matching specific criteria

---

## 📊 Pathlib vs os.path Comparison

```mermaid
flowchart LR
    subgraph os.path["os.path (Old Way)"]
        A1["os.path.join()"]
        A2["os.path.exists()"]
        A3["os.path.dirname()"]
        A4["open() + read()"]
    end
    
    subgraph pathlib["pathlib (Modern Way)"]
        B1["Path() / 'subdir'"]
        B2["path.exists()"]
        B3["path.parent"]
        B4["path.read_text()"]
    end
    
    style pathlib fill:#306998,stroke:#ffe873,color:#fff
    style os.path fill:#666,stroke:#444,color:#fff
```

| Operation | os.path (Old) | pathlib (Modern) |
|-----------|---------------|------------------|
| Join paths | `os.path.join(a, b, c)` | `Path(a) / b / c` |
| Check exists | `os.path.exists(p)` | `path.exists()` |
| Get filename | `os.path.basename(p)` | `path.name` |
| Get extension | `os.path.splitext(p)[1]` | `path.suffix` |
| Get parent | `os.path.dirname(p)` | `path.parent` |
| Read file | `open(p).read()` | `path.read_text()` |
| List directory | `os.listdir(p)` | `path.iterdir()` |

---

## 📊 Path Object Anatomy

```mermaid
flowchart LR
    subgraph "Path: /var/log/nginx/access.log"
        A["Path"] --> B["parts: ('/', 'var', 'log', 'nginx', 'access.log')"]
        A --> C["parent: /var/log/nginx"]
        A --> D["name: access.log"]
        A --> E["stem: access"]
        A --> F["suffix: .log"]
        A --> G["anchor: /"]
    end
    
    style A fill:#306998,stroke:#ffe873,color:#fff
```

---

## 📚 Core Concepts

### 1. Creating Path Objects

```python
from pathlib import Path

# Current and home directories
current = Path.cwd()         # /home/user/project
home = Path.home()           # /home/user

# From string
log_path = Path("/var/log/syslog")
config = Path("./config/app.yaml")

# Build paths with / operator (MUCH cleaner than os.path.join!)
config_file = Path("/etc") / "nginx" / "nginx.conf"
log_file = home / "logs" / "app.log"
backup = Path.home() / "backups" / "2026" / "01" / "data.tar.gz"

# Windows paths work too (automatically handled)
win_path = Path("C:/Users/admin/Documents")
```

### 2. Path Properties and Components

```python
from pathlib import Path

path = Path("/var/log/nginx/access.log")

# Components
path.name          # "access.log" - filename with extension
path.stem          # "access" - filename without extension
path.suffix        # ".log" - file extension
path.suffixes      # [".log"] - all extensions (useful for .tar.gz)
path.parent        # Path("/var/log/nginx")
path.parents       # [Path("/var/log/nginx"), Path("/var/log"), ...]
path.parts         # ("/", "var", "log", "nginx", "access.log")
path.anchor        # "/" on Unix, "C:\\" on Windows

# Type checks
path.exists()      # True/False
path.is_file()     # True if file exists
path.is_dir()      # True if directory exists
path.is_absolute() # True if absolute path
path.is_symlink()  # True if symbolic link

# Path manipulation
path.with_suffix(".bak")    # Path("/var/log/nginx/access.bak")
path.with_name("error.log") # Path("/var/log/nginx/error.log")
path.with_stem("errors")    # Path("/var/log/nginx/errors.log")
```

### 3. File Operations

```python
from pathlib import Path

# Reading files
content = Path("config.txt").read_text()          # String
binary = Path("image.png").read_bytes()           # Bytes

# Writing files
Path("output.txt").write_text("Hello World")
Path("data.bin").write_bytes(b"\x00\x01\x02")

# File statistics
stats = Path("app.log").stat()
print(f"Size: {stats.st_size} bytes")
print(f"Modified: {stats.st_mtime}")  # Unix timestamp

# Create directories
Path("logs/app/debug").mkdir(parents=True, exist_ok=True)
# parents=True: Create parent directories if needed
# exist_ok=True: Don't error if already exists

# Delete files/directories
Path("temp.txt").unlink()                # Delete file
Path("temp.txt").unlink(missing_ok=True) # No error if missing
Path("empty_dir").rmdir()                # Delete empty directory

# Rename/Move
Path("old.txt").rename("new.txt")
Path("file.txt").replace("target.txt")   # Overwrites if exists
```

### 4. Directory Navigation and Iteration

```python
from pathlib import Path

project = Path("/home/user/project")

# List immediate children
for item in project.iterdir():
    if item.is_file():
        print(f"File: {item.name}")
    elif item.is_dir():
        print(f"Dir: {item.name}")

# Glob patterns - find matching files
# Single directory
for py_file in project.glob("*.py"):
    print(py_file)

# Recursive (all subdirectories)
for config in project.glob("**/*.yaml"):
    print(f"Found config: {config}")

# Multiple extensions
for doc in project.glob("**/*.md"):
    print(doc)
```

### 5. Common Glob Patterns

| Pattern | Matches |
|---------|---------|
| `*.py` | Python files in current directory |
| `**/*.py` | Python files in all subdirectories |
| `*.{yaml,yml}` | YAML files (both extensions) |
| `test_*.py` | Test files |
| `**/config*` | Any file starting with "config" anywhere |
| `data[0-9].json` | data0.json through data9.json |

### 6. Cross-Platform Safety

```python
from pathlib import Path

# BAD - hardcoded separator won't work on Windows
path = "/var/log" + "/" + "app.log"  # ❌

# GOOD - pathlib handles separators automatically
path = Path("/var/log") / "app.log"  # ✅

# Resolve to absolute path
relative = Path("./config/app.yaml")
absolute = relative.resolve()  # Full absolute path

# Convert to string when needed (for APIs that require strings)
path = Path("/var/log/app.log")
path_str = str(path)  # "/var/log/app.log"

# For Windows compatibility
path.as_posix()       # Forward slashes: "C:/Users/admin"
path.as_uri()         # file:///C:/Users/admin
```

---

## 🛠️ Hands-On Challenges

### Challenge 1: Log File Cleanup

```python
from pathlib import Path

def cleanup_logs(log_dir, days_old=7):
    """Delete log files older than N days.
    
    TODO: Implement this function to:
    1. Find all .log files in the directory
    2. Check each file's modification time
    3. Delete files older than days_old
    4. Return count of deleted files
    """
    pass

# Test
deleted = cleanup_logs("/var/log/myapp", days_old=30)
print(f"Deleted {deleted} old log files")
```

<details>
<summary>💡 Solution</summary>

```python
from pathlib import Path
from datetime import datetime, timedelta

def cleanup_logs(log_dir, days_old=7):
    """Delete log files older than N days."""
    log_path = Path(log_dir)
    
    if not log_path.exists():
        print(f"Directory not found: {log_dir}")
        return 0
    
    cutoff_time = datetime.now() - timedelta(days=days_old)
    cutoff_timestamp = cutoff_time.timestamp()
    
    deleted_count = 0
    
    for log_file in log_path.glob("*.log"):
        file_mtime = log_file.stat().st_mtime
        
        if file_mtime < cutoff_timestamp:
            file_age_days = (datetime.now().timestamp() - file_mtime) / 86400
            print(f"Deleting: {log_file.name} (age: {file_age_days:.1f} days)")
            log_file.unlink()
            deleted_count += 1
    
    return deleted_count

# Test
deleted = cleanup_logs("./test_logs", days_old=7)
print(f"\n✅ Deleted {deleted} old log files")
```
</details>

### Challenge 2: Project File Analyzer

```python
from pathlib import Path

def analyze_project(project_dir):
    """Analyze a project directory structure.
    
    TODO: Return statistics including:
    - Total files and directories
    - Files by extension (count and total size)
    - Largest files (top 5)
    - Empty directories
    """
    pass
```

<details>
<summary>💡 Solution</summary>

```python
from pathlib import Path
from collections import defaultdict

def analyze_project(project_dir):
    """Analyze a project directory structure."""
    root = Path(project_dir)
    
    if not root.exists():
        return {"error": f"Directory not found: {project_dir}"}
    
    stats = {
        "total_files": 0,
        "total_dirs": 0,
        "total_size": 0,
        "by_extension": defaultdict(lambda: {"count": 0, "size": 0}),
        "largest_files": [],
        "empty_dirs": []
    }
    
    all_files = []
    
    for item in root.rglob("*"):
        if item.is_file():
            stats["total_files"] += 1
            size = item.stat().st_size
            stats["total_size"] += size
            
            ext = item.suffix.lower() or "(no extension)"
            stats["by_extension"][ext]["count"] += 1
            stats["by_extension"][ext]["size"] += size
            
            all_files.append((item, size))
        
        elif item.is_dir():
            stats["total_dirs"] += 1
            # Check if empty
            if not any(item.iterdir()):
                stats["empty_dirs"].append(str(item))
    
    # Top 5 largest files
    all_files.sort(key=lambda x: x[1], reverse=True)
    stats["largest_files"] = [
        {"path": str(f[0]), "size_mb": f[1] / (1024*1024)}
        for f in all_files[:5]
    ]
    
    # Convert defaultdict to regular dict
    stats["by_extension"] = dict(stats["by_extension"])
    
    return stats

# Test
stats = analyze_project(".")
print(f"📁 Total files: {stats['total_files']}")
print(f"📂 Total directories: {stats['total_dirs']}")
print(f"💾 Total size: {stats['total_size'] / (1024*1024):.2f} MB")
print(f"\n📊 Files by extension:")
for ext, data in stats["by_extension"].items():
    print(f"  {ext}: {data['count']} files, {data['size']/1024:.1f} KB")
```
</details>

### Challenge 3: Safe File Backup

```python
from pathlib import Path

def backup_file(source, backup_dir=None, max_backups=5):
    """Create a timestamped backup of a file.
    
    TODO: Implement this function to:
    1. Create backup with timestamp in name
    2. Store in backup_dir (or same directory)
    3. Keep only max_backups most recent
    4. Return path to new backup
    """
    pass
```

<details>
<summary>💡 Solution</summary>

```python
from pathlib import Path
from datetime import datetime
import shutil

def backup_file(source, backup_dir=None, max_backups=5):
    """Create a timestamped backup of a file."""
    source_path = Path(source)
    
    if not source_path.exists():
        raise FileNotFoundError(f"Source file not found: {source}")
    
    # Determine backup directory
    if backup_dir:
        backup_path = Path(backup_dir)
        backup_path.mkdir(parents=True, exist_ok=True)
    else:
        backup_path = source_path.parent
    
    # Create backup filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"{source_path.stem}_{timestamp}{source_path.suffix}"
    new_backup = backup_path / backup_name
    
    # Copy file
    shutil.copy2(source_path, new_backup)
    print(f"✅ Created backup: {new_backup}")
    
    # Cleanup old backups
    pattern = f"{source_path.stem}_*{source_path.suffix}"
    existing_backups = sorted(
        backup_path.glob(pattern),
        key=lambda p: p.stat().st_mtime,
        reverse=True
    )
    
    # Remove old backups beyond max_backups
    for old_backup in existing_backups[max_backups:]:
        print(f"🗑️ Removing old backup: {old_backup.name}")
        old_backup.unlink()
    
    return new_backup

# Test
backup_path = backup_file("config.yaml", backup_dir="./backups", max_backups=3)
```
</details>

### Challenge 4: Directory Synchronizer

```python
from pathlib import Path

def sync_directories(source, destination, dry_run=True):
    """Sync files from source to destination.
    
    TODO: Implement to:
    1. Copy new files from source to destination
    2. Update modified files (compare timestamps)
    3. Optionally remove files in dest not in source
    4. Support dry_run mode (show what would happen)
    """
    pass
```

<details>
<summary>💡 Solution</summary>

```python
from pathlib import Path
import shutil

def sync_directories(source, destination, dry_run=True, delete=False):
    """Sync files from source to destination."""
    src = Path(source)
    dst = Path(destination)
    
    if not src.exists():
        raise FileNotFoundError(f"Source not found: {source}")
    
    actions = {"copy": [], "update": [], "delete": [], "skip": []}
    
    # Create destination if needed
    if not dry_run:
        dst.mkdir(parents=True, exist_ok=True)
    
    # Process source files
    for src_file in src.rglob("*"):
        if src_file.is_file():
            # Calculate relative path
            rel_path = src_file.relative_to(src)
            dst_file = dst / rel_path
            
            if not dst_file.exists():
                actions["copy"].append(rel_path)
                if not dry_run:
                    dst_file.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src_file, dst_file)
            
            elif src_file.stat().st_mtime > dst_file.stat().st_mtime:
                actions["update"].append(rel_path)
                if not dry_run:
                    shutil.copy2(src_file, dst_file)
            
            else:
                actions["skip"].append(rel_path)
    
    # Check for files to delete (in dest but not in source)
    if delete and dst.exists():
        for dst_file in dst.rglob("*"):
            if dst_file.is_file():
                rel_path = dst_file.relative_to(dst)
                src_file = src / rel_path
                
                if not src_file.exists():
                    actions["delete"].append(rel_path)
                    if not dry_run:
                        dst_file.unlink()
    
    # Report
    print(f"\n{'[DRY RUN] ' if dry_run else ''}Sync Summary:")
    print(f"  📥 Copy: {len(actions['copy'])} files")
    print(f"  🔄 Update: {len(actions['update'])} files")
    print(f"  🗑️ Delete: {len(actions['delete'])} files")
    print(f"  ⏭️ Skip: {len(actions['skip'])} files (unchanged)")
    
    return actions

# Test
sync_directories("./source", "./backup", dry_run=True)
```
</details>

---

## 📖 Real-World Story: The Path Separator Bug

**Scenario**: A deployment script worked perfectly on the team's Mac laptops but crashed in production (Linux) and on the Windows CI server.

**Problem**: The script used hardcoded path separators:

```python
# ❌ Bug-prone code
config_path = project_dir + "\\" + "config" + "\\" + "app.yaml"
```

**Solution**: Refactored to use pathlib:

```python
from pathlib import Path

# ✅ Cross-platform code
config_path = Path(project_dir) / "config" / "app.yaml"
```

**Outcome**: The script now works on all platforms without modification's. The team adopted pathlib as their standard for all file operations.

---

## ❓ Interview Questions

1. **Why is pathlib preferred over os.path for new code?**
   > Pathlib provides an object-oriented interface that's more readable (using `/` operator for joining), has methods for common operations (read_text, write_text), and handles cross-platform path separators automatically.

2. **How do you find all Python files in a project recursively?**
   > Use `Path(".").rglob("*.py")` or `Path(".").glob("**/*.py")`. The `rglob` method is shorthand for recursive globbing, equivalent to prefixing the pattern with `**/`.

3. **What's the difference between `path.name`, `path.stem`, and `path.suffix`?**
   > For `/var/log/access.log`: `name` returns "access.log" (full filename), `stem` returns "access" (without extension), and `suffix` returns ".log" (the extension with dot).

4. **How do you safely create nested directories?**
   > Use `Path("a/b/c").mkdir(parents=True, exist_ok=True)`. `parents=True` creates parent directories if they don't exist, and `exist_ok=True` prevents errors if the directory already exists.

5. **How do you make pathlib code work with libraries expecting string paths?**
   > Use `str(path)` to convert a Path object to a string. Many modern libraries (like open()) accept Path objects directly due to the os.fspath() protocol.

6. **What's the difference between resolve() and absolute()?**
   > `resolve()` returns the absolute path AND resolves symlinks and normalizes the path (removes `..`). `absolute()` only makes the path absolute without resolving symlinks or normalizing. `resolve()` is generally preferred.

---

## 🧠 Quiz

1. How do you join paths with Pathlib?
   - a) `path.join("sub")`
   - b) `path / "sub"` ✅
   - c) `path + "sub"`
   - d) `path.append("sub")`

2. What does `Path("file.txt").stem` return?
   - a) "file.txt"
   - b) "file" ✅
   - c) ".txt"
   - d) Path("file")

3. How do you find all `.yaml` files recursively?
   - a) `path.glob("*.yaml")`
   - b) `path.glob("**/*.yaml")` ✅
   - c) `path.find("*.yaml")`
   - d) `path.search("*.yaml")`

4. What does `mkdir(parents=True)` do?
   - a) Creates only the final directory
   - b) Creates all parent directories if needed ✅
   - c) Requires parent to exist
   - d) Creates a copy of parent

5. How do you read a text file with pathlib?
   - a) `path.read()`
   - b) `path.read_text()` ✅
   - c) `path.load()`
   - d) `path.get_content()`

6. What does `path.resolve()` return?
   - a) Relative path
   - b) Normalized absolute path ✅
   - c) Parent directory
   - d) File contents

7. Which attribute gives the file extension?
   - a) `path.ext`
   - b) `path.extension`
   - c) `path.suffix` ✅
   - d) `path.type`

8. How do you check if a path is a directory?
   - a) `path.isdir()`
   - b) `path.is_dir()` ✅
   - c) `path.directory`
   - d) `path.type == 'dir'`

---

## 🔗 Related Topics

| Module | Relationship |
|--------|-------------|
| [File Operations](../04-File-Operations/README.md) | Pathlib is the modern approach to file handling |
| [Subprocess Module](../10-Subprocess-Module/README.md) | Pass pathlib paths as command arguments |
| [Working with JSON](../06-Working-with-JSON/README.md) | Read/write JSON files with pathlib |

---

**Next Step**: [Datetime Operations →](../12-Datetime-Operations/README.md)

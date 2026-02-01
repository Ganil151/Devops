# 📂 Pathlib: Modern Cross-Platform Navigation

> **"If os.path is the 'Old Manual Gearbox' of file systems, Pathlib is the 'Automatic Transmission.' It turns complex path logic into readable, object-oriented code that works seamlessly on every OS."**

![Pathlib vs os.path](../../assets/pathlib_architecture.png)

---

## 🧠 The Mental Model: Paths as Objects

**The Junior Struggle**: "I'm juggling `os.path.join`, `os.path.exists`, and manual string slicing to get filenames. It breaks on Windows because of backslashes!"

**The Engineer Solution**: Stop treating paths as **strings**. Treat them as **Objects** that know how to navigate themselves.

### 🏗️ The Infrastructure Analogy

Think of Pathlib as **GPS Navigation** vs. Paper Maps (`os.path`):

| Feature | Paper Map (`os.path`) | GPS Navigation (`pathlib`) |
|:--------|:----------------------|:---------------------------|
| **Navigation** | `os.path.join(a, b)` (Manual calculation) | `a / b` (Slash operator) |
| **Location** | `os.getcwd()` | `Path.cwd()` |
| **Properties** | `filename.split('.')[0]` (String math) | `path.stem`, `path.suffix` |
| **Search** | `glob.glob('*.py')` (Separate tool) | `path.glob('*.py')` (Built-in) |
| **Reading** | `open(p).read()` (context manager) | `path.read_text()` (One-liner) |

**The Key Insight**: Pathlib handles the Operating System differences (Windows `\` vs Linux `/`) automatically. You just write `folder / file` and it works everywhere.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll just type strings like `'C:\Users\Name'`"
- "I have to import `os`, `glob`, and `shutil` separately"
- "Cross-platform code is hard"

**After this module**, you'll understand:
- **Universal Operator**: The `/` operator works on all OSs.
- **Object Power**: Paths have methods (`.exists()`, `.mkdir()`, `.touch()`).
- **Recursive Globbing**: Finding files deep in nested folders is easy.
- **Safety**: No more silent errors from missing slashes.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master the Slash Operator**: Join paths elegantly (`path / "subdir"`)
- ✅ **Manipulate Metadata**: Get stems, suffixes, and parents
- ✅ **Perform Recursive Search**: Use `rglob` to find files anywhere
- ✅ **Read/Write Quickly**: Use `.read_text()` and `.write_text()`
- ✅ **Ensure Cross-Platform paths**: Write once, run on Windows/Linux

---

## 🏗️ Part 1: The Slash Operator

### 🧠 The Mental Model: The Universal Joint

**The Innovation**: Python overrides the division operator (`/`) to mean "Join Path".

### 🔧 Basic Navigation

```python
from pathlib import Path

# 1. Get Current Directory
cwd = Path.cwd()

# 2. Get Home Directory (Works on Win/Linux/Mac)
home = Path.home()

# 3. Join Paths (The Magic)
# Windows: C:\Users\Alice\logs\app.log
# Linux:   /home/alice/logs/app.log
log_path = home / "logs" / "app.log"

print(f"Target: {log_path}")
```

**Why it matters**: You never have to type a backslash (`\`) or forward slash (`/`) again. Python detects the OS and inserts the correct separator.

---

## 🔍 Part 2: Path Anatomy & Metadata

### 🧠 The Mental Model: Smart Objects

**The Shift**: We don't slice strings anymore. We ask the object for its properties.

### 🔧 Extracting Info

```python
from pathlib import Path

# Example: /var/log/nginx/access.tar.gz
p = Path("/var/log/nginx/access.tar.gz")

print(p.name)      # "access.tar.gz" (Full name)
print(p.stem)      # "access.tar"    (Name without LAST specific extension)
                   # Note: For multi-extensions properly, you might handle .tar.gz differently
print(p.suffix)    # ".gz"           (The last extension)
print(p.parent)    # "/var/log/nginx" (The folder)
print(p.parts)     # ('/', 'var', 'log', 'nginx', 'access.tar.gz')
```

### 🔨 Common File Ops
Pathlib objects have built-in methods to interact with the filesystem.

```python
config = Path("config.yaml")

# Check existence
if not config.exists():
    # Create empty file
    config.touch()

# Rename (Move)
config.rename("config.yaml.bak")

# Delete (Unlink)
# config.unlink()
```

---

## 🌪️ Part 3: Globbing (Search)

### 🧠 The Mental Model: The Dragnet

**The Use Case**: Find all `.log` files, no matter how deep they are nested.

### 🔧 Recursive Globbing

```python
project_dir = Path("/var/www/html")

# 1. Simple Glob (Current folder only)
# Equivalent to `ls *.jpg`
images = list(project_dir.glob("*.jpg"))

# 2. Recursive Glob (The Powerhouse)
# Finds files in /var/www/html/images/2023/01/profile/...
# "**" means "any number of subdirectories"
all_configs = list(project_dir.rglob("*.conf")) 

# 3. Iterating quickly
for log_file in project_dir.rglob("*.log"):
    if log_file.stat().st_size > 10 * 1024 * 1024:
        print(f"🚨 Large Log Found: {log_file.name}")
```

---

## ⚡ Part 4: Quick Read/Write

### 🧠 The Mental Model: Convenience Methods

**The Use Case**: You just want to read a small config file or write a PID file. Opening a context manager feels like overkill.

### 🔧 One-Liners

```python
token_file = Path(".secret_token")

# Write text (Opens, writes, closes automatically)
token_file.write_text("abc-123-xyz")

# Read text (Opens, reads, closes automatically)
content = token_file.read_text().strip()
```

**Warning**: Only use these for small files that fit in RAM. For 10GB logs, strictly use the standard `with open(...)` or `.open()` context manager.

---

## 🏆 Real-World DevOps Story: The Migration Nightmare

**The Scenario**: A retail company migrated their automation from legacy Windows Servers to Linux Containers (Kubernetes). They had 200+ Python scripts.

**The Problem**: The scripts were full of hardcoded Windows paths:
`report_path = "C:\\Reports\\" + date + "\\data.csv"`

**The Failure**: When run in Linux containers, these scripts crashed instantly because `C:\` means nothing on Linux, and backslashes are escape characters.

**The Solution**: The team spent a 2-week sprint refactoring everything to **Pathlib**.
Refactored: `report_path = Path("/reports") / date / "data.csv"`.

**The Outcome**: The same script now runs on the developer's Windows laptop AND the production Linux Cluster without a single change. They achieved **True Portability**.

---

## ❓ Interview Preparation (Pathlib)

### 🎯 Core Concepts

1. **Q: Why use Pathlib over `os.path`?**
   - *A: Pathlib is object-oriented, readable (using `/` operator), and safe. It creates code that is portable across Operating Systems without manual separator handling.*

2. **Q: How do you create a directory (including parents) with Pathlib?**
   - *A: `Path("a/b/c").mkdir(parents=True, exist_ok=True)`. This mimics `mkdir -p` in bash.*

3. **Q: What is the difference between `.glob()` and `.rglob()`?**
   - *A: `.glob()` searches only the immediate directory. `.rglob()` (Recursive Glob) searches the directory and all subdirectories trees (`**/*`).*

4. **Q: How do you resolve a relative path to absolute?**
   - *A: `path.resolve()`. It expands `..`, symlinks, and `~` to the full absolute system path.*

5. **Q: Can Pathlib handle file permissions?**
   - *A: Yes, via `.chmod()`. Example: `Path("script.sh").chmod(0o755)`.*

### 🚀 Advanced Questions

6. **Q: How do you check if a path is a file or directory?**
   - *A: `.is_file()` and `.is_dir()`. Both return False if the path doesn't exist.*

7. **Q: What does `.iterdir()` do?**
   - *A: It yields valid path objects for contents of the directory. It’s a generator, so it’s memory efficient for huge folders.*

8. **Q: How do you change a file extension?**
   - *A: `new_path = old_path.with_suffix('.txt')`. Note: This doesn't rename the file on disk; it just creates a new Path object representing that name.*

9. **Q: Is Pathlib compatible with standard `open()`?**
   - *A: Yes. `with open(Path("file.txt")):` works perfectly in modern Python.*

10. **Q: How do you read bytes (Binary) with Pathlib?**
    - *A: `path.read_bytes()`. Useful for quick image/key loading.*

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which operator joins path components?**
   - [ ] a) `+`
   - [x] b) `/`
   - [ ] c) `.`

2. **How do you get the parent folder?**
   - [ ] a) `path.up()`
   - [x] b) `path.parent`
   - [ ] c) `path.folder`

3. **Which method ensures a folder and all its parents exist?**
   - [ ] a) `os.makedirs()`
   - [x] b) `path.mkdir(parents=True)`
   - [ ] c) `path.create_all()`

### 🚀 Intermediate Level

4. **What does `rglob("*.py")` look for?**
   - [ ] a) Python files in current folder only
   - [x] b) Python files in current folder AND subfolders
   - [ ] c) Files named `rglob.py`

5. **What happens if you `.read_text()` on a missing file?**
   - [ ] a) Returns empty string
   - [x] b) Raises `FileNotFoundError`
   - [ ] c) Creates the file

6. **Why use `exist_ok=True` in mkdir?**
   - [ ] a) To verify the folder exists
   - [x] b) To prevent an error if the folder already exists (Idempotency)
   - [ ] c) To delete the folder first

### 🏆 Advanced Level

7. **Where does `Path.home()` point on Linux?**
   - [x] a) `/home/username` (or `/root`)
   - [ ] b) `/usr/bin`
   - [ ] c) `C:\Users\username`

8. **Can you sort Path objects?**
   - [x] a) Yes, they sort alphabetically/structurally
   - [ ] b) No, they are unordered
   - [ ] c) Only by converting to string first

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Path = Object**: It has methods (`.exists()`, `.unlink()`).
2. **Slash = Navigation**: `a / b` is the new way.
3. **Glob = Search**: Find what you need recursively.

### 🛡️ Safety Patterns

1. **Always use `exist_ok=True`** when creating dirs.
2. **Use `resolve()`** to normalize paths.
3. **Use `.with_suffix()`** for renaming extensions.

### 🚀 Production Rules

1. **Abandon `os.path`**: New code uses Pathlib.
2. **Handle Exceptions**: Wrap operations in `try/except`.
3. **Cross-Platform First**: Never hardcode `\` or `/`.

---

## 🔗 Next Steps

You can navigate files and parse arguments. Now let's combine everything into your **First Automation Script**.

**Proceed to**: [Project Structure →](../09-Project-Structure/README.md) (Checking path...)

---

## 📚 Additional Resources

- [Python Pathlib Documentation](https://docs.python.org/3/library/pathlib.html)
- [Pathlib Cheat Sheet](https://github.com/chris1610/pbpython/blob/master/extras/Pathlib-Cheatsheet.pdf)

---

**🎓 Remember**: A newbie concatenates strings: `"C:\\" + folder`. An engineer uses `os.path.join`. A senior engineer uses `Path(folder) / "file.txt"`.

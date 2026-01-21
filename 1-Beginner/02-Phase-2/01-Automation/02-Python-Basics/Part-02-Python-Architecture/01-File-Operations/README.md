# 📂 File Operations: The Bridge to Persistence

> **"In the DevOps world, everything eventually becomes a file. If you can't read, write, and manipulate files safely, you can't automate infrastructure."**

![Secure Python File Ops](../assets/python_file_ops.png)

## 📚 Overview

File operations are the fundamental "plumbing" of DevOps. Whether you are parsing a multi-gigabyte log file, generating a Kubernetes manifest from a template, or managing deployment artifacts, Python's file handling system provides the safety and performance required for production-grade automation.

This module moves you beyond basic `open()` calls. We will explore **Atomic Writes** to prevent config corruption, **Stream Processing** for high-performance log analysis, and the **Context Manager** pattern that acts as a safety harness for your system resources.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Master **Robust File Handling** using Context Managers (`with`).
- ✅ Implement **High-Performance Reading** for multi-gigabyte files.
- ✅ Orchestrate **Atomic Write Operations** to prevent data corruption.
- ✅ Navigate **File Modes & Permissions** (Read, Write, Append, Binary).
- ✅ Build **Generator-Based Pipelines** for memory-efficient log parsing.

---

## 🏗️ Robust File Handling: The Context Manager

In professional automation, a forgotten file handle is a "Resource Leak" that can crash a production server. Python solves this with the **Context Manager**.

### The "DevOps" Way (Guaranteed Safety)
Even if your script crashes mid-operation, Python guarantees the file is closed.

```python
# ✅ The standard for all production code
with open("inventory.txt", "w") as f:
    f.write("web-01\n")
    f.write("db-01\n")
    # If the power pulls here, the file handle is still released by the OS.
```

#### Under the Hood: The __enter__ / __exit__ Lifecycle
When you use `with`, Python executes the object's `__enter__` method. When the block ends (or fails), it executes `__exit__`. This is exactly how tools like **Terraform** handle state locks!

---

## 🚀 Performance Strategies for Engineers

### 1. Scaling to Gigabytes: Line-by-Line Iteration
**The Problem**: Reading a 10GB log file with `.read()` will occupy 10GB of RAM and likely crash your container.
**The Solution**: Treat the file as an **Iterator**. It yields one line at a time, keeping your memory usage near zero.

```python
# ✅ Memory efficient: Works for 1MB or 1TB
with open("/var/log/syslog", "r") as log_file:
    for line in log_file:
        if "CRITICAL" in line:
            print(f"Alert found: {line.strip()}")
```

### 2. Safeguarding State: The Atomic Write Pattern
**Scenario**: You are updating a central configuration file. If the script crashes halfway through, the file is corrupted, and your entire app goes down.

**The Pro Technique**: 
1. Write to a **Temporary File**.
2. **Rename** the temp file to the target name (an "Atomic" operation on the OS level).

```python
import os
import tempfile

def save_safe_config(path, data):
    dir_name = os.path.dirname(path)
    # Create temp file in the SAME directory (prevents cross-filesystem failure)
    with tempfile.NamedTemporaryFile("w", dir=dir_name, delete=False) as tmp:
        tmp.write(data)
        temp_name = tmp.name
    
    # Atomic swap: OS replaces the old file with the new one instantly
    os.replace(temp_name, path)
```

---

## 🧪 File Modes Cheat Sheet

Choosing the correct mode is your first line of defense against accidental data loss.

| Mode | Short | Behavior | Risk Level |
| :--- | :--- | :--- | :--- |
| **`r`** | Read | Default. Fails if file is missing. | 🟢 Safe |
| **`w`** | Write | **Wipes file contents instantly.** Creates if missing. | 🔴 Dangerous |
| **`a`** | Append | Adds to end. Creates if missing. No wiping. | 🟡 Moderate |
| **`rb` / `wb`**| Binary | Used for images, archives, or compiled binaries. | 🟡 Moderate |

---

## 🏆 Real-World DevOps Story: The 50GB Log Trap

**The Scenario**: A junior engineer wrote a "Log Deduplicator" script for a CDN. It worked perfectly on his laptop. On its first run in production against a 50GB audit log, it crashed the server, triggering a Sev-1 incident.

**The Discovery**: The script used `f.readlines()`, which attempts to load the **entire file** into a Python list. The server only had 16GB of RAM.

**The Solution**: The script was refactored to use a **Generator-based pipeline**. It read lines one-by-one, filtered them through a set of "seen" hashes, and yielded unique lines.

**The Outcome**: RAM usage dropped from 40GB+ to **45MB**. The script could now process logs of any size without ever risking a server crash.

---

## ❓ Interview Preparation (File I/O)

1. **Q: Why is it important to use `os.replace()` for atomic writes?**
   - *A: On most operating systems, a "move" or "rename" is an atomic operation. This ensures that the destination file is either the old version or the new version—it can never be a "corrupted half-version."*

2. **Q: What is the difference between `f.write()` and `f.writelines()`?**
   - *A: `write` takes a single string. `writelines` takes an iterable of strings (like a list) and writes them sequentially. Note: `writelines` does NOT add newlines automatically!*

3. **Q: How do you handle file encoding issues in international environments?**
   - *A: Always specify the encoding explicitly: `open("data.txt", "r", encoding="utf-8")`. Without it, Python uses the OS default, which leads to "broken character" bugs in cross-platform (Windows vs Linux) automation.*

4. **Q: What is the 'with' statement technically called?**
   - *A: A Context Manager. It implements the Context Management Protocol.*

5. **Q: How do you read a file in chunks rather than lines?**
   - *A: Use `f.read(buffer_size)` inside a loop. This is useful for large binary files or logs without clear newline characters.*

---

## 📝 Knowledge Check

1. **Which mode will preserve the existing data in a file?**
   - [ ] a) `w`
   - [x] b) `a`
   - [ ] c) `w+`

2. **What happens if you open a non-existent file in 'r' mode?**
   - [ ] a) It creates it.
   - [x] b) It raises `FileNotFoundError`.
   - [ ] c) It returns `None`.

3. **In the 'Atomic Write' pattern, where should the temp file be created?**
   - [ ] a) `/tmp`
   - [x] b) The same directory as the target (to avoid 'Cross-Device Link' errors).
   - [ ] c) The script's root folder.

4. **Which method is safest for reading a 100GB file on a machine with 4GB RAM?**
   - [ ] a) `f.readlines()`
   - [ ] b) `f.read()`
   - [x] c) `for line in f:`

5. **True or False: `open("data.txt", "w")` will create the file if it doesn't exist.**
   - [x] a) True
   - [ ] b) False

---

## 🔗 Next Steps

Now that you can persist data, let's learn how to handle the inevitable errors that occur in unstable environments.

Proceed to: **[Error Handling →](../Part-05-Error-Handling/README.md)**

# Failure Handling and Atomicity

A script that fails halfway is more dangerous than a script that doesn't run at all. **Atomicity** ensures that an operation either completes successfully or has no effect at all—leaving no "half-finished" mess.

## 📚 Module Structure
- **[Boilerplates](README.md)**: `atomic_write.py` (Writing files safely).
- **[CHALLENGES](./CHALLENGES.md)**: Building pre-flight checks and rollbacks.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Fail-Fast** | Verifying requirements (permissions, space, files) BEFORE starting work. |
| **Atomicity** | The "Everything or Nothing" principle. |
| **Atomic Move** | Writing a temporary file then using `os.replace()` to overwrite the target instantly. |
| **Rollback** | Logic that runs on failure to undo partial changes. |

---

## 🏗️ Robust Pattern: Atomic File Writing

Never edit a live configuration file directly. If your script crashes while writing, the file will be corrupted.

```python
import os
import tempfile

# 1. Create a temp file in the same directory
fd, temp_path = tempfile.mkstemp(dir=".", text=True)

try:
    with os.fdopen(fd, 'w') as tmp:
        tmp.write("NEW_CONFIG=VAL")
    
    # 2. Atomic Replace (Success!)
    # This is instantaneous at the OS level
    os.replace(temp_path, "prod.config")
    
except Exception:
    # 3. Cleanup on Failure
    os.remove(temp_path)
    raise
```

---

## 📖 Real-World Story: The "Zero-Byte" Config

**Scenario**: An automation script was updating the `/etc/nginx/nginx.conf` file on 50 servers. It opened the file in 'write' mode and started writing.
**Crisis**: A temporary network glitch caused the script to disconnect halfway through writing the file to one server.
**Outcome**: The `nginx.conf` on that server was left with 0 bytes (empty). Nginx crashed on the next restart, taking the site down.
**Solution**: Switched to the **Atomic Write** pattern (Write to temp -> Rename).
**Result**: Even if the script crashes, the original `nginx.conf` remains untouched.

---

## ❓ Interview Questions

1. **What is 'Defensive Programming'?**
   - *Answer*: It is a practice where you assume your inputs are bad, the network is down, and the disk is full. You write code to handle these exceptions rather than assuming "happy path" execution.
2. **Why is `os.rename()` or `os.replace()` considered 'Atomic'?**
   - *Answer*: At the filesystem level, renaming is a metadata change that happens in a single operation. There is no point in time where the file is "partially renamed."
3. **What is a 'Pre-flight Check'?**
   - *Answer*: A function at the start of a script that verifies things like `is_root?`, `has_internet?`, `has_disk_space?`. If any fail, the script exits immediately before touching any critical data.

---

[Next: Observability and Logging](../05-Observability-and-Logging/README.md)
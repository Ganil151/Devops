# Idempotency Patterns: Check-Act-Verify

In DevOps, failure is inevitable. Networks drop, disks fill up, and scripts crash. **Idempotency** is the property that allows you to re-run the same script multiple times without causing duplicate configurations or errors.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `idempotent_pattern.py` (The logic structure).
- **[CHALLENGES](./challenges.md)**: Safe folder managers and user creates.

---

## 🏗️ The 3-Step Pattern

| Step | Action | Logic |
| :--- | :--- | :--- |
| **1. Check** | **Read State** | Is the system already in the desired state? |
| **2. Act** | **Change State** | If NO, apply the change. If YES, do nothing. |
| **3. Verify** | **Confirm State** | Did the change actually happen? (Optional but recommended). |

---

## 🏗️ Case Study: Creating a Directory

### Non-Idempotent (Bad)
```bash
# This fails if the directory exists
mkdir /var/log/myapp 
```

### Idempotent (Good)
```bash
# This succeeds even if it exists
mkdir -p /var/log/myapp
```

### Advanced Idempotent (Best - Python)
```python
import os
path = "/var/log/myapp"

if not os.path.exists(path):
    os.makedirs(path)
    print(f"CHANGED: Created {path}")
else:
    print(f"OK: {path} already exists")
```

---

## 📖 Real-World Story: The "Double User" Bug

**Scenario**: A script created Linux users for the dev team. It ran once a month.
**Problem**: The script was not idempotent. It just ran `useradd alice`.
**Crisis**: The script crashed halfway. When the admin re-ran it, the first 10 users already had entries in `/etc/passwd`. The script stopped with "User already exists" errors, and the new 5 developers never got their accounts.
**Solution**: Switched to a Check-Act pattern.
**Result**: The script can now run 100 times per day safely.

---

## ❓ Interview Questions

1. **Why is idempotency critical for Ansible and Terraform?**
   - *Answer*: Because they are "Declarative" tools. You define the end state, and they use idempotent modules to reach that state regardless of the starting point.
2. **Is a 'Delete' operation naturally idempotent?**
   - *Answer*: Yes, usually. Deleting a file that is already gone results in the same final state (the file is gone). However, your script should handle the "File Not Found" error without crashing.
3. **What is 'Configuration Drift'?**
   - *Answer*: When the actual state of a server differs from its intended state (e.g., someone manually edited a file). An idempotent script fixes drift every time it runs.

---

[Next: Secrets & Parameters](../03-parameterization-and-secrets-management/readme.md)
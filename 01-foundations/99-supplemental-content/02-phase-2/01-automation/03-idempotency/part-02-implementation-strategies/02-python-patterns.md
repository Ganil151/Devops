# 🐍 Idempotency in Python: Leveraging EAFP

Python is fantastic for idempotency because its extensive standard library (`os`, `pathlib`) allows for precise state checking.

> **EAFP**: "It's Easier to Ask for Forgiveness than Permission."
> Python often prefers `try/except` blocks over `if exists` checks, essential for handling race conditions.

## ❌ Bad (Non-Idempotent)
```python
import os

# Fails if directory exists
os.mkdir("data")

# Appends every time
with open("config.txt", "a") as f:
    f.write("setting=true\n")
```

---

## ✅ Good (Idempotent)

### 1. Directory Creation (`os.makedirs`)
The `exist_ok=True` argument is your best friend.
```python
import os

# Safe to run recursively
os.makedirs("data/logs/current", exist_ok=True)
```

### 2. Atomic File Creation
Use `try/except` with `x` (exclusive creation) mode to ensure you never overwrite an existing file.
```python
try:
    with open("lockfile.pid", "x") as f:
        f.write("PID: 1234")
    print("Lock acquired.")
except FileExistsError:
    print("Lock already exists.")
```

### 3. Smart Configuration Update
Read the content first, check memory state, then write only if needed.
```python
config_path = "app.conf"
target_setting = "debug=True"

# 1. READ
current_content = ""
if os.path.exists(config_path):
    with open(config_path, "r") as f:
        current_content = f.read()

# 2. CHECK
if target_setting not in current_content:
    print("Applying setting...")
    # 3. ACT
    with open(config_path, "a") as f:
        f.write(f"\n{target_setting}\n")
else:
    print("Setting already applied.")
```

---

## 🏗️ The "State Enforcer" Pattern (Ansible-style Logic)

If you are building a tool using python, structure your functions to return `changed=True/False`.

```python
def ensure_user(username):
    import subprocess
    
    # Check
    result = subprocess.run(["id", username], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    if result.returncode == 0:
        return {"changed": False, "msg": f"User {username} exists"}
    
    # Act
    subprocess.run(["useradd", username], check=True)
    return {"changed": True, "msg": f"User {username} created"}

# Usage
status = ensure_user("deployer")
if status["changed"]:
    print("System state updated.")
```

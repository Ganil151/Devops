# 🛠️ Core Automation: The Python Engine Room

> **"Scripts break. Software endures. The difference is structure."**

This reference covers the fundamental building blocks of robust Python automation. Moving beyond "Hello World," these patterns ensure your tools are safe, readable, and distinct from bash scripts.

---

## 📂 1. Path & File Operations (`pathlib`)

Stop using strings for file paths. Use `pathlib` for object-oriented filesystem handling that works on Linux/Mac/Windows.

| Keyword | Use Case | Example |
| :--- | :--- | :--- |
| `Path('file')` | Create a path object. | `p = Path('/var/log/syslog')` |
| `.exists()` | Check file existence. | `if p.exists(): ...` |
| `.mkdir()` | Create directory. | `p.mkdir(parents=True, exist_ok=True)` |
| `.read_text()` | Read file content. | `content = p.read_text()` |
| `.write_text()` | Atomic write. | `p.write_text("config=true")` |
| `.glob()` | Find files matching pattern. | `list(Path('.').glob('*.json'))` |

**Staff Pattern**:
```python
from pathlib import Path
# Cross-platform safe joining
config_path = Path.home() / "app" / "config.yaml"
```

---

## ⚡ 2. Subprocess Management (`subprocess`)

The bridge to the OS. Never use `os.system`.

| Keyword | Use Case | Example |
| :--- | :--- | :--- |
| `subprocess.run` | Execute command. | `subprocess.run(['ls', '-la'])` |
| `capture_output` | Get stdout/stderr. | `res = subprocess.run(..., capture_output=True)` |
| `check=True` | Raise error on failure. | `subprocess.run(..., check=True)` |
| `text=True` | Return String not Bytes. | `subprocess.run(..., text=True)` |

**Staff Pattern**:
```python
import subprocess
try:
    # Safe, captured, text-mode execution
    res = subprocess.run(["git", "status"], capture_output=True, text=True, check=True)
    print(res.stdout)
except subprocess.CalledProcessError as e:
    print(f"Command failed: {e.stderr}")
```

---

## 🛡️ 3. Safety & Structure

Patterns that prevent bugs before they happen.

### Context Managers (`with`)
Ensures resources (files, sockets, DB connections) are closed even if errors occur.
```python
# The "File Handle" is automatically closed after the blocke
with open("data.lock", "w") as f:
    f.write(pid)
```

### Type Hints (`typing`)
Documentation that checks itself.
```python
from typing import List, Dict, Optional

def get_instances(tags: Dict[str, str]) -> List[str]:
    return ["i-12345"]
```

### Dataclasses (`dataclasses`)
Structured data objects without the boilerplate.
```python
from dataclasses import dataclass

@dataclass
class Server:
    hostname: str
    ip: str
    is_active: bool = True
```

---

## 🚀 4. Advanced Flow

### Generators (`yield`)
Process Infinite Data with Zero RAM.
```python
def read_huge_log():
    with open("10gb.log") as f:
        for line in f:
            if "ERROR" in line:
                yield line # Pauses here, resumes next loop

for err in read_huge_log():
    process(err)
```

### Decorators (`@`)
Modify function behavior (logging, timing, retries) non-destructively.
```python
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        print(f"Elapsed: {time.time() - start}s")
        return result
    return wrapper

@timer
def heavy_job():
    time.sleep(1)
```

---

[⬅️ Back to Reference Hub](./README.md)

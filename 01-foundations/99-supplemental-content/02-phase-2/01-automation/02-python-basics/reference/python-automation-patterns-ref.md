# 🛠️ Python Automation Patterns Reference
*Version 1.0 | Engineering Professional-Grade Scripting Systems*

---

## 🏛️ Executive Summary
Simple scripts grow into complex systems. Automation Patterns ensure that your Python code is **Modular**, **Observable**, and **Reliable**. This guide details the shift from "Flat Scripts" to "CLI Tools" that can be integrated into large-scale SRE pipelines.

---

## 🏗️ Technical Pillars: CLI Engineering

### 1. The Entry Point (`argparse`)
**Purpose**: Making scripts interactive and self-documenting.
- **SRE Standard**: Support `--verbose` and `--dry-run` flags in every production script.
```python
import argparse
parser = argparse.ArgumentParser(description="Multi-cloud Cleanup Tool")
parser.add_argument("--region", required=True, help="Cloud region to target")
args = parser.parse_args()
```

### 2. Logging & Observability
**Mechanism**: Moving beyond `print()` to formatted logs.
- **Rule**: Send info to `stdout` and errors to `stderr`. Use JSON logs if the script output is being consumed by Splunk or Datadog.

---

## ⚙️ Reliability Patterns

### 1. The Retry Decorator
Network calls fail. Your script shouldn't.
- **Pattern**: Implement **Exponential Backoff**.
```python
import time
from functools import wraps

def retry(retries=3, delay=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for i in range(retries):
                try: return func(*args, **kwargs)
                except Exception:
                    if i == retries - 1: raise
                    time.sleep(delay * (2 ** i)) # Backoff
        return wrapper
    return decorator
```

### 2. The Singleton Pattern (Database/Cloud Clients)
Prevent creating 1,000 AWS clients in a loop, which can cause memory leaks and API throttling.

---

## 🛡️ SRE Standards: Packaging & Environments

- **Virtual Environments**: Always use `venv` to avoid polluting the system Python.
- **Requirements**: Use `requirements.txt` or `pyproject.toml` for explicit dependency version pinning.
- **Type Checking**: Use `mypy` to verify type hints in CI pipelines to prevent "attribute errors" at runtime.

---

## 🧪 Real-World Troubleshooting
**Scenario**: "My script is hanging indefinitely when calling an internal API."
- **Root Cause**: Missing **Network Timeouts**. Default Python libraries often have infinite timeouts.
- **Solution**: Always specify `timeout=5` in `requests.get()` or socket connections.

---

## ❓ Interview "Deep-Cut" Questions
1. **Describe the impact of the GIL (Global Interpreter Lock) on CPU-bound automation scripts.**
2. **What is the difference between "Composition" and "Inheritance" in a Python-based cloud SDK wrapper?**
3. **How does the `contextlib` module simplify resource cleanup (like DB connections)?**
4. **Explain the benefits of `yield` (Generators) for processing massive XML/JSON inventories.**
5. **Describe how you would implement a "Dead Letter" logic in a Python-based event consumer.**

---
**Next Step**: [Testing & CI Integration →](./python-devops-testing-ref.md)

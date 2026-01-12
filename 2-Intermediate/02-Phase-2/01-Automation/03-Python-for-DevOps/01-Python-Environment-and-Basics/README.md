# Python Environment and Basics

Python is a high-level, interpreted language that has become the "standard glue" for DevOps due to its readability, rich library ecosystem, and native support for cloud SDKs and APIs.

## 🏗️ Python's Role in DevOps

Python bridges the gap where Bash scripts become too complex or brittle.

```mermaid
graph TD
    User([SRE / DevOps Engineer]) --> Logic[Python Logic]
    Logic --> Cloud[Cloud SDKs: Boto3/Azure]
    Logic --> APIs[REST APIs: requests]
    Logic --> Config[Config: PyYAML/JSON]
    Logic --> OS[System: os/subprocess]

Cloud -.-> Infra[Cloud Infrastructure]
    APIs -.-> Services[Third-party Services]
    style Logic fill:#f9f,stroke:#333,stroke-width:2px
```

## ❄️ Isolation: Virtual Environments

In DevOps, we often run scripts with conflicting dependency requirements. **Virtual Environments** (`venv`) allow you to create isolated Python installations for each project, ensuring your automation doesn't break when system packages are updated.

```bash
# Create a virtual environment
python -m venv .venv

# Activate it
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Install dependencies locally
pip install requests boto3
```

> [!TIP]
> Always include a `requirements.txt` file in your automation repo:
> `pip freeze > requirements.txt`

## 📊 Bash vs. Python: When to switch?

| Feature | Bash / Shell | Python |
| :--- | :--- | :--- |
| **Logic** | Best for linear, simple CLI tasks | Best for complex branching & data processing |
| **Data** | Limited (strings/arrays) | Rich (classes, dicts, tuples, objects) |
| **Integrations** | External tools (`jq`, `curl`) | Native excellence (`requests`, `json`) |
| **Stability** | Hard to test/maintain at scale | Highly testable (`pytest`) |

## 🛡️ Writing Robust DevOps Logic

### 1. Exception Handling
Never let your automation fail silently. Use `try...except` to catch and log errors.

```python
try:
    with open("config.yaml", "r") as f:
        data = f.read()
except FileNotFoundError:
    print("❌ Critical Error: Configuration file missing!")
    exit(1)
```

### 2. Type Hinting
Modern Python (3.5+) supports type hints, which act as documentation and prevent bugs in large pipelines.

```python
def check_cpu_threshold(current: float, limit: float = 90.0) -> bool:
    return current > limit
```

---

## 📖 Stories from the Field: The Library Conflict

**Scenario**: A DevOps engineer wrote a Python script to automate SSL renewal using a specific version of the `cryptography` library. They installed it globally on the production server.
**Problem**: Another tool on the same server required an older version of the same library.
**Outcome**: Updating the library for the renewal script broke the monitoring tool, causing a silent failure in service alerts.
**Resolution**: The engineer refactored both tools to use **Virtual Environments** (`.venv`).
**Prevention**: **NEVER** install automation dependencies globally (`sudo pip install`). Always use an isolated environment.

---

## ❓ Interview Questions

1. **Why is Python often preferred over Bash for complex automation?**
   * *Answer*: Python handles complex data structures (like nested JSON) natively, has superior error handling (`try/except`), and is much easier to unit test.
2. **What is the purpose of a `requirements.txt` file?**
   * *Answer*: It lists all external dependencies and their versions, allowing anyone to recreate the exact environment needed to run the script.
3. **How do you handle secrets (API keys) in Python?**
   * *Answer*: Never hardcode them. Use environment variables via `os.environ` or a dedicated Secrets Manager (AWS Secrets Manager, HashiCorp Vault).
4. **What is a "shebang" line for Python?**
   * *Answer*: Typically `#!/usr/bin/env python3`. It tells the shell which interpreter to use when the script is executed directly.
5. **How does Python's `exit()` differ from Bash's `exit`?**
   * *Answer*: In Python, `exit(1)` raises a `SystemExit` exception, which can be caught if needed, but ultimately stops the script with the provided exit code.

---

## 🧠 Quiz

1. **Which command creates a new virtual environment?** `(python -m venv <name>)`
2. **True/False: Virtual environments are only needed on Windows.** `(False)`
3. **What is the default tool for installing Python packages?** `(pip)`
4. **Which block is used to catch errors in Python?** `(try...except)`
5. **How do you activate a virtual environment on Linux?** `(source .venv/bin/activate)`
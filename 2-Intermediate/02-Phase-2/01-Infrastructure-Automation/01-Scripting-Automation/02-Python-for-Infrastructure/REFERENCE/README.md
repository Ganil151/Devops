# 🐍 Python for DevOps: Keyword Encyclopedia

Welcome to the comprehensive reference hub for **Python for DevOps**. This guide breaks down the core keywords, libraries, and design patterns that transform simple scripts into enterprise-grade automation tools.

---

## 🏗️ Reference Manuals

Explore the technical "Why" behind Python's role in modern Infrastructure Engineering:

### 1. [🛠️ Core Automation](./Core-Automation-Keywords.md)
System operations (`pathlib`, `subprocess`), process management (`sys.exit`), and robust error handling (`try/except/with`).

### 2. [📊 Data Manipulation](./Data-Manipulation-Keywords.md)
Parsing Cloud outputs (`JSON`, `YAML`), List Comprehensions, and high-performance processing.

### 3. [☁️ Cloud & Networking](./Cloud-Networking-Keywords.md)
API architecture (`Requests`), AWS SDK mastery (`Boto3`), Paginators, and Waiters.

### 4. [🧪 Testing & Observability](./Testing-Observability-Keywords.md)
Verification logic (`Pytest`), Mocking, and structured instrumentation (`Logging`).

---

## 🛡️ The "Staff Level" Python Bar

In the production world, Python code is evaluated by its **Safety**, **Maintainability**, and **Scale**.

| Junior Level | Staff Engineer Level |
| :--- | :--- |
| Uses `print()` for errors. | Uses the `logging` module with severity levels. |
| Hardcodes file paths as strings. | Uses `pathlib` for cross-platform path handling. |
| Ignores API return codes. | Uses `raise_for_status()` and Retry Adapters. |
| Writes logic-heavy scripts as one block. | Modularizes code into unit-testable functions with Type Hints. |
| Uses simple loops for cloud lists. | Uses Boto3 `Paginators` to handle thousands of resources. |

---

[⬅️ Back to Python for DevOps](../README.md)

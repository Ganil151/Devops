# Working with Data: JSON and YAML

Infrastructure is defined as data. Python's native support for dictionaries makes it the perfect tool for manipulating JSON and YAML configurations.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `data_parser.py` (Robust loading).
- **[CHALLENGES](./CHALLENGES.md)**: Validators and Converters.

---

## 🔑 Key Libraries

| Library  | Format | Notes                                                             |
| :------- | :----- | :---------------------------------------------------------------- |
| `json`   | JSON   | Native to Python. Fast.                                           |
| `pyyaml` | YAML   | Requires `pip install PyYAML`. De-facto standard for K8s/Ansible. |
| `csv`    | CSV    | Built-in. Good for legacy reports.                                |

---

## 🏗️ Modern Patterns

### 1. Robust Nested Access
Avoid `KeyError` crashes.

```python
data = {"spec": {"replicas": 3}}

# BAD
# count = data["spec"]["missing_key"] # Crashes

# GOOD
count = data.get("spec", {}).get("missing_key", 1)
```

### 2. Sets for Comparisons
Finding differences between infrastructure states.

```python
local_files = {"file1", "file2", "file3"}
s3_files = {"file1", "file2"}

missing = local_files - s3_files # {'file3'}
```

---

## 📖 Real-World Story: The "Ghost Resource"

**Problem**: A financial audit found 500 "Ghost" EBS volumes (detached but not deleted).
**Solution**: A Python script loaded the "Active Inventory" (JSON from AWS) and the "Billing Report" (CSV). It converted both lists to **Sets** and performed a math difference operation.
**Result**: Identified $50k/year in waste in 10 lines of code.

---

## ❓ Interview Questions

1.  **Difference between `json.load()` and `json.loads()`?**
    - *Answer*: `load()` reads from a file object. `loads()` reads from a string.
2.  **Why use `yaml.safe_load()` instead of `load()`?**
    - *Answer*: `load()` can execute arbitrary Python code embedded in the YAML tags. `safe_load()` restricts this.
3.  **How do you pretty-print JSON in Python?**
    - *Answer*: `json.dumps(data, indent=4)`.

---

[Next: API Mastery](../04-API-Mastery-with-Requests/README.md)
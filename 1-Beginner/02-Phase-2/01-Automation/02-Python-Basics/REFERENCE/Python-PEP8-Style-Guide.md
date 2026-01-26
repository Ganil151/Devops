# 🏷️ Python PEP 8 & Style Guide: The Exhaustive Master Reference
*Version 3.0 | Standardizing Enterprise Automation Architecture*

---

## 📖 Overview
PEP 8 is the "Constitution" of Python programming. In SRE and DevOps teams, code is read 100x more than it is written. Following these exhaustive standards ensures that your automation logic—from simple bash-replacement scripts to complex Kubernetes operators—remains readable, maintainable, and professionally consistent.

---

## 🏗️ Naming Conventions

### `snake_case`
**Definition**: All lowercase letters with words separated by underscores. 
**Usage**: The mandatory standard for **Variables** and **Functions**. 
**Example**:
```python
failed_instance_ids = ["i-123"]
def rotate_vault_keys():
    pass
```

### `PascalCase`
**Definition**: Every word starts with a capital letter, with no underscores. Also known as CapWords.
**Usage**: The mandatory standard for **Classes** and **Exceptions**.
**Example**:
```python
class K8sClusterManager:
    pass

class ProvisioningError(Exception):
    pass
```

### `UPPER_CASE`
**Definition**: All capital letters with words separated by underscores.
**Usage**: The standard for **Constants** defined at the module level.
**Example**:
```python
MAX_RECONNECT_ATTEMPTS = 5
DEFAULT_AWS_REGION = "us-east-1"
```

### `_single_leading_underscore`
**Definition**: A naming prefix indicating "internal use."
**Usage**: Signals that a variable or function is intended for private use within a module or class. It is not imported by `from module import *`.
**Example**:
```python
def _verify_internal_token():
    pass
```

### `__double_leading_underscore`
**Definition**: Triggers "Name Mangling" in classes.
**Usage**: Used to avoid name clashes with subclasses by prepending the class name to the variable.
**Example**:
```python
class BaseNode:
    def __init__(self):
        self.__id = 1  # Becomes _BaseNode__id
```

### `__double_leading_and_trailing_underscore__`
**Definition**: "Dunder" (Double Under) methods.
**Usage**: Reserved for special objects/methods in the Python language like `__init__` or `__str__`. Never invent your own.
**Example**:
```python
def __init__(self, ip):
    self.ip = ip
```

---

## 📏 Physical Code Layout

### Indentation
**Definition**: Using exactly **4 spaces** per indentation level.
**Usage**: Required for defining the scope of loops, classes, and functions. NEVER use tabs.
**Example**:
```python
if is_prod:
    deploy_to_cloud() # Exactly 4 spaces
```

### Line Length
**Definition**: Keeping lines to a maximum of **79 characters**.
**Usage**: Ensures that code can be viewed on small laptop screens and side-by-side terminal windows.
**Example**:
```python
# Wrap long strings or logic using parentheses
msg = (
    "Deployment to the US-EAST-1 region failed "
    "due to an unexpected network timeout."
)
```

### Blank Lines
**Definition**: Vertical spacing to separate logical blocks.
**Usage**: Two blank lines before top-level functions/classes; one blank line before classes methods.
**Example**:
```python
class Monitor:
    def ping(self):
        pass

    def scan(self):  # 1 blank line above
        pass
```

---

## 📦 Imports Organization

### Absolute vs Relative
**Definition**: Specifying the full path to a module.
**Usage**: Python recommends Absolute imports (e.g., `import myapp.utils`) to prevent name collisions.
**Example**:
```python
import os
import sys
from cloud_sdk.ec2 import utils
```

### Import Grouping
**Definition**: Categorizing imports by their source.
**Usage**: Groups should be separated by a single blank line in this order:
1. Standard Library
2. Related Third Party
3. Local application/library specific
**Example**:
```python
import json
import os

import boto3
import requests

from .local_helpers import audit_log
```

---

## 📝 Documentation & Comments

### Inline Comments
**Definition**: Comments on the same line as code.
**Usage**: Use sparingly. They should explain "Why," never "What" the code does.
**Example**:
```python
x = x + 1  # Increment boundary for binary search logic
```

### Block Comments
**Definition**: Multi-line comments at the same indentation level as the code.
**Usage**: Used to explain complex logic blocks or design decisions.
**Example**:
```python
# We use a set here instead of a list because 
# lookup time for 10k IPs is O(1) instead of O(n).
allowed_ips = set(fetch_ips())
```

### Docstrings
**Definition**: Strings placed immediately after a definition.
**Usage**: Mandatory for all public modules, functions, classes, and methods.
**Example**:
```python
def get_status(node_id):
    """
    Query the API for a specific node's current health.
    
    Args:
        node_id (str): The unique UUID of the EC2 instance.
    Returns:
        bool: True if healthy.
    """
    pass
```

---

## 🎯 Modern Type Hinting (Python 3.6+)

### Variable Annotations
**Definition**: Explicitly stating the expected data type of a variable.
**Usage**: Helps IDEs like VS Code catch errors before execution.
**Example**:
```python
retry_count: int = 0
active_nodes: list[str] = ["10.0.0.1"]
```

### Function Signatures
**Definition**: Defining the types of arguments and the return value.
**Usage**: Standard for all enterprise automation code to ensure data integrity.
**Example**:
```python
def calculate_drift(target: int, actual: int) -> int:
    return abs(target - actual)
```

---

## 📜 The "Zen of Python" (PEP 20)
**Definition**: The guiding principles of the language. Run `import this` to see them.
**Usage**: Apply these to DevOps logic to decide between complex vs. simple solutions.
**Example**:
- **Flat is better than nested**: Avoid deeply nested `if/else` blocks. Use "Guard Clauses" (returning early).
- **Explicit is better than implicit**: Don't hide logic inside "magic" functions.
- **Simple is better than complex**: If a 50-line Python script can be a 10-line Bash script, use Bash.

---
**Next Step**: [Keywords Reference →](./Python Keywords.md)

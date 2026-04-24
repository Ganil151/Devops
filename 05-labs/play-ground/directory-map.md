# 🗺️ Directory Mapping & Search Index
> **Senior Systems Engineer Refactor | Naming Standardization**

This file provides a bridge between the legacy naming convention and the new **DevOps Standard Convention**. 

## ⚖️ The DevOps Standard Convention
1. **Lowercase Only**: Prevents case-sensitivity issues in multi-platform pipelines.
2. **Kebab-Case**: Hyphens replace spaces and underscores for terminal clarity.
3. **Numeric Indexing**: Preserves sequential learning paths (`00-`, `01-`, etc).
4. **No Special Characters**: Ampersands (`&`), quotes, and dots are removed to ensure script stability.

---

## 📊 Major Refactor Log (Mapping)

| Legacy Name | DevOps Standard Name | Search Tags |
| :--- | :--- | :--- |
| `01-Beginner` | `01-beginner` | #foundations #intro |
| `02-Intermediate` | `02-intermediate` | #scaling #automation |
| `03-Advanced` | `03-advanced` | #architecture #sre |
| `OSI Model` | `osi-model` | #networking #fundamentals |
| `Cables & Connectors` | `cables-connectors` | #physical-layer #hardware |
| `Service Models` | `service-models` | #iaas #paas #saas |
| `Source_Code` | `source-code` | #git #dev |
| `Interview_Questions_and_Quiz.md` | `interview-questions-and-quiz.md` | #prep #evaluation |
| `Server Manager` | `server-manager` | #windows #administration |

---

## 🧩 Why Naming Matters (Junior Reasoning)
In a professional DevOps environment, **Consistency is Safety**.

**1. CLI Friction**: Bash and Python handle spaces poorly. A file named `My Lab.tf` requires escaping (`My\ Lab.tf`), which adds complexity to automation scripts.
**2. Case Sensitivity**: Windows is case-insensitive, but Linux (where most production workloads run) is **case-sensitive**. `Readme.md` and `README.md` are different files in Linux, leading to "File Not Found" errors during deployment.
**3. Tab-Completion**: Lowercase kebab-case is much faster to type and traverse using the terminal's `TAB` key.
**4. URL Friendliness**: Modern documentation platforms (GitHub Pages, GitBook) serve files over URLs. Hyphens are the standard for URL readability.

---

## 🛠️ Automation: The Dry Run Fixer
Below is the Python logic that identifies and proposes these renames.

```python
import os
import re

def standardize(name):
    name = name.replace('&', 'and')
    name = re.sub(r'[\s_]+', '-', name)
    name = re.sub(r'[^\w\-]', '', name)
    return name.lower().strip('-')

def dry_run_refactor(base_path):
    for root, dirs, files in os.walk(base_path):
        for name in dirs + files:
            old_path = os.path.join(root, name)
            new_name = standardize(name)
            if new_name != name:
                print(f"[RENAME] {name} -> {new_name}")

# Usage: dry_run_refactor('/home/gsmash/Documents/Devops')
```

---
*Documented by Senior Systems Engineer & Information Architect*

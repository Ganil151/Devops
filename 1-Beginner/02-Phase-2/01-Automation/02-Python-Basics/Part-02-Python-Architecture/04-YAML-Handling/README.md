# 🏗️ Working with YAML: The Blueprint of Infrastructure

> **"If JSON is the language of APIs, YAML is the language of Infrastructure. From Kubernetes manifests to Ansible playbooks, YAML is the blueprint that defines the modern cloud."**

> **⚠️ Missing Image**: *Python Data Flow* ('../assets/python_data_flow.png')

## 📚 Overview

YAML (YAML Ain't Markup Language) is a human-friendly data serialization standard. In DevOps, it is the primary interface for "Infrastructure as Code" (IaC). Every major tool in the ecosystem—**Kubernetes**, **Ansible**, **Docker Compose**, and **GitHub Actions**—relies on YAML for configuration.

This module focuses on the **PyYAML** library, teaching you how to programmatically generate complex manifests, handle multi-document streams, and implement advanced features like **Anchors**, **Aliases**, and **Custom Tags** to build DRY (Don't Repeat Yourself) configurations.

## 🎓 Learning Objectives

By the end of this module, you will:

- ✅ Master **Safe Loading** (`safe_load`) to prevent script vulnerabilities.
- ✅ Manipulate **Multi-Document Streams** (`---`) for K8s manifests.
- ✅ Implement **DRY Configurations** using YAML Anchors (`&`) and Aliases (`*`).
- ✅ Design **Custom YAML Constructors** for environment variable injection.
- ✅ Build **Templating Engines** using Python and YAML for dynamic deployments.

---

## 🏗️ The YAML Syntax Trio

YAML is designed for human readability, but its strict indentation makes it prone to "silent errors" if not handled correctly by code.

### 1. The Multi-Document Stream (`---`)
In Kubernetes, you often define a Service and a Deployment in the same file. Python handles this using a generator.

```python
import yaml

content = """
apiVersion: v1
kind: Service
---
apiVersion: apps/v1
kind: Deployment
"""

# 🧠 safe_load_all returns a generator!
documents = yaml.safe_load_all(content)
for doc in documents:
    print(f"Processing {doc['kind']} manifest...")
```

### 2. DRY Architecture: Anchors (`&`) and Aliases (`*`)
DevOps engineers hate repetition. YAML allows you to define a block once and "copy" it elsewhere.

```yaml
# 💡 Define a base config once
base: &base_config
  cpu: 2
  ram: 4GB

# 💡 Use it and override specific values
web_server:
  <<: *base_config
  ram: 8GB # Override
```

### 3. Block Scalars (`|` vs `>`)
Handling multi-line strings (like long scripts inside a ConfigMap) is a common DevOps task.
*   **`|` (Literal)**: Preserves every newline.
*   **`>` (Folded)**: Replaces single newlines with spaces (ideal for long descriptions).

---

## 🚀 Advanced Pattern: Custom YAML Tags

**The Scenario**: You want to keep sensitive passwords out of your YAML files and read them from environment variables instead.

**The Pro Solution**: Use a **Custom Constructor** to identify a tag like `!env` and execute Python logic during the load phase.

```python
import os

def env_constructor(loader, node):
    """Handle !env tag: extracts key from env or returns default."""
    value = loader.construct_scalar(node)
    return os.environ.get(value, f"MISSING_{value}")

# Register the logic
yaml.SafeLoader.add_constructor('!env', env_constructor)

config_yaml = "password: !env DB_PASS"
os.environ["DB_PASS"] = "super-secret"

data = yaml.safe_load(config_yaml)
print(data['password']) # "super-secret"
```

---

## 🏆 Real-World DevOps Story: The Tab-Indentation Disaster

**The Scenario**: A deployment script for a massive microservices cluster kept producing "Invalid Manifest" errors in Production, even though the YAML "looked identical" to the Staging file.

**The Discovery**: The engineer had used a generic text editor that inserted a **Tab** character instead of two spaces for one specific line. YAML prohibits tabs for indentation, but many browsers and CLI tools display them as spaces, making the bug invisible to the human eye.

**The Solution**: The team implemented a Python-based **YAML Linter** into their Git Pre-commit hooks. The script uses `yaml.safe_load()` to verify every file before it can be pushed.

**The Outcome**: Zero indentation-related outages. The team saved countless hours of "staring at white space" and moved toward a true "Validation-first" workflow.

---

## ❓ Interview Preparation (YAML)

1. **Q: Why is it dangerous to use `yaml.load()` on untrusted files?**
   - *A: Standard `yaml.load()` can execute arbitrary Python objects (constructors) embedded in the YAML. A malicious user could send a YAML file that deletes files or steals credentials. Always use `yaml.safe_load()`.*

2. **Q: How do you preserve the order of keys when dumping a dictionary to YAML?**
   - *A: In Python 3.7+, dictionaries are ordered by default. Use `yaml.dump(data, sort_keys=False)` to prevent PyYAML from alphabetically re-sorting your keys.*

3. **Q: What is the difference between `default_flow_style=True` and `False`?**
   - *A: `True` outputs JSON-like sequences `[a, b]`. `False` outputs block-style sequences (one per line with dashes), which is the standard for DevOps files.*

4. **Q: How does YAML handle booleans vs strings like "No"?**
   - *A: This is the "Norway Problem." In older YAML versions, "No" was interpreted as `False` (boolean). In modern versions, it is a string. To be safe, always wrap strings in quotes `"No"` or use explicit booleans `true/false`.*

5. **Q: How do you merge two YAML files programmatically?**
   - *A: Load both into Python dictionaries using `safe_load`, use a recursive dictionary merge function, and then `dump` the resulting dictionary back to YAML.*

---

## 📝 Knowledge Check

1. **Which block scalar preserves newlines exactly as they are written?**
   - [ ] a) `>` (Folded)
   - [x] b) `|` (Literal)

2. **True or False: YAML is a superset of JSON.**
   - [x] a) True (Any valid JSON file is also a valid YAML file).
   - [ ] b) False

3. **What character is used to create a YAML Alias?**
   - [ ] a) `&`
   - [x] b) `*`
   - [ ] c) `!`

4. **Which method should you use to load a file containing '---' separators?**
   - [ ] a) `yaml.load()`
   - [ ] b) `yaml.safe_load()`
   - [x] c) `yaml.safe_load_all()`

5. **How do you add a comment in YAML?**
   - [ ] a) `//`
   - [x] b) `#`
   - [ ] c) `/* */`

---

## 🔗 Next Steps

Now that you can manage structured data, let's learn how to configure your scripts dynamically using the surrounding environment.

Proceed to: **[Environment Variables →](../Part-08-Environment-Variables/README.md)**

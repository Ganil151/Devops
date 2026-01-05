# Working with Data: JSON and YAML

Modern infrastructure is defined as code, usually in JSON or YAML formats. Python's ability to seamlessly convert these formats into native data structures (Dictionaries and Lists) makes it the ideal tool for manipulating configuration at scale.

## 📦 Python Data Structures for DevOps

- **Dictionaries (`dict`)**: Best for key-value configurations (like an AWS resource description).
- **Lists (`list`)**: Best for collections of resources (like a list of IP addresses).
- **Sets (`set`)**: Best for finding unique items or comparing differences between two environments (drifts).

```python
# A typical "DevOps" Dictionary
server = {
    "name": "web-prod-01",
    "ip": "10.0.1.50",
    "tags": ["prod", "frontend"]
}
```

## 📄 Parsing and Generating JSON

The `json` module is part of Python's standard library.

```python
import json

# Parsing JSON (String to Dict)
json_data = '{"status": "running", "id": "i-123456"}'
data = json.loads(json_data)
print(data["status"])

# Generating JSON (Dict to String)
config = {"env": "prod", "replicas": 3}
with open("config.json", "w") as f:
    json.dump(config, f, indent=4)
```

## 📝 Working with YAML

YAML is the standard for Kubernetes, Ansible, and CloudFormation. Since it's not in the standard library, you must install `PyYAML`.

```bash
pip install pyyaml
```

```python
import yaml

# Loading YAML
with open("k8s-deploy.yaml", "r") as f:
    config = yaml.safe_load(f)

# Modifying and Saving
config["spec"]["replicas"] = 5
with open("k8s-deploy.yaml", "w") as f:
    yaml.safe_dump(config, f)
```

> [!IMPORTANT]
> Always use `yaml.safe_load()` instead of `yaml.load()` to prevent arbitrary code execution vulnerabilities.

---

## 📖 Stories from the Field: The Kubernetes Manifest Generator

**Scenario**: A company needed to deploy the same application to 50 different namespaces, but each namespace required a unique set of environment variables and labels.
**Problem**: Managing 50 separate YAML files was a maintenance nightmare and led to configuration drift.
**Discovery**: The team wrote a Python script that used a single "Template" YAML and a JSON "Inventory" file.
**Outcome**: The script iterated through the inventory, injected the specific values into the Python dictionary, and used `yaml.safe_dump()` to generate the 50 manifests on the fly.
**Prevention**: Use Python as a "Template Engine" for complex configurations rather than manually editing large YAML files.

---

## ❓ Interview Questions

1. **What is the difference between `json.load()` and `json.loads()`?**
   * *Answer*: `load()` reads from a file-like object (a file on disk), while `loads()` (Load String) parses a JSON string directly from memory.
2. **Why should you use `yaml.safe_load()`?**
   * *Answer*: `yaml.load()` can instantiate any Python object from a YAML file, which is a massive security risk if the YAML source is untrusted. `safe_load()` restricts parsing to simple, safe data types.
3. **How do you handle a JSON file that has keys that are not valid Python variable names?**
   * *Answer*: Python dictionaries use strings as keys, so any valid JSON key (including those with spaces or dashes) works perfectly: `data["key-with-dashes"]`.
4. **How do you find the difference between two lists of IP addresses?**
   * *Answer*: Use Python Sets. `set(list_a) - set(list_b)` will give you all IPs in list A that are not in list B.
5. **What happens if you try to parse a YAML file that contains multiple documents (separated by `---`)?**
   * *Answer*: You must use `yaml.safe_load_all()`, which returns a generator for each document in the file.

---

## 🧠 Quiz

1. **Which Python data structure is closest to a JSON object?** `(Dictionary)`
2. **True/False: The `json` module must be installed via pip.** `(False - it's built-in)`
3. **What is the command to install the most common YAML library?** `(pip install pyyaml)`
4. **How do you add an element to a Python list?** `(.append())`
5. **Which function converts a Python dictionary into a JSON file?** `(json.dump())`
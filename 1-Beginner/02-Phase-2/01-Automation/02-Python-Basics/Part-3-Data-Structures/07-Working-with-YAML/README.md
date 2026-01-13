# Working with YAML
*The Human-Friendly Configuration Language*

YAML (YAML Ain't Markup Language) is the preferred format for DevOps configuration—Kubernetes manifests, Ansible playbooks, Docker Compose, and CI/CD pipelines all use YAML. Mastering YAML manipulation is essential.

---

## 🎯 Learning Objectives

- Parse and generate YAML files
- Handle multi-document YAML streams
- Convert between YAML and other formats
- Validate YAML structure programmatically

---

## 📊 YAML in DevOps Pipeline

```mermaid
flowchart TD
    A[YAML Config Files] --> B[Python yaml Library]
    B --> C[Python Dict/List]
    C --> D{Process/Transform}
    D --> E[Generate K8s Manifests]
    D --> F[Create Ansible Vars]
    D --> G[Update CI/CD Config]
    
    subgraph DevOps Tools
        E --> H[kubectl apply]
        F --> I[ansible-playbook]
        G --> J[GitLab CI/GitHub Actions]
    end
    
    style A fill:#306998,stroke:#ffe873,color:#fff
    style C fill:#4b8bbe,stroke:#306998,color:#fff
```

---

## 📚 Core Concepts

### 1. YAML Basics

```python
import yaml

# Parse YAML string
yaml_content = """
apiVersion: v1
kind: Service
metadata:
  name: web-service
  labels:
    app: web
spec:
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: web
"""

data = yaml.safe_load(yaml_content)
print(data["metadata"]["name"])  # "web-service"

# Generate YAML from Python
config = {
    "server": {
        "host": "0.0.0.0",
        "port": 8080,
        "debug": False
    },
    "database": {
        "url": "postgresql://localhost:5432/db",
        "pool_size": 10
    }
}

yaml_output = yaml.dump(config, default_flow_style=False)
print(yaml_output)
```

### 2. File Operations

```python
# Read YAML file
with open("config.yaml", "r") as f:
    config = yaml.safe_load(f)

# Write YAML file
with open("output.yaml", "w") as f:
    yaml.dump(config, f, default_flow_style=False, sort_keys=False)

# Safe loading (prevents code execution)
yaml.safe_load(content)    # ✅ Always use this
yaml.load(content, Loader=yaml.SafeLoader)  # ✅ Equivalent

# Unsafe (NEVER use with untrusted input!)
yaml.load(content, Loader=yaml.FullLoader)  # ⚠️ Risky
```

### 3. Multi-Document YAML

```python
# Many DevOps tools use multi-doc YAML (separated by ---)
multi_doc = """
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: INFO
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  API_KEY: c2VjcmV0LWtleQ==
"""

# Load all documents
documents = list(yaml.safe_load_all(multi_doc))
print(f"Found {len(documents)} documents")

for doc in documents:
    print(f"  - {doc['kind']}: {doc['metadata']['name']}")

# Write multiple documents
output_docs = [
    {"kind": "ConfigMap", "metadata": {"name": "config1"}},
    {"kind": "Secret", "metadata": {"name": "secret1"}}
]

with open("multi.yaml", "w") as f:
    yaml.dump_all(output_docs, f, default_flow_style=False)
```

### 4. YAML Features

```python
# Anchors and Aliases (DRY in YAML)
yaml_with_anchors = """
defaults: &defaults
  timeout: 30
  retries: 3
  ssl: true

production:
  <<: *defaults
  host: prod.example.com
  
staging:
  <<: *defaults
  host: stage.example.com
  timeout: 60  # Override default
"""

data = yaml.safe_load(yaml_with_anchors)
print(data["production"]["timeout"])  # 30 (from defaults)
print(data["staging"]["timeout"])     # 60 (overridden)
```

---

## 🔧 Advanced Patterns

### Custom YAML Tags

```python
import yaml
import os

# Custom tag for environment variables
def env_constructor(loader, node):
    """Handle !env tag to read from environment."""
    value = loader.construct_scalar(node)
    return os.environ.get(value, f"${value}")

yaml.SafeLoader.add_constructor('!env', env_constructor)

# Usage
config_yaml = """
database:
  host: !env DB_HOST
  password: !env DB_PASSWORD
  port: 5432
"""

os.environ["DB_HOST"] = "prod-db.internal"
config = yaml.safe_load(config_yaml)
print(config["database"]["host"])  # "prod-db.internal"
```

### YAML Templating

```python
from jinja2 import Template
import yaml

# Template with Jinja2, then parse as YAML
template = Template("""
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ app_name }}
  namespace: {{ namespace }}
spec:
  replicas: {{ replicas }}
  template:
    spec:
      containers:
        - name: {{ app_name }}
          image: {{ image }}:{{ tag }}
          ports:
            - containerPort: {{ port }}
""")

deployment = template.render(
    app_name="api-server",
    namespace="production",
    replicas=3,
    image="myregistry/api",
    tag="v2.1.0",
    port=8080
)

manifest = yaml.safe_load(deployment)
print(f"Deploying {manifest['spec']['replicas']} replicas")
```

---

## 🛠️ Hands-On Exercises

### Exercise 1: K8s Manifest Generator
```python
# Create a function to generate Kubernetes deployment manifests
# TODO: Implement generate_deployment function
# - Takes app name, image, replicas, port
# - Returns valid K8s Deployment YAML

def generate_deployment(app_name, image, replicas=1, port=8080):
    pass

# Test
yaml_output = generate_deployment("web-api", "nginx:latest", replicas=3)
print(yaml_output)
```

<details>
<summary>💡 Solution</summary>

```python
import yaml

def generate_deployment(app_name, image, replicas=1, port=8080):
    """Generate Kubernetes Deployment manifest."""
    deployment = {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "name": app_name,
            "labels": {"app": app_name}
        },
        "spec": {
            "replicas": replicas,
            "selector": {
                "matchLabels": {"app": app_name}
            },
            "template": {
                "metadata": {
                    "labels": {"app": app_name}
                },
                "spec": {
                    "containers": [{
                        "name": app_name,
                        "image": image,
                        "ports": [{"containerPort": port}],
                        "resources": {
                            "limits": {"cpu": "500m", "memory": "256Mi"},
                            "requests": {"cpu": "100m", "memory": "128Mi"}
                        }
                    }]
                }
            }
        }
    }
    
    return yaml.dump(deployment, default_flow_style=False, sort_keys=False)

print(generate_deployment("web-api", "nginx:latest", replicas=3))
```
</details>

### Exercise 2: Ansible Inventory Parser
```python
# Parse this Ansible inventory YAML
inventory = """
all:
  children:
    webservers:
      hosts:
        web-01:
          ansible_host: 10.0.1.10
        web-02:
          ansible_host: 10.0.1.11
    databases:
      hosts:
        db-01:
          ansible_host: 10.0.2.10
          db_role: primary
        db-02:
          ansible_host: 10.0.2.11
          db_role: replica
"""

# TODO: Extract all hosts with their IPs and group membership
def parse_inventory(yaml_content):
    pass
```

<details>
<summary>💡 Solution</summary>

```python
import yaml

def parse_inventory(yaml_content):
    """Parse Ansible inventory and return host details."""
    data = yaml.safe_load(yaml_content)
    hosts = []
    
    def extract_hosts(group_data, group_name):
        if not isinstance(group_data, dict):
            return
            
        # Direct hosts in this group
        if "hosts" in group_data:
            for host_name, host_vars in group_data["hosts"].items():
                hosts.append({
                    "name": host_name,
                    "group": group_name,
                    "ip": host_vars.get("ansible_host"),
                    "vars": {k: v for k, v in host_vars.items() 
                            if k != "ansible_host"}
                })
        
        # Child groups
        if "children" in group_data:
            for child_name, child_data in group_data["children"].items():
                extract_hosts(child_data, child_name)
    
    extract_hosts(data.get("all", {}), "all")
    return hosts

hosts = parse_inventory(inventory)
for host in hosts:
    print(f"{host['name']} ({host['ip']}) - Group: {host['group']}")
```
</details>

### Exercise 3: Config Merger
```python
# Merge multiple YAML config files with proper precedence
# TODO: Implement merge_configs function
# - Load base config
# - Override with environment-specific config
# - Support nested merging

def merge_configs(base_file, override_file):
    pass
```

<details>
<summary>💡 Solution</summary>

```python
import yaml
from copy import deepcopy

def deep_merge(base, override):
    """Recursively merge override into base."""
    result = deepcopy(base)
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = deepcopy(value)
    return result

def merge_configs(base_file, override_file):
    """Merge two YAML config files."""
    with open(base_file, 'r') as f:
        base = yaml.safe_load(f) or {}
    
    with open(override_file, 'r') as f:
        override = yaml.safe_load(f) or {}
    
    return deep_merge(base, override)

# Alternative inline test
base_yaml = """
server:
  host: localhost
  port: 8080
database:
  host: localhost
  port: 5432
  pool_size: 5
"""

prod_yaml = """
server:
  host: 0.0.0.0
database:
  host: prod-db.internal
  pool_size: 20
"""

base = yaml.safe_load(base_yaml)
prod = yaml.safe_load(prod_yaml)
final = deep_merge(base, prod)

print(yaml.dump(final, default_flow_style=False))
```
</details>

---

## 📖 Real-World Story: The Indentation Bug

**Scenario**: A Kubernetes deployment kept failing with cryptic errors. The YAML looked correct visually.

**Problem**: Mixed tabs and spaces in the YAML file caused structure misalignment.

**Solution**: 
1. Added YAML validation to CI pipeline
2. Configured editors to show whitespace
3. Used `yamllint` for pre-commit checks

**Outcome**: No more whitespace-related deployment failures.

---

## ❓ Interview Questions

1. **Why use `yaml.safe_load()` instead of `yaml.load()`?**
   > `safe_load` prevents arbitrary code execution from malicious YAML files. Essential for security.

2. **How do YAML anchors work?**
   > Anchors (`&name`) define reusable blocks, aliases (`*name`) reference them. `<<:` merges the anchor.

3. **How do you handle multi-document YAML files?**
   > Use `yaml.safe_load_all()` which returns a generator of parsed documents.

4. **What's the difference between YAML and JSON?**
   > YAML is a superset of JSON, supports comments, anchors, multi-line strings, and is more human-readable.

5. **How do you preserve key order in YAML output?**
   > Python 3.7+ dicts are ordered. Use `sort_keys=False` in `yaml.dump()`.

---

## 🧠 Quiz

1. What's the safe way to load YAML?
   - a) `yaml.load()`
   - b) `yaml.safe_load()` ✅
   - c) `yaml.read()`

2. How do you load multiple YAML documents from one file?
   - a) `yaml.safe_load()` multiple times
   - b) `yaml.safe_load_all()` ✅
   - c) `yaml.load_many()`

3. What does `---` mean in YAML?
   - a) Comment
   - b) Document separator ✅
   - c) End of file

4. Which is valid YAML for a list?
   - a) `items: [a, b, c]` ✅
   - b) `items: (a, b, c)`
   - c) `items: {a, b, c}`

5. How do you write multi-line strings in YAML?
   - a) Triple quotes `"""`
   - b) Pipe `|` or `>` ✅
   - c) Backslash continuation

---

**Next Step**: [Environment Variables →](../08-Environment-Variables/README.md)

# 🏗️ YAML Deep Dive: The Infrastructure-as-Code Standard
*Version 1.0 | Mastering the Language of Containers & Orchestration*

---

## 📖 Overview
YAML (YAML Ain't Markup Language) is a human-readable data-serialization language. In DevOps, it is the primary format for Kubernetes manifests, Ansible playbooks, and CI/CD pipelines (GitHub Actions, GitLab CI). Its power lies in its simplicity and ability to represent complex hierarchies with minimal syntax.

---

## 🏛️ Core YAML Syntax

### Key-Value Pairs
**Definition**: The fundamental building block where a string key is followed by a colon and a space, then its value.
**Example**:
```yaml
environment: production
```

### Indentation (Lists & Maps)
**Definition**: YAML uses strictly **2 spaces** for indentation. It does not allow tabs. Indentation defines the scope and hierarchy.
**Example**:
```yaml
metadata:
  name: web-server
  labels:
    tier: frontend
```

### Lists (Sequences)
**Definition**: A collection of items denoted by a leading dash (`-`). Each item must be on its own line and indented correctly.
**Example**:
```yaml
ports:
  - 80
  - 443
```

### Scalars (Data Types)
**Definition**: The basic data values: Strings, Integers, Booleans, and Floats.
**Example**:
```yaml
count: 3            # Integer
enabled: true       # Boolean
version: "1.2.0"    # String (quotes optional unless special chars)
```

---

## 🚀 Advanced YAML Features

### Multiline Strings (`|` and `>`)
**Definition**: The pipe (`|`) preserves newlines (literal); the greater-than (`>`) folds newlines into spaces.
**Example**:
```yaml
config_scripts: |
  apt update
  apt install -y nginx
```

### Anchors (`&`) and Aliases (`*`)
**Definition**: Anchors mark a block for reuse; Aliases inject that block into another part of the document.
**SRE Impact**: Reduces duplication in massive configurations (e.g., repeating the same health check across 10 containers).
**Example**:
```yaml
default_settings: &defaults
  retries: 3
  timeout: 30

service_a:
  <<: *defaults
  name: app-a
```

### Comments (`#`)
**Definition**: Any text following a `#` is ignored by the parser. Use this for documenting infra logic.
**Example**:
```yaml
# Do not increase replicas beyond 10 without load testing
replicas: 3
```

---

## 🔍 DevOps Use Cases

### Kubernetes Manifests
**Description**: YAML is used to define the "Desired State" of a cluster.
**Example**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

### Ansible Playbooks
**Description**: YAML orchestrates automated system configuration.
**Example**:
```yaml
- name: Install Nginx
  hosts: webservers
  tasks:
    - name: install package
      apt:
        name: nginx
        state: present
```

---

## 💡 SRE Pro-Tips
- **The "Boolean Trap"**: Values like `yes`, `no`, `on`, and `off` are often parsed as Booleans. Always quote strings that could be mistaken for Booleans.
- **Validation**: Use tools like `yamllint` or online validators before pushing to Git to prevent CI pipeline failures.
- **Schema Validation**: For Kubernetes, use `kubeval` or `datree` to ensure your YAML matches the expected schema.

---
**Next Step**: [JSON API Standards →](./json-api-standard-ref.md)

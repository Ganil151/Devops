# ⚙️ TOML Configuration: The Modern Choice
*Version 1.0 | Mastering the Configuration standard for CLI Tools*

---

## 📖 Overview
TOML (Tom's Obvious, Minimal Language) is a configuration file format that's easy to read due to obvious semantics. It is increasingly popular in modern DevOps tools like **PyProject.toml** (Python), **Cargo.toml** (Rust), and **containerd** configuration. It is designed to map unambiguously to a hash table.

---

## 🏛️ TOML Syntax

### Key-Value Pairs
**Definition**: Similar to JSON/YAML but more flat and readable.
**Example**:
```toml
title = "Application Settings"
version = "1.0.0"
```

### Tables `[]`
**Definition**: Tables are used to organize properties into sections.
**Example**:
```toml
[database]
server = "192.168.1.1"
ports = [ 8000, 8001, 8002 ]
connection_max = 5000
enabled = true
```

### Inline Tables `{}`
**Definition**: A compact way to define a map on a single line.
**Example**:
```toml
name = { first = "Tom", last = "Preston-Werner" }
```

### Arrays of Tables `[[]]`
**Definition**: Used to create a list of maps/objects.
**Example**:
```toml
[[products]]
name = "Hammer"
sku = 738594937

[[products]]
name = "Nail"
sku = 284758393
```

---

## 🚀 Advanced Features

### Dates & Times
**Definition**: TOML has first-class support for RFC 3339 timestamps.
**Example**:
```toml
last_backup = 2024-01-26T07:32:00Z
```

### Multiline Strings
**Definition**: Using triple-quotes (`"""`) to preserve block text.
**Example**:
```toml
long_description = """
This is a long description
of the internal SRE tool.
"""
```

---

## 🔍 DevOps Use Cases

### PyProject.toml
**Description**: The modern standard for Python project configuration and dependency management.
**Example**:
```toml
[tool.poetry]
name = "deployment-script"
version = "0.1.0"
dependencies = { python = "^3.12", requests = "^2.31" }
```

### containerd Configuration
**Description**: Low-level container runtime configuration.
**Example**:
```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"
```

---

## 💡 SRE Pro-Tips
- **Ambiguity Removal**: TOML is designed to eliminate the "guessing" of data types. Everything is explicitly defined by its syntax.
- **Table vs. Section**: Think of `[table]` like a folder and everything inside it as files within that folder.
- **Deep Nesting**: Avoid deeply nesting tables. TOML excels at flat configurations. If you need more than 3 levels of nesting, YAML might be a better choice.

---
**Next Step**: [XML Enterprise Standards →](./xml-enterprise-legacy-ref.md)

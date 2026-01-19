# 🔴 Level 3: Custom Inventory Scripts & Caching

## 📖 Overview

At the enterprise level, you may encounter scenarios where standard plugins aren't enough. You might need to pull host data from a custom CMDB (Configuration Management Database), a proprietary API, or a legacy SQL database. Additionally, as your fleet grows to 5,000+ nodes, API latency becomes a bottleneck.

This level covers **Custom Inventory Scripts** and **High-Performance Caching**.

## 🐍 Custom Inventory Scripts (Python)

An inventory script must be an executable that:
1.  Accepts the `--list` argument and returns a JSON dictionary of all groups and hosts.
2.  (Optional) Accepts the `--host <hostname>` argument and returns a JSON dictionary of variables for that specific host.

### Architecture of a Custom Script

```mermaid
graph TD
    A[Ansible] -- --list --> B[Python Script]
    B -- GET /api/v1/assets --> C[Internal CMDB]
    C -- List of Servers --> B
    B -- Transform to Ansible JSON --> A
    
    style B fill:#ffd43b,stroke:#333
    style C fill:#00599c,stroke:#333,color:#fff
```

---

## 🚀 Boilerplate: `custom_inventory.py`

```python
#!/usr/bin/env python3
import json
import argparse
import sys

def get_inventory():
    # In a real scenario, you would fetch this from an API or DB
    return {
        "custom_web": {
            "hosts": ["10.50.1.10", "10.50.1.11"],
            "vars": {"env": "staging"}
        },
        "_meta": {
            "hostvars": {
                "10.50.1.10": {"role": "ui"},
                "10.50.1.11": {"role": "api"}
            }
        }
    }

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host', action='store')
    args = parser.parse_args()

    if args.list:
        print(json.dumps(get_inventory(), indent=2))
    elif args.host:
        # Returning empty vars as we use _meta in --list
        print(json.dumps({}))
    else:
        print("Usage: --list or --host <hostname>")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

## ⚡ Inventory Caching

When managing thousands of instances, querying the AWS/Azure API on every command is slow and may hit rate limits.

### How it works:
Ansible stores the inventory result in a local file or Memory-based store (like Redis) for a set duration (TTL).

### Configuration (`ansible.cfg`):
```ini
[defaults]
inventory_plugins = ./plugins/inventory
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_cache
fact_caching_timeout = 3600

[inventory]
cache = yes
cache_plugin = jsonfile
cache_connection = /tmp/ansible_inventory_cache
cache_timeout = 300
```

## 🔐 Security Best Practices
- **Never store secrets in inventory**: Use Ansible Vault or a dynamic lookup (e.g., `lookup('amazon.aws.aws_secret', ...)`).
- **Narrow API Permissions**: The IAM user/service account used for discovery should have "Read Only" permissions (e.g., `AmazonEC2ReadOnlyAccess`).

---
## 🎓 Interview Preparation
- **Q**: "What is the difference between an inventory script and an inventory plugin?"
- **A**: Plugins are more performant, support caching out of the box, and are written in a specific class-based format within the Ansible codebase. Scripts are standalone executables.

---
**Congratulations!** You've mastered dynamic host management. 🚀

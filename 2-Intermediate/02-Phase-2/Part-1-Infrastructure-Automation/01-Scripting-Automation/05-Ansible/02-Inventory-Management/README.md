# Inventory Management

The Inventory is Ansible's "Source of Truth". It tells Ansible *what* to automate.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `inventory.ini` (Groups and Children).
- **[CHALLENGES](./CHALLENGES.md)**: INI vs YAML, Aliasing.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Static Inventory** | Simple text files (`.ini` or `.yml`) listing hardcoded servers. |
| **Dynamic Inventory** | Scripts (Plugins) that query Cloud APIs (AWS, Azure) to get the *current* list of servers. |
| **Groups** | Logical collections (`[web]`, `[db]`) to target actions. |
| **Host Vars** | Variables specific to a single host (`ansible_host=1.2.3.4`). |

---

## 🏗️ Architecture: Dynamic Inventory

Modern infra scales up and down. Static IP lists are dead.

```mermaid
graph LR
    Ansible -->|Query| Plugin[AWS EC2 Plugin]
    Plugin -->|API Call| AWS[AWS Cloud]
    AWS -->|Return JSON| Plugin
    Plugin -->|Inventory| Ansible
```

---

## 📖 Real-World Story: The "Autoscaling" Gap

**Problem**: A team used a static `hosts` file. When AWS Autoscaling added 5 new servers during Black Friday, Ansible didn't know about them.
**Crisis**: New servers didn't get security patches.
**Solution**: Switched to `inventory_aws_ec2.yml`. Now Ansible asks AWS "Who is running?" before every job.

---

## ❓ Interview Questions

1.  **What is the default location for the inventory file?**
    - *Answer*: `/etc/ansible/hosts`, but usually overridden in `ansible.cfg`.
2.  **How do you see the list of hosts in a group?**
    - *Answer*: `ansible-inventory -i myinventory --list`.
3.  **Can a host belong to multiple groups?**
    - *Answer*: Yes. A server can be in `[web]`, `[prod]`, and `[us-east]` simultaneously.

---

[Next: Basic Playbooks](../03-Basic-Playbooks/README.md)
# Custom Modules

Sometimes Ansible's 3,000+ baked-in modules aren't enough. When you need to talk to a custom internal API, a legacy binary, or perform complex logic, it's time to build your own module.

## 📚 Learning Path

| # | Topic | Description | Key Modules |
| :--- | :--- | :--- | :--- |
| **01** | [**Development Basics**](./01-Module-Development-Basics/README.md) | How Modules Work | The JSON Bridge, Python vs. Others |
| **02** | [**AnsibleModule Utility**](./02-AnsibleModule-Utility/README.md) | The Standard Library | `argument_spec`, Types, `no_log` |
| **03** | [**Returns & Idempotency**](./03-Returns-and-Idempotency/README.md) | Communicating Success | `exit_json`, `fail_json`, State Logic |
| **04** | [**Testing & Distribution**](./04-Testing-and-Distribution/README.md) | Going Professional | `library/`, `ansible-doc`, Manual Testing |

---

## 🏗️ Module Life Cycle

```mermaid
graph LR
    Plan[Plan Logic] --> Dev[Develop in Python]
    Dev --> Test[Manual Test with JSON]
    Test --> Doc[Add docstrings]
    Doc --> Use[Call in Playbook]
    
    style Dev fill:#ff4444,color:#fff
    style Use fill:#3399ff,color:#fff
```

## Quick Start

Create a `library/` directory in your project root and drop your Python module there.

```bash
mkdir library
touch library/my_custom_module.py
```

Please proceed to **[01-Development-Basics](./01-Module-Development-Basics/README.md)**.
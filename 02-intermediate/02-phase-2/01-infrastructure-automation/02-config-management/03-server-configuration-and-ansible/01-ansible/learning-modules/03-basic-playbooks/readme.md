# Basic Playbooks

A Playbook is a YAML file used to deploy configuration. While ad-hoc commands are for one-off tasks, Playbooks are for repeatable, version-controlled automation.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `site.yml` (Anatomy of a Play).
- **[CHALLENGES](./challenges.md)**: File creation, Multi-play targeting.

---

## 🔑 Key Concepts

| Section | Description |
| :--- | :--- |
| **Hosts** | The group of servers this play applies to. |
| **Tasks** | The list of actions to perform, executed in order. |
| **Handlers** | Special tasks that run ONLY if notified (e.g., "Restart Service"). |
| **Become** | Privilege escalation (sudo). |

---

## 🏗️ The "Idempotency" Promise

Ansible tasks are declarative. You describe the *destination*, not the journey.

```yaml
# BAD (Shell script thinking)
- shell: apt-get install nginx

# GOOD (Ansible thinking)
- apt:
    name: nginx
    state: present
```

If you run the **BAD** example twice, it tries to install twice (and might error or waste time).
If you run the **GOOD** example twice, Ansible sees "It is already present" and does nothing (Green/OK).

---

## 📖 Real-World Story: The "Drift" Fixer

**Problem**: Developers would SSH into servers and manually change PHP configs. Production was drifting from the documentation.
**Solution**: A scheduled Ansible Playbook ran every hour. It defined the *correct* `php.ini`.
**Result**: If a dev manually changed a setting, Ansible reverted it automatically 59 minutes later. Configuration Drift Eliminated.

---

## ❓ Interview Questions

1.  **What is the difference between `state: present` and `state: latest`?**
    - *Answer*: `present` checks if it is installed (doesn't upgrade if already there). `latest` checks if it is the newest version (upgrades if available). `latest` is riskier for Prod.
2.  **When do Handlers run?**
    - *Answer*: At the very *end* of the play, and only if a task notified them AND changed state (Yellow).
3.  **How do you check syntax without running?**
    - *Answer*: `ansible-playbook --syntax-check site.yml`.

---

[Next: Core Modules](../04-core-modules/readme.md)

---
## 🧭 Additional Modules
- [01 Playbook Structure](01-playbook-structure/readme.md)
- [02 YAML Syntax](02-yaml-syntax/readme.md)
- [03 Task Execution Flow](03-task-execution-flow/readme.md)

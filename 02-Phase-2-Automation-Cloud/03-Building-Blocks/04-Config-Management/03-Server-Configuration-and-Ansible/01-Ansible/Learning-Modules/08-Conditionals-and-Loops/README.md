# Conditionals and Loops

Automation requires logic. "Do this 5 times." "Do this only if X is true."

## 📚 Module Structure
- **[Boilerplates](README.md)**: `logic.yml` (Loops, Register, When).
- **[CHALLENGES](./CHALLENGES.md)**: Refactoring lists, OS-specific logic.

---

## 🔑 Key Concepts

| Concept | Syntax |
| :--- | :--- |
| **Simple Loop** | `loop: [item1, item2]` |
| **Dictionary Loop** | `loop: [{name: a, id: 1}, {name: b, id: 2}]`. Access via `item.name`. |
| **When** | `when: result.rc == 0`. Skips task if false. |
| **Changed_when** | `changed_when: false`. Tells Ansible "This didn't actually change state" (Keep output Green). |

---

## 🏗️ Robust Logic

### 1. Waiting for things (`until`)
Don't use `sleep`. Poll the status.

```yaml
- name: Wait for DB to start
  command: /usr/bin/pg_isready
  register: db_check
  until: db_check.rc == 0
  retries: 10
  delay: 5
```

### 2. Failing Intentionally
Assert state before proceeding.

```yaml
- fail:
    msg: "This playbook only runs on Ubuntu!"
  when: ansible_distribution != 'Ubuntu'
```

---

## 📖 Real-World Story: The "Thundering Herd"

**Problem**: A playbook restarted all web servers at once (`loop`). The site went down.
**Solution**: Added `serial: 2` to the Playbook header.
**Result**: Ansible restarted servers 2 at a time (Rolling Restart). Conditionals (`when`) were used to drain traffic from the Load Balancer before restart.

---

## ❓ Interview Questions

1.  **What is the difference between `loop` and `with_items`?**
    - *Answer*: `with_items` is the old syntax. `loop` is the modern standard. They are mostly identical, but `loop` is stricter.
2.  **How do you prevent a task from reporting "Changed" (Yellow)?**
    - *Answer*: Use `changed_when: false` (e.g., when run a command that just checks a version).
3.  **Can you loop over a dictionary?**
    - *Answer*: Yes, use `with_dict` or `loop: "{{ my_dict | dict2items }}"`.

---

[Next: Error Handling](../09-Error-Handling/README.md)

---
## 🧭 Additional Modules
- [01 Conditional Execution](01-Conditional-Execution/README.md)
- [02 Looping Mechanics](02-Looping-Mechanics/README.md)
- [03 Error Handling Blocks](03-Error-Handling-Blocks/README.md)
- [04 Advanced Logic Control](04-Advanced-Logic-Control/README.md)

# 🛠️ Design Patterns for Idempotency
*Version 1.0 | Implementation Strategies for Shell, Python, and Beyond*

---

## 📖 Overview
Writing idempotent code requires a shift from "Do this" to "Ensure this state." This guide details the common software design patterns used to achieve reliability in automation.

---

## 🏗️ Technical Pillars

### 1. The "Check-Then-Act" Pattern
The most common pattern. Before executing a command, verify the current state.
- **Bash Example**:
```bash
if [[ ! -f /etc/config.conf ]]; then
    touch /etc/config.conf
fi
```
- **Standard**: Always prefer built-in flags when available (e.g., `mkdir -p`, `ln -sf`).

### 2. The "State Discovery" Pattern
Iterate through a collection and only modify items that are "Out of Sync."
```python
current_users = get_linux_users()
target_users = ["sre_admin", "dev_user"]

for user in target_users:
    if user not in current_users:
        create_user(user)
```

### 3. The "Atomic Rename" Pattern
To update a file without corrupting readers, create a temporary file and rename it.
1. Write to `config.yml.tmp`.
2. Verify integrity.
3. `mv config.yml.tmp config.yml`.
- **Note**: Re-running this results in the same final file.

---

## ⚙️ Handling APIs (Idempotency Keys)
When calling external APIs (e.g., AWS, Stripe), network timeouts can lead to duplicate resources.
- **Pattern**: Client generates a `UUID` (Idempotency Key) and sends it in the header.
- **Backend**: If it sees the same UUID again, it returns the result of the *original* request instead of creating a new resource.

---

## 🚀 SRE Safety Standards

### Shell Scripting
- Use **`set -e`**: So an error in state checking stops the script.
- Use **`command -v`**: To check for tool existence before run.

### Python Automation
- Use **`os.path`** or **`pathlib`** for file/directory checks.
- Use **Exceptions**: `try/except FileExistsError: pass`.

---

## 🏛️ Comparison Matrix

| Pattern | Complexity | Reliability | Use Case |
| :--- | :--- | :--- | :--- |
| **Logic Wrapper** | Low | Medium | Simple file/user scripts. |
| **Idempotency Keys**| High | High | Distributed systems/APIs. |
| **State File** | Medium | High | Terraform / Config mgmt. |

---

## ❓ Interview "Deep-Cut" Questions
1. **Describe a "Race Condition" in the Check-Then-Act pattern and how to solve it.**
2. **What is the risk of using `>>` (append) in a script that isn't idempotent?**
3. **How does the `CREATE IF NOT EXISTS` clause in SQL simplify database migrations?**
4. **Explain how "Sidecar" containers can enforce idempotency in pod initialization.**
5. **Describe the "Reconciliation Loop" pattern used in Kubernetes Controllers.**

---
**Next Step**: [State Management & Declarative Tools →](./state-management-declarative-tools-ref.md)

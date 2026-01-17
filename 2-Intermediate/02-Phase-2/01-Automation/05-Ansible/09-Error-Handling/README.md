# Error Handling in Ansible

By default, Ansible stops execution on a host if a task fails. However, production automation needs to be resilient. You need to handle failures, perform cleanups, and define what actually constitutes an "error".

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `rollback.yml` (Using Blocks for try/except/finally logic).
- **[CHALLENGES](./CHALLENGES.md)**: Ignoring errors, Rescue missions, and Custom failure logic.

---

## 🔑 Key Concepts

| Keyword | Description |
| :--- | :--- |
| **`ignore_errors`** | Continues the play even if the task fails. |
| **`failed_when`** | Overrides Ansible's failure logic (e.g., "Fail only if 'fatal' is in output"). |
| **`changed_when`** | Overrides when a task reports a change (useful for shell commands). |
| **`block`** | Groups tasks for shared error handling. |
| **`rescue`** | Tasks that run only if the `block` fails (The "Catch" block). |
| **`always`** | Tasks that run regardless of success or failure (The "Finally" block). |

---

## 🏗️ Robust Error Patterns

### 1. The Try/Except Pattern (Blocks)
Use blocks to ensure your system isn't left in a half-configured state.

```yaml
- name: Database Upgrade
  block:
    - name: Stop Database
      service: name=postgresql state=stopped
    - name: Run Upgrade Script
      command: /opt/upgrade.sh
  rescue:
    - name: Recovery - Restart Database
      service: name=postgresql state=started
    - name: Print Error
      debug: msg="Upgrade failed! Database reverted."
  always:
    - name: Send Slack Notification
      community.general.slack:
        msg: "Upgrade job finished"
```

### 2. Custom Success Definition
Sometimes a command returns a non-zero exit code but is actually successful (or vice-versa).

```yaml
- name: Check App Status
  command: /usr/bin/check_app
  register: app_res
  failed_when: "'CRITICAL' in app_res.stdout"
  changed_when: false
```

---

## 📖 Real-World Story: The "Infinite Update"

**Scenario**: A maintenance script updated 500 servers. It used `yum update -y`.
**Problem**: One server had a corrupted package database. The task failed, and because there was no error handling, the script stopped halfway through the list of servers.
**Outcome**: 200 servers were updated, 300 were not. The fleet was out of sync.
**Resolution**: Implemented `any_errors_fatal: true` and `max_fail_percentage: 10%`.
**Prevention**: By setting a failure threshold, the team ensured that if a few nodes fail it's okay, but if a large portion fails, the whole job stops immediately to prevent a mass "half-done" state.

---

## ❓ Interview Questions

1. **What is the difference between `ignore_errors` and `failed_when`?**
   - *Answer*: `ignore_errors` lets the play continue after a task fails. `failed_when` defines *what causes* the task to fail in the first place.
2. **When would you use a `rescue` block?**
   - *Answer*: To perform a rollback or cleanup action if a critical set of tasks fails.
3. **What does `any_errors_fatal: true` do?**
   - *Answer*: If any single host fails a task, Ansible stops the play for *all* hosts immediately.

---

[Next: Ansible Vault](../10-Ansible-Vault/README.md)
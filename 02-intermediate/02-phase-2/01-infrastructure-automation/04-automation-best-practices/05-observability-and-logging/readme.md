# Observability and Logging

If a script runs in a forest and no one is there to see the logs, did it actually succeed? In production, automation is often run by machines (Cron, CI/CD). **Observability** gives you the "eyes" to see how your automation is performing.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `logging_setup.py` (Structured logging with JSON).
- **[CHALLENGES](./challenges.md)**: Building dry-run guards and audit logs.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **Dry Run** | A mode that simulates changes without actually applying them. |
| **Silent Failures** | The most dangerous type of bug—where a script returns exit code 0 but didn't do its job. |
| **Structured Logging** | Logging in JSON format so machines (Splunk/ELK) can parse it. |
| **Verbosity Flags** | Using `-v` or `--debug` to control how much info is printed. |

---

## 🏗️ Robust Pattern: The Dry-Run Guard
Always include a way to test your script safely.

```python
DRY_RUN = True # Usually set via --dry-run flag

def delete_user(username):
    if DRY_RUN:
        print(f"[DRY-RUN] Would delete user: {username}")
    else:
        print(f"ACTUAL: Deleting user {username}...")
        # os.system(f"useradd {username}")
```

---

## 🏗️ Robust Pattern: Structured Logging
Don't just print strings. Use levels.

```python
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

logger = logging.getLogger("cleanup")
logger.info("Starting cleanup...")
logger.error("Failed to delete log file: Access Denied")
```

---

## 📖 Real-World Story: The "Midnight Mystery"

**Scenario**: A nightly backup script was supposedly running successfully for months.
**Crisis**: A server crashed. When the team went to restore the backup, they found the backup files were empty!
**Outcome**: The script had been failing to connect to the DB, but because it didn't log the error and returned success (Exit 0), no one noticed. 100% data loss.
**Solution**: Implemented **Observed Automation** (Level 4). Added a check: "If backup size < 1MB, FAIL and alert Slack."
**Result**: The next failure was caught in 10 minutes.

---

## ❓ Interview Questions

1. **Why is 'STDOUT' not enough for production logging?**
   - *Answer*: STDOUT is transient. You need to write to a Persistent Log File or a Centralized Logging system (ELK/Datadog) so you can audit failures that happened in the past.
2. **How does a '--dry-run' flag help with 'Change Management'?**
   - *Answer*: It allows engineers to generate a "Plan" of what will happen. This plan can be attached to a Change Request (CR) to prove that the automation won't do anything unexpected.
3. **What are the 5 standard logging levels?**
   - *Answer*: DEBUG, INFO, WARNING, ERROR, CRITICAL.

---

[Next: CI/CD Foundations →](../../../../../readme.md)
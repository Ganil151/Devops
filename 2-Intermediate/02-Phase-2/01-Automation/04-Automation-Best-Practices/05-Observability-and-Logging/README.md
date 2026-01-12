# Observability and Logging

Automation often runs in the background (cron jobs, CI/CD runners). If it fails silently, you might not notice for weeks. Observability ensures you always know what your scripts are doing—and *why* they failed.

## 📝 Why Standard Out is Not Enough

Printing "Done" to the terminal is fine for a one-off task. For production automation, you need structured logs that work even when nobody is watching.

### The "Anatomy" of a Good Log
A production-grade log entry should contain:
- **Timestamp**: When did this happen? (e.g., `2025-10-31 14:05:01`)
- **Severity**: Is this an `INFO`, `WARNING`, or `CRITICAL` error?
- **Host/Service**: Where did this run?
- **Message**: A clear, actionable description of the event.

```bash
# Example Shell Logger
log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1"
}
```

## 🧪 The "Dry Run" Pattern

Before running a script that deletes 1,000 servers, you should be able to see exactly what *would* happen without actually doing it. This is a **Dry Run**.

```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--dry-run", action="store_true", help="Show changes without applying")
args = parser.parse_args()

def delete_user(username):
    if args.dry_run:
        print(f"[DRY-RUN] Would delete user: {username}")
    else:
        # Actual deletion logic here
        print(f"Deleting user: {username}")
```

> [!TIP]
> Always make `--dry-run` the default behavior for highly destructive scripts. The user should have to explicitly pass a `--confirm` or `--apply` flag.

---

## 📖 Stories from the Field: The Silent Cron Job

**Scenario**: A nightly cleanup script was supposed to delete old database backups.
**Problem**: The script had a bug where it crashed immediately because of a missing library.
**Outcome**: Because the script didn't log to a file and was run by `cron` (which hides output by default), the engineering team thought the backups were being deleted. Six months later, the disk hit 100% capacity, crashing the database.
**Resolution**: The script was updated to log to `/var/log/automation.log` and used a monitoring tool to alert if the log file hadn't been updated in 24 hours.
**Prevention**: **Background scripts must log to a persistent file.** If a script doesn't log, it doesn't exist.

---

## ❓ Interview Questions

1. **Why are timestamps critical for automation logs?**
   * *Answer*: Because automation often fails due to external factors (network spikes, high load). Timestamps allow you to correlate script failures with other system events in your monitoring tools (like Datadog or CloudWatch).
2. **What is the purpose of a "Dry Run" mode?**
   * *Answer*: It allows developers and operations teams to verify the script's logic and the "Blast Radius" of a change before committing to it.
3. **Difference between `stdout` and `stderr` in logging?**
   * *Answer*: `stdout` (FD 1) is for normal output. `stderr` (FD 2) is for errors and diagnostic messages. Separating them allows you to redirect errors to a separate file or alerting system.
4. **How do you alert a human if a background script fails?**
   * *Answer*: By sending an HTTP POST request to a Slack webhook or using an exit code that the CI/CD system recognizes as a "Failure," which then triggers a notification.
5. **What is "Structured Logging"?**
   * *Answer*: Logging data in a machine-readable format like JSON. This makes it much easier to search and analyze logs using tools like ElasticSearch or Splunk.

---

## 🧠 Quiz

1. **Which flag is commonly used to test scripts safely?** `(--dry-run)`
2. **Where do background `cron` jobs typically hide their output?** `(/dev/null or mail)`
3. **True/False: Logs should always include a hostname.** `(True - especially in distributed systems)`
4. **Which log level is used for non-essential explanations?** `(DEBUG)`
5. **What is the standard file descriptor for error messages?** `(2 / stderr)`
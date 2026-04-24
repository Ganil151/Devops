# Time and Date - DevOps Challenges

## Challenge 1: SSL Certificate Expiry Checker
**Scenario**: Calculate days remaining until certificate expiry.

**Requirements:**
1. Parse certificate expiry date (string format)
2. Calculate difference from `time.Now()`
3. Alert if < 30 days remaining

**Verification:**
```bash
go run cert-check.go "2024-12-31"
# Expected: Days until expiry: 350
```

---

## Challenge 2: Cron Schedule Parser
**Scenario**: Determine next run time for a backup job.

**Requirements:**
1. Support simple intervals (e.g., "every 5m", "every 2h")
2. Calculate next run time from last run timestamp
3. Handle basic cron-like logic

**Verification:**
```bash
go run scheduler.go "every 24h"
# Expected: Next run: [Tomorrow's Date]
```

---

## Challenge 3: Log Retention Policy Enforcer
**Scenario**: Identify old logs for deletion.

**Requirements:**
1. Use `time.Parse` to read timestamps from filenames `backup-20230101.tar.gz`
2. Identify files older than retention period (e.g., 90 days)
3. Print list of files to delete

**Verification:**
```bash
go run cleanup.go
# Expected: List of old backup files
```

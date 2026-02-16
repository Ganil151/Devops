# 📉 Cron Patterns & Pitfalls

Cron is notorious for being "Silent but Deadly." If a job fails, it often fails silently.

## ⚠️ The "Environment Trap"
**Scenario**: Your script runs fine manually, but fails in Cron.
**Reason**: Cron runs with a nearly **empty shell environment**. It doesn't know your `$PATH`, your aliases, or your Python virtualenv.

### ✅ The Fix: Absolute Paths
Always use full paths for EVERYTHING.

```bash
# ❌ Bad
0 12 * * * python script.py

# ✅ Good
0 12 * * * /usr/bin/python3 /home/user/scripts/script.py
```

---

## ⚠️ The "Silent Failure"
**Scenario**: Your backup script crashed 3 weeks ago. You don't know because cron output goes nowhere.

### ✅ The Fix: Redirection
Redirect both Standard Output (1) and Error (2) to a file.

```bash
# Append (>>) logs to a file
0 3 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1
```

---

## 🚀 Professional Pattern: The "Wrapper Script"

Instead of putting complex logic directly in the crontab, call a "Wrapper."

**The Crontab**:
`0 4 * * * /opt/scripts/daily_backup_wrapper.sh`

**The Wrapper (`/opt/scripts/daily_backup_wrapper.sh`)**:
```bash
#!/bin/bash
# Source user profile to get variables
source /home/user/.bashrc

# Set specific path
export PATH=$PATH:/usr/local/bin

# Logic
cd /opt/app
npm run backup
```

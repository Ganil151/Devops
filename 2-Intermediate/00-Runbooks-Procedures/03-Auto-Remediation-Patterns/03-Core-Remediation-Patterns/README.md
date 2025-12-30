# Core Remediation Patterns

Certain failure modes are so common that they have become "Standard Patterns" for automation.

## Pattern 1: The Service Restarter
**Symptoms**: High error rates (5xx), connection timeouts, process hangs.
**Root Cause**: Memory leaks, deadlocks, or corrupted state.
**Action**: Graceful restart of the service.
**Implementation**:
```bash
# Kubernetes
kubectl rollout restart deployment/api-server

# Systemd
systemctl restart nginx
```
**Safety**: Ensure the service is stateless or has proper session persistence.

---

## Pattern 2: Intelligent Storage Cleanup
**Symptoms**: Disk usage > 85%, "No space left on device" errors.
**Root Cause**: Log files, temp files, or cache buildup.
**Action**: Delete old logs, clear `/tmp`, or archive to S3.
**Implementation**:
```python
import os
import shutil

def cleanup_logs(path="/var/log", days_old=7):
    for file in os.listdir(path):
        if file.endswith(".log") and is_older_than(file, days_old):
            os.remove(file)
```
**Safety**: Never delete active database logs or un-replicated data.

---

## Pattern 3: Proactive Capacity Scaling
**Symptoms**: CPU/RAM trending towards 90%.
**Root Cause**: Traffic spike or resource-intensive job.
**Action**: Horizontal scaling (add more instances/pods).
**Implementation**:
- **AWS**: Auto Scaling Groups (ASG).
- **Kubernetes**: Horizontal Pod Autoscaler (HPA).
**Safety**: Set maximum instance limits to prevent runaway costs.

---

## Pattern 4: Connection Pool Reset
**Symptoms**: "Too many connections" errors from database.
**Root Cause**: Connection leak in application code.
**Action**: Reset the connection pool without restarting the entire app.
**Implementation**:
```bash
# Send SIGHUP to reload config
kill -HUP $(pidof app-server)
```

---

## Pattern 5: DNS Cache Flush
**Symptoms**: Intermittent connection failures after infrastructure changes.
**Root Cause**: Stale DNS cache.
**Action**: Flush DNS resolver cache.
**Implementation**:
```bash
# Linux
systemd-resolve --flush-caches

# macOS
sudo dscacheutil -flushcache
```

---

## 🏗️ Real-Life Scenario: The "Disk Full" Cascade
**Problem**: A log aggregator fills the disk. The app can't write new logs and crashes.
**Manual Fix**: An engineer SSHs in, deletes old logs, restarts the app. Takes 15 minutes.
**Automated Fix**: A CloudWatch alarm triggers a Lambda function that runs the cleanup script and restarts the service.
**Outcome**: MTTR drops from 15 minutes to 45 seconds.

---

## ❓ Interview Questions
1.  **When is it safe to automatically restart a service?**
    *   *Answer*: When the service is stateless (or has proper session replication), when there's a retry limit to prevent infinite loops, and when the restart is graceful (drains connections first).
2.  **Why is 'Proactive Scaling' better than 'Reactive Scaling'?**
    *   *Answer*: Proactive scaling anticipates load increases (e.g., based on time of day or queue depth) and scales *before* performance degrades, preventing user-facing issues.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which pattern fixes high error rates?** (Service Restarter)
2.  **True/False: You should delete all log files when disk is full.** (False - only old/rotated logs)
3.  **What is HPA in Kubernetes?** (Horizontal Pod Autoscaler)
4.  **Which signal reloads config without full restart?** (SIGHUP)
5.  **What causes 'Too many connections' errors?** (Connection pool exhaustion/leak)

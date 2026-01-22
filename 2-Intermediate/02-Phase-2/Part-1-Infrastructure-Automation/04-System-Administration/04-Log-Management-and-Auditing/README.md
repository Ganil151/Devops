# 📜 04: Log Management & Auditing

> **"If it wasn't logged, it didn't happen. If it was logged but not audited, you'll never find out who did it."**

---

## 🏛️ Architecture: The Telemetry Pipeline

Logs are the "Black Box" of your aircraft. In an enterprise environment, we move beyond just reading `/var/log/syslog` into structured auditing and centralized collection.

### Log Workflow

```mermaid
graph LR
    Service[Service / App] --> Journal[Systemd-Journald]
    Journal --> Syslog[Rsyslog / Syslog-ng]
    Syslog --> Local[/var/log/...]
    Syslog --> Remote[Centralized Log Server / ELK]
    
    Audit[Kernel Auditd] --> AuditLog[/var/log/audit/audit.log]
    
    style Journal fill:#f0f9ff,stroke:#0369a1
    style AuditLog fill:#fdf2f2,stroke:#ef4444
    style Remote fill:#f0fdf4,stroke:#15803d
```

---

## 🌟 Overview

This module covers **System Accountability**. You will learn how to manage the massive amount of data servers generate and how to set up "Tripwires" to detect unauthorized changes.

### Key Intermediate Topics:
1.  **Systemd-Journald**: Mastering `journalctl` to filter by service, time, and severity.
2.  **Log Rotation**: Using `logrotate` to prevent disks from filling up with old logs.
3.  **Auditd (Linux Audit Framework)**: The ultimate auditing tool. Tracking file deletions, permission changes, and command execution at the kernel level.
4.  **Structured Logging**: Understanding JSON logs for better automated analysis.

---

## 🏆 Real-World Scenario: The "Who Deleted the Config?" Mystery

**The Crisis**: A critical Nginx config file was deleted, taking down the site. The standard syslog just showed the error that Nginx couldn't start, but not who deleted the file.
**The Solution**: An intermediate implementation of **Auditd**.
1.  **Set a Watch**: `auditctl -w /etc/nginx/nginx.conf -p wa -k nginx_change`.
2.  **Audit the Event**: When it happened again, the admin ran `ausearch -k nginx_change`.
3.  **Identify the Culprit**: The audit log clearly showed the UID, PID, and the exact timestamp of the `rm` command.
**Result**: The admin identified a malicious script running under a service account and neutralized it.

---

## ❓ Interview Preparation (Logging & Audit)

1.  **Q: How do you view logs for a specific systemd service for only the last 2 hours?**
    *A: Use `journalctl -u service_name --since "2 hours ago"`. This is significantly faster than grepping through text files.*

2.  **Q: What is the main benefit of Auditd over standard Syslog?**
    *A: Syslog records what services *want* to tell you (e.g., "Login Failed"). Auditd records what the kernel *sees* (e.g., "Process 1234 edited file X"). Auditd is tamper-resistant and captures much deeper system interactions.*

---

## 📝 Knowledge Check

1. **Which command is used to query the systemd journal?**
- [ ] a) `logctl`
- [x] b) `journalctl`
- [ ] c) `viewlog`

2. **True or False: Log rotation is necessary to prevent log files from consuming all available disk space.**
- [x] True
- [ ] False

---

## 🔗 Next Steps
Proceed to: **[Kernel & Boot Systems](../05-Kernel-and-Boot-Systems/README.md)** →

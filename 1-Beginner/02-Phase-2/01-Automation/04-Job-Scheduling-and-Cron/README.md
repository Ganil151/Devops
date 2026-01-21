# ⏱️ Job Scheduling: The Pulse of Automation

> **"Automation without scheduling is just a script waiting for a human."**

In DevOps, we don't just write scripts; we give them a heartbeat. This module covers how to make your code run automatically—whether it's a backup script at 3 AM or a cleanup task every Sunday.

## 🗺️ Module Architecture

We follow the evolution of Linux scheduling, from 1970s Unix tools to modern cloud orchestrators.

### 🕰️ Part 1: Cron (The Universal Standard)
*The classic way to schedule tasks on Linux.*

*   **[01. Crontab Syntax](./Part-01-Cron-Basics/01-Crontab-Syntax/README.md)**: Decoding `* * * * *`.
*   **[02. Cron Patterns](./Part-01-Cron-Basics/02-Patterns-and-Pitfalls.md)**: Handling Environment variables and "Silent Failures".

### ⚙️ Part 2: Systemd Timers (The Modern Standard)
*Why modern Linux distros (RHEL, Ubuntu, CentOS) are moving away from Cron.*

*   **[01. Systemd Concepts](./Part-02-Systemd-Timers/01-Systemd-Timers/README.md)**: Units, Timers, and Accuracy.
*   **[02. Creating a Timer](./Part-02-Systemd-Timers/02-Creating-Timers.md)**: Using `.service` and `.timer` files.

### ☁️ Part 3: Cloud Orchestration (The Distributed Future)
*Scheduling tasks when you have 1,000 servers.*

*   **[01. Distributed Jobs](./Part-03-Modern-Orchestration/01-Cloud-Schedulers/README.md)**: Kubernetes CronJobs and CloudWatch Events.

---

## ⚡ The "Cron vs Systemd" Quick Check

| Feature | Cron | Systemd Timer |
| :--- | :--- | :--- |
| **Simplicity** | ✅ High (1 line of text) | ❌ Low (2 files needed) |
| **Logging** | ❌ None (unless you redirect) | ✅ Native (`journalctl`) |
| **Dependencies** | ❌ None | ✅ Wait for Network/Disk |
| **Complexity** | Simple Tasks | Production Services |

**Rule of Thumb**:
*   Use **Cron** for quick user scripts.
*   Use **Systemd** for critical infrastructure services.

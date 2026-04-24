# ⏱️ Job Scheduling: The Pulse of Automation

> **"Automation without scheduling is just a script waiting for a human."**

In DevOps, we don't just write scripts; we give them a heartbeat. This module covers how to make your code run automatically—whether it's a backup script at 3 AM or a cleanup task every Sunday.

## 🗺️ Module Architecture

We follow the evolution of Linux scheduling, from 1970s Unix tools to modern cloud orchestrators.

### 🕰️ Part 1: Cron (The Universal Standard)
*The classic way to schedule tasks on Linux.*

*   **[01. Crontab Syntax](./part-01-cron-basics/01-crontab-syntax/readme.md)**: Decoding `* * * * *`.
*   **[02. Cron Patterns](./part-01-cron-basics/02-patterns-and-pitfalls.md)**: Handling Environment variables and "Silent Failures".

Check your timers:
`systemctl list-timers`

---

## 🏢 Reference Library
*Deep-dive documentation for at-a-glance problem solving.*

*   **[Cron Syntax](./reference/cron-syntax-standard-ref.md)**: Universal scheduling, paths, and environment traps.
*   **[Systemd Timers](./reference/systemd-timers-architecture-ref.md)**: Granular Linux scheduling, journal integration, and cgroups.
*   **[Distributed Scheduling](./reference/distributed-job-scheduling-ref.md)**: K8s CronJobs, EventBridge, and high-scale orchestration.

### ⚙️ Part 2: Systemd Timers (The Modern Standard)
*Why modern Linux distros (RHEL, Ubuntu, CentOS) are moving away from Cron.*

*   **[01. Systemd Concepts](./part-02-systemd-timers/01-systemd-timers/readme.md)**: Units, Timers, and Accuracy.
*   **[02. Creating a Timer](./part-02-systemd-timers/02-creating-timers.md)**: Using `.service` and `.timer` files.

### ☁️ Part 3: Cloud Orchestration (The Distributed Future)
*Scheduling tasks when you have 1,000 servers.*

*   **[01. Distributed Jobs](./part-03-modern-orchestration/01-cloud-schedulers/readme.md)**: Kubernetes CronJobs and CloudWatch Events.

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

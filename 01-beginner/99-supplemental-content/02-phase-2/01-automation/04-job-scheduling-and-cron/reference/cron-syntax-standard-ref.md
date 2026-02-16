# 🕒 Cron Syntax & Standard Scheduling
*Version 1.0 | Mastering the Universal Job Scheduler*

---

## 📖 Overview
Cron is a time-based job scheduler in Unix-like operating systems. It is the most ubiquitous tool for backend tasks, from log rotation to database backups. Understanding its syntax and limitations is essential for stable infrastructure operations.

---

## 🏗️ Technical Pillars: The Cron Expression

A cron expression consists of 5 (or sometimes 6) fields:
```
* * * * *
┬ ┬ ┬ ┬ ┬
│ │ │ │ └─ Day of week (0 - 6) (0 is Sunday)
│ │ │ └─── Month (1 - 12)
│ │ └───── Day of month (1 - 31)
│ └─────── Hour (0 - 23)
└───────── Minute (0 - 59)
```

### 1. Special Characters
- **`*`**: Every occurrence (Any).
- **`,`**: List of values (e.g., `1,15,30` for minutes).
- **`-`**: Range of values (e.g., `1-5` for days).
- **`/`**: Increments (e.g., `*/15` for every 15 minutes).

---

## ⚙️ Cron Management Files

| File/Path | Purpose |
| :--- | :--- |
| `/etc/crontab` | System-wide cron jobs. |
| `/etc/cron.d/` | Directory for individual system service cron files. |
| `/var/spool/cron/` | Directory for user-specific crontabs (accessed via `crontab -e`). |
| `/etc/cron.daily/` | Scripts executed once a day. |

---

## 🚀 SRE Safety Standards

### 1. The Environment Trap
Cron runs with a very limited environment. It does NOT load your `.bashrc` or `.profile`.
**Rule**: Always use **absolute paths** for binaries and files (e.g., `/usr/bin/python3` instead of `python3`).

### 2. Logging & Redirection
By default, cron tries to "mail" the output. In modern serverless/cloud environments, this is ignored.
**Rule**: Always redirect `stdout` and `stderr` to a log file.
`* * * * * /opt/script.sh >> /var/log/script.log 2>&1`

### 3. Locking (Avoid Overlaps)
If a job runs every minute but takes 2 minutes to finish, you will have multiple instances running.
**Rule**: Use `flock` or a lockfile to ensure only one instance runs.

---

## ❓ Interview "Deep-Cut" Questions
1. **How do you handle timezone differences in a global server fleet using cron?**
2. **Explain the purpose of the `MAILTO` variable in a crontab file.**
3. **What is the difference between `/etc/crontab` and `crontab -e` in terms of syntax (the user field)?**
4. **How would you schedule a job to run on the "Last Friday of every month"?**
5. **Describe how `anacron` differs from standard `cron` for desktop/laptop environments.**

---
**Next Step**: [Systemd Timers Architecture →](./systemd-timers-architecture-ref.md)

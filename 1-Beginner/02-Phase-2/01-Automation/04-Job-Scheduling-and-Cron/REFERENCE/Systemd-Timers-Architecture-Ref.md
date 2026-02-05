# ⏱️ Systemd Timers: The Modern Scheduler
*Version 1.0 | Engineering Robust Local Auto-Automation*

---

## 📖 Overview
Systemd timers are the modern replacement for Cron on Linux systems using `systemd`. They provide more granular control, better logging (via `journalctl`), and integration with system resource limits (`cgroups`).

---

## 🏗️ Core Architecture Components
A systemd timer requires two files:
1. **The Service Unit (`.service`)**: Defines *what* to run.
2. **The Timer Unit (`.timer`)**: Defines *when* to run it.

### 1. The .timer File Example
```ini
[Unit]
Description=Run My Script Hourly

[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=5m

[Install]
WantedBy=timers.target
```

---

## ⚙️ Key Technical Features

### 1. Real-Time vs Monotonic Timers
- **Real-Time (`OnCalendar`)**: Triggers based on wall-clock time (like Cron).
- **Monotonic (`OnUnitActiveSec`)**: Triggers based on an event (e.g., "30 minutes after the service last finished").

### 2. Accuracy & Randomization
- **AccuracySec**: Defines the window in which the timer is allowed to skip to save battery/CPU.
- **RandomizedDelaySec**: Adds a random jitter to the start time (Essential for preventing "Thundering Herd" API requests).

### 3. Persistency
- **Persistent=true**: If the machine was powered off when the timer should have fired, it will fire immediately upon next boot.

---

## 🚀 SRE Advantage Table

| Feature | Cron | Systemd Timer |
| :--- | :--- | :--- |
| **Granularity** | 1 Minute | 1 Microsecond |
| **Dependency** | Simple time-based | Can depend on other services |
| **Observability**| Simple logs | Integrated with `journalctl` |
| **Recovery** | Hard to track misses| `Persistent` flag handles power-offs|
| **Resource Control**| None | Can set Memory/CPU limits via service |

---

## 🛠️ Management Commands
- `systemctl list-timers`: List all active timers and their next trigger time.
- `journalctl -u my-service.service`: Inspect the logs of the scheduled task.

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain why a Systemd Timer is considered more "Observable" than a Cron job.**
2. **What is a "Thundering Herd" problem and how does `RandomizedDelaySec` solve it?**
3. **Describe how to create a timer that runs "Every 5 minutes starting from when the previous run finished."**
4. **How do you link a Timer to a specific Service unit if they have different names?**
5. **What is the `timers.target` and why is it needed in the `[Install]` section?**

---
**Next Step**: [Distributed Job Scheduling →](./Distributed-Job-Scheduling-Ref.md)

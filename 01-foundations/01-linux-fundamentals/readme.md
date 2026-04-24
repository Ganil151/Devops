# 🐧 Linux Mastery: The Cloud Foundation

> **"Linux is the bedrock of the cloud. Almost all containers, servers, and cloud services run on a Linux kernel. If you treat Linux like Windows, you will fail; if you treat it like an engine, you will fly."**

---

## 🏗️ Filesystem Hierarchy Standard (FHS)
Understanding where files live is non-negotiable for DevOps.

<LINUX_FHS_DIAGRAM>

| Directory | Purpose | DevOps Why |
| :--- | :--- | :--- |
| `/etc` | Config files | Central nervous system for apps (Nginx, SSH). |
| `/var/log` | Log files | The first place for troubleshooting. |
| `/root` | Root home | Admin territory (limit its use). |
| `/opt`| Third-party apps | Standard home for Prometheus, Grafana, etc. |

---

## 🚀 Professional Guide: Reading Production Logs
In a CI/CD world, logs are your eyes. Mastering log inspection is the difference between minutes and hours of downtime.

### The SRE Log Toolkit
| Tool | command | Senior Tip |
| :--- | :--- | :--- |
| `tail -f` | `tail -f /var/log/syslog` | Use for real-time monitoring of live events. |
| `grep` | `grep "ERROR" app.log` | Filter noise to find specific failures. |
| `less` | `less +G /var/log/nginx/error.log` | Navigate huge files without crashing the terminal. |
| `awk` | `awk '{print $4}' access.log` | Extract specific columns (like status codes). |

> **Senior Tip**: Always use `tail -n 100` before `-f` to get immediate context without being overwhelmed by the entire history.

---

## 🧠 The Mental Model: The Engine Room

**The Newbie Struggle**: "I'm staring at a black screen with a blinking cursor. I feel like I'm blind."

**The Engineer Solution**: You realize that Linux isn't a "Product"; it's a **Tool**. You learn to talk to the kernel directly. You realize that **Everything is a File**, and once you master the commands, you have more power than any GUI could ever give you.

---

## 🛠️ The Linux Toolbelt (Essential Commands)
| Command | Purpose | DevOps Why |
| :--- | :--- | :--- |
| `top` / `htop` | Resource monitoring | Identifying CPU/RAM "thieves" in production. |
| `df -h` | Disk usage | Preventing "Disk Full" outages. |
| `ps aux` | Process list | Checking if your application service is actually running. |
| `chmod` | Permissions | Security hardening for private keys and secrets. |

---

## 📂 Module Structure

1.  **[01-Introduction](./01-introduction/readme.md)**: Kernel vs. Distros (RHEL, Debian, Alpine).
2.  **[02-Filesystem](./02-filesystem/readme.md)**: The FHS Standard (Where do things go?).
3.  **[03-Commands](./03-commands/readme.md)**: The SRE Essential Toolkit.
4.  **[04-Permissions](./04-permissions/readme.md)**: The Security Model (u, g, o).
5.  **[SSH Mastery](./ssh/readme.md)**: Secure remote administration.

---

## 🏆 Real-World DevOps Story: The 2:00 AM Disk Full Error

**The Incident**: A production database stopped accepting connections. 
**The Fix**: A Senior SRE used `df -h` to find the mount point, `du -sh` to find the log file, and `> file.log` to truncate it.
**The Lesson**: The GUI wouldn't have saved you here. Command-line proficiency is survival.

---

**Next Step**: Start with **[Introduction to Linux](./01-introduction/readme.md)**

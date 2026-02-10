# 🐧 Technical Deep Dive: Linux Interview Mastery

Master the OS that runs the cloud. Shift from "copy-pasting commands" to understanding the kernel and system lifecycle.

## 📋 Table of Contents
- [🟢 Junior Tier: The Fundamentals](#-junior-tier-the-fundamentals)
- [🟡 Intermediate Tier: The Professional](#-intermediate-tier-the-professional)
- [🔴 Senior Tier: The Staff Engineer](#-senior-tier-the-staff-engineer)
- [🗝️ Master Key: Interviewer's Secret Summary](#️-master-key-interviewers-secret-summary)

---

## 🟢 Junior Tier: The Fundamentals

#### Q: What are the basic Linux commands every DevOps engineer should know? [Junior]
**Problem:** Demonstrating command-line fluency.
**Solution:**
- **Navigation:** `ls`, `cd`, `pwd`
- **File Ops:** `cp`, `mv`, `rm`, `mkdir`
- **Text:** `cat`, `grep`, `sed`, `awk`, `less`
- **System:** `top`, `df -h`, `free -m`, `ps aux`
**Insight (The Interviewer's Secret):** Don't just list them. Mention **Piping and Redirection** (`|`, `>`, `>>`). Showing you can chain commands together for automation is the real test.

#### Q: Explain the Linux File System Hierarchy (FHS) [Junior]
**Problem:** Understanding where things live.
**Solution:**
- `/etc`: Configuration files.
- `/var/log`: System and app logs.
- `/bin` & `/usr/bin`: Executables.
- `/home`: User data.
- `/root`: Root user home.
- `/tmp`: Temporary files.
**Insight (The Interviewer's Secret):** Mention **`/proc`**. Explain that it's a "virtual file system" that provides an interface to the kernel and process information.

---

## 🟡 Intermediate Tier: The Professional

#### Q: What is Shell Scripting and why use it? [Intermediate]
**Problem:** Automating repetitive OS tasks.
**Solution:** Shell scripting (Bash) is the process of writing a series of commands for the shell to execute. It's used for setup tasks, backups, and simple automation.
**Insight (The Interviewer's Secret):** Mention **Error Handling**. A pro script uses `set -e` (exit on error) and `set -u` (exit on unset variables). Discussing exit codes (`$?`) shows you write robust automation.

#### Q: What is systemd and how do you manage services? [Intermediate]
**Problem:** Service lifecycle and initialization.
**Solution:** `systemd` is the init system and service manager for most modern Linux distros.
- `systemctl start/stop/restart/status <service>`
- `systemctl enable <service>` (starts on boot)
**Insight (The Interviewer's Secret):** Mention **Journalctl**. Explain how to use `journalctl -u <service> -f` to follow logs for a specific service. This is the first thing an engineer should do when a service fails.

---

## 🔴 Senior Tier: The Staff Engineer

#### Q: How do you troubleshoot high Load Average when CPU is low? [Senior]
**Problem:** Understanding wait states and I/O bottlenecks.
**Solution:** Load average represents the number of processes in a "runnable" or "uninterruptible" state. If CPU is low, it usually means **I/O Wait** (waiting for disk or network).
**Insight (The Interviewer's Secret):** Use the term **"Zombie Processes"** or **"D state"**. Discuss using `iostat` or `iotop` to identify if the disk is saturated or if there's a network mount (NFS) causing the hang.

#### Q: Explain the difference between Hard Links and Soft (Symbolic) Links [Senior]
**Problem:** Deep dive into inodes and references.
**Solution:**
- **Soft Link:** A pointer to a filename (like a shortcut). If the original file is deleted, the link breaks.
- **Hard Link:** A second name for the same data (inode). If the original file is deleted, the data remains until all hard links are gone.
**Insight (The Interviewer's Secret):** A senior knows that hard links cannot cross file systems/partitions, but soft links can. This is a common "gotcha" question.

---

## 🗝️ Master Key: Interviewer's Secret Summary
| Concept | What they are REALLY looking for |
| :--- | :--- |
| **Permissions** | Do you understand `chmod` vs `chown` and what `root` actually means? |
| **SSH** | Do you know how to manage keys and why password auth should be disabled? |
| **Package Managers** | Can you explain the difference between `apt`, `yum/dnf`, and `pacman`? |
| **Kernel Tuning** | Have you ever modified `/etc/sysctl.conf` to optimize network or memory? |

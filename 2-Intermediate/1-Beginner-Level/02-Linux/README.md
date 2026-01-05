# Intermediate Linux: System Administration & Operations

Moving beyond basic commands, this level focuses on managing production Linux systems, understanding service lifecycles, and automating complex operations.

---

## 📂 Module Structure

### 🚀 Intermediate Topics
- **[System Administration](./System-Administration/)**: Managing `systemd` services, processes, and logs.
- **[Shell Scripting](../02-Automation/01-Shell-Scripting-Basics/)**: Writing reusable Bash scripts and logic.
- **[Linux Networking](./Networking/)**: Troubleshooting interfaces, routing, and ports.
- **[Intermediate SSH](./SSH/)**: Keys, config files, and tunneling.

---

## 🏗️ Core Concepts

### 1. Systemd Service Management
DevOps engineers must know how to keep applications running.
- **`systemctl start/stop/restart`**: basic control.
- **`systemctl enable/disable`**: managing persistence across boots.
- **`systemctl status`**: the first step in troubleshooting.

### 2. Process Lifecycle
- **`top` / `htop`**: Monitoring resource consumption.
- **`kill` / `pkill` / `killall`**: Handling runaway processes.
- **`nice` / `renice`**: Managing process priority.

### 3. Log Analysis
- **`journalctl`**: The modern interface for systemd logs.
- **`tail -f /var/log/syslog`**: Classic real-time log monitoring.
- **`grep` / `awk` / `sed`**: Extracting meaning from large log files.

---

## 📊 Linux System Architecture

```mermaid
graph TD
    User([User Space Applications]) --> Shell[Shell: Bash/Zsh]
    Shell --> Syscalls[System Calls]
    Syscalls --> Kernel[Linux Kernel]
    Kernel --> HW[Hardware: CPU/RAM/Disk]
    
    Kernel --> MemM[Memory Management]
    Kernel --> ProcM[Process Management]
    Kernel --> Net[Networking Stack]
    Kernel --> VFS[Virtual File System]
```

---

## ❓ Interview Questions & Quiz
**[Explore Interview Questions & Quizzes](./Interview_Questions_and_Quiz.md)**

---

## ✅ Intermediate Knowledge Check
- [ ] Create and manage custom `systemd` services
- [ ] Write a Bash script with loops and conditionals
- [ ] Troubleshoot network connectivity using `ip`, `ss`, and `dig`
- [ ] Configure SSH for key-based authentication
- [ ] Manage disk space using LVM or simple partitions
- [ ] Analyze application logs to identify root causes

# ⚒️ Essential Linux Commands: The Binary Bible
*Version 1.0 | High-Performance Terminal Operations for SREs*

---

## 📖 Overview
In a world of GUIs, the Linux Terminal is the professional interface for high-velocity automation and heavy-duty troubleshooting. These commands form the foundation of almost every shell script and CI/CD pipeline step you will ever write.

---

## 📂 Navigation & Filesystem Operations

### `ls` / `ll`
**Definition**: Lists directory contents. `ll` is often an alias for `ls -la`.
**Example**: `ls -lh /var/log` (List files with human-readable sizes).

### `cd`
**Definition**: Changes the current working directory.
**Example**: `cd ~` (Go home) or `cd -` (Return to previous directory).

### `cp` / `mv` / `rm`
**Definition**: Copy, Move/Rename, and Remove files.
**Example**: `cp -r ./src /opt/app` (Recursive copy). 
**Warning**: Never run `rm -rf /` as root.

### `find`
**Definition**: Searches for files in a directory hierarchy based on diverse criteria.
**Example**: `find /var/log -name "*.log" -mtime -7` (Find logs modified in the last 7 days).

---

## 📝 Data Processing & Inspection

### `cat` / `less` / `tail`
**Definition**: Output file content. `cat` prints all; `less` allows scrolling; `tail` shows the end.
**Example**: `tail -f /var/log/syslog` (Follow the log in real-time).

### `grep`
**Definition**: Searches for patterns (regex) within text.
**Example**: `grep -i "error" /var/log/nginx/access.log`.

### `awk` / `sed`
**Definition**: `awk` is a field-based text processor; `sed` is a stream editor for transformations.
**Example**: `cat file.csv | awk -F',' '{print $1}'` (Print first column).

---

## ⚙️ System Performance & Processes

### `top` / `htop`
**Definition**: Dynamic real-time view of running processes and resource usage (CPU/RAM).
**Example**: Running `htop` to identify a memory-leaking process.

### `ps`
**Definition**: Snapshot of current processes.
**Example**: `ps aux | grep nginx` (Find the PID of nginx).

### `kill` / `pkill`
**Definition**: Sends signals to processes (terminating them).
**Example**: `kill -9 1234` (Forcefully kill process 1234).

### `df` / `du`
**Definition**: `df` reports disk space usage; `du` estimates file space usage.
**Example**: `du -sh /var` (Check total size of the /var directory).

---

## 🌐 Network Diagnostics (Binary Tier)

### `curl` / `wget`
**Definition**: Transfers data from or to a server (HTTP, FTP, etc.).
**Example**: `curl -I https://google.com` (Inspect HTTP headers).

### `ip`
**Definition**: Modern tool for managing routing, devices, and policy routing.
**Example**: `ip addr show` (Check IP addresses).

### `ss` / `netstat`
**Definition**: Investigates sockets and network statistics.
**Example**: `ss -tulpn` (List all listening ports and their associated PIDs).

---

## ⚡ SRE Power Moves
- **Piping (`|`)**: Chain commands together. `ls | grep "test" | wc -l`.
- **Redirects (`>` / `>>`)**: Send output to files. `>` overwrites, `>>` appends.
- **Sudo (`sudo !!`)**: Re-run the last command with root privileges.

---
**Next Step**: [SSH Security & Configuration →](./linux-ssh-security-ref.md)

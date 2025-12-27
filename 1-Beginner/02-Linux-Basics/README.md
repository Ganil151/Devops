# Linux Basics & System Administration

Linux is the backbone of the cloud. Almost all containers, servers, and cloud services run on a Linux kernel. This module covers everything from first commands to advanced system management.

---

## 🐧 1. Why Linux?

DevOps engineers live in the shell. Linux provides the flexibility, security, and performance required to run high-scale workloads.
- **Open Source**: Full transparency and customizability.
- **Lightweight**: Can run on everything from a Raspberry Pi to a supercomputer.
- **CLI-First**: Perfect for automation and scripting.

## 🎯 Learning Objectives

- Navigate the Linux filesystem efficiently
- Manage files, directories, and permissions
- Monitor system resources and processes
- Automate tasks with basic shell scripting
- Secure a Linux server for production use

## 📂 Module Structure

This module is organized into the following sections:

### 🔰 Beginner Level
- **[01-Introduction](./1-Beginner-Level/01-Introduction/)**: Core concepts and architecture.
- **[02-Filesystem](./1-Beginner-Level/02-Filesystem/)**: Understanding the Linux file hierarchy.
- **[03-Commands](./1-Beginner-Level/03-Commands/)**: Essential commands for everyday tasks.
- **[04-Permissions](./1-Beginner-Level/04-Permissions/)**: User management and file permissions.

### 🚀 Intermediate Level
- **[System Administration](./2-Intermediate-Level/System-Administration/)**: Managing processes, services, and logs.
- **[Networking](./2-Intermediate-Level/Networking/)**: Linux networking fundamentals.
- **[Shell Scripting](./2-Intermediate-Level/Shell-Scripting/)**: Automating tasks with Bash.

### 🛡️ Advanced Level
- **[Security](./3-Advanced-Level/Security/)**: Hardening and securing your system.
- **[Performance](./3-Advanced-Level/Performance/)**: Optimization and monitoring.
- **[Virtualization & WSL](./3-Advanced-Level/Virtualization-WSL/)**: Using Linux on Windows (WSL) and VMs.

### 📚 Resources
- **[Resources](./Resources/)**: Additional guides and cheat sheets.

## 📖 Essential CLI Tools

### 📂 File & Directory Management
*When to use: Navigating and organizing the filesystem.*

```bash
# List files with details and hidden files
ls -la

# Create directory including parents
mkdir -p projects/app/src

# Move or rename files
mv old_name.txt new_name.txt

# Securely copy files between servers
scp local_file.txt user@remote_host:/path/to/dest
```

### 🔍 System Inspection
*When to use: Checking system health, resources, and logs.*

```bash
# Real-time system monitoring
top   # OR 'htop' for a better UI

# Disk space usage
df -h

# Memory usage
free -m

# Search for patterns in files
grep -r "ERROR" /var/log/
```

---

## 💡 Linux Best Practices

- **Never use Root**: Always use a standard user and `sudo` only when necessary.
- **Bash Scripting**: Automate repetitive tasks using simple shell scripts.
- **Log Everything**: Check `/var/log` when something goes wrong.
- **SSH Security**: Disable root login and password authentication for remote servers.
- **File Permissions**: Use the "Principle of Least Privilege". Don't `chmod 777` unless you absolutely have to.

---

## 🧪 Practical Labs

### Lab 1: System Inspection & Cleanup

**Scenario**: The "Disk Full" Panic. An application starts failing with `No space left on device`.
**Task**: Identify the large files and clean them up.
**Solution**:
1.  **Check Usage:** Run `df -h` to find the full partition.
2.  **Find the Culprit:** Run `du -sh * | sort -hr` in the `/var/log` or root directory to find which folder is consuming the most space.
3.  **The Fix:** Compress old logs (`gzip`) or delete temporary files in `/tmp`.

### Lab 2: Permission Management

**Scenario**: Permission Denied on Script. You try to run `./deploy.sh` but get `bash: ./deploy.sh: Permission denied`.
**Task**: Fix the permissions to allow execution.
**Solution**:
1.  **Check Permissions:** Run `ls -l deploy.sh`.
2.  **Observation:** The file has `-rw-r--r--` permissions (no `x`).
3.  **The Fix:** Grant execution permission using `chmod +x deploy.sh`.

### Lab 3: Log Monitoring

**Scenario**: You need to monitor a log file in real-time as your application starts up.
**Task**: Use `tail` to watch the log.
**Solution**:
```bash
tail -f /var/log/syslog
```

## 🧠 Knowledge Quiz

**1. Which command would you use to find all files ending in `.log` in the current directory?**
- A) `ls *.log`
- B) `find . -name "*.log"`
- C) `grep "*.log" .`
- D) `df -h *.log`

**2. What does the `chmod 644 file.txt` command do?**
- A) Gives everyone full access
- B) Owner: Read/Write, Group/Others: Read-only
- C) Makes the file executable
- D) Only root can read the file

**3. How do you view the last 20 lines of a log file in real-time as they appear?**
- A) `cat -n logfile.log`
- B) `tail -f -n 20 logfile.log`
- C) `head -20 logfile.log`
- D) `grep -20 logfile.log`

---



---

## ✅ Knowledge Check
- [ ] Master basic navigation (`cd`, `ls`, `pwd`)
- [ ] Understand absolute vs relative paths
- [ ] Use `grep`, `find`, and `awk` for text processing
- [ ] Manage users and groups
- [ ] Monitor CPU, RAM, and Disk usage

## 🏆 Related Certifications

- **CompTIA Linux+**: Validates the competencies required of an early-career system administrator supporting Linux systems.
- **Linux Foundation Certified System Administrator (LFCS)**: Validates the ability to proficiently install, configure, and operate Linux-based systems.
- **Red Hat Certified System Administrator (RHCSA)**: A very hands-on, respected certification for Red Hat Enterprise Linux environments.

---

## 🔗 Next Steps
- **[SSH & Remote Access](../03-SSH/)** - Securely connect to your Linux servers.
- **[Git & GitHub](../04-Git-GitHub/)** - Version control your scripts and configs.
- **[Windows Basics](../16-Windows-Basics/)** - Learn about Windows administration.

---
*The shell is your cockpit—learn the gauges and you can fly anything.*

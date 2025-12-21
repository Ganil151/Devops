# Linux Basics & System Administration

Linux is the backbone of the cloud. Almost all containers, servers, and cloud services run on a Linux kernel. This module covers everything from first commands to advanced system management.

---

## 1. Why Linux?

DevOps engineers live in the shell. Linux provides the flexibility, security, and performance required to run high-scale workloads.
- **Open Source**: Full transparency and customizability.
- **Lightweight**: Can run on everything from a Raspberry Pi to a supercomputer.
- **CLI-First**: Perfect for automation and scripting.

---

## 2. Core Modules

### 🐧 [Operating Systems](./Operate-Systems/README.md)
Understand kernels, shells, filesystems, and how Linux manages hardware.

### 🛠️ [System Administration (SysAdmin)](./SysAdmin/README.md)
Practical skills for managing users, permissions, packages, and system health.

---

## 3. Essential Concepts
- **Root & Sudo**: Understanding administrative privileges and the "Principle of Least Privilege".
- **File Permissions**: Mastering `chmod` and `chown` to secure your data.
- **Process Management**: Using `top`, `ps`, and `kill` to manage running applications.
- **Package Management**: Using `apt`, `yum`, or `dnf` to install software.

---

## 4. Best Practices
1. **Never use Root**: Always use a standard user and `sudo` only when necessary.
2. **Bash Scripting**: Automate repetitive tasks using simple shell scripts.
3. **Log Everything**: Check `/var/log` when something goes wrong.
4. **SSH Security**: Disable root login and password authentication for remote servers.

---
**Networking**: Learn how Linux systems communicate in the [Networking Foundations Module](../05-Networking/README.md).

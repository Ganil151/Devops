# 📂 Linux Filesystem Hierarchy: The SRE Map
*Version 1.0 | Standardizing Data Locations & OS Layout*

---

## 📖 Overview
The Linux Filesystem Hierarchy Standard (FHS) defines where binaries, configuration files, and data reside. For an SRE, knowing this map is essential for troubleshooting application crashes, locating logs, and managing storage mounts.

---

## 🏛️ Essential FHS Directories

### `/` (Root)
**Definition**: The starting point of the entire filesystem. Every file and directory is a child of root.
**Example**: Running `ls /` shows the top-level OS structure.

### `/bin` & `/sbin` (Binaries)
**Definition**: Essential command-line binaries required to boot and repair the system. `/sbin` contains "System" binaries typically restricted to root.
**Example**: `ls /bin/ls` (List tool), `ls /sbin/fdisk` (Disk partitioning).

### `/etc` (Configuration)
**Definition**: The "Engine Room." Contains all host-specific system configuration files.
**Example**: `/etc/nginx/nginx.conf` (Webserver settings), `/etc/fstab` (Disk mount config).

### `/var` (Variable Data)
**Definition**: Files that change size frequently, such as logs, spool files, and temporary database data.
**Example**: `/var/log/syslog` (System log), `/var/lib/mysql` (Database files).

### `/home` & `/root` (Users)
**Definition**: `/home` stores personal data for standard users; `/root` is the home directory for the administrative superuser.
**Example**: `/home/ganil/.ssh/` (User's SSH keys).

### `/tmp` (Temporary)
**Definition**: A global "scratch pad" for short-term files. Many systems wipe this directory on reboot.
**Example**: `/tmp/install_script.sh`.

### `/proc` & `/sys` (Virtual Filesystems)
**Definition**: Virtual filesystems that represent the kernel state, hardware information, and running processes.
**Example**: `cat /proc/cpuinfo` (Get CPU specs), `ls /sys/class/net` (List network interfaces).

---

## 📏 Pathing Standards

### Absolute Paths
**Definition**: The full path starting from the root (`/`). It is deterministic and works regardless of your current directory.
**Example**: `/var/log/nginx/error.log`

### Relative Paths
**Definition**: A path based on your current working directory (CWD).
**Example**: `./logs/access.log` (In the current dir) or `../config.yaml` (Up one level).

---

## 💡 SRE Pro-Tips
- **Disk Full Recovery**: If `/` is full, check `/var/log` or `/tmp` first. These are the most common culprits for disk pressure.
- **Config Backup**: Before editing entries in `/etc`, always create a backup: `cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`.
- **Mount Points**: Use `df -h` to see which physical disks are mapped to which FHS directories.

---
**Next Step**: [Permissions & Ownership →](./Linux-Permissions-Ownership-Ref.md)

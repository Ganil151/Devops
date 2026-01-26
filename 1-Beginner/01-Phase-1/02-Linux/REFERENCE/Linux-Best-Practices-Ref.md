# 🌟 Linux Best Practices: The DevOps Standard
*Version 1.0 | Ensuring Stability, Security, and Scalability*

---

## 📖 Overview
A production Linux server is a high-availability asset. Following these best practices ensures that your systems are predictable, secure from common exploits, and optimized for automation performance.

---

## 🛡️ Security & Identity Standards

### Principle of Least Privilege (PoLP)
**Definition**: Creating individual users for specific applications rather than running everything as `root`.
**Example**: Running the Nginx service as the `www-data` user.

### Key-Based Authentication
**Definition**: Strictly disabling password logins in favor of RSA/Ed25519 keys.
**Action**: Edit `/etc/ssh/sshd_config` set `PasswordAuthentication no`.

### Regular Security Patching (CVE Defense)
**Definition**: Automating OS updates to close known security vulnerabilities.
**Action**: `sudo apt update && sudo apt upgrade -y` or configuring `unattended-upgrades`.

---

## 🚜 Operational & Automation Hygiene

### Infrastructure as Code (IaC) First
**Definition**: Never making manual configuration changes directly on a server. Every change must be tracked in a script or tool.
**Tools**: Use Ansible, Terraform, or simple Bash scripts stored in Git.

### Logging & Observability
**Definition**: Centralizing log collection so server state can be audited without SSHing in.
**Action**: Ensuring all critical applications log to `/var/log/` and using tools like CloudWatch or ELK.

### Immutable Filesystem Discipline
**Definition**: Separating application code from variable data (logs/configs) to prevent disk fill-ups from crashing the app.
**Action**: Mounting logs to a separate partition (e.g., `/dev/sdb` to `/var/log`).

---

## ⚡ Performance Optimization

### Swap Management
**Definition**: Ensuring a small swap partition/file exists to prevent OOM (Out Of Memory) kills on the kernel.
**Action**: `swapon --show` to verify current status.

### File Descriptor Limits (ulimit)
**Definition**: Increasing the number of simultaneous files a process can open (critical for databases and webservers).
**Action**: Tuning `/etc/security/limits.conf`.

### TCP Stack Tuning
**Definition**: Optimizing network buffers for high-throughput automation agents.
**Action**: Modifications in `/etc/sysctl.conf`.

---

## ✅ SRE Linux Checklist
- [ ] Is `sudo` restricted with specific logging?
- [ ] Is the firewall (`ufw` or `iptables`) blocking everything by default?
- [ ] Are logs being rotated automatically (via `logrotate`)?
- [ ] Is the SSH port changed or restricted by IP?
- [ ] Is the system backup verified and recoverable?

---
**Next Step**: [Back to Filesystem Hierarchy →](./Linux-Filesystem-Ref.md)

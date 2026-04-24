# 🛡️ Module 01.03: Hardening & Security in Systemd

> **"A service should have exactly enough power to do its job, and not a single permission more. Systemd isn't just a service manager; it is a sandbox that can cage a process to prevent a small hack from becoming a total disaster."**

```mermaid
graph TD
    subgraph Jail[The Systemd Sandbox]
        S[The Application Process]
        
        P1[NoNewPrivileges=true]
        P2[PrivateTmp=true]
        P3[ProtectSystem=strict]
        P4[ProtectHome=true]
    end

    S --- P1
    S --- P2
    S --- P3
    S --- P4

    P1 -.->|Prevents| Root[Privilege Escalation]
    P3 -.->|Protects| Bin[/usr /bin /etc]
    P4 -.->|Hides| Home[/home /root]

    style Jail fill:#fee2e2,stroke:#b91c1c
    style S fill:#3b82f6,stroke:#1d4ed8,color:#fff
```

## 📚 Overview

One of the most powerful features of modern Systemd is its built-in security directives. Historically, security meant setting file permissions and running as a non-root user. Systemd takes this further by providing **Linux Namespace** and **Cgroup** isolation directly in the unit file. This module covers how to "cage" your applications so that even if they are compromised through a web vulnerability, the attacker cannot see your home files, modify your system binaries, or escalate to root.

## 🎓 Learning Objectives

- ✅ Implement **Privilege Isolation** by running services as dedicated users.
- ✅ Configure **Filesystem Protections** (PrivateTmp, ProtectSystem, ProtectHome).
- ✅ Understand **Privilege Escalation Prevention** using `NoNewPrivileges`.
- ✅ Restrict resource usage (CPU/RAM) using built-in Systemd directives.
- ✅ Audit the security score of your services using `systemd-analyze security`.

---

## 🏗️ 1. Essential Security Directives

Add these to the `[Service]` section of your unit files for an instant security boost:

| Directive | Effect | Why use it? |
| :--- | :--- | :--- |
| `NoNewPrivileges=true` | Blocks `setuid` binaries. | Prevents a process from ever gaining root via an exploit. |
| `PrivateTmp=true` | Isolated `/tmp`. | Prevents attackers from seeing or touching other apps' temp files. |
| `ProtectSystem=strict` | Read-Only OS. | Makes `/usr`, `/boot`, and `/etc` read-only for that process. |
| `ProtectHome=true` | Hidden `/home`. | The application cannot see any user home directories or the root home. |
| `ReadWritePaths=` | Whitelist. | Only allows the app to write to specific folders (e.g., `/var/log/myapp`). |

---

## 🏗️ 2. Auditing Your Security

Did you know Systemd can "Grade" your service's security?

```bash
# Get a security report for a running service
systemd-analyze security nginx.service
```

This command will give you a score (0 to 10) and a list of specific improvements you can make to harden the service.

---

## 🚀 Professional Pattern: The "Read-Only" Web Server

Junior admins let their web servers write all over the disk. Senior admins lock the web server in a cage where it can only read the code and write to one specific log folder.

**The Pro Standard**:
1. **The Config**: `ProtectSystem=strict` and `ReadWritePaths=/var/log/nginx`.
2. **The Logic**: The web server can "see" the entire system, but it cannot "touch" anything. In fact, most of the OS is hidden from it.
3. **The Benefit**: Even if an attacker gets a shell inside your web application, they can't install a rootkit or modify your server configuration.
4. **The Outcome**: Dramatically reduced "Blast Radius" for security breaches.

---

## ❓ Interview Preparation

1. **Q: How does 'PrivateTmp=true' work under the hood?**
    *A: It uses 'Mount Namespaces'. When the service starts, Systemd creates a unique, private `/tmp` directory that is only visible to that service. To the application, it looks like `/tmp`, but on the host, it's hidden under `/tmp/systemd-private-...`.*

2. **Q: Why should you avoid running services as 'root' in the unit file?**
    *A: If an application is compromised, the attacker inherits the permissions of the user running it. If it's root, they have total control. Running as a dedicated `myapp_user` restricts the attacker to only the files that user owns.*

3. **Q: What is 'systemd-analyze security' used for?**
    *A: It provides a comprehensive audit of a service's hardening status. It checks for nearly 100 potential vulnerabilities (like lack of namespaces or excess capabilities) and gives a numeric "Exposure" score.*

---

## 📝 Knowledge Check

1. **Which directive prevents a service from seeing any user's /home directory?**
    - [ ] a) ProtectSystem=full
    - [ ] b) PrivateHome=yes
    - [x] c) ProtectHome=true
    - [ ] d) NoHomeAccess=true

1. **What does 'ProtectSystem=strict' do to the /etc directory?**
    - [ ] a) Deletes it
    - [ ] b) Hides it
    - [x] c) Makes it read-only for the service
    - [ ] d) Encrypts it

1. **Which command provides a security 'Score' for a unit?**
    - [ ] a) systemd-check
    - [x] b) systemd-analyze security
    - [ ] c) systemd-audit
    - [ ] d) journalctl -s

---

## 🔗 Next Steps

Security isn't just about cages; it's also about timing and relationships. Let's learn how to orchestrate service startups. Proceed to: **[04. Dependencies & Targets](../04-dependencies-and-targets/readme.md)** →
 Node: Moving into orchestration.

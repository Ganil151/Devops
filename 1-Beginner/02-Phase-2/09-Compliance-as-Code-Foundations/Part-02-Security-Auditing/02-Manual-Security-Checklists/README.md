# 📋 Module 02: Manual Security Checklists

> **"You cannot automate what you do not understand. First, we audit by hand."**

## 📚 Overview

Before using tools like InSpec or Open Policy Agent, we need to know *what* to look for. This module introduces the **CIS Benchmarks**, the gold standard for secure configuration.

## 🎓 Learning Objectives

- ✅ Understand **CIS Benchmarks** (Center for Internet Security).
- ✅ Perform a basic Linux audit (SSH config, User rights).
- ✅ Create a remediation plan.

---

## 🛠️ The Mini-Audit Checklist

If you were auditing a Linux server right now, check these 3 files:

1.  **`/etc/ssh/sshd_config`**
    - `PermitRootLogin no` (Root should never login remotely).
    - `PasswordAuthentication no` (Keys only).

2.  **`/etc/passwd`**
    - Any unknown users with UID `0` (Root privileges)?

3.  **`/var/log/auth.log`**
    - Any repeated failed login attempts?

---

**Next Step**: Prove your skills in **[CHALLENGES.md](../../CHALLENGES.md)** 🚀

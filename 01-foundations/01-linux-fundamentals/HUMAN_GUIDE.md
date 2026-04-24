# 🐧 01: Linux Engineering (From Power on to Permission Zen)

> **"In space, no one can hear you scream. In Linux, no one can hear you delete the entire root directory as root."**

Welcome to the **Foundational Pillar of SRE**. Everything in DevOps—from the smallest container to the largest cloud cluster—runs on a Linux kernel. If you don't master the kernel, you are just a passenger in the car. Mastering the kernel makes you the mechanic.

---

## 🗺️ The Narrative: Your Journey

### Phase 1: The First Breath (Introduction & Shell)
When you first connect to a server via SSH, you are met with a blinking cursor. This is the **Shell**. It’s not just a terminal; it's a conversation with the hardware.
- **The DevOps Why**: We use the CLI because it is repeatable, scriptable, and 100% predictable. You can't "click a button" on 500 servers at once, but you can run a single bash command across all of them.

### Phase 2: The Map of the Land (Filesystem & Navigation)
Linux doesn't have "C: drives" or "D: drives". Everything is a file, and everything starts at the root `/`.
- **Analogy**: Think of the filesystem as a giant library. `/etc` is the index card cabinet (Configuration), `/home` is the reading room (Users), and `/var` is the backroom where logs are stored (Variable data).

### Phase 3: The Surgeon’s Tools (Commands & Manipulation)
Mastering commands like `ls`, `grep`, `awk`, and `sed` allows you to slice and dice through gigabytes of logs in seconds.
- **Junior Way**: Manually scrolling through a text file looking for an error.
- **Senior Way**: `grep "ERROR" system.log | awk '{print $1, $4}' | sort | uniq -c`.

### Phase 4: The Shield & The Key (Permissions & SSH)
Security in Linux is built on **Ownership** (User, Group, Others) and **Permissions** (Read, Write, Execute).
- **The "Handshake"**: Incorrect Linux permissions on your host machine can cause your **Docker Volumes** to fail inside a container. If the host folder is owned by `root` but the container user is `app`, your app will crash with "Permission Denied."

---

## 🏗️ Architectural Overview
<LINUX_ENGINEERING_DIAGRAM>

---

## 🆘 What to do when this fails: Linux Edition

**Issue: "Permission Denied" (The most common error)**
- **The Fix**: Check `ls -l`. Identify the owner. Use `chmod` or `chown`. *Pro-Tip*: Never use `777` permissions; it's like leaving your front door wide open with a sign saying "Rob me."

**Issue: "Command not found"**
- **The Fix**: Check your `$PATH` environment variable (`echo $PATH`). Ensure the binary is in one of those folders or use the absolute path.

---

## 🎯 Pro-Tips for SREs
> **Always Use `man`**: Don't Google every flag. Type `man <command>` to read the local manual. It's faster and more accurate for your specific OS version.

---
*Visit the [Assessment/](./Assessment/) folder to test your knowledge!*

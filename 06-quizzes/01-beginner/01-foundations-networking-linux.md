# 01 Foundations: Networking & Linux Mastery

This module covers the core pillars of the DevOps world: how packets move and how the OS manages resources.

---

## 🌐 Part 1: Networking & OSI Model

### [Junior] What is the primary purpose of a "Subnet Mask"?
- [ ] A) To encrypt data during transit.
- [ ] B) To distinguish between the network portion and the host portion of an IP address.
- [ ] C) To increase the baud rate of the physical connection.
- [ ] D) To manage DNS resolution for local hosts.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** A subnet mask (e.g., /24 or 255.255.255.0) tells the system which part of an IP address refers to the network and which refers to the individual device (host).
**Certification Alignment:** AWS Certified Solutions Architect (Networking Basics)
</details>

### [Intermediate] Host A (192.168.1.5/24) cannot ping Host B (192.168.1.130/25). Why?
- [ ] A) The IP addresses are identical.
- [x] B) Host B is in a separate subnet (192.168.1.128 - 192.168.1.255) and requires a router for communication.
- [ ] C) MAC addresses are not configured.
- [ ] D) Pinging is disabled at the Physical Layer (Layer 1).

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** A /25 mask splits the network into two subnets (.0-.127 and .128-.255). Since Host A sees Host B as external but believes its own subnet is /24, there is a mask mismatch or a routing requirement.
**Certification Alignment:** AWS SysOps Administrator (Troubleshooting VPC)
</details>

---

## 🐧 Part 2: Linux Mastery

### [Junior] Which command is used to change the owner of a file?
- [ ] A) `chmod`
- [x] B) `chown`
- [ ] C) `chgrp`
- [ ] D) `umask`

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** B
**Why?** `chown` (Change Owner) is the standard utility. `chmod` is for permissions, and `chgrp` is specifically for group membership.
**Certification Alignment:** RHCSA (Red Hat Certified System Administrator)
</details>

### [Senior] What does "Inode exhaustion" mean on a Linux filesystem?
- [ ] A) The RAM is full and the system is swapping.
- [ ] B) The disk space is 100% full.
- [x] C) No more files can be created because the filesystem has run out of index nodes, even if free space exists.
- [ ] D) The CPU is pegged at 100% due to context switching.

<details>
<summary>Click to Reveal Answer</summary>

**Correct Answer:** C
**Why?** Every file needs an Inode. If you have millions of tiny files, you can use up all the Inodes while still having many Gigabytes of free space. This is a common SRE-level failure in logging systems.
**Certification Alignment:** Linux Foundation Certified System Administrator (LFCS)
</details>

---

## 🏆 Master Answer Key

| Question ID | Difficulty | Answer | Topic |
| :--- | :--- | :--- | :--- |
| N-01 | Junior | B | Networking |
| N-02 | Intermediate | B | Subnetting |
| L-01 | Junior | B | Permissions |
| L-02 | Senior | C | Filesystems |

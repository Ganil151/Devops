# Advanced Linux: Security, Performance & Tuning

At the advanced level, Linux is treated as a highly tunable performance engine and a hardened fortress. This module covers kernel tuning, advanced security models (SELinux/AppArmor), and deep performance tracing.

---

## 📂 Module Structure

### 🛡️ Advanced Topics
- **[Security & Hardening](./Security/)**: SELinux, AppArmor, `sysctl` hardening, and auditing.
- **[Performance & Optimization](./Performance/)**: CPU/IO tuning, `eBPF`, and observability tools (`perf`, `bpftrace`).
- **[Virtualization & WSL](./Virtualization-WSL/)**: Advanced WSL2 config, KVM/QEMU, and container runtimes.
- **[Advanced SSH](./SSH/)**: Certificates, Bastion hosts, and proxying.

---

## 🏗️ Core Concepts

### 1. Kernel Parameter Tuning (`sysctl`)
Optimizing the network stack and memory management for high-concurrency workloads.
- **`net.core.somaxconn`**: Increasing the listen queue for high-traffic web servers.
- **`vm.swappiness`**: Controlling how aggressively the kernel swaps memory to disk.
- **`fs.file-max`**: Increasing the system-wide limit for open files.

### 2. Advanced Security Models
- **SELinux (Security-Enhanced Linux)**: Label-based access control (Red Hat default).
- **AppArmor**: Path-based access control (Ubuntu/Debian default).
- **Auditd**: Tracking every system call for compliance and forensics.

### 3. Observability & Tracing
- **`perf`**: Sampling performance profiling.
- **`eBPF`**: Running sandboxed programs in the kernel for high-performance monitoring without overhead.
- **`strace`**: Intercepting and recording system calls made by a process.

---

## 📊 Linux Boot & Performance Layers

```mermaid
graph TB
    subgraph "Boot Process"
        BIOS[BIOS / UEFI] --> GRUB[Bootloader: GRUB]
        GRUB --> Kernel[Kernel Initialization]
        Kernel --> Init[Init System: Systemd]
    end
    
    subgraph "Tuning Layers"
        H[Hardware] --- Drv[Drivers]
        Drv --- Kp[Kernel Parameters]
        Kp --- Us[User Space / Apps]
    end
    
    Init --> Us
```

---

## ❓ Interview Questions & Quiz
**[Explore Advanced Interview Questions & Quizzes](./Interview_Questions_and_Quiz.md)**

---

## ✅ Advanced Knowledge Check
- [ ] Configure `sysctl` for network performance optimization
- [ ] Implement and troubleshoot SELinux/AppArmor policies
- [ ] Use `perf` or `bpftrace` to identify kernel-level bottlenecks
- [ ] Secure a server using `fail2ban` and advanced firewall rules
- [ ] Manage multi-tenant isolation using Linux namespaces and cgroups
- [ ] Design a secure SSH infrastructure with bastion hosts and MFA

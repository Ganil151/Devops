# Advanced Linux: Interview Questions & Quiz

Deep dive into the internals of the Linux kernel, security subsystems, and performance tuning for enterprise DevOps.

---

## 🎤 Top 20 Advanced Linux Interview Questions

1. **What is eBPF and how is it used in DevOps?**
   - *Answer*: eBPF (extended Berkeley Packet Filter) allows running sandboxed programs in the Linux kernel without changing kernel source code. It's used for high-performance networking, security (Falco), and observability (Cilium, bpftrace).

2. **Explain the difference between Hard and Soft preemption in the Linux kernel.**
   - *Answer*: **Soft preemption** happens when a higher priority process becomes runnable. **Hard preemption** allows the kernel to interrupt a process running in kernel mode (latency reduction).

3. **What are Control Groups (cgroups) and Namespaces?**
   - *Answer*: **Namespaces** isolate system resources (PID, Net, Mount) so a process thinks it's the only one. **cgroups** limit and monitor resource usage (CPU, Memory, I/O). Together, they form the foundation of Linux containers.

4. **What is the "OOM Killer" and how can you configure it?**
   - *Answer*: The Out-Of-Memory Killer is a kernel mechanism that kills processes to free up memory when the system is under extreme pressure. You can influence it using `oom_score_adj` in `/proc/<PID>/`.

5. **Explain the "Dirty Writeback" process in the Linux kernel.**
   - *Answer*: When data is written to a file, it's first stored in the page cache (dirty page). The kernel `pdflush` or `writeback` threads asynchronously write these pages to disk based on `sysctl` settings like `vm.dirty_ratio`.

6. **What is SELinux "Enforcing", "Permissive", and "Disabled" modes?**
   - *Answer*: **Enforcing**: Policies are applied and denials logged. **Permissive**: Denials are logged but not applied (useful for debugging). **Disabled**: SELinux is completely off.

7. **How does the Linux kernel handle System Calls (Syscalls)?**
   - *Answer*: User space applications use an interrupt (like `int 0x80` or `syscall` instruction) to transition to kernel mode. The kernel looks up the syscall number in a table and executes the corresponding kernel function.

8. **What is a "Huge Page" and when should you use it?**
   - *Answer*: A feature that allows the kernel to use page sizes larger than the default 4KB (e.g., 2MB or 1GB). It reduces TLB (Translation Lookaside Buffer) misses, which is beneficial for large memory applications like databases (Oracle, MySQL).

10. **Explain the concept of "Load Average" vs "CPU Utilization".**
    - *Answer*: **CPU Utilization** shows how busy the CPU is at a moment. **Load Average** includes processes waiting for CPU *and* processes waiting for disk I/O. A load average of 10 on a 4-core machine might mean high I/O wait, not just CPU saturation.

11. **What is the difference between Synchronous and Asynchronous I/O?**
    - *Answer*: **Synchronous**: The thread blocks until the I/O operation is complete. **Asynchronous**: The thread requests I/O and continues; it's notified when the I/O is finished (e.g., `io_uring`).

12. **How do you troubleshoot a "Locked file" that you cannot delete?**
    - *Answer*: Use `lsof <filename>` to see which process has it open. If it's still locked after the process is killed, check for kernel-level locks or NFS locks.

13. **What is "TCP Slow Start" and how can it be tuned?**
    - *Answer*: A congestion control mechanism that starts with a small window and grows it until congestion is detected. It can be tuned via `initcwnd` using the `ip route` command.

14. **How does the `epoll` system call improve performance over `select` or `poll`?**
    - *Answer*: `select` and `poll` scale linearly O(N) with the number of file descriptors (they scan the whole list). `epoll` is O(1) or O(log N) because it only returns the descriptors that actually have events, making it ideal for high-concurrency servers.

15. **What is a "Context Switch" and what causes high rates of it?**
    - *Answer*: The process of storing the state of a CPU so that it can be restored and execution resumed from the same point later. High rates are caused by many threads competing for CPU or excessive I/O interrupts.

16. **Explain the `sysctl` parameter `net.ipv4.tcp_tw_reuse`.**
    - *Answer*: It allows the kernel to reuse sockets in the `TIME_WAIT` state for new connections when it's safe from a protocol standpoint. Highly useful for high-load web servers to prevent port exhaustion.

17. **What is its role in modern Linux observability (e.g., bpftrace)?**
    - *Answer*: Use `bpftrace` to write small eBPF scripts that hook into kernel functions (`kprobes`) or user space functions (`uprobes`) to collect metrics without restarting applications or kernel.

18. **How do you perform a "Non-disruptive" kernel update?**
    - *Answer*: Using technologies like **kpatch** (Red Hat) or **kGraft** (SUSE), which allow patching kernel code in memory without a reboot.

19. **What is "NUMA" and how does it affect Linux performance?**
    - *Answer*: Non-Uniform Memory Access. In multi-socket systems, CPUs access their local RAM faster than RAM connected to another socket. Linux uses "NUMA-aware" scheduling to keep processes close to their memory.

20. **Explain the "VFS" (Virtual File System) layer.**
    - *Answer*: A kernel abstraction layer that allows the OS to support many different types of filesystems (ext4, XFS, NFS, Btrfs) through a common set of system calls (`open`, `read`, `write`).

---

## 🧠 Advanced Linux Quiz (20+ Questions)

<b>1. Which tool is used to monitor disk I/O in real-time by process?</b>
<details>
<summary>Show Answer</summary>
Answer: iotop
</details>

<b>2. Which `sysctl` parameter controls how aggressively the kernel swaps memory?</b>
<details>
<summary>Show Answer</summary>
Answer: vm.swappiness
</details>

<b>3. What does "TTL" stand for in the context of IP packets?</b>
<details>
<summary>Show Answer</summary>
Answer: Time To Live
</details>

<b>4. Which command is used to permanently save `sysctl` parameters?</b>
<details>
<summary>Show Answer</summary>
Answer: sysctl -p (after editing /etc/sysctl.conf)
</details>

<b>5. What is the modern replacement for the `route` command?</b>
<details>
<summary>Show Answer</summary>
Answer: ip route
</details>

<b>6. Which subsystem handles Mandatory Access Control (MAC) in Ubuntu?</b>
<details>
<summary>Show Answer</summary>
Answer: AppArmor
</details>

<b>7. What is the purpose of the `dmesg` command?</b>
<details>
<summary>Show Answer</summary>
Answer: To display the kernel's message buffer (boot logs, hardware errors).
</details>

<b>8. Which file descriptor number represents `stderr`?</b>
<details>
<summary>Show Answer</summary>
Answer: 2
</details>

<b>9. What does the `nice` value range from?</b>
<details>
<summary>Show Answer</summary>
Answer: -20 (highest priority) to 19 (lowest priority).
</details>

<b>10. Which command shows the shared libraries required by an executable?</b>
<details>
<summary>Show Answer</summary>
Answer: ldd
</details>

<b>11. What is a "Block Device"?</b>
<details>
<summary>Show Answer</summary>
Answer: A device that moves data in fixed-sized blocks (like SSDs, HDDs).
</details>

<b>12. How do you view the current resource limits for your shell session?</b>
<details>
<summary>Show Answer</summary>
Answer: ulimit -a
</details>

<b>13. What is the role of `kswapd`?</b>
<details>
<summary>Show Answer</summary>
Answer: The kernel daemon responsible for reclaiming memory pages (swapping).
</details>

<b>14. Which command is used to create an LVM Physical Volume?</b>
<details>
<summary>Show Answer</summary>
Answer: pvcreate
</details>

<b>15. What is the default filesystem for modern RHEL/CentOS systems?</b>
<details>
<summary>Show Answer</summary>
Answer: XFS
</details>

<b>16. How do you check for hardware interrupts in real-time?</b>
<details>
<summary>Show Answer</summary>
Answer: watch -n 1 cat /proc/interrupts
</details>

<b>17. What is "strace" used for?</b>
<details>
<summary>Show Answer</summary>
Answer: Tracing system calls and signals.
</details>

<b>18. What is the purpose of the `auditd` service?</b>
<details>
<summary>Show Answer</summary>
Answer: To provide a security auditing system that tracks security-relevant events.
</details>

<b>19. What does the `noatime` mount option do?</b>
<details>
<summary>Show Answer</summary>
Answer: Disables the recording of file access times (improves performance).
</details>

<b>20. Which command is used to trace the network path to a host?</b>
<details>
<summary>Show Answer</summary>
Answer: traceroute (or mtr)
</details>

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed Top 20 Advanced Interview Questions
- [x] Understand Kernel Tuning and Performance

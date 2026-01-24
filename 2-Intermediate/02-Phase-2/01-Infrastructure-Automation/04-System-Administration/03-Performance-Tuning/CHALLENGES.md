# Performance Tuning Challenges ⚡

Optimize your system resources to handle high-concurrency enterprise workloads.

---

## 🏆 Challenge 01: The Ulimit Bottleneck
**Objective**: Allow a high-traffic server to handle thousands of open files.

1.  **Scenario**: An Nginx server is returning "Too many open files" errors.
2.  **Task**: Modify `/etc/security/limits.conf`.
3.  **Logic**: Increase the `soft` and `hard` nproc/nofile limits to `65535`.
4.  **Verification**: Log in and run `ulimit -n` to confirm the new limit is active.

---

## 🏆 Challenge 02: Kernel Parameter Tuning (sysctl)
**Objective**: Optimize the Linux TCP stack.

1.  **Requirement**: Modify `/etc/sysctl.conf`.
2.  **Task**: Add the following optimizations:
    ```text
    net.ipv4.tcp_fin_timeout = 15
    net.ipv4.tcp_window_scaling = 1
    net.core.somaxconn = 1024
    ```
3.  **Discovery**: Research what `tcp_window_scaling` actually does for large-bandwidth connections.
4.  **Action**: Apply the changes LIVE using `sysctl -p`.

---

## 🏆 Challenge 03: Swap and Swappiness
**Objective**: Manage memory pressure gracefully.

1.  **Requirement**: Identify your system's `vm.swappiness` value (usually 60).
2.  **Task**: Lower this value to `10` or `20` to force the kernel to use RAM more aggressively before hitting the disk.
3.  **Theory**: Explain why high `swappiness` is detrimental to an In-Memory database like Redis or MongoDB.

---

## 📁 Solutions
System-wide sysctl.conf templates and Ulimit shell scripts are in the `Boilerplates/` directory.

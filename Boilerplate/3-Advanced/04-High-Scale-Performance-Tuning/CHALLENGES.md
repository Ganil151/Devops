# Advanced Challenges: High-Scale Performance

### Challenge 1: The 1M Connection Test
**Scenario**: The current script increases `somaxconn` and `netdev_max_backlog`.
-   **Requirement**: Modify the script to automatically calculate these values based on the total system RAM (e.g., use 1% of RAM for the TCP buffer).
-   **Metric**: Successfully handle 1,000,000 concurrent TCP "keep-alive" connections on a 64GB RAM instance.

### Challenge 2: Dynamic eBPF Loader
**Scenario**: The current script only detects `bpftool`.
-   **Requirement**: Add a function that downloads, compiles, and attaches a simple XDP program that drops all traffic from a dynamic "Blocklist" file (updated every 60 seconds).
-   **Pre-requisite**: Must check for `clang` and `llvm` availability.

### Challenge 3: No-Reboot Persistency
**Scenario**: Parameters set via `sysctl -w` are lost on reboot.
-   **Requirement**: Refactor the script to write all changes to a custom file in `/etc/sysctl.d/` and ensure it persists across reboots without duplicating entries.

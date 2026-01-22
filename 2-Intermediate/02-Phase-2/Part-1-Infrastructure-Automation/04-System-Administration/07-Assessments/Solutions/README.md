# ✅ Quiz Solutions: System Administration

### 1. Which Systemd command shows if any services have failed since the last boot?
**Correct Answer: c) systemctl --failed**
*Explanation*: Running `systemctl --failed` is the quickest way to get a clean list of all services that are in a failed state. `systemctl status` usually requires a specific service name to be useful.

### 2. In LVM, which component is created directly on top of a physical disk or partition?
**Correct Answer: a) Physical Volume (PV)**
*Explanation*: The hierarchy is PV (Physical) -> VG (Pool) -> LV (Logical). You must initialize the disk as a PV before it can be added to a Volume Group.

### 3. Which signal is sent by the `kill <PID>` command by default?
**Correct Answer: b) SIGTERM (15)**
*Explanation*: `SIGTERM` is a polite request for the process to terminate, allowing it to clean up logs and close connections. `SIGKILL (9)` is an immediate forced termination that doesn't allow for cleanup.

### 4. What does the sticky bit `t` (e.g., in /tmp) prevent?
**Correct Answer: c) Users from deleting files they don't own**
*Explanation*: In world-writable directories like `/tmp`, the sticky bit ensures that even though anyone can *create* a file, only the owner (or root) can *delete* it.

### 5. Which sysctl parameter controls how aggressively the kernel moves data from RAM to Swap?
**Correct Answer: b) vm.swappiness**
*Explanation*: `vm.swappiness` ranges from 0 to 100. A lower value (e.g., 10) tells the kernel to avoid swapping as much as possible, while a high value (e.g., 60+) tells it to swap proactively to keep RAM free for caching.

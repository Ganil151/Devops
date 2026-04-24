# 📝 System Administration Quiz

### 1. Which Systemd command shows if any services have failed since the last boot?
- [ ] a) `systemctl list-units`
- [ ] b) `systemctl status --failed`
- [x] c) `systemctl --failed`
- [ ] d) `journalctl -xe`

### 2. In LVM, which component is created directly on top of a physical disk or partition?
- [x] a) Physical Volume (PV)
- [ ] b) Volume Group (VG)
- [ ] c) Logical Volume (LV)
- [ ] d) Filesystem

### 3. Which signal is sent by the `kill <PID>` command by default?
- [ ] a) SIGKILL (9)
- [x] b) SIGTERM (15)
- [ ] c) SIGHUP (1)
- [ ] d) SIGSTOP (19)

### 4. What does the sticky bit `t` (e.g., in /tmp) prevent?
- [ ] a) Users from reading files
- [ ] b) Users from executing files
- [x] c) Users from deleting files they don't own
- [ ] d) Root from editing files

### 5. Which sysctl parameter controls how aggressively the kernel moves data from RAM to Swap?
- [ ] a) `vm.dirty_ratio`
- [x] b) `vm.swappiness`
- [ ] c) `kernel.swap_max`
- [ ] d) `fs.file-max`

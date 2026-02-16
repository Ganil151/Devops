# Quiz: Linux Filesystem

Test your knowledge of the Linux directory structure.

---

### 1. Which directory contains system configuration files?
- [ ] A) `/bin`
- [x] B) `/etc`
- [ ] C) `/var`
- [ ] D) `/usr`

### 2. Where would you look for the kernel ring buffer logs (boot messages)?
- [ ] A) `/etc/kernel`
- [ ] B) `/var/run`
- [x] C) `/var/log/dmesg`
- [ ] D) `/dev/boot`

### 3. Which of these is a virtual filesystem that exists only in memory?
- [ ] A) `/home`
- [x] B) `/proc`
- [ ] C) `/usr`
- [ ] D) `/opt`

### 4. What happens if you redirect output to `/dev/null`?
- [ ] A) It is saved to a hidden file
- [ ] B) It is printed to the console
- [x] C) It is discarded
- [ ] D) It triggers a system error

### 5. If `df -h` shows space but you can't create files, what should you check?
- [ ] A) `ls -la`
- [x] B) `df -i` (Inodes)
- [ ] C) `uname -a`
- [ ] D) `/etc/fstab`

### 6. Which directory is standard for installing third-party applications?
- [ ] A) `/bin`
- [ ] B) `/usr/bin`
- [x] C) `/opt`
- [ ] D) `/root`

### 7. What does the `/sbin` directory typically contain?
- [ ] A) Shell scripts
- [x] B) System binaries for administration
- [ ] C) Shared libraries
- [ ] D) Software installers

### 8. Which file contains the list of filesystems to be mounted automatically at boot?
- [ ] A) `/etc/mtab`
- [x] B) `/etc/fstab`
- [ ] C) `/etc/hosts`
- [ ] D) `/var/run/mount`

---

## 🏆 Assessment
- **Score 0-3**: Review the FHS tree.
- **Score 4-6**: Good! You know where things live.
- **Score 7-8**: Filesystem Ninja! You're ready for SRE work.

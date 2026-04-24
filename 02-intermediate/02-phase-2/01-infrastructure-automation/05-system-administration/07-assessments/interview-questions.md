# ❓ Technical Interview Questions: System Administration

### 1. The Broken Service
**Q: A service you enabled with `systemctl enable` is not running after a reboot. What are your first 3 troubleshooting steps?**
**A:** 
1. `systemctl status <service>`: Check if it's currently loaded or in a 'failed' state.
2. `journalctl -u <service> -b`: Check the logs specific to the current boot to see if there was a dependency failure or config error.
3. `systemctl is-enabled <service>`: Verify that the symlink in `/etc/systemd/system/` was actually created.

### 2. The Kernel Panic
**Q: Explain the difference between 'Soft Link' and 'Hard Link'. Which one works across different filesystems?**
**A:** 
- **Hard Link**: Points to the same Inode as the original file. Deleting the original doesn't destroy the data. It **cannot** span filesystems.
- **Soft Link (Symlink)**: A tiny file that points to the *pathname* of the original file. If the original is moved or deleted, the link breaks. It **can** span across different filesystems/disks.

### 3. Permission Escalation
**Q: You see an executable with permissions `-rwsr-xr-x`. What does the 's' mean, and why is it a security risk?**
**A:** The 's' stands for **SUID (Set Owner User ID)**. It means the program will execute with the permissions of the file *owner* (usually root) rather than the user calling it. This is a massive risk because if the program has a bug, a low-privilege user can gain root access to the system.

### 4. Storage Crisis
**Q: A 2TB disk has 500GB free, yet you get 'No space left on device' when trying to create a 1KB file. Why?**
**A:** You have run out of **Inodes**. Every file requires an entry in the Inode table. If you have millions of tiny files, you can exhaust the Inode table even if physical disk space is still available. Use `df -i` to verify.

### 5. Performance Monitoring
**Q: Your server has 100% CPU usage, but 90% is 'idle' and the rest is 'user'. However, the system is slow. What metric did you likely ignore?**
**A:** **I/O Wait (wa)** or **Steal Time (st)**. If 'wa' is high, the CPU is waiting for the disk/network. If 'st' is high (in a cloud VM), the hypervisor is taking CPU cycles away from your VM to give to another customer (Oversubscription).

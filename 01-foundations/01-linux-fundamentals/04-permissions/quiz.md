# Quiz: Linux Permissions & Security

Challenge your understanding of Linux access controls.

---

### 1. Which numeric value represents "Read" permission?
- [ ] A) 1
- [ ] B) 2
- [x] C) 4
- [ ] D) 7

### 2. What are the permissions for `chmod 640 file.txt`?
- [ ] A) Owner: rwx, Group: r-x, Others: ---
- [x] B) Owner: rw-, Group: r--, Others: ---
- [ ] C) Owner: rw-, Group: rw-, Others: ---
- [ ] D) Owner: r--, Group: r--, Others: r--

### 3. Which command changes the group ownership of a file?
- [ ] A) `chmod`
- [ ] B) `chown`
- [x] C) `chgrp` (or `chown :group`)
- [ ] D) `usermod`

### 4. What does the leading `-` in `-rwxr-xr-x` signify?
- [x] A) It is a regular file
- [ ] B) It is a directory
- [ ] C) It is a symbolic link
- [ ] D) Permissions are disabled

### 5. Which special permission allows a file to run with the owner's privileges?
- [x] A) SUID
- [ ] B) SGID
- [ ] C) Sticky Bit
- [ ] D) Immutable Bit

### 6. If a directory has permissions `drwxrwxrwt`, what does the `t` represent?
- [ ] A) Temporary directory
- [ ] B) Transparent directory
- [x] C) Sticky Bit
- [ ] D) Trash directory

### 7. What is the standard permission for a private SSH key (`id_rsa`)?
- [ ] A) 777
- [ ] B) 644
- [x] C) 600
- [ ] D) 444

### 8. How do you add "Execute" permission for the Owner using symbolic mode?
- [ ] A) `chmod +x`
- [x] B) `chmod u+x`
- [ ] C) `chmod g+x`
- [ ] D) `chmod o+x`

---

## 🏆 Assessment
- **Score 0-3**: Be careful! One wrong `chmod` can break a system.
- **Score 4-6**: Good understanding of the basics.
- **Score 7-8**: Security Guru! You're ready to harden production servers.

# Quiz: Linux Fundamentals

Test your knowledge of Linux core concepts.

---

### 1. Who created the Linux kernel?
- [ ] A) Bill Gates
- [ ] B) Steve Jobs
- [x] C) Linus Torvalds
- [ ] D) Richard Stallman

### 2. Which of the following is NOT a Linux Distribution?
- [ ] A) Debian
- [ ] B) Fedora
- [x] C) Solaris
- [ ] D) OpenSUSE

### 3. What is the default shell on most modern Linux distributions?
- [ ] A) Sh
- [x] B) Bash
- [ ] C) Zsh
- [ ] D) Csh

### 4. Which command is used to display the currently running processes in real-time?
- [ ] A) `ps`
- [x] B) `top`
- [ ] C) `ls`
- [ ] D) `cat`

### 5. In the Linux architecture, what sits directly between the Hardware and the Shell?
- [x] A) Kernel
- [ ] B) Applications
- [ ] C) BIOS
- [ ] D) File System

### 6. Which distribution is known for its extremely small footprint (approx 5MB)?
- [ ] A) Ubuntu
- [ ] B) CentOS
- [x] C) Alpine
- [ ] D) Kali

### 7. What does the `LTS` acronym stand for in Ubuntu versions?
- [ ] A) Linux Technical Support
- [x] B) Long Term Support
- [ ] C) Latest Technology System
- [ ] D) Lightweight Terminal Service

### 8. Which file represents the first process started by the kernel (PID 1) in modern systems?
- [ ] A) `/bin/bash`
- [x] B) `/sbin/init` (or systemd)
- [ ] C) `/etc/passwd`
- [ ] D) `/dev/null`

---

## 🏆 Assessment
- **Score 0-3**: Keep studying the basics!
- **Score 4-6**: Good start, focus on the architecture.
- **Score 7-8**: You're ready to start using the command line!
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
# Quiz: Linux Commands Mastery

Test your ability to navigate and manage the Linux environment.

---

### 1. Which command shows your current directory path?
- [ ] A) `cd`
- [ ] B) `ls`
- [x] C) `pwd`
- [ ] D) `whoami`

### 2. How do you rename `old.txt` to `new.txt`?
- [ ] A) `cp old.txt new.txt`
- [x] B) `mv old.txt new.txt`
- [ ] C) `rn old.txt new.txt`
- [ ] D) `touch old.txt new.txt`

### 3. Which flag is used with `mkdir` to create parent directories as needed?
- [ ] A) `-r`
- [ ] B) `-f`
- [x] C) `-p`
- [ ] D) `-v`

### 4. How do you search for the word "database" in all `.log` files in the current directory?
- [ ] A) `find . -name "database"`
- [x] B) `grep "database" *.log`
- [ ] C) `cat *.log | find "database"`
- [ ] D) `ls | grep "database"`

### 5. What does `kill -9 1234` do?
- [ ] A) Gracefully stops process 1234
- [ ] B) Restarts process 1234
- [x] C) Immediately forces process 1234 to terminate
- [ ] D) Changes the priority of process 1234

### 6. Which tool is best for extracting one specific column from a text file?
- [ ] A) `grep`
- [x] B) `awk`
- [ ] C) `cat`
- [ ] D) `sort`

### 7. Which command displays the total amount of free and used memory?
- [ ] A) `df -h`
- [ ] B) `du -sh`
- [x] C) `free -h`
- [ ] D) `top`

### 8. How do you redirect both standard output and standard error to a file?
- [x] A) `command > file 2>&1`
- [ ] B) `command 2> file`
- [ ] C) `command | file`
- [ ] D) `command >> file`

---

## 🏆 Assessment
- **Score 0-3**: Practice more basic navigation!
- **Score 4-6**: Good! You can survive the terminal.
- **Score 7-8**: Power user! You're ready to automate.
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
# Quiz: SSH Mastery

Test your knowledge of secure remote access.

---

### 1. Which file on the server stores the public keys allowed to connect?
- [ ] A) `~/.ssh/known_hosts`
- [ ] B) `/etc/ssh/ssh_config`
- [x] C) `~/.ssh/authorized_keys`
- [ ] D) `~/.ssh/id_rsa.pub`

### 2. What is the correct permission for a private key file (`id_rsa`)?
- [ ] A) 777
- [ ] B) 644
- [x] C) 600
- [ ] D) 700

### 3. Which SSH flag is used for local port forwarding?
- [x] A) `-L`
- [ ] B) `-R`
- [ ] C) `-D`
- [ ] D) `-P`

### 4. What does the command `ssh -v` provide?
- [ ] A) Version information
- [x] B) Verbose output for debugging
- [ ] C) Verification of the remote host
- [ ] D) Virtual terminal access

### 5. In which file do you define SSH aliases to simplify connections?
- [ ] A) `/etc/hosts`
- [ ] B) `~/.bashrc`
- [x] C) `~/.ssh/config`
- [ ] D) `/etc/ssh/sshd_config`

### 6. Which cryptographic algorithm is currently recommended for new SSH keys?
- [ ] A) DSA
- [ ] B) RSA 1024
- [ ] C) MD5
- [x] D) Ed25519

### 7. What is the effect of `PermitRootLogin no` in `sshd_config`?
- [ ] A) Users cannot use the `sudo` command
- [x] B) The `root` user cannot log in directly via SSH
- [ ] C) Only the `root` user can log in
- [ ] D) Root can only log in with a password

### 8. Which command is used to remove a stale host key from `known_hosts`?
- [ ] A) `rm ~/.ssh/known_hosts`
- [x] B) `ssh-keygen -R <hostname>`
- [ ] C) `ssh-copy-id -R <hostname>`
- [ ] D) `ssh-add -d <hostname>`

---

## 🏆 Assessment
- **Score 0-3**: You're at risk of getting locked out!
- **Score 4-6**: Good knowledge of basic connectivity.
- **Score 7-8**: SSH Expert! You can safely manage large clusters.

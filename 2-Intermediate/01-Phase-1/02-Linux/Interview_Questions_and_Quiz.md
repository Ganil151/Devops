# Intermediate Linux: Interview Questions & Quiz

Solidify your system administration skills and prepare for DevOps technical interviews.

---

## 🎤 Top 20 Intermediate Linux Interview Questions

1. **What is `systemd` and how do you manage a service with it?**
   - *Answer*: `systemd` is the init system and system manager for Linux. You manage services using `systemctl` (start, stop, restart, status, enable, disable).

2. **Explain the difference between a Hard link and a Soft (Symbolic) link.**
   - *Answer*: A **Hard link** points to the same inode as the original file (only works on same filesystem). A **Soft link** is a pointer to the filename (works across filesystems). If original is deleted, soft link breaks; hard link persists.

3. **How do you find which process is using a specific port (e.g., 8080)?**
   - *Answer*: `ss -tuln | grep 8080` or `lsof -i :8080` or `netstat -tunlp | grep 8080`.

4. **What is an Inode?**
   - *Answer*: A data structure on a Linux filesystem that stores metadata about a file (permissions, owner, size, location on disk), but not the filename or the actual data.

5. **Explain the `set -e` flag in a Bash script.**
   - *Answer*: It tells the shell to exit immediately if any command returns a non-zero exit status, which is a best practice for "Fail-Fast" automation.

6. **What is the difference between `ps aux` and `top`?**
   - *Answer*: `ps aux` provides a static snapshot of all running processes. `top` provides a real-time, interactive view that updates every few seconds.

7. **How do you troubleshoot high CPU usage on a Linux server?**
   - *Answer*: Use `top` or `htop` to identify the hogging process, check `uptime` for load averages, and use `strace` or `perf` for deeper analysis if it's an application issue.

8. **What are the three standard streams in Linux?**
   - *Answer*: Standard Input (stdin, 0), Standard Output (stdout, 1), and Standard Error (stderr, 2).

9. **How do you redirect both stdout and stderr to the same file?**
   - *Answer*: `command > file 2>&1` or the shorthand `command &> file`.

10. **What is a "Zombie" process?**
    - *Answer*: A process that has completed execution but still has an entry in the process table. It occurs when a parent hasn't yet read the child's exit status.

11. **Explain the purpose of `/etc/fstab`.**
    - *Answer*: A configuration file that defines how disk partitions, remote filesystems, and other block devices should be mounted and integrated into the filesystem at boot.

12. **How do you change the owner and group of a file recursively?**
    - *Answer*: `chown -R user:group /path/to/directory`.

13. **What is the `Load Average` in Linux?**
    - *Answer*: The average number of processes in a runnable or uninterruptible state over 1, 5, and 15 minutes. It indicates system pressure (CPU or I/O).

14. **How do you search for a specific string recursively in a directory?**
    - *Answer*: `grep -r "string" /path/to/dir`.

15. **What is the difference between `SUDO` and `SU`?**
    - *Answer*: `su` (switch user) switches you to another user account (requires that user's password). `sudo` (superuser do) executes a command as another user (usually root) using *your own* password, subject to `/etc/sudoers`.

16. **How do you check for open file descriptors for a process?**
    - *Answer*: `lsof -p <PID>` or look in `/proc/<PID>/fd/`.

17. **What is a "Shebang" in a script?**
    - *Answer*: The first line (`#!/bin/bash`) that tells the OS which interpreter to use to run the script.

18. **Explain the `sticky bit` on a directory (like `/tmp`).**
    - *Answer*: A permission bit that ensures only the file's owner (or root) can delete or rename files within that directory, even if others have write access.

19. **How do you monitor logs in real-time?**
    - *Answer*: `tail -f /var/log/filename` or `journalctl -f`.

20. **What is the difference between `SIGTERM` and `SIGKILL`?**
    - *Answer*: `SIGTERM` (15) is a polite request to terminate (allows graceful shutdown). `SIGKILL` (9) is an immediate, forced termination that the process cannot ignore.

---

## 🧠 Intermediate Linux Quiz (20+ Questions)

<b>1. Which directory contains configuration files for the system?</b>
<details>
<summary>Show Answer</summary>
Answer: /etc
</details>

<b>2. What command shows memory usage in human-readable format?</b>
<details>
<summary>Show Answer</summary>
Answer: free -h
</details>

<b>3. Which signal is sent by the `kill` command by default?</b>
<details>
<summary>Show Answer</summary>
Answer: SIGTERM (15)
</details>

<b>4. How do you make a script `deploy.sh` executable?</b>
<details>
<summary>Show Answer</summary>
Answer: chmod +x deploy.sh
</details>

<b>5. What does `umask` control?</b>
<details>
<summary>Show Answer</summary>
Answer: Default permissions for newly created files and directories.
</details>

<b>6. Which file contains information about user accounts?</b>
<details>
<summary>Show Answer</summary>
Answer: /etc/passwd
</details>

<b>7. What command displays the kernel version?</b>
<details>
<summary>Show Answer</summary>
Answer: uname -r
</details>

<b>8. How do you view the systemd journal logs for a service named `nginx`?</b>
<details>
<summary>Show Answer</summary>
Answer: journalctl -u nginx
</details>

<b>9. What is the PID of the `init` process (or systemd)?</b>
<details>
<summary>Show Answer</summary>
Answer: 1
</details>

<b>10. Which command displays the amount of disk space used by a directory?</b>
<details>
<summary>Show Answer</summary>
Answer: du -sh
</details>

<b>11. What is the purpose of the `PATH` environment variable?</b>
<details>
<summary>Show Answer</summary>
Answer: A list of directories where the shell looks for executable files.
</details>

<b>12. How do you find the line number of a string in a file using `grep`?</b>
<details>
<summary>Show Answer</summary>
Answer: grep -n "string" filename
</details>

<b>13. What does `df` stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: disk free
</details>

<b>14. Which command is used to change the priority of a running process?</b>
<details>
<summary>Show Answer</summary>
Answer: renice
</details>

<b>15. What is the default port for SSH?</b>
<details>
<summary>Show Answer</summary>
Answer: 22
</details>

<b>16. How do you combine multiple commands so that the second only runs if the first succeeds?</b>
<details>
<summary>Show Answer</summary>
Answer: `command1 && command2`
</details>

<b>17. Which command shows the routing table?</b>
<details>
<summary>Show Answer</summary>
Answer: ip route (or netstat -r)
</details>

<b>18. What is the "root" directory symbol?</b>
<details>
<summary>Show Answer</summary>
Answer: /
</details>

<b>19. What does the `top` command's `RES` column represent?</b>
<details>
<summary>Show Answer</summary>
Answer: Resident Memory (physical RAM actually used by the process).
</details>

<b>20. Which command shows who is currently logged into the system?</b>
<details>
<summary>Show Answer</summary>
Answer: who (or w)
</details>

<b>21. How do you compare two files to see the differences?</b>
<details>
<summary>Show Answer</summary>
Answer: diff file1 file2
</details>

<b>22. What is the purpose of the `alias` command?</b>
<details>
<summary>Show Answer</summary>
Answer: Create a shortcut or nickname for a longer command.
</details>

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed Top 20 Interview Questions
- [x] Understand Systemd and Process management

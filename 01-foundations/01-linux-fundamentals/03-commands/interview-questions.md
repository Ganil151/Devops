# Interview Questions: Linux Commands

## 🟢 Beginner Level

### 1. What is the difference between `ls -l` and `ls -a`?
**Answer**: `ls -l` shows the long format listing (permissions, owner, size, date). `ls -a` shows all files, including hidden files (those starting with a dot `.`). They are often combined as `ls -la`.

### 2. How do you create a file without opening an editor?
**Answer**: You can use `touch filename` to create an empty file, or use redirection: `echo "content" > filename` or `cat > filename` (then type content and press Ctrl+D).

### 3. What does the `tail -f` command do?
**Answer**: It displays the last few lines of a file and "follows" it, meaning it keeps the file open and updates the screen in real-time as new lines are added. It's essential for monitoring logs.

---

## 🟡 Intermediate Level

### 4. How do you find a specific process and kill it?
**Answer**:
1. Find the PID: `ps aux | grep process_name` or `pgrep process_name`.
2. Kill it: `kill <PID>` (graceful) or `kill -9 <PID>` (forced).

### 5. Explain the difference between `grep`, `sed`, and `awk`.
**Answer**:
- **`grep`**: Search for patterns within text (Filter).
- **`sed`**: Stream Editor used for transforming text (Find and Replace).
- **`awk`**: Advanced text processing language, best for column-based data.

### 6. How do you check which process is using a specific port (e.g., 8080)?
**Answer**: Use `lsof -i :8080` or `ss -tulpn | grep 8080`.

---

## 🔴 Advanced (DevOps/SRE) Level

### 7. What is "Load Average" and how is it different from CPU usage?
**Answer**: CPU usage is the percentage of time the CPU is actively processing. **Load Average** is the average number of processes in the "runnable" state (either using CPU or waiting for CPU/Disk I/O). A high load with low CPU usage usually indicates a disk or network bottleneck (I/O Wait).

### 8. How would you find all files larger than 100MB modified in the last 7 days?
**Answer**:
```bash
find /path -type f -size +100M -mtime -7
```

### 9. Explain the use of `strace`.
**Answer**: `strace` is a diagnostic tool that intercepts and records the system calls made by a process and the signals it receives. It's used for deep troubleshooting when a binary is failing but doesn't provide clear error messages.

# Interview Questions: Linux Fundamentals

## 🟢 Beginner Level

### 1. What is the Linux Kernel?
**Answer**: The Linux kernel is the core part of the operating system that manages hardware resources (CPU, Memory, I/O) and provides a bridge between software applications and the physical hardware.

### 2. What is a "Distribution" (Distro)?
**Answer**: A distribution is a version of the Linux kernel bundled with additional software, a package manager (like `apt` or `yum`), and often a desktop environment. Examples include Ubuntu, CentOS, and Alpine.

### 3. What does "Everything is a file" mean in Linux?
**Answer**: In Linux, almost all resources—including hardware devices (hard drives, keyboards), network connections, and directories—are represented as files in the filesystem. This allows tools to interact with them using a unified API.

---

## 🟡 Intermediate Level

### 4. What is the difference between a Process and a Thread?
**Answer**: A process is an independent execution unit with its own memory space. A thread is a subset of a process that shares the same memory space as other threads in that process. Processes are heavier to create than threads.

### 5. What are the different runlevels in Linux (or Systemd targets)?
**Answer**: Runlevels (or targets in Systemd) define the state of the machine.
- `0`: Shutdown
- `1`: Single-user mode (recovery)
- `3` or `multi-user.target`: Multi-user CLI mode
- `5` or `graphical.target`: GUI mode
- `6`: Reboot

### 6. Explain the concept of "Inodes".
**Answer**: An Inode (Index Node) is a data structure on a Linux filesystem that stores metadata about a file (size, permissions, owner, timestamps) but *not* its name or actual data. Every file has a unique Inode number within its filesystem.

---

## 🔴 Advanced (DevOps/SRE) Level

### 7. What happens when you type `ls` and press Enter?
**Answer**: 
1. The Shell reads the input string.
2. It parses the command and checks if `ls` is an alias or internal command.
3. If not, it searches for the `ls` binary in the directories listed in the `$PATH` environment variable.
4. The shell uses the `fork()` system call to create a child process.
5. In the child process, it uses `execve()` to load and run the `ls` binary.
6. The kernel allocates resources, `ls` interacts with the filesystem via system calls to read directory contents, and outputs the result to `stdout`.

### 8. How do you troubleshoot a "Disk Full" error when `df -h` shows space but `touch file` fails?
**Answer**: This usually happens for two reasons:
1. **Inode Exhaustion**: The filesystem has run out of Inodes (check with `df -i`). This happens when there are millions of tiny files.
2. **Deleted but Open Files**: A process is still holding a large deleted file open. The space won't be reclaimed until the process is killed (check with `lsof | grep deleted`).

### 9. What is a Zombie Process, and how do you kill it?
**Answer**: A Zombie process is a process that has completed execution but remains in the process table because its parent hasn't yet read its exit status. You **cannot** kill a zombie process directly because it's already dead. You must instead kill its parent process or signal the parent to reap it.

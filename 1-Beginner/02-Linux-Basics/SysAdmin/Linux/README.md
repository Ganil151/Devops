# Linux Command Line Mastery

The command line is the primary interface for DevOps engineers. This guide covers the essential commands needed for systems administration and automation.

---

## 📂 1. File & Directory Operations

| Command | Description | Example |
| :--- | :--- | :--- |
| `ls` | List directory contents | `ls -la` (all files, long format) |
| `cd` | Change directory | `cd /var/log` |
| `pwd` | Print Working Directory | `pwd` |
| `mkdir` | Make directory | `mkdir -p projects/app` |
| `cp` | Copy files/folders | `cp -r src/ backup/` |
| `mv` | Move or Rename | `mv old_name.txt new_name.txt` |
| `rm` | Remove (Delete) | `rm -rf tmp_folder` (Caution!) |
| `touch` | Create empty file | `touch config.yaml` |

---

## 📝 2. File Content & Manipulation

- **`cat`**: Print entire file to stdout.
- **`less`**: View file with paging and searching.
- **`head` / `tail`**: View the beginning or end of a file (useful for logs: `tail -f app.log`).
- **`grep`**: Search for patterns within text.
- **`find`**: Search for files in the directory hierarchy.
- **`sed`**: Stream editor for filtering and transforming text.
- **`awk`**: Pattern scanning and processing language.

---

## ⚙️ 3. Systems & Process Management

- **`top` / `htop`**: Real-time system monitoring.
- **`ps`**: Report a snapshot of current processes (`ps aux`).
- **`kill`**: Terminate a process by ID (`kill -9 1234`).
- **`df`**: Report file system disk space usage (`df -h`).
- **`du`**: Estimate file space usage (`du -sh *`).
- **`free`**: Display amount of free and used memory.

---

## 🛡️ 4. Permissions & Ownership

- **`chmod`**: Change file modes or Access Control Lists (e.g., `chmod 400 key.pem`).
- **`chown`**: Change file owner and group.
- **`sudo`**: Execute a command as another user (usually root).

---

## 🌐 5. Networking Basics (CLI)

- **`curl` / `wget`**: Transfer data from or to a server.
- **`ip addr`**: Display/manage IP addresses.
- **`netstat` / `ss`**: Show network socket information.
- **`ping`**: Send ICMP ECHO_REQUEST to network hosts.

> [!TIP]
> Use the `man` command (e.g., `man grep`) to see the full manual for any Linux command.

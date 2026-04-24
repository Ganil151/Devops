# 🏗️ Bash Architecture & Process Management
*Version 1.0 | Under the Hood of the Shell Executor*

---

## 📖 Overview
Bash (Bourne Again SHell) is more than just a command runner; it is a complex process manager. Understanding how it forks, handles signals, and manages background tasks is essential for building resilient backend automation agents.

---

## ⚙️ Process Execution Lifecycle

### Fork & Exec
When you run an external command (e.g., `ls`), Bash:
1. **Forks**: Creates a copy of itself (Child Process).
2. **Execs**: Replaces the child process memory with the code of the target command.
- **Built-in Commands**: Commands like `cd` or `echo` run directly inside the current shell process, which is why `cd` can change the shell's directory while an external script cannot unless `sourced`.

### Subshells
**Definition**: A child process spawned by the parent shell to execute a block of code.
- **Triggered by**: `( command1; command2 )`, `&` (backgrounding), or pipes `|`.
- **Logic**: Variables and directory changes inside a subshell **never** propagate back to the parent.

---

## 📡 Signal Handling (IPC)

Signals are asynchronous notifications sent to a process to notify it of an event.

| Signal | Name | Trigger | Default Action |
| :--- | :--- | :--- | :--- |
| **1** | SIGHUP | Terminal disconnect | Terminate |
| **2** | SIGINT | `Ctrl + C` | Interrupt |
| **9** | SIGKILL | Forced kill | Immediate termination (non-catchable) |
| **15** | SIGTERM | Software kill | Graceful termination (catchable) |

### The `trap` Command
Use `trap` to catch signals and run cleanup logic.
```bash
trap "echo 'Cleaning up...'; rm /tmp/lock; exit" SIGINT SIGTERM
```

---

## 🚀 Job Control & Backgrounding

- **`&`**: Runs the command in the background.
- **`jobs`**: Lists active background jobs.
- **`fg %1`**: Brings job #1 to the foreground.
- **`bg %1`**: Resumes a paused job in the background.
- **`nohup`**: Disconnects the process from the terminal (ignores SIGHUP).

---

## 🛡️ SRE Global Patterns

### Parallel Execution (The "Waiter" Pattern)
```bash
for ip in $(cat servers.txt); do
  ssh $ip "uptime" & 
done
wait # Blocking call: wait for all background SSH processes to finish
echo "All server checks complete."
```

### Locking Mechanisms
Prevent concurrent script execution using `flock`.
```bash
exec 200>/tmp/myscript.lock
flock -n 200 || { echo "Script already running!"; exit 1; }
```

---

## ❓ Interview "Deep-Cut" Questions
1. **Explain the difference between `SIGKILL` and `SIGTERM`. Which is preferred and why?**
2. **What is a "Zombie Process" in the context of shell execution, and how do you prevent them?**
3. **Describe the impact of the `exec` command when run before another command (e.g., `exec python script.py`).**
4. **How does Bash handle standard streams (stdin/stdout) when a command is piped into another?**
5. **What is the "OOM Killer" and how does it relate to intensive shell-loop operations?**

---
**Next Step**: [Stream Editing & Filtering Mastery →](./stream-editing-filtering-ref.md)

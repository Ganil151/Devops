# Remote Execution and SSH

Sometimes you can't use an agent (like checking a router or a legacy server). Python's `paramiko` library allows you to script SSH interactions programmatically.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `ssh_manager.py` (Command execution).
- **[CHALLENGES](./CHALLENGES.md)**: SFTP Uploaders, Remote Patchers.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **SSHClient** | The main object for High-level commands (`exec_command`). |
| **Transport** | Low-level socket handler. |
| **SFTPClient** | File transfer over SSH (`put`, `get`). |
| **AutoAddPolicy** | What to do if the Host Key is unknown (Trust/Reject). |

---

## 🏗️ Safety Patterns

### 1. Handling Host Keys
Man-in-the-Middle attacks happen. In Prod, load system host keys.

```python
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.RejectPolicy())
```

### 2. Timeouts
SSH can hang forever if a firewall drops packets.

```python
client.connect(..., timeout=10)
```

---

## 📖 Real-World Story: The "Thundering Herd"

**Problem**: A script SSH'd into 500 servers simultaneously to restart a service.
**Crisis**: The central jump host (bastion) crashed due to CPU load from crypto operations (SSH handshake is heavy).
**Solution**: Used a Python script with a **Semaphore** to limit concurrency to 10 connections at a time.

---

## ❓ Interview Questions

1.  **Why Paramiko over `subprocess.run(["ssh", ...])`?**
    - *Answer*: Paramiko gives you programmatic control over stdin/stdout, error handling, and key management without parsing string output or dealing with interactive prompts.
2.  **How do you handle Sudo passwords?**
    - *Answer*: You write to the `stdin` stream returned by `exec_command()`.
3.  **What is Fabric?**
    - *Answer*: A higher-level library built ON TOP of Paramiko, designed specifically for application deployment tasks.

---

[Next: Database Operations](../10-Database-Operations/README.md)

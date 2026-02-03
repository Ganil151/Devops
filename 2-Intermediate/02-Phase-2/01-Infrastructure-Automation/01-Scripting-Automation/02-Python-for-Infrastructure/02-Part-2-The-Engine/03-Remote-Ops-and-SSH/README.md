# 🌐 Remote Execution: Scripting the Fleet with SSH

> **"If you have to log in to more than one server manually, you aren't an engineer—you're a tourist. High-scale DevOps is the art of never leaving your own terminal."**

Welcome to the **Remote Execution** module. SSH (Secure Shell) is the main artery of the internet. While specific tools like Ansible or Terraform exist for state management, sometimes you just need to run a Python script to "check disk space on 5,000 servers" or "reboot a hung router". Mastering `Paramiko` and modern Async SSH libraries gives you this power.

**Why This Matters for Junior DevOps Engineers:**
- 🛡️ **Control**: Automation tools (Ansible) break. SSH scripts are the "Break Glass" emergency tool.
- ⚡ **Scale**: Running `ssh` in a bash loop is serial (slow). Python can run 100 connections in parallel.
- 🎯 **Interview**: "How do you handle key-based authentication failure in a Python script?"
- 🔧 **Legacy**: Many companies still use "Bastion Hosts" that require complex SSH hopping logic.

---

## 📚 Table of Contents

1. [The SSH Protocol Architecture](#-the-ssh-protocol-architecture)
2. [The Standard: Paramiko](#-the-standard-paramiko)
3. [The Speed: AsyncSSH](#-the-speed-asyncssh)
4. [Real-World DevOps Scenarios](#-real-world-devops-scenarios)
5. [Security Best Practices](#-security-best-practices)
6. [Common Pitfalls & Solutions](#-common-pitfalls--solutions)
7. [Hands-On Exercises](#-hands-on-exercises)
8. [Interview Preparation](#-interview-preparation)
9. [Knowledge Check](#-knowledge-check)

---

## 🏗️ The SSH Protocol Architecture

Remote execution isn't just "sending text". It involves encryptions, channels, and sub-systems.

```mermaid
graph TD
    A[Local Python Script] --> B{Handshake (Port 22)}
    B -- Key Exchange --> C[Encrypted Tunnel]
    C --> D[Channel 0: Exec (One-Shot Command)]
    C --> E[Channel 1: Shell (Interactive PTY)]
    C --> F[Subsystem: SFTP (File Transfer)]
    D --> G[Stdout / Stderr Streams]
    
    style B fill:#fef3c7,stroke:#d97706
    style C fill:#f0fdf4,stroke:#15803d
    style D fill:#e0f2fe,stroke:#0369a1
```

### 🔍 Concept Breakdown
1.  **Transport**: The encrypted TCP connection.
2.  **Channel**: Logical streams inside the transport. You can have multiple channels (Shell + SFTP) over one connection.
3.  **PTY (Pseudo-Terminal)**: Simulates a real terminal. Required for `sudo` commands that expect a user.

---

## 🐍 The Standard: Paramiko

Paramiko is the pure-Python implementation of SSHv2. It is the foundation of Ansible.

### The "Staff Engineer" Pattern
Don't use the simple wrapper. Use the `SSHClient` with explicit policy.

```python
import paramiko
import time

def run_secure_command(hostname, key_path, cmd):
    client = paramiko.SSHClient()
    
    # 🛡️ Security: Reject unknown hosts in Production
    # In Dev, you might use AutoAddPolicy()
    client.set_missing_host_key_policy(paramiko.RejectPolicy())
    client.load_system_host_keys()
    
    try:
        client.connect(hostname, username='admin', key_filename=key_path, timeout=5)
        
        # 3 Streams: Input, Output, Error
        stdin, stdout, stderr = client.exec_command(cmd)
        
        # ⚠️ BLOCKING CALL: Waits for command to finish
        exit_code = stdout.channel.recv_exit_status()
        
        if exit_code == 0:
            return stdout.read().decode().strip()
        else:
            raise Exception(f"Command Failed: {stderr.read().decode()}")
            
    finally:
        client.close()
```

---

## ⚡ The Speed: AsyncSSH

Paramiko is synchronous (blocking). If one server takes 10s to reply, your script halts.
**AsyncSSH** allows you to mix asyncio with SSH for massive parallelism.

```python
import asyncio
import asyncssh

async def run_client(host):
    async with asyncssh.connect(host, username='admin') as conn:
        result = await conn.run('uname -a')
        print(f"{host}: {result.stdout}", end='')

async def main():
    hosts = ['10.0.0.1', '10.0.0.2', '10.0.0.3']
    # 🚀 Run ALL connections simultaneously
    await asyncio.gather(*[run_client(h) for h in hosts])

# asyncio.run(main())
```

---

## 🎭 Real-World DevOps Scenarios

### 🧱 Scenario 1: The "Sudo" Trap

**The Incident:** A script needed to restart Nginx (`sudo systemctl restart nginx`). It failed silently.
**The Cause:** `sudo` usually requires a TTY (terminal) or it refuses to run for security. Standard `exec_command` has no TTY.
**The Fix:** Request a PTY.

```python
# Enable get_pty to simulate a terminal
stdin, stdout, stderr = client.exec_command("sudo restart nginx", get_pty=True)

# Write password if queried (Naïve approach)
stdin.write('mypassword\n')
stdin.flush()
```

### 🔥 Scenario 2: The "Thundering Herd"

**The Incident:** A junior engineer wrote a script using threads to SSH into 2,000 servers instantly.
**The Failure:** The Bastion host (jump box) ran out of ports/file descriptors and crashed.
**The Fix:** Use a **Semaphore** to limit concurrency.

```python
# AsyncIO Semaphore limits active connections to 50
sem = asyncio.Semaphore(50)

async def limited_run(host):
    async with sem:
        await run_client(host)
```

### ☁️ Scenario 3: SFTP Backup

**The Task:** Download logs from a legacy router that doesn't support S3.
**Solution:** `open_sftp()`.

```python
sftp = client.open_sftp()
sftp.get('/var/log/syslog', 'local_backup.log')
sftp.close()
```

---

## 🔒 Security Best Practices

### 1. SSH Agent Forwarding
Never store private keys on intermediate servers. Use Agent Forwarding (`allow_agent=True`).
This allows the remote server to "ask" your local laptop to sign the request.

### 2. Known Hosts Management
**Problem**: Man-in-the-Middle (MITM) attacks.
**Fix**: Pre-populate `~/.ssh/known_hosts` using `ssh-keyscan` in your CI pipeline before running Python scripts. Don't blindly accept keys.

### 3. Timeouts
Always set a `timeout`. Default TCP timeout is minutes.
`client.connect(..., timeout=10)`.

---

## ⚠️ Common Pitfalls

### Pitfall 1: Hanging Connections
**Symptom**: Script runs forever.
**Cause**: A command like `tail -f` never exits.
**Fix**: `exec_command` waits for EOF. Don't run infinite commands without a timeout logic loop.

### Pitfall 2: Mixing Stdout/Stderr
**Symptom**: Error messages appear in your "Success" log.
**Cause**: Some tools print warnings to stdout.
**Fix**: Always check `exit_status` (`recv_exit_status()`), not just output content.

---

## 🎯 Hands-On Exercises

### Exercise 1: The "Uptime" Checker
**Objective**: Connect to `localhost`.
**Requirements**:
1. Run `hostname` and `uptime`.
2. Capture stdout.
3. Handle authentication errors gracefully (`try/except`).

**Starter Code**:
```python
import paramiko
# TODO: Setup Client
# TODO: Connect to '127.0.0.1'
```

### Exercise 2: The Parallel Rebooter (Concept)
**Objective**: Design a script structure.
**Task**: Write the logic (pseudocode or async) to reboot 10 servers, but only 2 at a time (Semaphore).

---

## 🎙️ Interview Preparation

### Foundation Questions

**1. "What is a Bastion Host?"**
- **Answer**: A heavily secured server used as the single entry point to a private network. You SSH into the Bastion, then jump to internal servers.

**2. "Why prefer Key-based auth over Passwords?"**
- **Answer**: Passwords can be brute-forced and are hard to automate securely (require `expect` scripts). Keys use 2048+ bit encryption and support automation natively.

### Advanced Scenario Questions

**3. "How do you handle SSH strict host key checking in a dynamic cloud group?"**
- **Answer**: In dynamic clouds (AutoScaling), IPs change often.
    - Option A: Disable checking (`AutoAddPolicy`) - Risky.
    - Option B: Use **Signed SSH Certificates** (Netflix approach).
    - Option C: Sync `known_hosts` from Cloud API.

---

## 🧠 Knowledge Check

**1. Which library supports AsyncIO?**
- [ ] Paramiko
- [x] AsyncSSH
- [ ] Fabric

**2. What method opens a file transfer channel?**
- [ ] `open_shell()`
- [x] `open_sftp()`
- [ ] `exec_command()`

**3. What does `get_pty=True` do?**
- [ ] Speeds up connection
- [x] Allocates a pseudo-terminal (like a real user)
- [ ] Encrypts the data

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:
- [ ] Connect to a server using `Paramiko`.
- [ ] execute a command and capture `exit_code`.
- [ ] Explain why `AutoAddPolicy` is bad for production.
- [ ] Describe the difference between `exec_command` and `invoke_shell`.
- [ ] Use SFTP to download a file.

**Score yourself**: 5+/5 = Ready to advance | <5 = Review exercises

[⬅️ Back to Log Parsing](../08-Log-Parsing-and-Regex/README.md) | [Next: Database Ops](../10-Database-Operations/README.md) ➡️

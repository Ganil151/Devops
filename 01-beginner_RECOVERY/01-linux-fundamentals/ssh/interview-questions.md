# Interview Questions: SSH Mastery

## 🟢 Beginner Level

### 1. What is SSH and what is its default port?
**Answer**: SSH (Secure Shell) is a protocol used to securely access and manage remote systems over an unsecured network. Its default port is **22**.

### 2. What is the difference between a Public Key and a Private Key?
**Answer**: 
- **Private Key**: Stays on your local machine and must be kept secret (like a physical key).
- **Public Key**: Shared with the remote server and added to `authorized_keys` (like a lock). You can only open the lock if you have the matching key.

### 3. How do you copy your SSH key to a remote server?
**Answer**: The most efficient way is using `ssh-copy-id -i ~/.ssh/id_rsa.pub user@remote-host`. Alternatively, you can manually append the public key string to `~/.ssh/authorized_keys` on the server.

---

## 🟡 Intermediate Level

### 4. Why should you change the default SSH port?
**Answer**: To reduce "noise" from automated bots and script kiddies who scan the internet for port 22. It doesn't make the system "hack-proof," but it significantly reduces the number of brute-force attempts in your logs.

### 5. Explain the purpose of `~/.ssh/known_hosts`.
**Answer**: It stores the public host keys of the servers you have connected to. When you reconnect, SSH checks if the server's key matches the one stored. If it differs, SSH warns you that the host identification has changed, protecting against Man-in-the-Middle (MITM) attacks.

### 6. What is SSH Port Forwarding (Tunneling)?
**Answer**: It is a method of transporting arbitrary networking data over an encrypted SSH connection. 
- **Local Forwarding (`-L`)**: Access a remote port on your local machine.
- **Remote Forwarding (`-R`)**: Allow a remote server to access a port on your local machine.

---

## 🔴 Advanced (DevOps/SRE) Level

### 7. How would you connect to a server that is only accessible via a Bastion/Jump host?
**Answer**: Use the `-J` flag: `ssh -J user@bastion-ip user@internal-ip`. In a config file, use the `ProxyJump` directive.

### 8. What is SSH Multiplexing (ControlMaster)?
**Answer**: It allows you to reuse an existing TCP connection for multiple SSH sessions to the same host. This drastically speeds up subsequent connections (like when running multiple Ansible tasks) because the cryptographic handshake only happens once.

### 9. What are the security risks of "Agent Forwarding" (`-A`)?
**Answer**: If you forward your SSH agent to a compromised remote server, a user with root access on that server can access your local socket and use your keys to authenticate to other servers as you. A safer alternative is using `ProxyJump` or `ProxyCommand`.

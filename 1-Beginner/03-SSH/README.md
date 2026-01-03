# SSH & Remote Access

SSH (Secure Shell) is the industry standard for securely communicating with a remote server. It is the primary tool for a DevOps engineer to manage infrastructure that isn't on their local machine.

---

## 🎯 Learning Objectives

- Understand public/private key cryptography basics
- Generate and manage SSH keys securely
- Configure SSH tunneling and port forwarding
- Harden SSH server configuration
- Troubleshoot common connection issues

## 📂 Module Structure

### 🔰 Beginner Level
- **[01-Introduction](./1-Beginner-Level/01-Introduction/)**: What is SSH and why use it?
- **[02-Configuration](./1-Beginner-Level/02-Configuration/)**: Managing `~/.ssh/config` for easy access.
- **[03-Key-Management](./1-Beginner-Level/03-Key-Management/)**: Generating, copying, and managing keys.
- **[04-Troubleshooting](./1-Beginner-Level/04-Troubleshooting/)**: Solving "Permission Denied" and other errors.

### 🚀 Intermediate Level
- **[01-Best-Practices](./2-Intermediate-Level/01-Best-Practices/)**: Security and performance tips.
- **[02-Tunneling](./2-Intermediate-Level/02-Tunneling/)**: Port forwarding and SOCKS proxies.
- **[03-Automation](./2-Intermediate-Level/03-Automation/)**: Scripting with SSH.

### 🛡️ Advanced Level
- **[01-Security](./3-Advanced-Level/01-Security/)**: Hardening, 2FA, and Certificates.

---

## 📖 How SSH Works (Asymmetric Encryption)
SSH relies on public-key cryptography to authenticate the remote computer and allow it to authenticate the user.
- **Private Key**: Kept on your computer (Never share this!).
- **Public Key**: Placed on the remote server (Stored in `~/.ssh/authorized_keys`).
- **Handshake**: When you connect, the server uses your public key to encrypt a challenge that only your private key can decrypt.

---

## 🏗️ Essential SSH Workflow

### 🔑 Key Management
*When to use: Setting up initial access or adding a new machine to your fleet.*

```bash
# Generate a modern Ed25519 key pair
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy your public key to a remote server
ssh-copy-id user@192.168.1.10
```

### 🌉 Tunnels and Forwarding
*When to use: Accessing internal databases or web services that aren't exposed to the public internet.*

```bash
# Local Port Forwarding: Access remote DB on port 5432 locally on port 8888
ssh -L 8888:localhost:5432 user@remote-host

# Dynamic Forwarding (SOCKS Proxy): Route all browser traffic through a server
ssh -D 1080 user@remote-host
```

### ⚙️ The SSH Config File (`~/.ssh/config`)
*When to use: Simplifying connections to servers with complex IPs or custom ports.*

```text
Host bastion
    HostName 10.0.1.50
    User admin
    IdentityFile ~/.ssh/id_ed25519
    Port 2222
```

---

## 💡 SSH Best Practices

- **Never use Passwords**: Passwords can be brute-forced. SSH Keys are virtually impossible to crack if kept secure.
- **Disable Root Login**: Edit `/etc/ssh/sshd_config` and set `PermitRootLogin no`. Users should log in as themselves and elevate permissions via `sudo`.
- **Use a Passphrase**: Encrypt your private key with a passphrase. If your laptop is stolen, the thief still can't use your keys.
- **Agent Forwarding Caution**: Use `ssh -A` only with trusted servers. Malicious root users on the remote server can hijack your local agent.
- **Audit `authorized_keys`**: Regularly check `~/.ssh/authorized_keys` on your servers to ensure no old or unauthorized keys remain.

---

## 🧪 Practical Labs

### Lab 1: Debugging Connection Refusals

**Scenario**: "Permission Denied (publickey)". You try to connect to a new server, but it rejects your connection.
**Task**: Identify the missing key or permission issue.
**Solution**:
1.  **Check Key:** Verify private key exists in `~/.ssh/`.
2.  **Check Server:** Ensure *public* key is in server's `~/.ssh/authorized_keys`.
3.  **Check Permissions:** Run `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys`.

### Lab 2: Handling Host Key Changes

**Scenario**: "Host Key Verification Failed". You try to connect to a known server, but Git/SSH warns the key has changed.
**Task**: Reset the known host entry.
**Solution**:
1.  **Command**: Run `ssh-keygen -f "~/.ssh/known_hosts" -R "server-ip"`.
2.  **Verify**: Re-connect and accept the new fingerprint (if valid).

## 🧠 Knowledge Quiz

**1. Which file on the REMOTE server stores the public keys of authorized users?**
- A) `~/.ssh/id_rsa.pub`
- B) `~/.ssh/authorized_keys`
- C) `/etc/ssh/sshd_config`
- D) `~/.ssh/known_hosts`

**2. What is the main advantage of using Ed25519 keys over RSA keys?**
- A) They are older and more compatible
- B) They are shorter but provide significantly stronger security and faster performance
- C) They don't require a public key
- D) They work without SSH

**3. What does the command `ssh -L 8080:localhost:80 user@server` do?**
- A) It logs into the server on port 8080
- B) It deletes the server on port 80
- C) It maps port 80 on the remote server to port 8080 on your local machine
- D) It changes the remote server's password

---

## ✅ Knowledge Check
- [ ] Generate an SSH key pair
- [ ] Transfer a key using `ssh-copy-id`
- [ ] Configure a `~/.ssh/config` file with at least one alias
- [ ] Set up a local port forward to access a remote service
- [ ] Secure a server by disabling password authentication

---
 **Collaboration**: Remote access is just the start. Learn how to track changes in [Git & GitHub](../04-Git-GitHub/README.md).
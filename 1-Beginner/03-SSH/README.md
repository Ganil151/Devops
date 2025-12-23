# SSH & Remote Access

SSH (Secure Shell) is the industry standard for securely communicating with a remote server. It is the primary tool for a DevOps engineer to manage infrastructure that isn't on their local machine.

---

## 1. How SSH Works (Asymmetric Encryption)

SSH relies on public-key cryptography to authenticate the remote computer and allow it to authenticate the user.
- **Private Key**: Kept on your computer (Never share this!).
- **Public Key**: Placed on the remote server (Stored in `~/.ssh/authorized_keys`).
- **Handshake**: When you connect, the server uses your public key to encrypt a challenge that only your private key can decrypt.

---

## 🏗️ 2. Essential SSH Workflow

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

## 🧠 Training & Assessment

### Knowledge Quiz

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

### Real-World Troubleshooting Scenarios

#### Scenario 1: "Permission Denied (publickey)"
**Problem:** You try to connect to a new server, but it rejects your connection.
**Investigation:**
1.  **Check Key:** Do you have a private key in `~/.ssh/`?
2.  **Check Server:** Is your *public* key inside the server's `~/.ssh/authorized_keys`?
3.  **Check Permissions:** SSH is strict. `~/.ssh/` must be `700` and `authorized_keys` must be `600`.
**Solution:** Ensure permissions are correct on both sides and that the key is actually loaded into your `ssh-agent`.

#### Scenario 2: "Host Key Verification Failed"
**Problem:** You try to connect to a server you've used before, but Git/SSH warns you the key has changed.
**Investigation:**
1.  **Cause:** The server might have been reinstalled, or someone is performing a Man-in-the-Middle attack.
**Solution:** If you *know* the server was reinstalled, remove the old key from your local cache: `ssh-keygen -f "~/.ssh/known_hosts" -R "server-ip"`.

---

## ✅ Knowledge Check
- [ ] Generate an SSH key pair
- [ ] Transfer a key using `ssh-copy-id`
- [ ] Configure a `~/.ssh/config` file with at least one alias
- [ ] Set up a local port forward to access a remote service
- [ ] Secure a server by disabling password authentication

---
 **Collaboration**: Remote access is just the start. Learn how to track changes in [Git & GitHub](../04-Git-GitHub/README.md).
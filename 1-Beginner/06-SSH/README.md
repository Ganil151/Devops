# SSH & Remote Access

SSH (Secure Shell) is the industry standard for securely communicating with a remote server. It is the primary tool for a DevOps engineer to manage infrastructure that isn't on their local machine.

---

## 1. How SSH Works (Asymmetric Encryption)

SSH relies on public-key cryptography to authenticate the remote computer and allow it to authenticate the user.
- **Private Key**: Kept on your computer (Never share this!).
- **Public Key**: Placed on the remote server (Stored in `~/.ssh/authorized_keys`).
- **Handshake**: When you connect, the server uses your public key to encrypt a challenge that only your private key can decrypt.

---

## 2. Core Concepts

- **Key Generation**: Using `ssh-keygen -t ed25519` (the modern standard).
- **Config File**: Using `~/.ssh/config` to manage multiple servers with aliases.
- **Port Forwarding**: Tunneling local traffic to a remote server.
- **Agents**: Using `ssh-agent` to store your keys in memory so you don't have to keep typing passwords.

---

## 3. Tooling Reference
- `ssh user@ip`: Standard connection.
- `scp file.txt user@ip:/path`: Secure copy of files.
- `ssh-copy-id user@ip`: Automated way to install your public key on a server.
- `ssh-add`: Adding a key to your agent.

---

## 4. Best Practices
1. **Never use Passwords**: Always use SSH Keys.
2. **Disable Root Login**: Force users to log in as standard users and then use `sudo`.
3. **Change Default Port**: Moving from port 22 to a random port can stop 99% of automated brute-force bots.
4. **Use Modern Algorithms**: Prefer `ed25519` over older `RSA` keys.

---
**Build Automation**: Remote access is just the start. Learn how to automate builds with [Maven](../07-Maven/README.md).
# 🔑 SSH Security & Configuration: The Access Manual
*Version 1.0 | Hardening Remote Management & Tunneling*

---

## 📖 Overview
Secure Shell (SSH) is the industry standard for remote server administration. For a DevOps professional, SSH is not just a login tool—it's a secure transit layer for automation agents (like Ansible), file transfers (SCP), and port forwarding.

---

## 🏗️ The Key Pairing Standard

### Public Key
**Definition**: A cryptographic key that can be shared with anyone. Placed inside the `~/.ssh/authorized_keys` file of the server you want to access.
**Example**: `ssh-rsa AAAAB3Nza...`

### Private Key
**Definition**: A secret key that must never be shared. Kept on your local machine to prove your identity.
**Example**: `id_rsa` or `id_ed25519`.

### Key Generation
**Definition**: Creating a strong key pair.
**Example**: `ssh-keygen -t ed25519 -C "admin@domain.com"`.

---

## 🛡️ SRE Hardening: `sshd_config`

### `PermitRootLogin no`
**Definition**: Disables direct SSH access for the `root` user.
**Impact**: Forces attackers to guess a standard username first, reducing the attack surface.

### `PasswordAuthentication no`
**Definition**: Disables password-based logins, requiring SSH keys only.
**Impact**: Eliminates the risk of "Brute Force" password attacks.

### `Port 2222` (Security through Obscurity)
**Definition**: Changing the default SSH port (22) to a non-standard port.
**Impact**: Stops 99% of scripted bot scans.

---

## 🔧 Essential SSH Utilities

### `ssh-copy-id`
**Definition**: Installs your public key on a remote server correctly with the right permissions.
**Example**: `ssh-copy-id -i ~/.ssh/id_ed25519 user@remote-host`.

### `scp` / `rsync`
**Definition**: `scp` is for simple file transfer; `rsync` is for efficient, incremental synchronization.
**Example**: `rsync -avz ./local_dir/ user@server:/remote_dir/`.

### `ssh-agent`
**Definition**: A background process that holds your decrypted private keys in RAM so you don't have to re-enter your passphrase.
**Example**: `ssh-add ~/.ssh/id_ed25519`.

---

## 💡 Tunneling & Proxying
- **Local Port Forwarding**: Access a remote database locally. `ssh -L 3306:localhost:3306 user@db-gateway`.
- **Dynamic Forwarding (SOCKS)**: Use a remote server as a proxy for all browser traffic. `ssh -D 8080 user@proxy-host`.

---
**Next Step**: [Linux Best Practices →](./linux-best-practices-ref.md)

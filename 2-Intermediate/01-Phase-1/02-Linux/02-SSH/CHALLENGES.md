# SSH Hardening & Tunneling Challenges 🛡️

Secure your communications and master the art of the encrypted tunnel.

---

## 🏆 Challenge 01: The Bastion Lock-down
**Objective**: Hardening `sshd_config` for production use.

1.  **Scenario**: You are tasked with securing a new Linux server.
2.  **Task**: Modify a copy of `sshd_config` (see Boilerplates) with the following rules:
    *   Disable Root Password login (allow keys only).
    *   Change the default SSH port from 22 to 2222.
    *   Limit login attempts to 3.
    *   Disable X11 Forwarding (unless explicitly needed).
3.  **Command**: Research how to reload the SSH service without disconnecting your current session.
4.  **Verification**: Write a command to test the configuration syntax before applying it (`sshd -t`).

---

## 🏆 Challenge 02: The Jump Host (SSH Proxy)
**Objective**: Access a private server through a public gateway.

1.  **Scenario**: Private Server `10.0.1.5` is only accessible from Bastion Host `34.20.10.5`.
2.  **Task**: Research the `-J` (Jump) flag.
3.  **Action**: Draft a one-liner command to SSH into the Private Server directly from your laptop using the Bastion.
4.  **Advanced**: Add an entry to your `~/.ssh/config` file to automate this so you can just type `ssh private-app`.

---

## 🏆 Challenge 03: Local Port Forwarding
**Objective**: Access a remote database locally through an encrypted tunnel.

1.  **Requirement**: A Remote DB is running on Port 5432 on a server at `db-prod.internal`.
2.  **Task**: Use SSH to map the remote Port 5432 to your Localhost Port 8888.
3.  **Command**: Research `ssh -L`.
4.  **Security Question**: Why is port forwarding safer than opening Port 5432 to the entire Internet in a Security Group?

---

## 📁 Solutions
Hardened configuration templates and SSH Config snippets are found in the `Boilerplates/` directory.

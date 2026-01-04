# Introduction to SSH

## What is SSH?

SSH (Secure Shell) is a cryptographic network protocol for operating network services securely over an unsecured network. Its most notable applications are remote login and command-line execution.

## Why is it important?

For DevOps engineers and System Administrators, SSH is the primary tool for:
- Managing remote servers.
- Securely transferring files (SCP/SFTP).
- Tunneling other protocols for security.
- Automating infrastructure tasks (Ansible runs over SSH).

## Key Concepts

1.  **Client-Server Model**: You run an SSH client (like `ssh` on Linux/Mac or PowerShell on Windows) to connect to an SSH server (`sshd` running on the remote machine).
2.  **Encryption**: All traffic is encrypted. Even if someone intercepts the data, they cannot read it.
3.  **Authentication**: Verifies your identity using passwords (less secure) or SSH Keys (more secure).

## Basic Usage

To connect to a remote server:

```bash
ssh username@hostname_or_ip
```

Example:

```bash
ssh admin@192.168.1.50
```

## Next Steps

Once you understand the basics, move on to configuring your client:
- **[Client Configuration](../02-Configuration/README.md)**: Simplify your connections with `~/.ssh/config`.

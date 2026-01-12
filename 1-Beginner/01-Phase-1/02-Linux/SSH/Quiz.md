# Quiz: SSH Mastery

Test your knowledge of secure remote access.

---

### 1. Which file on the server stores the public keys allowed to connect?
- [ ] A) `~/.ssh/known_hosts`
- [ ] B) `/etc/ssh/ssh_config`
- [x] C) `~/.ssh/authorized_keys`
- [ ] D) `~/.ssh/id_rsa.pub`

### 2. What is the correct permission for a private key file (`id_rsa`)?
- [ ] A) 777
- [ ] B) 644
- [x] C) 600
- [ ] D) 700

### 3. Which SSH flag is used for local port forwarding?
- [x] A) `-L`
- [ ] B) `-R`
- [ ] C) `-D`
- [ ] D) `-P`

### 4. What does the command `ssh -v` provide?
- [ ] A) Version information
- [x] B) Verbose output for debugging
- [ ] C) Verification of the remote host
- [ ] D) Virtual terminal access

### 5. In which file do you define SSH aliases to simplify connections?
- [ ] A) `/etc/hosts`
- [ ] B) `~/.bashrc`
- [x] C) `~/.ssh/config`
- [ ] D) `/etc/ssh/sshd_config`

### 6. Which cryptographic algorithm is currently recommended for new SSH keys?
- [ ] A) DSA
- [ ] B) RSA 1024
- [ ] C) MD5
- [x] D) Ed25519

### 7. What is the effect of `PermitRootLogin no` in `sshd_config`?
- [ ] A) Users cannot use the `sudo` command
- [x] B) The `root` user cannot log in directly via SSH
- [ ] C) Only the `root` user can log in
- [ ] D) Root can only log in with a password

### 8. Which command is used to remove a stale host key from `known_hosts`?
- [ ] A) `rm ~/.ssh/known_hosts`
- [x] B) `ssh-keygen -R <hostname>`
- [ ] C) `ssh-copy-id -R <hostname>`
- [ ] D) `ssh-add -d <hostname>`

---

## 🏆 Assessment
- **Score 0-3**: You're at risk of getting locked out!
- **Score 4-6**: Good knowledge of basic connectivity.
- **Score 7-8**: SSH Expert! You can safely manage large clusters.

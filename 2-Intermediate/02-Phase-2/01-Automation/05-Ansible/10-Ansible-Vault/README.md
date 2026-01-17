# Ansible Vault: Securing Secrets

Automation usually requires sensitive data—API keys, database passwords, and SSH keys. Storing these in plain text in a Git repository is a major security risk. **Ansible Vault** provides encryption at rest for your variables and files.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `vault_usage.txt` (Command reference and integration).
- **[CHALLENGES](./CHALLENGES.md)**: Encrypting files, string encryption, and using password files.

---

## 🔑 Key Concepts

| Command | Action |
| :--- | :--- |
| **`create`** | Create a new encrypted file. |
| **`encrypt`** | Encrypt an existing plain-text file. |
| **`decrypt`** | Permanently decrypt a file back to plain text. |
| **`edit`** | Edit an encrypted file without permanently decrypting it. |
| **`encrypt_string`** | Encrypt a single specific value for use in a plain-text file. |

---

## 🏗️ Robust Security Patterns

### 1. `no_log: true`
Encryption at rest is useless if your secrets are printed to the console (and thus stored in CI/CD logs) during execution.

```yaml
- name: Set API Token
  shell: "my-cli login --token {{ vault_api_token }}"
  no_log: true # This hides the entire task output from logs
```

### 2. The Password File
Typing a password every time you run a playbook is impossible in a CI/CD pipeline (Jenkins, GitLab, GitHub Actions).

```bash
# Store the vault password in a protected file
echo "my_vault_password" > ~/.ansible_vault_pass
chmod 600 ~/.ansible_vault_pass

# Reference it in ansible.cfg or via CLI
ansible-playbook site.yml --vault-password-file ~/.ansible_vault_pass
```

---

## 📖 Real-World Story: The "Public Secret" Leak

**Scenario**: A developer committed a new Ansible Role to GitHub that included a `vars/main.yml` containing a Production AWS Secret Key.
**Crisis**: Within 2 minutes, bot scanners found the key and started spinning up 100 expensive GPU instances for crypto-mining.
**Outcome**: The company received a $10,000 bill in 4 hours.
**Solution**: Implemented a "Pre-Commit Hook" that scans for secrets and enforced **Ansible Vault** for all sensitive variables.
**Result**: All secrets are now AES256 encrypted. Even if the repo is public, the secrets stay safe.

---

## ❓ Interview Questions

1. **What encryption algorithm does Ansible Vault use?**
   - *Answer*: AES-256 (Advanced Encryption Standard with a 256-bit key).
2. **How do you handle multiple different vault passwords in one project?**
   - *Answer*: Using "Vault IDs" (`--vault-id label@path`). This allows you to have different passwords for `dev` vs `prod` secrets.
3. **Can you encrypt an entire directory with Ansible Vault?**
   - *Answer*: No, Ansible Vault works on individual files. However, you can use wildcards in the command line or store all secrets in a specific subdirectory.

---

[Next: Custom Modules](../11-Custom-Modules/README.md)
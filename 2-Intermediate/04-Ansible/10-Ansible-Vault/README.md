# Ansible Vault

Never commit passwords to Git in plain text. **Ansible Vault** encrypts secrets so you can store them safely in version control.

## 1. How Vault Works

Vault uses **AES-256** encryption to protect your data.

```mermaid
graph LR
    User[User/Ansible] -->|Password/Key| Decrypt{Decryption}
    Files[Encrypted Files] --> Decrypt
    Decrypt -->|Success| Plain[Cleartext (In Memory)]
    Decrypt -->|Fail| Error[Exit]
```

### Encryption Methods
1.  **Encrypt Entire File**: The whole file is unreadable without the key.
2.  **Encrypt Single String**: You can mix plain text labels with encrypted values (`!vault | ...`).

---

## 2. Vault Workflow

### Basic Commands
```bash
# Create a new encrypted file
ansible-vault create vars/secrets.yml

# Edit an existing encrypted file (opens in vim/nano)
ansible-vault edit vars/secrets.yml

# View contents without editing
ansible-vault view vars/secrets.yml

# Encrypt an existing plain text file
ansible-vault encrypt vars/plain.yml

# Decrypt a file permanently
ansible-vault decrypt vars/encrypted.yml
```

### Changing the Password
```bash
ansible-vault rekey vars/secrets.yml
```

---

## 3. Automation (CI/CD)

Typing a password every time you run a playbook is annoying.
Entering a password in Jenkins/GitLab CI is impossible interactively.

### The Password File
1.  Create a file containing just the password: `echo "my_secret_pass" > .vault_pass`.
2.  Add `.vault_pass` to your `.gitignore` (CRITICAL!).
3.  Run ansible with:
    ```bash
    ansible-playbook site.yml --vault-password-file .vault_pass
    ```
    *   Or set `ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass` in environment variables.

---

## 4. Real-Life Scenarios

### Scenario 1: "The Git Leak"
**Problem**: A developer accidentally committed `db_password: "supersecret"` to a public repo.
**Consequence**: The database was hacked in 15 minutes.
**Solution**: Used `ansible-vault encrypt_string 'supersecret' --name 'db_password'`.
*   Now the repo contains `$ANSIBLE_VAULT;1.1;AES256...`. Even if leaked, it's useless without the key.

### Scenario 2: "CI/CD Integration"
**Problem**: Jenkins needed to run Ansible, but nobody wanted to store the vault password in a file on the Jenkins server.
**Solution**:
1.  Stored the Vault Password in "Jenkins Credentials" (secure storage).
2.  In the pipeline: `withCredentials([file(credentialsId: 'ansible-vault-pass', variable: 'VAULT_FILE')]) { sh 'ansible-playbook ... --vault-password-file $VAULT_FILE' }`.
3.  Jenkins injects the file temporarily and deletes it after the run.

### Scenario 3: "Multiple Vaults"
**Problem**: The "Web Team" and "Database Team" share a repo but shouldn't see each other's secrets.
**Solution**: Used Vault IDs.
*   `ansible-vault create --vault-id web@prompt web_secrets.yml`
*   `ansible-vault create --vault-id db@prompt db_secrets.yml`
*   Run: `ansible-playbook site.yml --vault-id web@.web_pass --vault-id db@.db_pass`.

---

## 5. ❓ Interview Questions

1.  **What encryption algorithm does Ansible Vault use?**
    *   **Answer**: AES-256.

2.  **Can I grep for a string inside an encrypted file?**
    *   **Answer**: No. It is binary data (or base64 encoded binary). You must `ansible-vault view` it first.

3.  **How do you encrypt just one variable, not the whole file?**
    *   **Answer**: `ansible-vault encrypt_string`.

4.  **If I lose my Vault password, can I recover the data?**
    *   **Answer**: No. It is standard AES encryption. Without the key, the data is gone.

5.  **Is `ansible-vault` installed separately?**
    *   **Answer**: No, it comes bundled with `ansible-core`.

6.  **How do you prevent git from tracking the password file?**
    *   **Answer**: Add the filename (e.g., `.vault_pass`) to `.gitignore`.

7.  **Can you have different passwords for different environments (Dev vs Prod)?**
    *   **Answer**: Yes. Usually, you have `group_vars/dev/secrets.yml` encrypted with "pass1" and `group_vars/prod/secrets.yml` encrypted with "pass2". You provide the correct password at runtime.

8.  **What is a "Vault ID"?**
    *   **Answer**: A label allows you to use multiple passwords in one run. `--vault-id dev@.dev_pass`.

9.  **Does Vault hide the variable names?**
    *   **Answer**: If you encrypt the *whole file*, yes. If you use `encrypt_string`, the variable name is visible, but the value is hidden.

10. **How does Ansible know a file is encrypted?**
    *   **Answer**: The header of the file starts with `$ANSIBLE_VAULT;...`.

---

## 6. 🧠 Knowledge Check (Quiz)

### Usage
1.  **To edit an encrypted file:**
    *   [x] `ansible-vault edit filename`.
    *   [ ] `vim filename`.

2.  **To change the password of a vault file:**
    *   [x] `ansible-vault rekey`.
    *   [ ] `ansible-vault passwd`.

3.  **To avoid typing the password interactively:**
    *   [x] `--vault-password-file`.
    *   [ ] `--password-skip`.

4.  **Can you view the file without editing?**
    *   [x] Yes, `ansible-vault view`.
    *   [ ] No.

### Security
5.  **Where should the password file stay?**
    *   [x] On a secure local disk or injected by CI, NEVER in Git.
    *   [ ] In the root logic of the repo.

6.  **If you `cat` an encrypted file, what do you see?**
    *   [x] A text block starting with `$ANSIBLE_VAULT`.
    *   [ ] Binary garbage characters.

7.  **Is MD5 used for Vault?**
    *   [x] No (AES-256).
    *   [ ] Yes.

8.  **Does Ansible decrypt files to disk during execution?**
    *   [x] No, it decrypts in memory.
    *   [ ] Yes, in `/tmp`.

9.  **Can you use Vault for binary files (images/certs)?**
    *   [x] Yes, `ansible-vault encrypt_string` on base64 data, or encrypt the whole file.
    *   [ ] No, text only.

10. **Multiple passwords are supported via:**
    *   [x] Vault IDs.
    *   [ ] Not supported.

### Scenarios
11. **Encrypting `string` vs `file`:**
    *   [x] `file` hides structure (keys), `string` hides only values.
    *   [ ] `string` is more secure.

12. **For CI/CD, the best practice is:**
    *   [x] Inject keys via secret management (Vault/AWS/Jenkins).
    *   [ ] Hardcode in the pipeline script.

13. **If you have `dev` and `prod` secrets:**
    *   [x] You can use the same key or different keys. Different is better.
    *   [ ] Must use the same key.

14. **To speed up decryption:**
    *   [x] It's fast enough not to worry (unless files are massive).
    *   [ ] Use `fast_decrypt: yes`.

15. **If `ansible-playbook` fails with "Decryption failed":**
    *   [x] Wrong password provided.
    *   [ ] Corruption.

### General
16. **Vault is part of:**
    *   [x] Ansible Core.
    *   [ ] Third party plugin.

17. **Can you encrypt `host_vars`?**
    *   [x] Yes.
    *   [ ] No.

18. **The editor used by `ansible-vault edit` is determined by:**
    *   [x] `$EDITOR` environment variable.
    *   [ ] Hardcoded to Vim.

19. **Can you lint encrypted files?**
    *   [x] No (ansible-lint usually skips them unless decrypted).
    *   [ ] Yes.

20. **Is the password passed over SSH?**
    *   [x] No, decryption happens on Control Node, cleartext data is sent over SSH (encrypted transport).
    *   [ ] Yes.
# Parameterization and Secrets Management

Hardcoding values like IP addresses, usernames, or passwords makes automation brittle, insecure, and impossible to reuse across environments (Dev, Staging, Prod).

## 🪜 The Hierarchy of Inputs

DevOps engineers should use the most appropriate input method based on how often the data changes and how sensitive it is.

| Method | Best For... | Example |
| :--- | :--- | :--- |
| **CLI Flags** | Runtime overrides | `--dry-run`, `--force` |
| **Env Variables** | CI/CD parameters | `DB_HOST`, `APP_VERSION` |
| **Config Files** | Logical structure | `config.yaml` |
| **Secrets Manager** | Highly sensitive data | Database Passwords, API Keys |

## 🔑 Handling Secrets Safely

**Never bake secrets into your code or git repositories!** This is the #1 cause of security breaches in DevOps.

### 🐍 Python Example (Environment Variables)
```python
import os

# Safe: Fetches value from the shell environment
db_password = os.getenv("DB_PASSWORD")
if not db_password:
    raise ValueError("DB_PASSWORD not set!")
```

### 🐚 Bash Example (Vault Integration)
```bash
# Fetching a secret from HashiCorp Vault during execution
API_KEY=$(vault kv get -field=key secret/myapp)
```

> [!CAUTION]
> If a script prints a secret to the screen (Standard Out), it will be saved in build logs or console history. Always use tools like `jq` or `grep` to sanitize output before logging.

---

## 📖 Stories from the Field: The $10,000 GitHub Mistake

**Scenario**: A developer committed a Python script to a private GitHub repo. The script contained a hardcoded AWS Accessory Key.
**Problem**: The developer believed being "private" made it safe. Two weeks later, an intern's account was compromised.
**Outcome**: Botnets found the key and spun up 500 massive GPU instances for crypto-mining. The company received a $10,000 bill in 24 hours.
**Resolution**: The keys were revoked, and the script was refactored to pull credentials from an AWS IAM Role (no keys needed in code).
**Prevention**: **Assume every repository will eventually be leaked.** Use IAM roles or Secrets Managers for all production credentials.

---

## ❓ Interview Questions

1. **Why is hardcoding environment-specific values a "Day 0" mistake?**
   * *Answer*: It makes it impossible to promote the exact same automation from Dev to Prod, violating the core DevOps principle of "Consistency."
2. **Difference between an Environment Variable and a Config File?**
   * *Answer*: Environment variables are better for "Secrets" and "Global" settings that a CI/CD system might inject. Config files (YAML/JSON) are better for complex, structured settings that don't change often.
3. **How do you safely pass a secret to a Docker container?**
   * *Answer*: Use Docker Secrets, Kubernetes Secrets, or inject them as Environment Variables at runtime (not in the Dockerfile).
4. **What is a `.env` file and should it be in Git?**
   * *Answer*: A `.env` file stores local development variables. It should **NEVER** be committed to Git; instead, commit a `.env.example` file with dummy values.
5. **How do you rotate secrets in a production script?**
   * *Answer*: By pulling the secret from a Secrets Manager (like AWS Secrets Manager) on every run. When the secret is rotated in the manager, the script automatically gets the new value next time it executes.

---

## 🧠 Quiz

1. **Where should you store a database password?** `(Secrets Manager / Vault)`
2. **True/False: It is okay to hardcode IP addresses if the repo is private.** `(False)`
3. **Which Python function reads environment variables?** `(os.getenv())`
4. **Which input method is best for runtime flags like --verbose?** `(CLI Arguments)`
5. **What is the primary risk of printing secrets to the console?** `(They are saved in logs/history)`
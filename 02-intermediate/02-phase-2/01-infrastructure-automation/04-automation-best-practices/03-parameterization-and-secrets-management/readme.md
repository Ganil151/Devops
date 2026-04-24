# Parameterization and Secrets Management

Hardcoding is the root of all technical debt. If you change a server IP or a password and have to edit 10 different scripts, your automation is broken. **Parameterization** decouples your logic from your data.

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `config_loader.py` (Env vars and defaults).
- **[CHALLENGES](./challenges.md)**: Building secure loaders.

---

## 🔑 The Input Hierarchy
Never hardcode. Follow this hierarchy from worst to best:

1.  **Level 1 (Worst)**: Hardcoded string in the function.
2.  **Level 2**: Variable at the top of the file.
3.  **Level 3**: Command-line argument (`sys.argv`).
4.  **Level 4**: Environment Variable (`os.environ`).
5.  **Level 5 (Best)**: External Secret Store (AWS Secrets Manager, HashiCorp Vault, Ansible Vault).

---

## 🏗️ Robust Pattern: Env Var Defaults

```python
import os

# USE THIS: Decoupled and flexible
DB_USER = os.getenv("DB_USER", "guest") # Defaults to 'guest' if env var missing

# NEVER THIS: Hardcoded
# db_user = "admin" 
```

---

## 🛡️ Secrets: The "No-Log" Rule
When dealing with secrets, ensure they never leak into logs.

```python
def login(password):
    # BAD: Logs the password!
    print(f"DEBUG: Logging in with {password}")
    
    # GOOD
    print("DEBUG: Attempting login...")
```

---

## 📖 Real-World Story: The "Public Secret" Leak

**Scenario**: A developer hardcoded an AWS `access_key` in a script to "save time".
**Crisis**: They pushed the code to a Public GitHub repo.
**Outcome**: Within 60 seconds, bots detected the key. Within 5 minutes, 20 high-end GPU instances were started in the account. Total cost: $4,000 in one hour.
**Solution**: Switched to **Secrets Manager**. The script now requests a temporary token at runtime.

---

## ❓ Interview Questions

1. **Why use Environment Variables instead of command-line flags for secrets?**
   - *Answer*: Command-line flags (like `./script.py --password=xyz`) show up in the process list (`ps -aux`), meaning any user on the machine can see the password. Environment variables are private to the process and its children.
2. **What is 'Twelve-Factor App' configuration?**
   - *Answer*: A methodology that states app configuration should be stored in environment variables, completely separate from the code.
3. **How do you handle 'Configuration Drift' when parameters change?**
   - *Answer*: By using a centralized configuration store (Consul, Vault, or a Git-versioned YAML file) that all scripts pull from.

---

[Next: Failure Handling and Atomicity](../04-failure-handling-and-atomicity/readme.md)
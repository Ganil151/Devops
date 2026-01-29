# 🔐 Environment Variables: The 12-Factor Configuration

> **"Code is static, but environments are dynamic. If you hardcode a credentials or a URL, you've built a fragile script. If you use environment variables, you've built a portable tool."**

**⚠️ Missing Image**: *Python Ecosystem* ('../../assets/python_ecosystem.png')

## 📚 Overview
Environment variables are the "Gold Standard" for configuring modern, cloud-native applications. They allow you to change a script's behavior—switching from a development database to a production one—without changing a single line of code. This fulfills a core principle of the **12-Factor App** methodology.

In DevOps, you will use environment variables to:
* Pass **Secrets** (API keys, passwords) securely to containers.
* Toggle **Feature Flags** or Log Levels (`DEBUG` vs `INFO`) in CI/CD.
* Define **Environment Targets** (`staging` vs `production`) for deployment scripts.

This module covers the `os` module for basic handling and the `python-dotenv` library for managing local secrets safely.

## 🎓 Learning Objectives
By the end of this module, you will:
* ✅ Master the **Safest Access Pattern** using `os.environ.get()`.
* ✅ Implement **Strict Validation** for mandatory production variables.
* ✅ Management **Local Secrets** using `.env` files and `python-dotenv`.
* ✅ Build **Type-Safe Config Classes** using Python Dataclasses.
* ✅ Protect against **Credential Leaks** using security best practices.

---

## 🏗️ The Configuration Hierarchy

In a professional DevOps pipeline, configuration values often flow from multiple sources.

### 1. Reading and Setting Variables (`os.environ`)
Python interacts with the host environment through the `os` module.

```python
import os

# 1. Reading safely: Returns 'localhost' if DB_HOST is missing
db_host = os.environ.get("DB_HOST", "localhost")

# 2. Reading strictly: Raises KeyError if API_KEY is missing
# 💡 Best for MANDATORY variables in production
api_key = os.environ["API_KEY"]

# 3. Setting a variable: (Only affects this script and its children)
os.environ["DEPLOY_STATUS"] = "IN_PROGRESS"
```

### 2. Local Development with `.env` Files
You should never hardcode secrets in your script or export them manually in every terminal session. Use a `.env` file (and ensure it is in your `.gitignore`!).

```text
# .env (Local Only)
DB_USER=admin
DB_PASS=super-secret-password
GITHUB_TOKEN=ghp_123456789
```

```python
from dotenv import load_dotenv
import os

# 🧠 Loads the .env file into os.environ at startup
load_dotenv()

# Access as usual
github_token = os.environ.get("GITHUB_TOKEN")
```

---

## 🚀 Advanced Pattern: The Config Dataclass

Accessing `os.environ` randomly throughout a 1,000-line script is a maintenance nightmare. Instead, load everything into a single, type-safe **Config Object** at startup.

```python
from dataclasses import dataclass
import os

@dataclass
class AppConfig:
    db_url: str
    port: int
    is_debug: bool

def load_config() -> AppConfig:
    # 💡 Centrally handle defaults and type casting here
    return AppConfig(
        db_url=os.environ.get("DATABASE_URL", "sqlite:///dev.db"),
        port=int(os.environ.get("APP_PORT", 8080)),
        is_debug=os.environ.get("DEBUG", "false").lower() == "true"
    )

# Now, use dot notation (config.port) for better IDE support and safety
config = load_config()
if config.is_debug:
    print(f"Debugger active on port {config.port}")
```

---

## 🛡️ Security Checkpoint: The "Leaks" Checklist

| Rule | Action |
| :--- | :--- |
| **No Hardcoding** | Never put raw passwords in `.py` files. |
| **Masking** | If you log `os.environ`, ensure you scrub sensitive keys. |
| **.gitignore** | Always add `.env` and `*.pem` to your ignore list. |
| **Pre-commit** | Use tools like `gitleaks` or `trufflehog` to scan for secrets. |

---

## 🏆 Real-World DevOps Story: The Public Password

**The Scenario**: A junior engineer was debugging a Terraform-wrapper script locally. He was tired of exporting his AWS credentials every time, so he added them to a `.env` file in the project root.

**The Discovery**: He pushed his changes to the company's public GitHub repository, forgetting that he hadn't created a `.gitignore` file yet. Within **22 seconds**, an automated bot detected the credentials and used them to spin up 50 "extra-large" EC2 instances for crypto-mining in 5 different regions.

**The Solution**: The company's automated security scanner detected the "Unusual Activity" and killed the instances, but the bill was already $4,000.

**The Outcome**: The team implemented a mandatory "Secret Scanning" gate in the CI/CD pipeline and moved to using **AWS IAM Roles** for development machines, eliminating the need for long-lived secret keys entirely.

---

## ❓ Interview Preparation (Environment Variables)

* **Q: Why is `get()` better than direct indexing `os.environ['KEY']`?**
  * *A: Direct indexing raises a `KeyError` if the key is missing, crashing the script. `get()` allows you to provide a default value, making the script more "Resilient" to missing configuration.*

* **Q: How do you handle environment variables in a containerized (Docker) environment?**
  * *A: You pass them using the `-e` flag (`docker run -e KEY=VAL`) or define them in an `env_file`. Inside the container, Python accesses them exactly the same way via `os.environ`.*

* **Q: Can a Python script change the environment variables of the terminal that started it?**
  * *A: No. A process can change its own environment and the environment of its **children**, but it cannot modify the environment of its **parent** process (the shell).*

* **Q: What is the '12-Factor App' rule for configuration?**
  * *A: It states that configuration should be strictly decoupled from the code and stored in environment variables, ensuring that the same build can run in Dev, Stage, and Prod without modification.*

* **Q: How do you handle multi-line secrets (like an SSH Private Key) in an environment variable?**
  * *A: Common solutions include base64-encoding the entire key and decoding it in Python, or replacing newlines with a specific character (like `\n`) and using `.replace()` in the script.*

---

## 📝 Knowledge Check

* [ ] a) `dotenv`
* [x] b) `os`
* [ ] c) `sys`

* [ ] a) `None`
* [x] b) `5000`
* [ ] c) Error

* [ ] a) On your local workstation
* [ ] b) In a secure password manager
* [x] c) In a public Git repository

* [ ] a) `python-env`
* [x] b) `python-dotenv`
* [ ] c) `env-loader`

* [x] a) It provides type safety and better IDE autocompletion (IntelliSense).
* [ ] b) It makes the script run faster.
* [ ] c) It encrypts the variables in RAM.

---

## 🔗 Next Steps

Environment variables are for system-level config, but for user-facing tools, Command Line Arguments are the preferred interface.

Proceed to: **[Command Line Arguments →](../Part-09-Command-Line-Arguments/README.md)**

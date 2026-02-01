# 🔐 Environment Variables: The Secret Vault

> **"Code is static, but environments are dynamic. If you hardcode credentials or a URL, you've built a fragile script. If you use environment variables, you've built a portable tool."**

![Environment Variables](../../assets/env_vars.png)

---

## 🧠 The Mental Model: Environment Variables as the Control Panel

**The Junior Struggle**: "Why not just put the database password in the code?"

**The Engineer Solution**: Environment variables are like a **control panel** that changes behavior without changing code. Same script, different settings for dev/staging/production.

### 🏗️ The Infrastructure Analogy

Think of environment variables like a **car's dashboard controls**:

| Concept | Car Analogy | Environment Variable |
|:--------|:------------|:---------------------|
| **Control Panel** | Dashboard with knobs and switches | Collection of env vars |
| **Settings** | AC temperature, radio station | DB_HOST, API_KEY, LOG_LEVEL |
| **Same Car, Different Settings** | You adjust for weather/preference | Same code, different environments |
| **Hidden Compartment** | Glove box for valuables | Secrets stored securely |
| **Factory Defaults** | Car comes with preset settings | Default values in code |

**The Key Insight**: Just like you adjust car settings without modifying the engine, you configure applications via environment variables without changing code.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "I'll just hardcode the database URL"
- "I'll commit my API keys to Git"
- "Different environments need different code"

**After this module**, you'll understand:
- **Environment variables separate config from code** (12-factor app)
- **Secrets should never be in source code**
- **Same codebase runs in dev/staging/production** with different env vars
- **.env files manage local development** safely
- **Type-safe config classes** prevent runtime errors

**The Difference**: Your applications will be portable, secure, and follow industry best practices.

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Read Environment Variables**: Using `os.environ.get()` safely
- ✅ **Set Environment Variables**: For child processes
- ✅ **Validate Required Variables**: Fail fast if missing
- ✅ **Use .env Files**: Manage local secrets with python-dotenv
- ✅ **Build Config Classes**: Type-safe configuration objects
- ✅ **Prevent Credential Leaks**: Security best practices
- ✅ **Follow 12-Factor App**: Industry-standard configuration

---

## 🏗️ Part 1: Reading Environment Variables

### 🧠 The Mental Model: The Safe vs Unsafe Access

**The Concept**: Environment variables might not exist. Always handle missing variables gracefully.

### 🔧 Basic Access Patterns

```python
import os

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Method 1: Safe access with default (RECOMMENDED)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ✅ Returns "localhost" if DB_HOST doesn't exist
db_host = os.environ.get("DB_HOST", "localhost")
db_port = os.environ.get("DB_PORT", "5432")

print(f"Connecting to {db_host}:{db_port}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Method 2: Strict access (for REQUIRED variables)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

try:
    # ❌ Raises KeyError if API_KEY doesn't exist
    api_key = os.environ["API_KEY"]
    print("API key loaded successfully")
except KeyError:
    print("❌ ERROR: API_KEY environment variable is required")
    exit(1)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Method 3: Check if variable exists
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if "DEBUG" in os.environ:
    print("Debug mode is enabled")
else:
    print("Debug mode is disabled")
```

### 🚀 Professional Pattern: Safe Environment Variable Reader

```python
import os
from typing import Optional

def get_env_var(
    key: str,
    default: Optional[str] = None,
    required: bool = False
) -> str:
    """
    Safely get an environment variable.
    
    Args:
        key: Environment variable name
        default: Default value if not found
        required: If True, raise error if not found
    
    Returns:
        Environment variable value
    
    Raises:
        ValueError: If required=True and variable not found
    
    Example:
        >>> db_host = get_env_var("DB_HOST", "localhost")
        >>> api_key = get_env_var("API_KEY", required=True)
    """
    value = os.environ.get(key, default)
    
    if required and value is None:
        raise ValueError(
            f"Required environment variable '{key}' is not set. "
            f"Please set it before running this script."
        )
    
    return value


# 🎯 Usage
try:
    # Optional with default
    db_host = get_env_var("DB_HOST", "localhost")
    
    # Required (will raise error if missing)
    api_key = get_env_var("API_KEY", required=True)
    
    print(f"Connecting to {db_host} with API key")
    
except ValueError as e:
    print(f"❌ Configuration error: {e}")
    exit(1)
```

**💡 Pro Tip**: Use `.get()` for optional variables with defaults. Use `[]` or `required=True` for mandatory variables.

---

## 🔧 Part 2: Type Conversion and Validation

### 🧠 The Mental Model: The Type Enforcer

**The Problem**: Environment variables are always strings. You need to convert them to the right type.

### 🔧 Type Conversion Patterns

```python
import os
from typing import List

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Converting to integers
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ✅ Safe conversion with default
port = int(os.environ.get("PORT", "8080"))
max_retries = int(os.environ.get("MAX_RETRIES", "3"))

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Converting to booleans
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def str_to_bool(value: str) -> bool:
    """Convert string to boolean."""
    return value.lower() in ("true", "1", "yes", "on")

debug = str_to_bool(os.environ.get("DEBUG", "false"))
dry_run = str_to_bool(os.environ.get("DRY_RUN", "false"))

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Converting to lists
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Environment variable: ALLOWED_IPS="10.0.1.5,10.0.1.10,10.0.1.15"
allowed_ips_str = os.environ.get("ALLOWED_IPS", "")
allowed_ips: List[str] = [ip.strip() for ip in allowed_ips_str.split(",") if ip.strip()]

print(f"Allowed IPs: {allowed_ips}")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Converting to floats
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cpu_limit = float(os.environ.get("CPU_LIMIT", "0.5"))
memory_limit = float(os.environ.get("MEMORY_LIMIT", "1.0"))
```

### 🚀 Professional Pattern: Validated Environment Reader

```python
import os
from typing import Optional, List, Union

def get_int_env(key: str, default: int = 0, min_val: Optional[int] = None, max_val: Optional[int] = None) -> int:
    """
    Get integer environment variable with validation.
    
    Args:
        key: Environment variable name
        default: Default value if not found
        min_val: Minimum allowed value
        max_val: Maximum allowed value
    
    Returns:
        Integer value
    
    Raises:
        ValueError: If value is invalid or out of range
    """
    value_str = os.environ.get(key)
    
    if value_str is None:
        return default
    
    try:
        value = int(value_str)
    except ValueError:
        raise ValueError(f"Environment variable '{key}' must be an integer, got: {value_str}")
    
    if min_val is not None and value < min_val:
        raise ValueError(f"Environment variable '{key}' must be >= {min_val}, got: {value}")
    
    if max_val is not None and value > max_val:
        raise ValueError(f"Environment variable '{key}' must be <= {max_val}, got: {value}")
    
    return value


# 🎯 Usage
try:
    port = get_int_env("PORT", default=8080, min_val=1024, max_val=65535)
    workers = get_int_env("WORKERS", default=4, min_val=1, max_val=32)
    
    print(f"Starting server on port {port} with {workers} workers")
    
except ValueError as e:
    print(f"❌ Configuration error: {e}")
    exit(1)
```

**💡 Pro Tip**: Always validate environment variables at startup. Fail fast if configuration is invalid.

---

## 📁 Part 3: Local Development with .env Files

### 🧠 The Mental Model: The Local Secrets File

**The Problem**: Manually exporting environment variables in every terminal session is tedious.

**The Solution**: Use a `.env` file for local development (never commit it to Git!).

### 🔧 Using python-dotenv

```bash
# Install python-dotenv
pip install python-dotenv
```

```python
# .env file (in project root, add to .gitignore!)
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=super-secret-password
API_KEY=sk_test_123456789
DEBUG=true
LOG_LEVEL=DEBUG
```

```python
# main.py
from dotenv import load_dotenv
import os

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Load .env file at startup
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ✅ Loads .env file into os.environ
load_dotenv()

# Now access variables normally
db_host = os.environ.get("DB_HOST")
db_user = os.environ.get("DB_USER")
db_password = os.environ.get("DB_PASSWORD")

print(f"Connecting to {db_host} as {db_user}")
```

### 🚀 Professional Pattern: Environment-Specific .env Files

```python
from dotenv import load_dotenv
import os

def load_environment_config(env: str = "development") -> None:
    """
    Load environment-specific configuration.
    
    Args:
        env: Environment name (development, staging, production)
    """
    # Map environment to .env file
    env_files = {
        "development": ".env.development",
        "staging": ".env.staging",
        "production": ".env.production"
    }
    
    env_file = env_files.get(env, ".env")
    
    # Load the appropriate .env file
    if os.path.exists(env_file):
        load_dotenv(env_file)
        print(f"✅ Loaded configuration from {env_file}")
    else:
        print(f"⚠️ Warning: {env_file} not found, using system environment variables")


# 🎯 Usage
environment = os.environ.get("ENVIRONMENT", "development")
load_environment_config(environment)

# Now use environment variables
db_host = os.environ.get("DB_HOST")
```

**💡 Pro Tip**: Use different `.env` files for different environments, but **never** commit them to Git.

---

## 🏗️ Part 4: Type-Safe Configuration Classes

### 🧠 The Mental Model: The Configuration Object

**The Problem**: Accessing `os.environ` throughout your code is messy and error-prone.

**The Solution**: Load all configuration into a single, type-safe object at startup.

### 🔧 Using Dataclasses

```python
from dataclasses import dataclass
from typing import List
import os

@dataclass
class DatabaseConfig:
    """Database connection configuration."""
    host: str
    port: int
    user: str
    password: str
    database: str
    
    @property
    def connection_string(self) -> str:
        """Generate database connection string."""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"


@dataclass
class AppConfig:
    """Application configuration."""
    environment: str
    debug: bool
    log_level: str
    port: int
    workers: int
    allowed_hosts: List[str]
    database: DatabaseConfig


def load_config() -> AppConfig:
    """
    Load configuration from environment variables.
    
    Returns:
        AppConfig object with all configuration
    
    Raises:
        ValueError: If required variables are missing
    """
    # Helper function for boolean conversion
    def str_to_bool(value: str) -> bool:
        return value.lower() in ("true", "1", "yes", "on")
    
    # Load database configuration
    database = DatabaseConfig(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", "5432")),
        user=os.environ.get("DB_USER", "postgres"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "myapp")
    )
    
    # Load application configuration
    allowed_hosts_str = os.environ.get("ALLOWED_HOSTS", "localhost")
    allowed_hosts = [host.strip() for host in allowed_hosts_str.split(",")]
    
    return AppConfig(
        environment=os.environ.get("ENVIRONMENT", "development"),
        debug=str_to_bool(os.environ.get("DEBUG", "false")),
        log_level=os.environ.get("LOG_LEVEL", "INFO"),
        port=int(os.environ.get("PORT", "8080")),
        workers=int(os.environ.get("WORKERS", "4")),
        allowed_hosts=allowed_hosts,
        database=database
    )


# 🎯 Usage
config = load_config()

print(f"Environment: {config.environment}")
print(f"Debug mode: {config.debug}")
print(f"Server port: {config.port}")
print(f"Database: {config.database.connection_string}")

# Use config throughout your application
if config.debug:
    print("🐛 Debug mode enabled")
```

**💡 Pro Tip**: Load configuration once at startup into a config object. Use type hints for IDE autocomplete.

---

## 🛡️ Part 5: Security Best Practices

### 🧠 The Mental Model: The Security Checklist

**The Danger**: Leaked credentials can cost thousands of dollars in minutes.

**The Solution**: Follow security best practices religiously.

### 📋 Security Checklist

| Rule | Action | Why |
|:-----|:-------|:----|
| **Never hardcode secrets** | Use environment variables | Prevents accidental commits |
| **Add .env to .gitignore** | Always | Prevents committing secrets |
| **Use .env.example** | Template without secrets | Shows required variables |
| **Mask secrets in logs** | Redact sensitive values | Prevents log leaks |
| **Use secret managers** | AWS Secrets Manager, Vault | Production-grade security |
| **Rotate credentials** | Regular schedule | Limits exposure window |
| **Use IAM roles** | Instead of API keys | No long-lived credentials |

### 🔧 .gitignore Template

```gitignore
# Environment files
.env
.env.local
.env.*.local
.env.development
.env.staging
.env.production

# Credentials
*.pem
*.key
*.p12
*.pfx
credentials.json
secrets.yaml

# IDE files
.vscode/
.idea/
```

### 🔧 .env.example Template

```bash
# .env.example - Template for required environment variables
# Copy this to .env and fill in your values

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=your_database

# API Keys (get from https://example.com/api-keys)
API_KEY=your_api_key_here
API_SECRET=your_api_secret_here

# Application Settings
ENVIRONMENT=development
DEBUG=false
LOG_LEVEL=INFO
PORT=8080
```

### 🚀 Professional Pattern: Secret Masking in Logs

```python
import os
import re
from typing import Dict, Any

def mask_secrets(data: Dict[str, Any], sensitive_keys: list = None) -> Dict[str, Any]:
    """
    Mask sensitive values in a dictionary.
    
    Args:
        data: Dictionary to mask
        sensitive_keys: List of keys to mask (default: common secret keys)
    
    Returns:
        Dictionary with masked values
    """
    if sensitive_keys is None:
        sensitive_keys = [
            "password", "passwd", "pwd",
            "secret", "token", "key", "api_key",
            "access_token", "refresh_token",
            "private_key", "credentials"
        ]
    
    masked_data = {}
    
    for key, value in data.items():
        # Check if key contains sensitive terms
        is_sensitive = any(term in key.lower() for term in sensitive_keys)
        
        if is_sensitive and value:
            # Mask the value
            masked_data[key] = "***REDACTED***"
        else:
            masked_data[key] = value
    
    return masked_data


# 🎯 Usage
config = {
    "DB_HOST": "localhost",
    "DB_PASSWORD": "super-secret-123",
    "API_KEY": "sk_live_abc123xyz",
    "PORT": "8080"
}

# Safe to log
safe_config = mask_secrets(config)
print(f"Configuration: {safe_config}")
# Output: {'DB_HOST': 'localhost', 'DB_PASSWORD': '***REDACTED***', 'API_KEY': '***REDACTED***', 'PORT': '8080'}
```

**💡 Pro Tip**: Always mask secrets before logging. Use automated secret scanning in CI/CD.

---

## 🏆 Part 6: Real-World DevOps Story

### 📖 The Public Password Incident

**The Scenario**: A junior engineer was debugging a Terraform wrapper script locally. Tired of exporting AWS credentials every time, he added them to a `.env` file in the project root.

**The Mistake**: He pushed changes to the company's **public** GitHub repository, forgetting he hadn't created a `.gitignore` file yet.

**The Attack**: Within **22 seconds**, an automated bot detected the credentials and used them to spin up 50 "extra-large" EC2 instances for crypto-mining in 5 different regions.

**The Detection**: The company's security scanner detected "Unusual Activity" and killed the instances, but the bill was already **$4,000**.

**The Solution**:
1. Implemented mandatory **secret scanning** in CI/CD pipeline
2. Moved to **AWS IAM Roles** for development machines
3. Eliminated long-lived secret keys entirely
4. Added pre-commit hooks to check for secrets

**The Code**:
```bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

**The Lesson**: **ALWAYS** add `.env` to `.gitignore` before committing anything. Use automated secret scanning.

---

## ❓ Interview Preparation

### 🎯 Core Concepts

1. **Q: Why is `os.environ.get()` better than `os.environ['KEY']`?**
   - **A**: `get()` returns None (or a default) if the key doesn't exist, preventing KeyError crashes. Direct indexing `[]` raises KeyError if the key is missing, which is useful for required variables but needs error handling.

2. **Q: What is the 12-Factor App rule for configuration?**
   - **A**: Configuration should be strictly decoupled from code and stored in environment variables. This ensures the same build can run in dev, staging, and production without modification.

3. **Q: How do you handle environment variables in Docker?**
   - **A**: Pass them using `-e` flag (`docker run -e KEY=VAL`), use `--env-file`, or define them in docker-compose.yml. Inside the container, Python accesses them via `os.environ`.

4. **Q: Can a Python script change the environment variables of its parent shell?**
   - **A**: No. A process can only modify its own environment and that of its child processes, not its parent process.

5. **Q: How do you handle multi-line secrets (like SSH keys) in environment variables?**
   - **A**: Base64-encode the entire key, or replace newlines with `\n` and use `.replace('\\n', '\n')` in Python to restore them.

### 🚀 Advanced Questions

6. **Q: What's the difference between .env and .env.example?**
   - **A**: `.env` contains actual secrets (gitignored). `.env.example` is a template showing required variables without sensitive values (committed to Git).

7. **Q: How do you validate environment variables at startup?**
   - **A**: Load all variables into a config object with type conversion and validation. Fail fast with clear error messages if required variables are missing or invalid.

8. **Q: What's the security risk of logging `os.environ`?**
   - **A**: It may contain secrets (API keys, passwords). Always mask sensitive keys before logging.

9. **Q: When should you use AWS Secrets Manager instead of .env files?**
   - **A**: In production environments. Secrets Manager provides encryption, rotation, auditing, and access control. `.env` files are for local development only.

10. **Q: How do you handle different configurations for dev/staging/production?**
    - **A**: Use environment-specific .env files (`.env.development`, `.env.production`) or use a single `ENVIRONMENT` variable to load different configurations.

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which module is used to read environment variables?**
   - [ ] a) `dotenv`
   - [x] b) `os`
   - [ ] c) `sys`
   - [ ] d) `env`

2. **What does `os.environ.get("PORT", "5000")` return if PORT is not set?**
   - [ ] a) `None`
   - [x] b) `"5000"`
   - [ ] c) Error
   - [ ] d) `0`

3. **Where should you NEVER store secrets?**
   - [ ] a) On your local workstation
   - [ ] b) In a secure password manager
   - [x] c) In a public Git repository
   - [ ] d) In environment variables

4. **Which library is used to load .env files?**
   - [ ] a) `python-env`
   - [x] b) `python-dotenv`
   - [ ] c) `env-loader`
   - [ ] d) `dotenv-python`

### 🚀 Intermediate Level

5. **Why use a config dataclass instead of accessing os.environ directly?**
   - [x] a) Type safety and better IDE autocompletion
   - [ ] b) Makes the script run faster
   - [ ] c) Encrypts variables in RAM
   - [ ] d) Required by Python

6. **What should be in .gitignore?**
   - [ ] a) `.env.example`
   - [x] b) `.env`
   - [ ] c) `config.py`
   - [ ] d) `requirements.txt`

7. **How do you convert environment variable to boolean?**
   - [ ] a) `bool(os.environ.get("DEBUG"))`
   - [x] b) `os.environ.get("DEBUG", "false").lower() == "true"`
   - [ ] c) `int(os.environ.get("DEBUG"))`
   - [ ] d) `os.environ.get("DEBUG") is True`

8. **What does load_dotenv() do?**
   - [ ] a) Creates a .env file
   - [x] b) Loads .env file into os.environ
   - [ ] c) Validates environment variables
   - [ ] d) Encrypts secrets

### 🏆 Advanced Level

9. **What's the 12-Factor App principle for configuration?**
   - [ ] a) Store config in code
   - [x] b) Store config in environment variables
   - [ ] c) Store config in database
   - [ ] d) Store config in files

10. **How do you fail fast if a required variable is missing?**
    - [ ] a) Use `os.environ.get()` with default
    - [x] b) Use `os.environ["KEY"]` and catch KeyError
    - [ ] c) Ignore it and use None
    - [ ] d) Print a warning

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Environment Variables = Control Panel**: Change behavior without changing code
2. **.env Files = Local Secrets**: For development only, never commit
3. **Config Classes = Type Safety**: Load once, use everywhere
4. **12-Factor App = Portability**: Same code, different environments

### 🛡️ Safety Patterns

1. **Use `.get()` with defaults** for optional variables
2. **Validate required variables** at startup
3. **Never commit .env files** to Git
4. **Mask secrets in logs** before printing
5. **Use .env.example** as a template

### 🚀 Production Rules

1. **Add .env to .gitignore** immediately
2. **Load config once** at startup into a dataclass
3. **Fail fast** if required variables are missing
4. **Use secret managers** in production (AWS Secrets Manager, Vault)
5. **Rotate credentials** regularly

---

## 🔗 Next Steps

Now that you can manage configuration securely, you're ready to learn how to build command-line interfaces.

**Proceed to**: [CLI Arguments →](../08-CLI-Arguments/README.md)

---

## 📚 Additional Resources

- [The Twelve-Factor App](https://12factor.net/config)
- [python-dotenv Documentation](https://github.com/theskumar/python-dotenv)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [Gitleaks - Secret Scanning](https://github.com/gitleaks/gitleaks)

---

**🎓 Remember**: A newbie hardcodes secrets. An engineer uses environment variables. A senior engineer uses secret managers with rotation. Master environment variables, and you master secure, portable configuration.

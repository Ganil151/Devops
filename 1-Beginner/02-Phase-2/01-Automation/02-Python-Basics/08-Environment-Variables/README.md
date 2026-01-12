# Environment Variables
*Configuring Applications the 12-Factor Way*

Environment variables are the preferred method for configuring applications across different environments.

---

## 🎯 Learning Objectives

- Read and set environment variables in Python
- Use `python-dotenv` for local development
- Implement environment-based configuration patterns

---

## 📊 Environment Configuration Flow

```mermaid
flowchart TD
    A[.env File] --> B[python-dotenv]
    C[Shell Export] --> D[os.environ]
    E[Container Env] --> D
    B --> D
    D --> F[Config Class]
    F --> G[Application]
    
    style D fill:#306998,stroke:#ffe873,color:#fff
```

---

## 📚 Core Concepts

### 1. Reading Environment Variables

```python
import os

# Get with default (preferred)
database_url = os.environ.get("DATABASE_URL", "sqlite:///default.db")
debug_mode = os.environ.get("DEBUG", "false").lower() == "true"
port = int(os.environ.get("PORT", "8080"))

# Check if exists
if "DATABASE_URL" in os.environ:
    print("Database configured")
```

### 2. Using python-dotenv

```python
from dotenv import load_dotenv
import os

# Load .env file into environment
load_dotenv()

# Now access normally
database_url = os.environ.get("DATABASE_URL")
```

```ini
# .env file example
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
API_KEY=secret-key-here
DEBUG=true
```

### 3. Configuration Class

```python
from dataclasses import dataclass
import os

@dataclass
class Config:
    database_url: str = os.environ.get("DATABASE_URL", "sqlite:///app.db")
    port: int = int(os.environ.get("PORT", "8080"))
    debug: bool = os.environ.get("DEBUG", "false").lower() == "true"
    
    def validate(self):
        if not self.database_url:
            raise ValueError("DATABASE_URL required")

config = Config()
```

---

## 🛠️ Hands-On Exercises

### Exercise 1: Config Validator
```python
# Validate required environment variables
REQUIRED = ["DATABASE_URL", "API_KEY"]

def validate_env(required_vars):
    missing = [v for v in required_vars if v not in os.environ]
    return missing

missing = validate_env(REQUIRED)
if missing:
    print(f"Missing: {missing}")
```

### Exercise 2: Environment Switcher
```python
def load_environment():
    env = os.environ.get("ENVIRONMENT", "development")
    load_dotenv(f".env.{env}")
    return env
```

---

## ❓ Interview Questions

1. **Why use environment variables instead of config files?**
   > Separates config from code, follows 12-Factor App principles.

2. **What's `.get()` vs direct access?**
   > `.get()` returns None/default safely; direct raises KeyError.

3. **How do you prevent secrets from being logged?**
   > Mask values in logs, use logging filters.

---

## 🧠 Quiz

1. What does `os.environ.get("VAR", "default")` return if VAR is not set?
   - a) None
   - b) "default" ✅
   - c) KeyError

2. What type does `os.environ.get()` return?
   - a) int
   - b) str ✅
   - c) auto-detected

3. Which file loads environment vars in Python?
   - a) `load_dotenv()` ✅
   - b) `os.load_env()`

---

**Next Step**: [Command Line Arguments →](../09-Command-Line-Arguments/README.md)

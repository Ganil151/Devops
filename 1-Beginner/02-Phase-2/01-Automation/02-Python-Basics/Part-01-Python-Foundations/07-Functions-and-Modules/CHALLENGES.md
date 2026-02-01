# 🎯 Functions & Modules: The Automation Toolbox Challenges

> **"Code duplication is a silent killer in DevOps. These challenges test your ability to build reusable, reliable, and modular tools."**

---

## 🏆 Challenge 1: The Cloud Connection String Builder
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 20 minutes

### Objective
Create a professional function with type hints and docstrings to build database connection URLs.

### Requirements
- Function `build_db_url()` with the following parameters:
    - `user: str`
    - `password: str`
    - `host: str` (default: "localhost")
    - `port: int` (default: 5432)
    - `db_name: str` (default: "postgres")
- Return a **Tuple[str, bool]**: the URL and a boolean indicating if it's using the default port.
- Include a **Google-style docstring** and **Type Hints**.
- Use a **Guard Clause** to raise `ValueError` if the `user` or `password` is empty.

---

## 🏆 Challenge 2: The Action Dispatcher (Strategy Pattern)
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 40 minutes

### Objective
Build a flexible dispatcher that runs different "deployment strategies" based on input.

### Requirements
- Create three functions: `deploy_canary()`, `deploy_blue_green()`, and `deploy_rolling()`.
- Create a dictionary `DEPLOYMENT_STRATEGIES` that maps strategy names to these functions.
- Create a main `execute_deployment(app_id: str, strategy: str)` function that:
    1. Looks up the strategy in the dictionary.
    2. Calls the function if it exists.
    3. Handles the case where an invalid strategy is provided by printing an ERROR log.
- **Bonus**: Use `**kwargs` in the strategy functions to accept optional parameters like `cluster_name` or `replicas`.

---

## 🏆 Challenge 3: The Modular Secret Guard
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 60 minutes

### Objective
Organize your automation into a package structure with shared configuration.

### Requirements
- Create a directory structure:
    ```
    secret_vault/
    ├── __init__.py
    ├── config.py           # Stores DEFAULT_LOG_LEVEL
    └── scanner.py          # Contains scan_file(path) function
    ```
- In `scanner.py`, create a function that looks for keywords like "password" or "api_key" in a file.
- Use `if __name__ == "__main__":` in `scanner.py` to allow running it as a standalone script for testing.
- The `scanner.py` must import the `DEFAULT_LOG_LEVEL` from `config.py` using a **relative import** (`from . import config`).

---

## ✅ Completion Checklist
- [ ] Challenge 1: Cloud Connection Builder
- [ ] Challenge 2: Action Dispatcher
- [ ] Challenge 3: Modular Secret Guard

# Python Automation Script Checklist 🐍

This checklist provides a structured approach for elevating a simple Python script into a robust, reliable, and production-ready automation tool. It's designed to help you move from a "Junior" (it works on my machine) to a "Senior" (it works reliably for everyone, every time) mindset.

## 📝 Planning & Setup

- [ ] **Define Objective**: Clearly define the purpose and scope of the script. What problem does it solve? What is the exact success condition?
- [ ] **Identify Requirements**: List all necessary dependencies (e.g., `boto3`, `requests`), input parameters, and expected output formats (e.g., JSON, CSV).
- [ ] **Error Handling Strategy**: Plan how to handle potential errors. Differentiate between transient errors (e.g., network timeout, which might be retried) and fatal errors (e.g., invalid credentials, which should cause an immediate exit).
- [ ] **Virtual Environment**:
    - [ ] Create a virtual environment (`python3 -m venv .venv`) to isolate dependencies.
    - [ ] Create a `requirements.txt` for application dependencies and a `requirements-dev.txt` for development tools (`pytest`, `black`).
- [ ] **Source Control**: Initialize a Git repository from the start. Commit early and often.

## 💻 Coding Best Practices

- [ ] **Modularity**: Break down the script into small, reusable functions with a single responsibility. A function should do one thing and do it well.
- [ ] **Guard Clauses (Fail-Fast)**: At the start of functions, validate parameters and state. Exit early if prerequisites are not met. This prevents deeply nested `if` statements and improves clarity.
  ```python
  def process_user(user_id: int):
      if not user_id or user_id <= 0:
          logging.error("Invalid user_id provided.")
          return # Exit early
      # ... proceed with valid user_id
  ```
- [ ] **Idempotency by Design**: Ensure that running a script multiple times has the same effect as running it once (e.g., 'ensure resource exists' not 'create resource'). This is critical for safe, re-runnable automation.
  ```python
  # Not Idempotent
  os.mkdir("/tmp/my_app") # Fails on second run

  # Idempotent
  os.makedirs("/tmp/my_app", exist_ok=True) # Safe to re-run
  ```
- [ ] **Type Hinting**: Use type hints (e.g., `def my_func(name: str) -> bool:`) to improve code clarity, enable static analysis tools (`mypy`), and improve IDE support.
- [ ] **Configuration Separation**: Keep configuration (endpoints, thresholds, file paths) separate from the code logic. Use a dedicated config file (YAML, INI) or environment variables, loaded at runtime.
  ```bash
  # Use a .env file with python-dotenv
  API_ENDPOINT="https://api.example.com"
  ```
- [ ] **Secret Management**: **Never** hardcode secrets (passwords, API keys). Use environment variables (`os.environ.get('API_TOKEN')`) or a dedicated secrets manager (like AWS Secrets Manager or HashiCorp Vault).
- [ ] **Comprehensive Logging**: Replace `print()` with the `logging` module. Log actions, decisions, and errors with appropriate severity levels (INFO, WARNING, ERROR).
  ```python
  import logging
  logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
  logging.info("Script started.")
  ```
## 🧪 Testing & Validation

- [ ] **Unit Tests**: Write `pytest` tests for individual functions, especially for pure business logic. Use `unittest.mock` to isolate from external systems like networks or filesystems.
- [ ] **Integration Tests**: Test the script's interaction with external systems or APIs. These can be run against a non-production or sandboxed environment.
- [ ] **Dry-Run Mode**: Implement a `--dry-run` flag that simulates changes and logs what _would_ happen without making actual modifications. This is the most important feature for building trust in your automation.
  ```python
  if args.dry_run:
      logging.info(f"[DRY RUN] Would delete instance: {instance_id}")
  else:
      # client.delete_instance(instance_id)
      logging.warning(f"Deleting instance: {instance_id}")
  ```
- [ ] **Idempotency Testing**: Create a test case that runs the script twice and asserts that the system state is identical after the first and second run.
- [ ] **Error Handling Tests**: Intentionally trigger expected errors (e.g., invalid input, network failure) and verify the script handles them gracefully and exits with a non-zero status code. Use `pytest.raises` for this.
  ```python
  import pytest

  def test_invalid_input():
      with pytest.raises(ValueError):
          my_function(invalid_parameter)
  ```

## 🚀 Execution & Monitoring

- [ ] **Command-Line Interface (CLI)**: Use `argparse` or `click` to create a user-friendly CLI with clear arguments, flags, and `--help` text. This makes your script a usable tool.
- [ ] **Structured Output**: Format output in a machine-readable format like JSON (`json.dumps`) or a human-readable table (using the `tabulate` library) for easy consumption by other tools or users.
- [ ] **Exit Codes**: Use `sys.exit(0)` for success and `sys.exit(1)` for failures to clearly signal the outcome to CI/CD pipelines or calling scripts.
- [ ] **Status Notifications**: For long-running or critical jobs, send notifications (e.g., to Slack, Teams, or email) on success or failure.
- [ ] **Scheduling**: If needed, schedule the script to run automatically using cron or a cloud-native scheduler (e.g., AWS EventBridge, Google Cloud Scheduler).

## 🛡️ Security Considerations

- [ ] **Least Privilege Principle**: Ensure the script's execution role (e.g., an AWS IAM role) has only the minimum permissions required to perform its task. Avoid using wildcard (`*`) permissions.
- [ ] **Dependency Scanning**: Regularly scan `requirements.txt` for known vulnerabilities using tools like `pip-audit` or `safety` as part of your CI pipeline.
- [ ] **Static Analysis (SAST)**: Integrate a security-focused linter like `bandit` to automatically detect common security issues in the Python code (`bandit -r .`).
- [ ] **Input Sanitization**: Sanitize all inputs to prevent injection attacks, especially if inputs are used to construct shell commands or database queries.
- [ ] **Secure Communication**: Use TLS/HTTPS for all network communication and avoid disabling certificate validation (`verify=False` in `requests` is a major red flag).

## 📖 Documentation & Maintenance

- [ ] **README File**: Create a `README.md` that explains what the script does, how to set it up (prerequisites, installation), and provides clear usage examples.
- [ ] **Docstrings**: Document every function using standard docstring formats (e.g., Google, reST). Explain its purpose, arguments (`Args:`), and what it returns (`Returns:`).
- [ ] **Versioning**: If the script is shared or used in production, consider giving it a version number (e.g., in a `__version__` variable) and use semantic versioning.
- [ ] **Ownership**: Define who owns and maintains the script. Add this to the README.

---


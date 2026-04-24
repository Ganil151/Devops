# Python Infrastructure CI/CD Checklist 🐍

This checklist is a comprehensive guide for building production-ready CI/CD pipelines for Python-based infrastructure automation. It is derived from the **Automation Maturity Model**, **Virtual Environment Challenges**, and **Pytest Testing Guides** found within the DevOps repository.

**Goal**: Progress your automation scripts from "Scripted" (Level 2: works on your machine) to "Observed" (Level 4: reliable, auditable, and resilient).

## 🏗️ Phase 1: Foundation & Isolation (The "Ephemeral" Standard)
*This phase ensures your automation runs in a clean, predictable, and disposable environment every time, preventing "it works on my machine" errors.*

- [ ] **Virtual Environment Management**: Ensure the pipeline creates a fresh `.venv` for every run. This is non-negotiable for dependency isolation.
  ```bash
  # Create a self-contained environment
  python3 -m venv .venv
  # Activate it to run subsequent commands
  source .venv/bin/activate
  ```
- [ ] **Clean Teardown**: Implement `try...finally` blocks or `trap` (in shell wrappers) to delete the `.venv` and temporary files after execution, even if the script fails.
  ```python
  # In Python, for guaranteed cleanup
  try:
      # ... your main logic ...
  finally:
      print("Cleaning up resources...")
      shutil.rmtree('.venv', ignore_errors=True)
  ```
- [ ] **Dependency Split**: Separate production libraries from development tools for smaller, more secure production deployments.
    - [ ] **`requirements.txt`**: For production libraries (`boto3`, `requests`).
    - [ ] **`requirements-dev.txt`**: For CI tools (`pytest`, `black`, `flake8`).
    - **Pro-Tip**: Keep the dev file DRY (Don't Repeat Yourself). The first line of `requirements-dev.txt` should be `-r requirements.txt`.

- [ ] **Path Verification**: Add a step to prove the script is running inside the isolated environment. This is critical for debugging CI runners. (Reference: _Challenge 3 - Path Investigator_).
  ```python
  import sys
  is_in_venv = (sys.prefix != sys.base_prefix)
  print(f"Running from: {sys.executable}")
  print(f"Inside a virtual environment: {is_in_venv}")
  assert is_in_venv, "FATAL: Script is not running in a virtual environment!"
  ```

## 🛡️ Phase 2: Code Quality & Security
*This phase hardens the code, making it secure, readable, and less prone to common runtime errors.*

- [ ] **Linting**: Run `flake8` to catch syntax errors, undefined names, and style issues before the code ever executes.
  ```bash
  # Fail the CI job if linting issues are found
  flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
  ```
- [ ] **Formatting**: Run `black --check` to enforce a consistent, non-negotiable code style. This ends debates about formatting.
- [ ] **Secret Handling**:
    - [ ] **Never** hardcode passwords, API keys, or tokens.
    - [ ] Use `os.environ.get('API_TOKEN')` to read secrets injected by the CI runner's secret management system (e.g., GitHub Secrets, Vault). This prevents secrets from ever touching the disk or git history.
- [ ] **Timeout Safety**: Every network call must have a `timeout`. An automation script that can hang indefinitely is a production liability.
  ```python
  # For requests
  response = requests.get(url, timeout=30)

  # For boto3 (via botocore config)
  from botocore.config import Config
  config = Config(connect_timeout=10, read_timeout=30)
  s3 = boto3.client('s3', config=config)
  ```

## ⚙️ Phase 3: Automation Maturity (Level 3 & 4)
*This phase transforms a simple script into a reusable, configurable, and observable automation tool.*

- [ ] **Argument Parsing**: Replace hardcoded variables with `argparse` to accept inputs (e.g., `--region`, `--env`). This makes the script a flexible tool, not a one-off.
  ```python
  import argparse
  parser = argparse.ArgumentParser()
  parser.add_argument('--env', required=True, choices=['dev', 'prod'])
  args = parser.parse_args()
  print(f"Running against environment: {args.env}")
  ```
- [ ] **Exit Codes**: Ensure the script raises `SystemExit(1)` on failure. CI/CD runners depend on non-zero exit codes to detect failure and stop a pipeline.
  ```python
  import sys
  if error_condition:
      logging.error("A critical error occurred!")
      sys.exit(1)
  ```
- [ ] **Logging**: Replace `print()` with the `logging` module. This provides timestamps, severity levels (INFO, DEBUG, ERROR), and the ability to direct output to files or monitoring systems.
  ```python
  import logging
  logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
  logging.info("Script starting.")
  ```
- [ ] **Dry-Run Capability**: Implement a `--dry-run` flag that logs what *would* happen without making changes. This is the most important feature for safe infrastructure automation.
  ```python
  if args.dry_run:
      logging.info(f"[DRY RUN] Would delete instance {instance_id}")
  else:
      logging.warning(f"DELETING instance {instance_id}")
      # client.delete_instance(...)
  ```

## 🚀 Phase 4: Execution & Reporting
*This phase focuses on making the script's execution transparent and its results easy to consume.*

- [ ] **Pre-flight Checks**: Validate prerequisites (e.g., disk space, connectivity, auth token validity) before starting the main task to fail fast and provide clear errors.
- [ ] **Structured Output**:
    - [ ] If the script generates data, output it as JSON (`json.dumps`) or a Markdown table (using `tabulate`). This makes the output machine-readable for downstream jobs.
    - [ ] For financial operations, generate a "Showback" report to communicate value and cost (Reference: _FinOps Challenge 3_).
- [ ] **Artifact Handling**: Archive logs, reports, or JSON output as CI artifacts. This provides a persistent record of what happened during the run.

## 🧪 Phase 5: Testing
*Untested automation is a liability. This phase ensures your code is verified before it can impact production.*

- [ ] **Unit Tests**: Write `pytest` cases for critical logic functions. Use mocking to isolate your code from external systems like the cloud or databases.
  ```python
  # From the Pytest README: Mock external calls
  from unittest.mock import patch

  @patch('boto3.client')
  def test_resource_creation(mock_boto_client):
      # ... your test logic ...
      mock_boto_client.assert_called_with('s3')
  ```
- [ ] **Cloud Simulation**: Use tools like `moto` to create a mocked AWS environment in memory. This allows youto test `boto3` logic (e.g., creating and deleting S3 buckets) without any real AWS credentials or cost.
- [ ] **Integration Test**: Run the script against a non-production (sandbox) environment.

---


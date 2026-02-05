# Strategic Automation & Scripting

Automation is the glue that binds the DevOps lifecycle. This module transitions you from "writing scripts" to "building automation platforms."

![Automation Pyramid Placeholder](README.md)'. Shows the evolution of maturity.)

## 🏗️ The Automation Hierarchy

1.  **[01-Shell-Scripting-Mastery](./01-Shell-Scripting-Mastery)**: The universal language of Linux. Used for bootstapping (`user_data`), glue code in CI/CD, and system diagnostics.
2.  **[02-Python-for-Infrastructure](./02-Python-for-Infrastructure)**: The standard for complex logic. Used for interacting with Cloud APIs (Boto3), data processing, and custom CLI tools.
3.  **[03-Cost-Estimation-and-FinOps](./03-Cost-Estimation-and-FinOps)**: Automating the economics of the cloud using tools like Infracost.

---

## ⚖️ The "Right Tool" Logic

| Task | Best Tool | Why? |
| :--- | :--- | :--- |
| **System Bootstrapping** | **Bash** | Native to Linux, no dependencies required. Perfect for `cloud-init`. |
| **Complex Logic / API Calls** | **Python** | Robust libraries (`requests`, `boto3`), error handling, and testability. |
| **High Performance CLI** | **Go** | Compiles to a single binary, fast execution. (e.g., Terraform/Docker are written in Go). |
| **Configuration Mgmt** | **Ansible** | Idempotent, declarative YAML. Don't write a Bash script to install Nginx; use Ansible. |

---

## 🛡️ Production Scripting Standards

### 1. Bash "Strict Mode"
Every shell script in production MUST start with:
```bash
#!/bin/bash
set -euo pipefail
# -e: Exit on error
# -u: Exit on unset variable
# -o pipefail: Catch errors in piped commands
```

### 2. Python Type Hinting
Modern Python infrastructure code should use type hints for clarity:
```python
def get_instance_id(instance_name: str) -> str:
    # Logic here
    return "i-0123456789"
```

### 3. Idempotency
Scripts should be runnable multiple times without side effects.
*   **Bad**: `mkdir /tmp/logs` (Fails if exists)
*   **Good**: `mkdir -p /tmp/logs` (Succeeds if exists)

---

## 🛠️ Assets
- **[Automation-Challenges.md](./Automation-Challenges.md)**: From "Log Rotator" to "Auto-Remediation Bot".
- **[Interview-Questions.md](01-Shell-Scripting-Mastery/04-Part-4-The-Safety-Net/01-Skill-Assessments/Interview-Questions.md)**: Senior scripting questions.

---
## 🧭 Additional Modules
- [00 Reference Metadata](00-Reference-Metadata/README.md)

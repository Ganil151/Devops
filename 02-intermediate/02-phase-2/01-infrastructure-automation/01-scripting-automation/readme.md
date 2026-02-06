# Strategic Automation & Scripting

Automation is the glue that binds the DevOps lifecycle. This module transitions you from "writing scripts" to "building automation platforms."

![Automation Pyramid Placeholder](README.md)'. Shows the evolution of maturity.)

## 🏗️ The Automation Hierarchy

1.  **[01-Shell-Scripting-Mastery](./01-Shell-Scripting-Mastery)**: The universal language of Linux. Used for bootstapping (`user_data`), glue code in CI/CD, and system diagnostics.
2.  **[02-Python-for-Infrastructure](./02-Python-for-Infrastructure)**: The standard for complex logic. Used for interacting with Cloud APIs (Boto3), data processing, and custom CLI tools.
3.  **[03-Cost-Estimation-and-FinOps](./03-Cost-Estimation-and-FinOps)**: Automating the economics of the cloud using tools like Infracost.

---

## 🎯 Junior's Mission: The Auto-Remediation Bot
**Scenario**: Your application is crashing every Friday at 3:00 AM because a temporary log directory fills up. You can't be awake every Friday to delete it manually.
**Your Goal**: Build a **Python-based Auto-Remediation Script** that monitors the directory size and automatically clears it when it exceeds 90% capacity, logging the action to Slack.

---

## 🏗️ Operational Reality: Production Hazards
Automation is a "Force Multiplier." If your automation has a bug, you can break 1,000 servers in 10 seconds.
1.  **The Recursive Loop**: A script that deletes "Old Logs" but has a regex bug and starts deleting the kernel boot files.
2.  **Concurrency Race**: Two instances of the same script running at once, both trying to modify the same database record.
3.  **Hardcoded Secrets**: Putting your Slack Webhook URL or AWS keys directly in the script. If the script is pushed to GitHub, the keys are stolen.
4.  **No Error Handling**: A script that assumes the "Cloud API" is always up. When the API times out, the script crashes, leaving the system in a half-configured state.

---

## 🛠️ The Automation Toolbelt (Essential Commands)
| Tool/Command | Why it matters |
| :--- | :--- |
| `shellcheck script.sh` | A "Static Analysis" tool that finds bugs in your Bash scripts before they run. |
| `pylint script.py` | Enforcing the "Staff Standard" for Python code quality. |
| `cron -e` | The Unix heartbeat. Scheduling your automation to run at regular intervals. |
| `logger "message"` | Sending your script's output to the system logs (`syslog`) for auditing. |
| `jq -r '.id' file.json` | Surgical extraction of data from JSON API responses. |

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

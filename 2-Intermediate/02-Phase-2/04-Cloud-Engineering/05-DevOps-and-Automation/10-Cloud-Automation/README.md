# Cloud Automation & Scripting - Intermediate

Automation is the difference between a sysadmin and a DevOps engineer. This module focuses on using code to eliminate repetitive manual tasks.

---

## 1. The Automation Spectrum

Automation in the cloud ranges from simple shell scripts to complex serverless workflows.
- **Bash**: Best for OS-level tasks, simple CLI interactions, and quick fixes.
- **Python (Boto3)**: Best for complex logic, data processing, and enterprise-grade automation loops.
- **Event-driven**: Using Lambda and EventBridge to react to cloud events automatically.

---

## 2. Core Guides

### 📜 [Cloud Scripting Fundamentals](cloud-scripting-fundamentals.md)
A direct comparison between Bash and Python for common cloud tasks.

### ⚙️ [Resource Management Automation](resource-management-automation.md)
Practical scripts for auditing instances, managing backups, and scaling environments.

### 🛠️ [Automation Troubleshooting & Hacks](automation-troubleshooting-hacks.md)
Advanced tips for debugging scripts and handling API limits (Throttling).

---

## 3. When to use what?

| Tool | Pro | Con |
| :--- | :--- | :--- |
| **AWS CLI** | Fast, interactive, pre-installed. | Hard to handle complex JSON logic. |
| **Python (SDK)** | Powerful logic, error handling. | Requires environment setup/dependencies. |
| **IaC (Terraform)** | Manages state, declarative. | Slow for "ad-hoc" actions or one-offs. |

---

## 4. Best Practices
- **Idempotency**: Ensure your scripts can run multiple times without causing side effects.
- **Error Handling**: Always account for "Resource Not Found" or "Access Denied" errors.
- **Dry Run**: Support a `--dry-run` flag to show what the script *would* do without acting.

---
**Next Level**: Scale your automation logic with [AWS Lambda Functions](../../../../../README.md).

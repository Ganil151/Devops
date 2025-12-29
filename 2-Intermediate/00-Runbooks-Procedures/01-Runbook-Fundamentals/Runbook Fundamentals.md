Automation is the heart of DevOps, but clear, actionable documentation is its brain. **Runbooks** ensure that in the middle of a P0 outage, an engineer knows exactly what to do without guessing.

## 📖 What is a Runbook?
A **Runbook** is a step-by-step guide for performing a specific operational task. Unlike a configuration script (Playbook), a Runbook details the "Who, What, When, and Why" of a process.

### The DevOps Hierarchy
1.  **SOP (Standard Operating Procedure)**: High-level policy (e.g., "All deployments must be approved").
2.  **Runbook**: Detailed instructions for a specific task (e.g., "How to restart the Payment Service").
3.  **Playbook**: Automated code that executes the task (e.g., An Ansible script that restarts the service).

---

## 🛠️ Types of Runbooks

### 🟢 1. Manual Runbooks
Static documents intended for human consumption.
- **Use Case**: Complex logic, physical hardware maintenance, or high-risk human-in-the-loop decisions.
- **Example**: "Coordinating a multi-cloud database failover."

### 🟡 2. Hybrid Runbooks
Contain snippets of scripts or CLI commands embedded within the text.
- **Use Case**: Daily maintenance where human judgment is needed before execution.
- **Example**: "If traffic > 10k, run `./scripts/scale.up.sh`."

### 🔵 3. Automated Runbooks
Executable code triggered by specific system signals (Alerts).
- **Use Case**: Routine, low-risk fixes.
- **Example**: "Restarting a web server if the health check fails three times."

---

## 🔄 The Deployment Lifecycle
Runbooks shouldn't just exist for disasters. They should be integrated into every stage:
- **Development**: Documenting local setup steps.
- **Staging**: Validating environment similarity.
- **Production**: Handling incidents and routine updates.
- **Post-Mortem**: Updating existing runbooks based on incident findings.

# Documentation Hierarchy

Not all documentation is created equal. Understanding the difference between an SOP, a Runbook, and a Playbook is essential for operational clarity.

## The Three Layers

### 1. SOP (Standard Operating Procedure)
- **What**: Higher-level policy and governance.
- **Goal**: Compliance and "The Big Picture."
- **Example**: "Incident Communication Policy" or "How to request production access."

### 2. Runbook (The Instructions)
- **What**: A specific, step-by-step procedure for a task.
- **Goal**: Actionable execution for humans.
- **Example**: "Restarting the PostgreSQL Cluster after a crash."

### 3. Playbook (The Automation)
- **What**: Executable code (Ansible, Terraform, Python).
- **Goal**: Machine execution.
- **Example**: `ansible-playbook restart_db.yml`.

## Relationship Table

| Level | Audience | Execution | Format |
| :--- | :--- | :--- | :--- |
| **SOP** | Managers / Legal | Human Strategy | Narrative Text |
| **Runbook** | SREs / Developers | Human Action | Checklist / Steps |
| **Playbook** | The System | Automated | Code (YAML/Python) |

---

## 🏗️ Real-Life Scenario: The Confusion Matrix
**Problem**: An auditor asks to see the "Backup Procedure." The engineer shows them a 5,000-line Python script. 
**Auditor Response**: "I don't read Python. I need to see the human process for verifying that the backup worked."
**Fix**: The team creates an **SOP** that defines *why* we backup, a **Runbook** that explains *how* a human checks the logs, and keeps the Python **Playbook** for the actual work. 
**Result**: Both the machine and the auditor are happy.

---

## ❓ Interview Questions
1.  **If you have an automated script (Playbook), do you still need a Runbook?**
    *   *Answer*: Yes. The Runbook explains the context, prerequisites, and what to do if the automation fails. It is the "Human-in-the-loop" safety manual.
2.  **At what stage of an incident do you move from an SOP to a Runbook?**
    *   *Answer*: The SOP tells you *to* declare an incident and notify stakeholders. The Runbook is moved to once you start technical troubleshooting and mitigation.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which layer is written in code like YAML or Python?** (Playbook)
2.  **Which layer covers high-level policies like 'Access Control'?** (SOP)
3.  **True/False: A Runbook is more detailed than an SOP.** (True)
4.  **Can a Runbook contain a link to a Playbook?** (Yes - this is a Hybrid Runbook)
5.  **Which document describes 'How to restart a service'?** (Runbook)

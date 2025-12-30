# Runbook Anatomy

A professional runbook isn't just a list of steps. It's a structured document designed for speed and safety.

## Required Sections

### 1. Metadata
- **Title**: Clear and searchable (e.g., `RB-NET-01: VPC Peering Failure`).
- **Owner**: The team responsible for maintaining it.
- **Version**: Last updated date.
- **Context**: Link to the specific Dashboard or Alert that triggers this runbook.

### 2. Prerequisites
- **Permissions**: What access do I need? (e.g., `Administrator` or `ReadOnly`).
- **Tools**: What software do I need? (e.g., `aws-cli`, `kubectl`).

### 3. Step-by-Step Instructions
- **Clear Commands**: Use copy-pasteable blocks.
- **Expected Output**: Tell the user what they *should* see after each step.
- **Decision Points**: "If you see Error A, go to Step 10. If you see Success, go to Step 5."

### 4. Verification & Rollback
- **How to verify**: How do I know it's fixed?
- **Rollback**: If this makes things worse, how do I undo it?

---

## 🏗️ Real-Life Scenario: The "No Escape" Runbook
**Problem**: An engineer follows a runbook to restart a Kubernetes deployment. In the middle of the process, the cluster starts crashing harder.
**Crisis**: The engineer looks for the "Undo" section of the runbook. It's empty. They panic and start randomly deleting pods.
**Recovery**: A senior engineer joins and has to manually restore from a backup.
**Fix**: Update the **Runbook Template**. Every runbook MUST have a "Rollback Procedure" section or it will be rejected in code review.

---

## ❓ Interview Questions
1.  **Why is it important to include 'Expected Output' in a runbook?**
    *   *Answer*: It prevents the engineer from continuing with a broken process. If they run a command and see something different than the "Expected Output," they know to stop and call for help before causing further damage.
2.  **What is 'Metadata' in a runbook and why does an SRE care?**
    *   *Answer*: Metadata includes ownership, last updated date, and alert links. It helps SREs quickly find the right person to contact if the runbook is outdated or confusing during an incident.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which section tells you how to 'Undo' a change?** (Rollback)
2.  **True/False: You should use screenshots for every step.** (False - screenshots rot faster than text; use text-based expected outputs)
3.  **What is a 'Decision Point'?** (A step that changes the course of the runbook based on observations)
4.  **Should a runbook list the permissions required?** (Yes, in the Prerequisites)
5.  **Is 'Step 1: Fix the server' a good runbook instruction?** (No - too vague)

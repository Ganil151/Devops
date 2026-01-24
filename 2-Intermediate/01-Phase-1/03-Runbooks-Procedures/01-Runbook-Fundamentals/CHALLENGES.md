# Runbook Fundamentals Challenges 📜

Master the documentation that bridges the gap between manual human effort and automated system response.

---

## 🏆 Challenge 01: The "Bus Factor" Audit
**Objective**: Ensure anyone on the team can execute a task without your help.

1.  **Requirement**: Choose a frequent manual task (e.g., "Add a new developer to GitHub").
2.  **Task**: Write a "Level 1" Runbook.
3.  **Specifications**:
    *   **Prerequisites**: List required permissions/access.
    *   **Step-by-Step**: Use clear, numbered instructions.
    *   **Verification**: How do you know it worked? (e.g., check for a confirmation email).
4.  **Goal**: Hand this document to someone who has never done the task and see if they can finish it without asking questions.

---

## 🏆 Challenge 02: Dynamic SOPs (Markdown)
**Objective**: Use version-controlled documentation.

1.  **Task**: Create an SOP for "Database Scaling."
2.  **Constraint**: Use Markdown formatting.
3.  **Requirements**:
    *   Include a "Warning" block (Red) for destructive commands.
    *   Include a "Code Block" for the CLI commands.
    *   Add an "Escalation" section (who to contact if it fails).
4.  **Action**: Commit this to a `docs/` folder in your repo.

---

## 🏆 Challenge 03: The "Draft to Prod" Workflow
**Objective**: Maintain documentation reliability.

1.  **Scenario**: A CLI command in your Runbook is outdated.
2.  **Task**: Design a process for updating Runbooks.
3.  **Question**: Should Runbooks be stored in a Wiki (Confluence) or in Git next to the code? Compare the pros and cons.
4.  **Analysis**: Explain why "Stale Documentation" is more dangerous than "No Documentation."

---

## 📁 Solutions
High-fidelity Runbook templates are located in the `Boilerplates/` directory.

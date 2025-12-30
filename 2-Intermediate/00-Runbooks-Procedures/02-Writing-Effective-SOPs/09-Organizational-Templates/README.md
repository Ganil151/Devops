# Organizational Templates

Standardization reduces the "Time to Start." When every document looks the same, your brain doesn't have to waste energy "finding" where the commands are.

## The Global Template
Every SOP in the organization should follow this layout:

1.  **Header**: Title, ID, Tags, Owner.
2.  **SLO Impact**: [P0 / P1 / P2]
3.  **Summary**: One sentence describing the goal.
4.  **Prerequisites**: Access and Tools.
5.  **Health Check**: How to verify the incident is real.
6.  **Steps**: Linear remediation path.
7.  **Resolution Check**: How to verify the fix works.
8.  **Rollback**: The "Undo" buttons.

## Enforcing the Standard
- **Cookiecutter**: Use a CLI tool like Cookiecutter or a GitHub Template repository to generate the folder structure automatically.
- **Pre-commit Hooks**: Prevent a `git push` if the file is missing mandatory headers (like `Owner`).

---

## 🏗️ Real-Life Scenario: The "Custom" Headache
**Problem**: One team likes to write SOPs as "Stories" in a Wiki. Another team uses "Checklists" in Git. A third team uses "Presentations."
**Crisis**: During a "Cross-Team" incident (e.g., Network + DB), the engineers are constantly confused by the different styles. They take 3 minutes per document just to figure out "how to read it."
**Outcome**: The CTO mandates a company-wide **Standard Markdown Template**.
**Result**: Context-switching time between teams drops to zero.

---

## ❓ Interview Questions
1.  **Why is standardization of documentation formats important for large organizations?**
    *   *Answer*: It reduces cognitive load and context-switching time. It allows engineers to move between different service documents and instantly know where to find the 'Meat' (the commands and the rollback plans).
2.  **How do you handle 'Exceptions' to the standard template?**
    *   *Answer*: Exceptions are allowed but must be a conscious choice. For example, a "Security Incident" SOP might have different confidentiality sections, but it should still maintain the same core 'Steps' and 'Header' format for consistency.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What is the benefit of a Header in every doc?** (Fast search and ownership tracking)
2.  **True/False: You should have a different template for every team.** (False - keep it consistent across teams)
3.  **What is a 'Cookiecutter'?** (A tool for creating projects/folders from templates)
4.  **Can a linter check if a Header exists?** (Yes, using a custom rule)
5.  **Which section tells you the 'Severity' of the task?** (SLO Impact)

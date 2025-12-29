# 02: Writing Effective SOPs

A **Standard Operating Procedure (SOP)** is a set of step-by-step instructions compiled by an organization to help workers carry out complex routine operations. In DevOps, we aim for **Docs-as-Code**.

## 📝 The Golden Rules of SOPs

1.  **Be Concise**: Use bullet points and clear, imperative verbs (e.g., "Run this command", not "You should probably try to run this").
2.  **Use Templates**: A consistent format reduces cognitive load during stress.
3.  **State the Outcome**: Every step should describe what the expected result looks like.
4.  **Version Everything**: Store your SOPs in Git alongside the code they document.

---

## 📐 A Standard Runbook/SOP Template

Every SOP should include:

| Section | Description |
| :--- | :--- |
| **Header** | Title, Owner, Service Name, and Severity Level. |
| **Pre-requisites** | What access tokens or tools does the engineer need? |
| **Health Check** | How do I verify the issue is real? |
| **Resolution** | The "Meat" of the document. Clear, numbered steps. |
| **Validation** | How do I know the fix worked? |
| **Rollback** | What if the fix makes things worse? |

---

## 🛠️ Docs-As-Code Tools

- **Markdown**: The standard for technical documentation.
- **MkDocs / Hugo**: Generate beautiful documentation sites from Markdown files.
- **Mermaid.js**: Embed diagrams directly in your docs using text (Diagrams-as-Code).
- **Git**: Ensures accountability and a history of changes.

---

## 📈 Improving Documentation Efficiency

- **Linting for Docs**: Use tools like `vale` or `markdown-lint` to ensure consistency.
- **DRY (Don't Repeat Yourself)**: If three services use the same auth method, link to a single "Authentication Shared SOP" rather than copying it three times.

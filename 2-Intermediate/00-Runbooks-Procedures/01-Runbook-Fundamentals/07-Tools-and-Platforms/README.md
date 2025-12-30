# Tools and Platforms

Where you store your runbooks is just as important as what's inside them.

## 1. Git-Based (Markdown)
The "Docs as Code" approach.
- **Tools**: GitHub, GitLab, Bitbucket.
- **Workflow**: Pull Requests for updates, Mermaid for diagrams.
- **Pros**: Version history, developer-friendly, stays with the HCL/Code.

## 2. Integrated Wiki
- **Tools**: Confluence, Notion, Obsidian.
- **Pros**: Easy search, collaborative editing, good for non-technical stakeholders.
- **Cons**: Can become a "Document Cemetery" if not strictly managed.

## 3. Incident Management Platforms
- **Tools**: PagerDuty, Opsgenie, FireHydrant.
- **Pros**: Automatically serves the runbook link *inside* the alert notification.

## 4. Executable Runbook Tools
- **Tools**: Jupyter Notebooks, Runbear, Transposit.
- **Pros**: You can run the code blocks directly inside the doc.

## Tool Comparison

| Platform | Best For | Accessibility | Automation Level |
| :--- | :--- | :--- | :--- |
| **GitHub** | Engineering Teams | High (Web/CLI) | Medium (Actions) |
| **Confluence** | General Biz Knowledge | High (Web) | Low |
| **Jupyter** | Data/Complex Troubleshooting | Medium (Notebooks) | High |
| **PagerDuty** | High-Priority Alerts | High (Mobile/Web) | Medium |

---

## 🏗️ Real-Life Scenario: The "Offline" Wiki
**Problem**: An SRE team keeps their recovery docs in a self-hosted Confluence instance.
**Crisis**: The company's internal network goes down. The SREs need the runbook to fix the network, but the wiki is *on* the network.
**Outcome**: They are locked out of their own instructions.
**Fix**: Move critical recovery runbooks to a Git repo hosted on a public platform (like GitHub) or use a tool that supports offline/Cached access.

---

## ❓ Interview Questions
1.  **Why would an SRE prefer 'Docs as Code' over a Wiki?**
    *   *Answer*: It allows for the same rigorous peer-review process as application code (Pull Requests), provides a clear version history, and ensures that documentation changes are deployed alongside the feature changes they describe.
2.  **What is an 'Executable Runbook'?**
    *   *Answer*: It's a document (like a Jupyter Notebook) where the instructions and the code snippets are combined in a way that the user can click a "Run" button to execute the fix directly within the UI.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which approach treats docs like code?** (Docs as Code)
2.  **True/False: You should store production recovery docs in a private, local-only server.** (False - risk of lockout during network failure)
3.  **Which format is used for Git-based documentation?** (Markdown)
4.  **Can PagerDuty suggest a runbook?** (Yes, based on the alert type)
5.  **What is a major downside of using PDFs for runbooks?** (Hard to update and version)
